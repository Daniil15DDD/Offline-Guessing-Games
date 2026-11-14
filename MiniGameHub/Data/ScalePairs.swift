import Foundation

struct ScalePair: Equatable {
    /// Drawn at a fixed size.
    let referenceName: String
    let referenceSize: Double
    /// Which outline to draw (see `Silhouettes`).
    let referenceOutline: String
    /// The one the player resizes.
    let targetName: String
    let targetSize: Double
    let targetOutline: String
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

    struct Member {
        let name: String
        let size: Double
        /// Key of the outline that represents it.
        let outline: String

        init(_ name: String, _ size: Double, _ outline: String) {
            self.name = name
            self.size = size
            self.outline = outline
        }
    }

    struct Family {
        let unit: String
        let members: [Member]
    }

    static let families: [Family] = [
        Family(unit: "km across", members: [
            Member("Sun", 1_392_000, "disc.sun"), Member("Jupiter", 139_820, "disc.banded"),
            Member("Saturn (without rings)", 116_460, "disc.banded"), Member("Uranus", 50_724, "disc"),
            Member("Neptune", 49_244, "disc"), Member("Earth", 12_742, "disc"), Member("Venus", 12_104, "disc"),
            Member("Mars", 6_779, "disc"), Member("Ganymede", 5_268, "disc"), Member("Titan", 5_150, "disc"),
            Member("Mercury", 4_879, "disc"), Member("Io", 3_643, "disc"), Member("Moon", 3_474, "disc.moon"),
            Member("Europa", 3_122, "disc"), Member("Pluto", 2_377, "disc")
        ]),
        Family(unit: "cm across", members: [
            Member("Basketball", 24, "ball.basketball"), Member("Football (soccer ball)", 22, "ball.soccer"),
            Member("Bowling ball", 21.8, "ball.bowling"), Member("Volleyball", 21, "ball.volleyball"),
            Member("Softball", 9.7, "ball.baseball"), Member("Baseball", 7.4, "ball.baseball"),
            Member("Cricket ball", 7.2, "ball.cricket"), Member("Tennis ball", 6.7, "ball.tennis"),
            Member("Pool ball", 5.7, "ball.pool"), Member("Golf ball", 4.27, "ball.golf"),
            Member("Table tennis ball", 4.0, "disc"), Member("Basketball hoop", 45.7, "ring")
        ]),
        Family(unit: "m tall", members: [
            Member("Burj Khalifa", 828, "b.burj"), Member("Tokyo Skytree", 634, "b.skytree"),
            Member("Shanghai Tower", 632, "b.shanghai"), Member("CN Tower", 553, "b.cn"),
            Member("One World Trade Center", 541, "b.wtc"), Member("Taipei 101", 508, "b.taipei"),
            Member("Petronas Towers", 452, "b.petronas"), Member("Empire State Building", 443, "b.empire"),
            Member("Eiffel Tower", 330, "b.eiffel"), Member("Chrysler Building", 319, "b.chrysler"),
            Member("The Shard", 310, "b.shard"), Member("Gateway Arch", 192, "b.arch"),
            Member("Space Needle", 184, "b.needle"), Member("Washington Monument", 169, "b.obelisk"),
            Member("Great Pyramid of Giza", 139, "b.pyramid"), Member("St Peter's Basilica", 137, "b.stpeters"),
            Member("London Eye", 135, "b.eye"), Member("Big Ben's tower", 96, "b.bigben"),
            Member("Statue of Liberty", 93, "b.liberty"), Member("Taj Mahal", 73, "b.taj"),
            Member("Sydney Opera House", 65, "b.opera"), Member("Leaning Tower of Pisa", 56, "b.pisa"),
            Member("Arc de Triomphe", 50, "b.arc")
        ]),
        Family(unit: "m high", members: [
            Member("Mount Everest", 8_849, "m.everest"), Member("K2", 8_611, "m.k2"),
            Member("Aconcagua", 6_961, "m.aconcagua"), Member("Denali", 6_190, "m.denali"),
            Member("Kilimanjaro", 5_895, "m.kilimanjaro"), Member("Mount Elbrus", 5_642, "m.elbrus"),
            Member("Mount Kenya", 5_199, "m.kenya"), Member("Vinson Massif", 4_892, "m.vinson"),
            Member("Mont Blanc", 4_806, "m.blanc"), Member("Matterhorn", 4_478, "m.matterhorn"),
            Member("Mount Rainier", 4_392, "m.rainier"), Member("Mauna Kea", 4_207, "m.maunakea"),
            Member("Mount Fuji", 3_776, "m.fuji"), Member("Aoraki / Mount Cook", 3_724, "m.cook"),
            Member("Mount Olympus", 2_917, "m.olympus"), Member("Ben Nevis", 1_345, "m.nevis"),
            Member("Vesuvius", 1_281, "m.vesuvius"), Member("Table Mountain", 1_085, "m.table")
        ]),
        Family(unit: "m tall", members: [
            Member("Giraffe", 5.5, "img.s_giraffe"), Member("African elephant", 3.2, "img.s_elephant"),
            Member("Dromedary camel", 2.0, "img.s_camel"), Member("Llama", 1.8, "img.s_llama"),
            Member("Adult human", 1.7, "img.s_person"), Member("Greater flamingo", 1.3, "img.s_flamingo"),
            Member("Emperor penguin", 1.1, "img.s_penguin")
        ])
    ]

    static let all: [ScalePair] = {
        var pairs: [ScalePair] = []
        for family in families {
            for reference in family.members {
                for target in family.members where target.name != reference.name {
                    let ratio = target.size / reference.size
                    // Skip near-twins, where the right answer is "the same".
                    guard ratio >= smallestPair, ratio <= largestPair, abs(ratio - 1) > 0.04 else { continue }
                    pairs.append(ScalePair(
                        referenceName: reference.name,
                        referenceSize: reference.size,
                        referenceOutline: reference.outline,
                        targetName: target.name,
                        targetSize: target.size,
                        targetOutline: target.outline,
                        unit: family.unit
                    ))
                }
            }
        }
        return pairs
    }()
}
