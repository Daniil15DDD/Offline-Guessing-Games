import Foundation
import Combine

/// Critter Clues: find the mystery animal. Every guess shows which of its
/// traits match the answer.
final class CritterGame: ObservableObject {
    enum Mark: Equatable {
        case match
        case partial
        case miss
        /// The answer's number is higher than the guess.
        case higher
        /// The answer's number is lower than the guess.
        case lower
    }

    struct Row: Identifiable, Equatable {
        let id: Int
        let critter: Critter
        let group: Mark
        let diet: Mark
        let home: Mark
        let legs: Mark
        let regions: Mark
        let weight: Mark
    }

    static let maxGuesses = 8
    static let maxScore = 100

    @Published private(set) var target: Critter
    @Published private(set) var rows: [Row] = []
    @Published private(set) var solved = false
    @Published private(set) var isOver = false
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private let critters: [Critter]

    init(mode: PlayMode = .free, critters: [Critter] = Critters.all) {
        precondition(!critters.isEmpty, "Critter Clues needs animals")
        self.mode = mode
        self.critters = critters
        self.target = critters[0]
        deal()
    }

    func restart() {
        deal()
    }

    private func deal() {
        target = critters[Dealer(key: "critters", mode: mode).index(count: critters.count)]
        rows = []
        solved = false
        isOver = false
        score = 0
        isFinished = false
    }

    var guessesLeft: Int { Self.maxGuesses - rows.count }

    /// Animals matching what has been typed, minus ones already guessed.
    func suggestions(for text: String) -> [Critter] {
        let guessed = Set(rows.map(\.critter.id))
        let pool = critters.filter { !guessed.contains($0.id) }
        if TextMatch.normalize(text).isEmpty {
            return []
        }
        return TextMatch.suggestions(for: text, in: pool.map { [$0.name] }, limit: 6).map { pool[$0] }
    }

    func guess(_ critter: Critter) {
        guard !isOver, !rows.contains(where: { $0.critter.id == critter.id }) else { return }
        rows.append(Self.compare(critter, to: target, id: rows.count))
        if critter.id == target.id {
            solved = true
            score = Scoring.ladder(attempt: rows.count, maxAttempts: Self.maxGuesses)
            isOver = true
        } else if rows.count >= Self.maxGuesses {
            isOver = true
        }
    }

    func giveUp() {
        guard !isOver else { return }
        isOver = true
    }

    func finish() {
        guard isOver else { return }
        isFinished = true
    }

    static func compare(_ guess: Critter, to target: Critter, id: Int) -> Row {
        func same(_ a: String, _ b: String) -> Mark { a == b ? .match : .miss }

        let legs: Mark = guess.legs == target.legs ? .match : (target.legs > guess.legs ? .higher : .lower)

        let shared = Set(guess.regions).intersection(target.regions)
        let regions: Mark
        if Set(guess.regions) == Set(target.regions) {
            regions = .match
        } else {
            regions = shared.isEmpty ? .miss : .partial
        }

        let weight: Mark
        if guess.weightKg == target.weightKg {
            weight = .match
        } else {
            weight = target.weightKg > guess.weightKg ? .higher : .lower
        }

        return Row(
            id: id,
            critter: guess,
            group: same(guess.group, target.group),
            diet: same(guess.diet, target.diet),
            home: same(guess.home, target.home),
            legs: legs,
            regions: regions,
            weight: weight
        )
    }
}
