import Foundation
import Combine

/// Price Point: guess what an everyday item costs. Each guess is answered
/// with "higher" or "lower" until you land within 5 percent.
final class PriceGame: ObservableObject {
    enum Hint: Equatable {
        case higher
        case lower
        case correct
    }

    struct Guess: Identifiable, Equatable {
        let id: Int
        let amount: Double
        let hint: Hint
        /// Within 25 percent of the price.
        let isClose: Bool
    }

    static let rounds = 3
    static let maxGuesses = 6
    static let winMargin = 0.05
    static let closeMargin = 0.25
    static let maxScore = rounds * 100

    @Published private(set) var item: PriceItem
    @Published private(set) var roundIndex = 0
    @Published private(set) var guesses: [Guess] = []
    @Published private(set) var roundOver = false
    @Published private(set) var solved = false
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    let mode: PlayMode
    private let items: [PriceItem]
    private var queue: [Int] = []

    init(mode: PlayMode = .free, items: [PriceItem] = PriceItems.all) {
        precondition(!items.isEmpty, "Price Point needs items")
        self.mode = mode
        self.items = items
        self.item = items[0]
        deal()
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        queue = Dealer(key: "prices", mode: mode).indices(count: items.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        item = items[queue[min(roundIndex, queue.count - 1)]]
        guesses = []
        roundOver = false
        solved = false
        lastPoints = 0
    }

    var guessesLeft: Int { Self.maxGuesses - guesses.count }

    func guess(_ amount: Double) {
        guard !roundOver, amount.isFinite, amount > 0 else { return }
        let error = abs(amount - item.price) / item.price
        let hint: Hint
        if error <= Self.winMargin {
            hint = .correct
        } else {
            hint = amount < item.price ? .higher : .lower
        }
        guesses.append(Guess(
            id: guesses.count,
            amount: amount,
            hint: hint,
            isClose: error <= Self.closeMargin
        ))
        if hint == .correct {
            solved = true
            lastPoints = Scoring.ladder(attempt: guesses.count, maxAttempts: Self.maxGuesses)
            score += lastPoints
            roundOver = true
        } else if guesses.count >= Self.maxGuesses {
            roundOver = true
        }
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
