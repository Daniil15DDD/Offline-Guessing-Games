import Foundation
import Combine

/// Borderline: name the country from its outline. Each wrong guess tells you
/// how far away the right country is and in which direction.
final class BorderlineGame: ObservableObject {
    struct Guess: Identifiable, Equatable {
        let id: Int
        let name: String
        let distanceKm: Int
        /// Degrees clockwise from north, pointing from the guess to the answer.
        let bearing: Double
        let compass: String
        let proximity: Int
        let isCorrect: Bool
    }

    static let rounds = 3
    static let maxGuesses = 6
    static let maxScore = rounds * 100

    @Published private(set) var target: Country
    @Published private(set) var roundIndex = 0
    @Published private(set) var guesses: [Guess] = []
    @Published private(set) var roundOver = false
    @Published private(set) var solved = false
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    private let countries: [Country]
    private var queue: [Int] = []

    init(countries: [Country] = Atlas.countries) {
        precondition(!countries.isEmpty, "Borderline needs country data")
        self.countries = countries
        self.target = countries[0]
        deal()
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        queue = Deck.draw("borderline", count: countries.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        target = countries[queue[min(roundIndex, queue.count - 1)]]
        guesses = []
        roundOver = false
        solved = false
        lastPoints = 0
    }

    /// Countries matching what has been typed, minus ones already guessed.
    func suggestions(for text: String) -> [Country] {
        let guessed = Set(guesses.map(\.name))
        let pool = countries.filter { !guessed.contains($0.name) }
        return TextMatch.suggestions(for: text, in: pool.map(\.spellings), limit: 6).map { pool[$0] }
    }

    func guess(_ country: Country) {
        guard !roundOver, !guesses.contains(where: { $0.name == country.name }) else { return }
        let correct = country.name == target.name
        let km = Geo.distanceKm(lat1: country.latitude, lon1: country.longitude,
                                lat2: target.latitude, lon2: target.longitude)
        let bearing = Geo.bearing(lat1: country.latitude, lon1: country.longitude,
                                  lat2: target.latitude, lon2: target.longitude)
        guesses.append(Guess(
            id: guesses.count,
            name: country.name,
            distanceKm: correct ? 0 : Int(km.rounded()),
            bearing: bearing,
            compass: Geo.compass(bearing),
            proximity: correct ? 100 : min(99, Geo.proximity(km: km)),
            isCorrect: correct
        ))
        if correct {
            solved = true
            lastPoints = Scoring.ladder(attempt: guesses.count, maxAttempts: Self.maxGuesses)
            score += lastPoints
            roundOver = true
        } else if guesses.count >= Self.maxGuesses {
            roundOver = true
        }
    }

    func giveUp() {
        guard !roundOver else { return }
        roundOver = true
    }

    /// Moves to the next country, or ends the run after the last one.
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
