import Foundation
import Combine

/// Scale It: two things are drawn side by side. Resize the second one until
/// the pair looks true to life.
final class ScaleGame: ObservableObject {
    static let rounds = 5
    static let maxScore = rounds * 100

    @Published private(set) var pair: ScalePair
    @Published private(set) var roundIndex = 0
    /// Slider position from 0 to 1.
    @Published var slider = 0.5
    @Published private(set) var revealed = false
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private let pairs: [ScalePair]
    private var queue: [Int] = []
    private var dealer: Dealer

    init(mode: PlayMode = .free, pairs: [ScalePair] = ScalePairs.all) {
        precondition(!pairs.isEmpty, "Scale It needs pairs")
        self.mode = mode
        self.dealer = Dealer(key: "scale", mode: mode)
        self.pairs = pairs
        self.pair = pairs[0]
        deal()
    }

    /// The size ratio the slider currently stands for.
    var ratio: Double { Self.ratio(forSlider: slider) }

    /// The slider is logarithmic, so halving and doubling are equal steps.
    static func ratio(forSlider position: Double) -> Double {
        let t = min(1, max(0, position))
        let low = log(ScalePairs.minRatio)
        let high = log(ScalePairs.maxRatio)
        return exp(low + (high - low) * t)
    }

    static func slider(forRatio ratio: Double) -> Double {
        let low = log(ScalePairs.minRatio)
        let high = log(ScalePairs.maxRatio)
        return min(1, max(0, (log(ratio) - low) / (high - low)))
    }

    /// 100 points within about 6 percent, none at double or half the size.
    static func points(guess: Double, answer: Double) -> Int {
        guard guess > 0, answer > 0 else { return 0 }
        return Scoring.closeness(error: abs(log(guess / answer)), perfect: 0.06, zero: log(2))
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        dealer = Dealer(key: "scale", mode: mode)
        queue = dealer.indices(count: pairs.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        pair = pairs[queue[min(roundIndex, queue.count - 1)]]
        revealed = false
        lastPoints = 0
        // Start somewhere that is clearly not the answer.
        let answer = Self.slider(forRatio: pair.ratio)
        var start = dealer.double(in: 0.15...0.85)
        if abs(start - answer) < 0.12 {
            start = answer > 0.5 ? answer - 0.25 : answer + 0.25
        }
        slider = start
    }

    func lockIn() {
        guard !revealed else { return }
        lastPoints = Self.points(guess: ratio, answer: pair.ratio)
        score += lastPoints
        revealed = true
    }

    func next() {
        guard revealed, !isFinished else { return }
        if roundIndex + 1 >= min(Self.rounds, queue.count) {
            isFinished = true
        } else {
            roundIndex += 1
            startRound()
        }
    }
}
