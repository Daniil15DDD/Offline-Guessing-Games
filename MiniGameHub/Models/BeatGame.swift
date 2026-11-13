import Foundation
import Combine

/// Beat Keeper: a beat plays a few times and stops. Keep it going by
/// tapping at the same speed.
final class BeatGame: ObservableObject {
    enum Phase: Equatable {
        case ready
        case listening
        case tapping
        case revealed
    }

    static let rounds = 5
    static let demoBeats = 6
    static let tapsNeeded = 6
    static let maxScore = rounds * 100

    /// Beats per minute.
    @Published private(set) var targetBPM = 100.0
    @Published private(set) var phase = Phase.ready
    @Published private(set) var beatsPlayed = 0
    /// When each tap landed, in seconds.
    @Published private(set) var taps: [Double] = []
    @Published private(set) var tappedBPM = 0.0
    @Published private(set) var roundIndex = 0
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private var dealer: Dealer

    init(mode: PlayMode = .free) {
        self.mode = mode
        self.dealer = Dealer(key: "beat", mode: mode)
        startRound()
    }

    /// Seconds between beats at the target speed.
    var interval: Double { 60 / targetBPM }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        dealer = Dealer(key: "beat", mode: mode)
        startRound()
    }

    private func startRound() {
        targetBPM = Double(dealer.int(in: 60...160))
        phase = .ready
        beatsPlayed = 0
        taps = []
        tappedBPM = 0
        lastPoints = 0
    }

    func startListening() {
        guard phase == .ready else { return }
        beatsPlayed = 0
        phase = .listening
    }

    /// The screen calls this each time it plays one demo beat.
    func beatPlayed() {
        guard phase == .listening else { return }
        beatsPlayed += 1
    }

    /// The screen calls this one beat after the last demo beat.
    func finishListening() {
        guard phase == .listening else { return }
        phase = .tapping
    }

    static func bpm(fromTaps taps: [Double]) -> Double {
        guard taps.count >= 2, let first = taps.first, let last = taps.last, last > first else { return 0 }
        let average = (last - first) / Double(taps.count - 1)
        return 60 / average
    }

    /// 100 points within 2 percent of the tempo, none at 25 percent off.
    static func points(tapped: Double, target: Double) -> Int {
        guard tapped > 0, target > 0 else { return 0 }
        return Scoring.closeness(error: abs(tapped - target) / target, perfect: 0.02, zero: 0.25)
    }

    func tap(at time: Double) {
        guard phase == .tapping else { return }
        if let last = taps.last, time <= last { return }
        taps.append(time)
        if taps.count >= Self.tapsNeeded {
            tappedBPM = Self.bpm(fromTaps: taps)
            lastPoints = Self.points(tapped: tappedBPM, target: targetBPM)
            score += lastPoints
            phase = .revealed
        }
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
