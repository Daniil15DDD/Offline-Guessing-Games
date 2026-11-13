import Foundation
import Combine

/// Getting Warmer: a mystery country is hidden on the globe. Every country
/// you name lights up, hotter the nearer it is to the answer.
final class GlobeGame: ObservableObject {
    struct Guess: Identifiable, Equatable {
        /// The guessed country's id.
        let id: Int
        let name: String
        /// Edge to edge. Zero for the answer and for its neighbours.
        let distanceKm: Int
        /// 0 is cold (far away), 1 is hot (touching or correct).
        let heat: Double
        let isCorrect: Bool
    }

    static let maxScore = 100
    /// Anything this far away or further is fully cold.
    static let coldDistanceKm = 6000.0

    @Published private(set) var target: Country
    /// In the order they were made.
    @Published private(set) var guesses: [Guess] = []
    @Published private(set) var solved = false
    @Published private(set) var isOver = false
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    private let countries: [Country]

    init(countries: [Country] = Atlas.countries) {
        precondition(!countries.isEmpty, "The globe game needs country data")
        self.countries = countries
        self.target = countries[0]
        deal()
    }

    func restart() {
        deal()
    }

    private func deal() {
        target = countries[Deck.next("globe", count: countries.count)]
        guesses = []
        solved = false
        isOver = false
        score = 0
        isFinished = false
    }

    /// Nearest first.
    var ranked: [Guess] {
        guesses.sorted { first, second in
            first.distanceKm == second.distanceKm ? first.id < second.id : first.distanceKm < second.distanceKm
        }
    }

    var latest: Guess? { guesses.last }

    static func heat(forDistanceKm km: Double) -> Double {
        let share = min(1, max(0, km / coldDistanceKm))
        // Ease out so the last few hundred kilometres change colour fastest.
        return (1 - share) * (1 - share)
    }

    /// 100 for a first-try win, 4 less for each extra guess, never under 10.
    static func points(guessCount: Int) -> Int {
        guard guessCount >= 1 else { return 0 }
        return max(10, 100 - 4 * (guessCount - 1))
    }

    /// Countries matching what has been typed, minus ones already guessed.
    func suggestions(for text: String) -> [Country] {
        let guessed = Set(guesses.map(\.id))
        let pool = countries.filter { !guessed.contains($0.id) }
        return TextMatch.suggestions(for: text, in: pool.map(\.spellings), limit: 5).map { pool[$0] }
    }

    func guess(_ country: Country) {
        guard !isOver, !guesses.contains(where: { $0.id == country.id }) else { return }
        let correct = country.id == target.id
        let km = correct ? 0 : Atlas.borderDistanceKm(country, target)
        guesses.append(Guess(
            id: country.id,
            name: country.name,
            distanceKm: Int(km.rounded()),
            heat: correct ? 1 : Self.heat(forDistanceKm: km),
            isCorrect: correct
        ))
        if correct {
            solved = true
            score = Self.points(guessCount: guesses.count)
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
}
