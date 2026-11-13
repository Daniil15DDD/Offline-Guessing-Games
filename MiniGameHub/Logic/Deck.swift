import Foundation

/// Deals puzzles in a shuffled order and remembers where it got to, so you
/// see every puzzle once before any repeats, even across app launches.
enum Deck {

    /// The next puzzle index for this deck, from 0 up to `count`.
    static func next(_ key: String, count: Int, defaults: UserDefaults = .standard) -> Int {
        guard count > 0 else { return 0 }
        let storageKey = "deck." + key
        var remaining = (defaults.array(forKey: storageKey) as? [Int]) ?? []
        remaining = remaining.filter { $0 >= 0 && $0 < count }
        if remaining.isEmpty {
            remaining = Array(0..<count).shuffled()
        }
        let index = remaining.removeLast()
        defaults.set(remaining, forKey: storageKey)
        return index
    }

    /// Several different puzzles at once.
    static func draw(_ key: String, count: Int, take: Int, defaults: UserDefaults = .standard) -> [Int] {
        var picked: [Int] = []
        var attempts = 0
        while picked.count < min(take, count) && attempts < count * 3 + take {
            let index = next(key, count: count, defaults: defaults)
            if !picked.contains(index) {
                picked.append(index)
            }
            attempts += 1
        }
        return picked
    }
}

/// How a game is being played.
enum PlayMode: Hashable {
    /// Any number of rounds, dealt from the shuffled deck.
    case free
    /// The one puzzle everybody gets on a given day.
    case daily(day: Int)

    var day: Int? {
        if case .daily(let day) = self { return day }
        return nil
    }

    var isDaily: Bool { day != nil }
}

/// A small, fast random number generator that always produces the same
/// sequence for the same seed (SplitMix64). Daily puzzles depend on it.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// Works out which puzzle belongs to which day.
enum Daily {
    /// Day 0 of the daily calendar.
    static let epoch = DateComponents(year: 2026, month: 1, day: 1)

    /// Whole days since the epoch, in the player's own time zone, so the
    /// puzzle changes at their midnight.
    static func dayNumber(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        guard let start = calendar.date(from: epoch) else { return 0 }
        let from = calendar.startOfDay(for: start)
        let to = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// A seed that is stable for a given game and number (FNV-1a hash).
    static func seed(_ key: String, _ number: Int) -> UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in "\(key)#\(number)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01B3
        }
        return hash
    }

    /// The puzzle indexes for a day. Each game walks through its puzzles in
    /// a fixed shuffled order, so every puzzle comes up once before any
    /// repeats, and the order is reshuffled for each pass.
    static func indices(_ key: String, count: Int, take: Int, day: Int) -> [Int] {
        guard count > 0, take > 0 else { return [] }
        let wanted = min(take, count)
        var picked: [Int] = []
        var position = max(day, 0) * wanted
        var guardCount = 0
        while picked.count < wanted && guardCount < count * 2 + wanted {
            let pass = position / count
            var generator = SeededGenerator(seed: seed(key, pass))
            let order = Array(0..<count).shuffled(using: &generator)
            let index = order[position % count]
            if !picked.contains(index) {
                picked.append(index)
            }
            position += 1
            guardCount += 1
        }
        return picked
    }
}

/// Hands a game its puzzles and its random numbers. In free play these come
/// from the remembered deck and true randomness. In daily mode everything is
/// derived from the day, so it is the same on every launch.
struct Dealer {
    let key: String
    let mode: PlayMode
    private var generator: SeededGenerator?

    init(key: String, mode: PlayMode) {
        self.key = key
        self.mode = mode
        if let day = mode.day {
            generator = SeededGenerator(seed: Daily.seed(key + ".values", day))
        }
    }

    /// Different puzzle indexes, from 0 up to `count`.
    func indices(count: Int, take: Int) -> [Int] {
        if let day = mode.day {
            return Daily.indices(key, count: count, take: take, day: day)
        }
        return Deck.draw(key, count: count, take: take)
    }

    func index(count: Int) -> Int {
        indices(count: count, take: 1).first ?? 0
    }

    mutating func double(in range: ClosedRange<Double>) -> Double {
        if generator != nil {
            return Double.random(in: range, using: &generator!)
        }
        return Double.random(in: range)
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        if generator != nil {
            return Int.random(in: range, using: &generator!)
        }
        return Int.random(in: range)
    }

    mutating func shuffled<T>(_ items: [T]) -> [T] {
        if generator != nil {
            return items.shuffled(using: &generator!)
        }
        return items.shuffled()
    }
}
