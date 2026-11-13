import Foundation

struct ScalePair: Equatable {
    enum Shape: String { case circle, bar }

    let shape: Shape
    /// Drawn at a fixed size.
    let referenceName: String
    let referenceSize: Double
    /// The one the player resizes.
    let targetName: String
    let targetSize: Double
    /// What the sizes measure, for the reveal ("km across", "m tall").
    let unit: String

    /// Target size divided by reference size.
    var ratio: Double { targetSize / referenceSize }
}

/// Comparisons for Scale It, built from families of things with well-known
/// sizes. Every two members of a family make a pair (in both directions),
/// as long as one is not too many times bigger than the other.
enum ScalePairs {
    /// The slider covers these ratios.
    static let minRatio = 0.05
    static let maxRatio = 6.0
    /// Pairs are only made inside this narrower band, so the answer is never
    /// right at the end of the slider.
    static let smallestPair = 0.08
    static let largestPair = 5.0

    struct Family {
        let shape: ScalePair.Shape
        let unit: String
        let members: [(String, Double)]
    }

    static let families: [Family] = [
        Family(shape: .circle, unit: "km across", members: [
            ("Sun", 1_392_000), ("Jupiter", 139_820), ("Saturn (without rings)", 116_460),
            ("Uranus", 50_724), ("Neptune", 49_244), ("Earth", 12_742), ("Venus", 12_104),
            ("Mars", 6_779), ("Ganymede", 5_268), ("Titan", 5_150), ("Mercury", 4_879),
            ("Io", 3_643), ("Moon", 3_474), ("Europa", 3_122), ("Pluto", 2_377)
        ]),
        Family(shape: .circle, unit: "cm across", members: [
            ("Basketball", 24), ("Football (soccer ball)", 22), ("Bowling ball", 21.8),
            ("Volleyball", 21), ("Softball", 9.7), ("Baseball", 7.4), ("Cricket ball", 7.2),
            ("Tennis ball", 6.7), ("Pool ball", 5.7), ("Golf ball", 4.27),
            ("Table tennis ball", 4.0), ("Basketball hoop", 45.7)
        ]),
        Family(shape: .bar, unit: "m tall", members: [
            ("Burj Khalifa", 828), ("Tokyo Skytree", 634), ("Shanghai Tower", 632),
            ("CN Tower", 553), ("One World Trade Center", 541), ("Taipei 101", 508),
            ("Petronas Towers", 452), ("Empire State Building", 443), ("Eiffel Tower", 330),
            ("Chrysler Building", 319), ("The Shard", 310), ("Gateway Arch", 192),
            ("Space Needle", 184), ("Washington Monument", 169), ("Great Pyramid of Giza", 139),
            ("St Peter's Basilica", 137), ("London Eye", 135), ("Big Ben's tower", 96),
            ("Statue of Liberty", 93), ("Taj Mahal", 73), ("Sydney Opera House", 65),
            ("Leaning Tower of Pisa", 56), ("Arc de Triomphe", 50)
        ]),
        Family(shape: .bar, unit: "m high", members: [
            ("Mount Everest", 8_849), ("K2", 8_611), ("Aconcagua", 6_961), ("Denali", 6_190),
            ("Kilimanjaro", 5_895), ("Mount Elbrus", 5_642), ("Mount Kenya", 5_199),
            ("Vinson Massif", 4_892), ("Mont Blanc", 4_806), ("Matterhorn", 4_478),
            ("Mount Rainier", 4_392), ("Mauna Kea", 4_207), ("Mount Fuji", 3_776),
            ("Aoraki / Mount Cook", 3_724), ("Mount Olympus", 2_917), ("Ben Nevis", 1_345),
            ("Vesuvius", 1_281), ("Table Mountain", 1_085)
        ]),
        Family(shape: .bar, unit: "m tall", members: [
            ("Giraffe", 5.5), ("African elephant", 3.2), ("Ostrich", 2.5),
            ("Adult human", 1.7), ("Emperor penguin", 1.1)
        ])
    ]

    static let all: [ScalePair] = {
        var pairs: [ScalePair] = []
        for family in families {
            for reference in family.members {
                for target in family.members where target.0 != reference.0 {
                    let ratio = target.1 / reference.1
                    // Skip near-twins, where the right answer is "the same".
                    guard ratio >= smallestPair, ratio <= largestPair, abs(ratio - 1) > 0.04 else { continue }
                    pairs.append(ScalePair(
                        shape: family.shape,
                        referenceName: reference.0,
                        referenceSize: reference.1,
                        targetName: target.0,
                        targetSize: target.1,
                        unit: family.unit
                    ))
                }
            }
        }
        return pairs
    }()
}
