import Foundation
import Combine

/// Pitch Match: listen to a tone, then tune a slider until your tone matches.
final class PitchGame: ObservableObject {
    static let rounds = 5
    static let maxListens = 3
    static let maxScore = rounds * 100
    static let lowestHz = 150.0
    static let highestHz = 1200.0

    @Published private(set) var targetHz = 440.0
    /// Slider position from 0 to 1.
    @Published var slider = 0.5
    @Published private(set) var listensLeft = PitchGame.maxListens
    @Published private(set) var revealed = false
    /// Distance from the target in musical semitones.
    @Published private(set) var semitonesOff = 0.0
    @Published private(set) var roundIndex = 0
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    init() {
        startRound()
    }

    /// The pitch the slider currently stands for. Equal slider steps are
    /// equal musical steps.
    var guessHz: Double { Self.frequency(forSlider: slider) }

    static func frequency(forSlider position: Double) -> Double {
        let t = min(1, max(0, position))
        return lowestHz * pow(highestHz / lowestHz, t)
    }

    static func slider(forFrequency hz: Double) -> Double {
        min(1, max(0, log(hz / lowestHz) / log(highestHz / lowestHz)))
    }

    static func semitones(between first: Double, and second: Double) -> Double {
        guard first > 0, second > 0 else { return .infinity }
        return abs(12 * log2(first / second))
    }

    /// 100 points within a quarter of a semitone, none at six semitones.
    static func points(semitonesOff: Double) -> Int {
        Scoring.closeness(error: semitonesOff, perfect: 0.25, zero: 6)
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        startRound()
    }

    private func startRound() {
        // Between the A below middle C and the A two octaves above it.
        targetHz = 220 * pow(4, Double.random(in: 0...1))
        listensLeft = Self.maxListens
        revealed = false
        semitonesOff = 0
        lastPoints = 0
        let answer = Self.slider(forFrequency: targetHz)
        var start = Double.random(in: 0.1...0.9)
        if abs(start - answer) < 0.15 {
            start = answer > 0.5 ? answer - 0.3 : answer + 0.3
        }
        slider = start
    }

    /// Spends one listen. Returns false when none are left.
    func useListen() -> Bool {
        guard !revealed, listensLeft > 0 else { return false }
        listensLeft -= 1
        return true
    }

    func lockIn() {
        guard !revealed else { return }
        semitonesOff = Self.semitones(between: guessHz, and: targetHz)
        lastPoints = Self.points(semitonesOff: semitonesOff)
        score += lastPoints
        revealed = true
    }

    func next() {
        guard revealed, !isFinished else { return }
        if roundIndex + 1 >= Self.rounds {
            isFinished = true
        } else {
            roundIndex += 1
            startRound()
        }
    }
}
