import Foundation

/// Point rules shared by the games. Every round is worth up to 100 points.
enum Scoring {

    /// Guessing games: 100 for a first-try win, sliding down evenly to the
    /// last allowed attempt. `attempt` starts at 1.
    static func ladder(attempt: Int, maxAttempts: Int) -> Int {
        guard maxAttempts > 0, attempt >= 1, attempt <= maxAttempts else { return 0 }
        return Int((100 * Double(maxAttempts - attempt + 1) / Double(maxAttempts)).rounded())
    }

    /// Precision games: full marks at or under `perfect` error, nothing at or
    /// beyond `zero`, and a straight line in between.
    static func closeness(error: Double, perfect: Double, zero: Double) -> Int {
        guard error.isFinite else { return 0 }
        if error <= perfect { return 100 }
        if error >= zero { return 0 }
        return Int((100 * (zero - error) / (zero - perfect)).rounded())
    }

    /// How many times too big or too small a guess is. Always 1 or more.
    static func factorOff(guess: Double, answer: Double) -> Double {
        guard guess > 0, answer > 0 else { return .infinity }
        return max(guess / answer, answer / guess)
    }

    /// Estimation games: 100 for spot on, 50 for ten times off, 0 for a
    /// hundred times off or worse.
    static func estimate(guess: Double, answer: Double) -> Int {
        let factor = factorOff(guess: guess, answer: answer)
        guard factor.isFinite else { return 0 }
        return max(0, min(100, Int((100 - 50 * log10(factor)).rounded())))
    }
}
