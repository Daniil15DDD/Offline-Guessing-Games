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
