import Foundation
import Combine

/// Rare Find: seven "name a ..." prompts against the clock. Any accepted
/// answer scores, but the less obvious it is, the more it is worth.
final class RareGame: ObservableObject {
    static let rounds = 7
    static let secondsPerPrompt = 25.0
    static let maxScore = rounds * 100

    @Published private(set) var prompt: RarePrompt
    @Published private(set) var roundIndex = 0
    @Published private(set) var timeLeft = RareGame.secondsPerPrompt
    /// The answer that scored this round, if any.
    @Published private(set) var accepted: RareAnswer?
    @Published private(set) var rejected: [String] = []
    @Published private(set) var roundOver = false
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    private let prompts: [RarePrompt]
    private var queue: [Int] = []
    private var deadline: Date?

    init(prompts: [RarePrompt] = RarePrompts.all) {
        precondition(!prompts.isEmpty, "Rare Find needs prompts")
        self.prompts = prompts
        self.prompt = prompts[0]
        deal()
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        queue = Deck.draw("rare", count: prompts.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        prompt = prompts[queue[min(roundIndex, queue.count - 1)]]
        accepted = nil
        rejected = []
        roundOver = false
        lastPoints = 0
        timeLeft = Self.secondsPerPrompt
        deadline = nil  // the clock starts on the first tick
    }

    /// Call several times a second while the screen is showing.
    func tick(now: Date = Date()) {
        guard !roundOver, !isFinished else { return }
        guard let deadline = deadline else {
            self.deadline = now.addingTimeInterval(Self.secondsPerPrompt)
            return
        }
        let left = max(0, deadline.timeIntervalSince(now))
        if abs(left - timeLeft) >= 0.05 || left == 0 {
            timeLeft = left
        }
        if left <= 0 {
            roundOver = true
        }
    }

    /// Returns true when the answer was accepted.
    @discardableResult
    func submit(_ text: String) -> Bool {
        let typed = TextMatch.normalize(text)
        guard !roundOver, !typed.isEmpty else { return false }
        if let index = TextMatch.bestMatch(text, in: prompt.answers.map(\.spellings)) {
            let answer = prompt.answers[index]
            accepted = answer
            lastPoints = RarePrompts.points[answer.tier - 1]
            score += lastPoints
            roundOver = true
            return true
        }
        if !rejected.contains(where: { TextMatch.normalize($0) == typed }) {
            rejected.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return false
    }

    /// A few of the rarest answers, shown after the round.
    var rarestExamples: [String] {
        let top = prompt.answers.filter { $0.tier == 5 }.map(\.name)
        return Array(top.prefix(4))
    }

    func next() {
        guard roundOver, !isFinished else { return }
        if roundIndex + 1 >= min(Self.rounds, queue.count) {
            isFinished = true
        } else {
            roundIndex += 1
            startRound()
        }
    }
}
