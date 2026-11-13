import Foundation
import Combine

/// Offline scores and play counts. Everything lives in UserDefaults on the
/// device, so no network or account is ever needed.
final class HighScoreStore: ObservableObject {
    @Published private(set) var scores: [GameKind: Int] = [:]
    /// Finished runs per game.
    @Published private(set) var plays: [GameKind: Int] = [:]
    /// Sum of the scores of all finished runs per game.
    @Published private(set) var totals: [GameKind: Int] = [:]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        for kind in GameKind.allCases {
            scores[kind] = defaults.integer(forKey: kind.scoreKey)
            plays[kind] = defaults.integer(forKey: Self.playsKey(kind))
            totals[kind] = defaults.integer(forKey: Self.totalKey(kind))
        }
    }

    private static func playsKey(_ kind: GameKind) -> String { "plays.\(kind.rawValue)" }
    private static func totalKey(_ kind: GameKind) -> String { "total.\(kind.rawValue)" }

    func best(for kind: GameKind) -> Int {
        scores[kind] ?? 0
    }

    func playCount(for kind: GameKind) -> Int {
        plays[kind] ?? 0
    }

    /// Average score over finished runs, or nil before the first one.
    func average(for kind: GameKind) -> Int? {
        let count = playCount(for: kind)
        guard count > 0 else { return nil }
        return Int((Double(totals[kind] ?? 0) / Double(count)).rounded())
    }

    var totalPlays: Int {
        plays.values.reduce(0, +)
    }

    /// Saves `score` if it beats the stored best. Returns true for a new record.
    @discardableResult
    func submit(_ score: Int, for kind: GameKind) -> Bool {
        guard score > best(for: kind) else { return false }
        scores[kind] = score
        defaults.set(score, forKey: kind.scoreKey)
        return true
    }

    /// Records a finished run: counts the play and checks for a new best.
    @discardableResult
    func finishRun(_ score: Int, for kind: GameKind) -> Bool {
        plays[kind] = playCount(for: kind) + 1
        totals[kind] = (totals[kind] ?? 0) + score
        defaults.set(plays[kind], forKey: Self.playsKey(kind))
        defaults.set(totals[kind], forKey: Self.totalKey(kind))
        return submit(score, for: kind)
    }

    func resetAll() {
        for kind in GameKind.allCases {
            defaults.removeObject(forKey: kind.scoreKey)
            defaults.removeObject(forKey: Self.playsKey(kind))
            defaults.removeObject(forKey: Self.totalKey(kind))
        }
        scores = [:]
        plays = [:]
        totals = [:]
    }
}
