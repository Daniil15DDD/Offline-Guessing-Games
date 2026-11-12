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

/// Comparisons for Scale It. Sizes are standard reference figures.
enum ScalePairs {
    /// The slider covers these ratios, so every pair must sit inside them.
    static let minRatio = 0.05
    static let maxRatio = 6.0

    static let all: [ScalePair] = [
        ScalePair(shape: .circle, referenceName: "Earth", referenceSize: 12_742, targetName: "Moon", targetSize: 3_474, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Moon", referenceSize: 3_474, targetName: "Earth", targetSize: 12_742, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Earth", referenceSize: 12_742, targetName: "Mars", targetSize: 6_779, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Earth", referenceSize: 12_742, targetName: "Venus", targetSize: 12_104, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Neptune", referenceSize: 49_244, targetName: "Earth", targetSize: 12_742, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Jupiter", referenceSize: 139_820, targetName: "Saturn (without rings)", targetSize: 116_460, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Jupiter", referenceSize: 139_820, targetName: "Earth", targetSize: 12_742, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Sun", referenceSize: 1_392_000, targetName: "Jupiter", targetSize: 139_820, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Moon", referenceSize: 3_474, targetName: "Pluto", targetSize: 2_377, unit: "km across"),
        ScalePair(shape: .circle, referenceName: "Basketball", referenceSize: 24, targetName: "Tennis ball", targetSize: 6.7, unit: "cm across"),
        ScalePair(shape: .circle, referenceName: "Football (soccer ball)", referenceSize: 22, targetName: "Golf ball", targetSize: 4.27, unit: "cm across"),
        ScalePair(shape: .circle, referenceName: "Golf ball", referenceSize: 4.27, targetName: "Tennis ball", targetSize: 6.7, unit: "cm across"),
        ScalePair(shape: .circle, referenceName: "Tennis ball", referenceSize: 6.7, targetName: "Table tennis ball", targetSize: 4.0, unit: "cm across"),
        ScalePair(shape: .circle, referenceName: "Basketball hoop", referenceSize: 45.7, targetName: "Basketball", targetSize: 24, unit: "cm across"),
        ScalePair(shape: .bar, referenceName: "Eiffel Tower", referenceSize: 330, targetName: "Statue of Liberty", targetSize: 93, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Statue of Liberty", referenceSize: 93, targetName: "Eiffel Tower", targetSize: 330, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Burj Khalifa", referenceSize: 828, targetName: "Eiffel Tower", targetSize: 330, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Burj Khalifa", referenceSize: 828, targetName: "Empire State Building", targetSize: 443, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Great Pyramid of Giza", referenceSize: 139, targetName: "Statue of Liberty", targetSize: 93, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Big Ben's tower", referenceSize: 96, targetName: "Leaning Tower of Pisa", targetSize: 56, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Mount Everest", referenceSize: 8_849, targetName: "Mont Blanc", targetSize: 4_806, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Mount Everest", referenceSize: 8_849, targetName: "Kilimanjaro", targetSize: 5_895, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Adult human", referenceSize: 1.7, targetName: "Giraffe", targetSize: 5.5, unit: "m tall"),
        ScalePair(shape: .bar, referenceName: "Giraffe", referenceSize: 5.5, targetName: "Adult human", targetSize: 1.7, unit: "m tall")
    ]
}
