import Foundation

/// Forgiving comparison of typed answers: ignores case, accents, spaces,
/// punctuation and a leading "the", and allows small typos in longer words.
enum TextMatch {

    static func normalize(_ text: String) -> String {
        let folded = text
            .replacingOccurrences(of: "&", with: " and ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .lowercased()
        var words = folded
            .split(whereSeparator: { !($0.isLetter || $0.isNumber) })
            .map(String.init)
        if words.count > 1, words[0] == "the" {
            words.removeFirst()
        }
        words = words.map { word in
            switch word {
            case "st": return "saint"
            case "mt": return "mount"
            default: return word
            }
        }
        return words.joined()
    }

    /// Typos forgiven for an answer of this (normalized) length.
    static func allowedTypos(forLength length: Int) -> Int {
        if length >= 9 { return 2 }
        if length >= 5 { return 1 }
        return 0
    }

    /// Classic Levenshtein distance.
    static func editDistance(_ first: String, _ second: String) -> Int {
        let a = Array(first)
        let b = Array(second)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var previous = Array(0...b.count)
        var current = Array(repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }

    /// Finds which option the input means. Each option is a list of accepted
    /// spellings. An exact match always wins. Otherwise the closest spelling
    /// within the typo allowance wins, unless two options are equally close.
    static func bestMatch(_ input: String, in options: [[String]]) -> Int? {
        let typed = normalize(input)
        guard !typed.isEmpty else { return nil }

        for (index, spellings) in options.enumerated() {
            if spellings.contains(where: { normalize($0) == typed }) {
                return index
            }
        }

        var best: (index: Int, distance: Int)?
        var tied = false
        for (index, spellings) in options.enumerated() {
            for spelling in spellings {
                let target = normalize(spelling)
                let allowed = allowedTypos(forLength: target.count)
                guard allowed > 0, abs(target.count - typed.count) <= allowed else { continue }
                let distance = editDistance(typed, target)
                guard distance <= allowed else { continue }
                if let current = best {
                    if distance < current.distance {
                        best = (index, distance)
                        tied = false
                    } else if distance == current.distance && index != current.index {
                        tied = true
                    }
                } else {
                    best = (index, distance)
                }
            }
        }
        if tied { return nil }
        return best?.index
    }

    /// Options whose name (or any alias) starts with or contains the typed
    /// text, best matches first. Used for suggestion lists.
    static func suggestions(for input: String, in options: [[String]], limit: Int) -> [Int] {
        let typed = normalize(input)
        guard !typed.isEmpty else { return [] }
        var starts: [Int] = []
        var contains: [Int] = []
        for (index, spellings) in options.enumerated() {
            let normalized = spellings.map(normalize)
            if normalized.contains(where: { $0.hasPrefix(typed) }) {
                starts.append(index)
            } else if typed.count >= 3, normalized.contains(where: { $0.contains(typed) }) {
                contains.append(index)
            }
        }
        return Array((starts + contains).prefix(limit))
    }
}
