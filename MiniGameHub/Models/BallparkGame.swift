import Foundation
import Combine

/// Ballpark: three estimation questions, one guess each. The score depends
/// on how many times too big or too small the guess was.
final class BallparkGame: ObservableObject {
    static let rounds = 3
    static let maxScore = rounds * 100

    @Published private(set) var question: BallparkQuestion
    @Published private(set) var roundIndex = 0
    @Published private(set) var guess: Double?
    /// How many times off the guess was (1 is exact).
    @Published private(set) var factor = 1.0
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    private let questions: [BallparkQuestion]
    private var queue: [Int] = []

    init(questions: [BallparkQuestion] = BallparkQuestions.all) {
        precondition(!questions.isEmpty, "Ballpark needs questions")
        self.questions = questions
        self.question = questions[0]
        deal()
    }

    var revealed: Bool { guess != nil }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        queue = Deck.draw("ballpark", count: questions.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        question = questions[queue[min(roundIndex, queue.count - 1)]]
        guess = nil
        factor = 1
        lastPoints = 0
    }

    func lockIn(_ value: Double) {
        guard guess == nil, value.isFinite, value > 0 else { return }
        guess = value
        factor = Scoring.factorOff(guess: value, answer: question.answer)
        lastPoints = Scoring.estimate(guess: value, answer: question.answer)
        score += lastPoints
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

/// Number formatting shared by the estimation games.
enum NumberText {
    /// 384400 becomes "384,400". Very large values get a word: "9.46 trillion".
    static func plain(_ value: Double) -> String {
        guard value.isFinite else { return "?" }
        let magnitude = abs(value)
        // Billions and up always get a word. Millions do from ten million.
        let words: [(Double, Double, String)] = [
            (1e12, 1e12, "trillion"), (1e9, 1e9, "billion"), (1e7, 1e6, "million")
        ]
        for (threshold, size, word) in words where magnitude >= threshold {
            return trimmed(value / size, maxDecimals: 2) + " " + word
        }
        if magnitude >= 100 {
            return grouped(value.rounded())
        }
        return trimmed(value, maxDecimals: 2)
    }

    /// "2.4x" style multiplier.
    static func factor(_ value: Double) -> String {
        guard value.isFinite else { return "way off" }
        if value < 1.005 { return "spot on" }
        if value >= 100 { return grouped(value.rounded()) + "x off" }
        return trimmed(value, maxDecimals: value < 10 ? 2 : 1) + "x off"
    }

    static func trimmed(_ value: Double, maxDecimals: Int) -> String {
        var text = String(format: "%.\(maxDecimals)f", value)
        if text.contains(".") {
            while text.hasSuffix("0") { text.removeLast() }
            if text.hasSuffix(".") { text.removeLast() }
        }
        return text
    }

    static func grouped(_ value: Double) -> String {
        let negative = value < 0
        let digits = String(format: "%.0f", abs(value))
        var result = ""
        for (offset, character) in digits.reversed().enumerated() {
            if offset > 0 && offset % 3 == 0 {
                result.append(",")
            }
            result.append(character)
        }
        return (negative ? "-" : "") + String(result.reversed())
    }

    /// Reads what a player typed: digits with an optional decimal point.
    /// Commas and spaces are ignored.
    static func parse(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "$", with: "")
        guard !cleaned.isEmpty, let value = Double(cleaned), value.isFinite else { return nil }
        return value
    }
}
