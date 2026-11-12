import Foundation
import Combine

/// Offline high scores. Everything lives in UserDefaults on the device, so
/// no network or account is ever needed.
final class HighScoreStore: ObservableObject {
    @Published private(set) var scores: [GameKind: Int] = [:]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var loaded: [GameKind: Int] = [:]
        for kind in GameKind.allCases {
            loaded[kind] = defaults.integer(forKey: kind.scoreKey)
        }
        scores = loaded
    }

    func best(for kind: GameKind) -> Int {
        scores[kind] ?? 0
    }

    /// Saves `score` if it beats the stored best. Returns true for a new record.
    @discardableResult
    func submit(_ score: Int, for kind: GameKind) -> Bool {
        guard score > best(for: kind) else { return false }
        scores[kind] = score
        defaults.set(score, forKey: kind.scoreKey)
        return true
    }

    func resetAll() {
        for kind in GameKind.allCases {
            defaults.removeObject(forKey: kind.scoreKey)
        }
        scores = [:]
    }
}
