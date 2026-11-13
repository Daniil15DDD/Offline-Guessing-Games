import Foundation
import Combine

/// A colour as hue, saturation and brightness, each from 0 to 1.
struct HSB: Equatable {
    var hue: Double
    var saturation: Double
    var brightness: Double

    /// Red, green and blue from 0 to 1.
    var rgb: (red: Double, green: Double, blue: Double) {
        let h = (hue - floor(hue)) * 6
        let sector = Int(h) % 6
        let f = h - floor(h)
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - saturation * f)
        let t = brightness * (1 - saturation * (1 - f))
        switch sector {
        case 0: return (brightness, t, p)
        case 1: return (q, brightness, p)
        case 2: return (p, brightness, t)
        case 3: return (p, q, brightness)
        case 4: return (t, p, brightness)
        default: return (brightness, p, q)
        }
    }

    /// 0 for identical colours, 1 for black against white.
    func distance(to other: HSB) -> Double {
        let a = rgb
        let b = other.rgb
        let dr = a.red - b.red
        let dg = a.green - b.green
        let db = a.blue - b.blue
        return sqrt((dr * dr + dg * dg + db * db) / 3)
    }
}

/// Hue Recall: study a colour for a few seconds, then rebuild it from memory
/// with three sliders.
final class HueGame: ObservableObject {
    enum Phase: Equatable {
        case memorize
        case recreate
        case revealed
    }

    static let rounds = 5
    static let showSeconds = 3.0
    static let maxScore = rounds * 100

    @Published private(set) var target = HSB(hue: 0, saturation: 1, brightness: 1)
    @Published var guess = HSB(hue: 0.5, saturation: 0.5, brightness: 0.5)
    @Published private(set) var phase = Phase.memorize
    @Published private(set) var timeLeft = HueGame.showSeconds
    @Published private(set) var roundIndex = 0
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private var hideAt: Date?
    private var dealer: Dealer

    init(mode: PlayMode = .free) {
        self.mode = mode
        self.dealer = Dealer(key: "hue", mode: mode)
        startRound()
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        dealer = Dealer(key: "hue", mode: mode)
        startRound()
    }

    private func startRound() {
        target = HSB(
            hue: dealer.double(in: 0...0.999),
            saturation: dealer.double(in: 0.35...1),
            brightness: dealer.double(in: 0.45...1)
        )
        guess = HSB(hue: 0.5, saturation: 0.5, brightness: 0.5)
        phase = .memorize
        timeLeft = Self.showSeconds
        lastPoints = 0
        hideAt = nil  // the countdown starts on the first tick
    }

    /// Call several times a second while the screen is showing.
    func tick(now: Date = Date()) {
        guard phase == .memorize, !isFinished else { return }
        guard let hideAt = hideAt else {
            self.hideAt = now.addingTimeInterval(Self.showSeconds)
            return
        }
        let left = max(0, hideAt.timeIntervalSince(now))
        if abs(left - timeLeft) >= 0.05 || left == 0 {
            timeLeft = left
        }
        if left <= 0 {
            phase = .recreate
        }
    }

    static func points(target: HSB, guess: HSB) -> Int {
        Scoring.closeness(error: target.distance(to: guess), perfect: 0.03, zero: 0.45)
    }

    func lockIn() {
        guard phase == .recreate else { return }
        lastPoints = Self.points(target: target, guess: guess)
        score += lastPoints
        phase = .revealed
    }

    func next() {
        guard phase == .revealed, !isFinished else { return }
        if roundIndex + 1 >= Self.rounds {
            isFinished = true
        } else {
            roundIndex += 1
            startRound()
        }
    }
}
