import Foundation
import Combine

/// Remembers which daily puzzles have been played today, and the streak of
/// days in a row with at least one daily finished. Stored on the device.
final class DailyStore: ObservableObject {
    /// Today's number in the daily calendar (see `Daily.dayNumber`).
    @Published private(set) var day: Int
    /// Game key to score, for the dailies finished today.
    @Published private(set) var results: [String: Int] = [:]
    @Published private(set) var streak = 0

    private var lastPlayedDay: Int?
    private let defaults: UserDefaults

    private enum Key {
        static let day = "daily.day"
        static let results = "daily.results"
        static let streak = "daily.streak"
        static let lastPlayedDay = "daily.lastPlayedDay"
    }

    init(defaults: UserDefaults = .standard, today: Int = Daily.dayNumber()) {
        self.defaults = defaults
        self.day = today
        load()
    }

    /// Call when the app comes to the front, in case midnight has passed.
    func refresh(today: Int = Daily.dayNumber()) {
        guard today != day else { return }
        day = today
        load()
    }

    private func load() {
        var loaded: [String: Int] = [:]
        if defaults.object(forKey: Key.day) != nil, defaults.integer(forKey: Key.day) == day {
            // Read each score leniently, so a value stored as text still counts.
            for (key, value) in defaults.dictionary(forKey: Key.results) ?? [:] {
                if let score = (value as? Int) ?? Int("\(value)") {
                    loaded[key] = score
                }
            }
        }
        results = loaded
        lastPlayedDay = defaults.object(forKey: Key.lastPlayedDay) == nil ? nil : defaults.integer(forKey: Key.lastPlayedDay)
        let stored = defaults.integer(forKey: Key.streak)
        // A streak survives until a whole day is missed.
        if let last = lastPlayedDay, last >= day - 1 {
            streak = stored
        } else {
            streak = 0
        }
    }

    func score(for key: String) -> Int? {
        results[key]
    }

    var finishedCount: Int { results.count }

    var totalToday: Int { results.values.reduce(0, +) }

    /// Saves a finished daily. Only the first result for a game counts.
    /// Returns false if it was ignored.
    @discardableResult
    func record(_ score: Int, for key: String, day playedDay: Int) -> Bool {
        // A puzzle finished after midnight belongs to a day that is over.
        guard playedDay == day, results[key] == nil else { return false }
        results[key] = score
        if lastPlayedDay != day {
            streak = (lastPlayedDay == day - 1) ? streak + 1 : 1
            lastPlayedDay = day
        }
        defaults.set(day, forKey: Key.day)
        defaults.set(results, forKey: Key.results)
        defaults.set(streak, forKey: Key.streak)
        defaults.set(day, forKey: Key.lastPlayedDay)
        return true
    }
}
