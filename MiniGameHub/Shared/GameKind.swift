import SwiftUI

/// The games available in the hub. To add one: add a case here, give it a
/// screen, and add that screen to the `switch` in `HubView`.
enum GameKind: String, CaseIterable, Identifiable, Hashable {
    case borderline
    case fourfold
    case topTen
    case critter
    case rare
    case price
    case ballpark
    case trend
    case scale
    case hue
    case pitch
    case beat

    enum Shelf: String, CaseIterable, Identifiable {
        case words = "Words and trivia"
        case numbers = "Maps and numbers"
        case senses = "Eyes and ears"

        var id: String { rawValue }
    }

    var id: String { rawValue }

    var shelf: Shelf {
        switch self {
        case .fourfold, .topTen, .critter, .rare: return .words
        case .borderline, .price, .ballpark, .trend, .scale: return .numbers
        case .hue, .pitch, .beat: return .senses
        }
    }

    var title: String {
        switch self {
        case .borderline: return "Borderline"
        case .fourfold: return "Fourfold"
        case .topTen: return "Ten Count"
        case .critter: return "Critter Clues"
        case .rare: return "Rare Find"
        case .price: return "Price Point"
        case .ballpark: return "Ballpark"
        case .trend: return "Trendline"
        case .scale: return "Scale It"
        case .hue: return "Hue Recall"
        case .pitch: return "Pitch Match"
        case .beat: return "Beat Keeper"
        }
    }

    var tagline: String {
        switch self {
        case .borderline: return "Name the country from its outline."
        case .fourfold: return "Sort sixteen words into four hidden groups."
        case .topTen: return "Name everything on a top-ten list."
        case .critter: return "Find the mystery animal from its traits."
        case .rare: return "Quick prompts. Rarer answers score more."
        case .price: return "Guess what everyday things cost."
        case .ballpark: return "Estimate big numbers. Close counts."
        case .trend: return "Draw where a real chart went next."
        case .scale: return "Resize one thing to match another."
        case .hue: return "Memorise a colour, then rebuild it."
        case .pitch: return "Hear a note, then tune yours to match."
        case .beat: return "Hear a beat, then keep it going."
        }
    }

    /// SF Symbol used on the hub card.
    var symbol: String {
        switch self {
        case .borderline: return "globe.europe.africa.fill"
        case .fourfold: return "square.grid.2x2.fill"
        case .topTen: return "list.number"
        case .critter: return "pawprint.fill"
        case .rare: return "sparkles"
        case .price: return "tag.fill"
        case .ballpark: return "target"
        case .trend: return "chart.line.uptrend.xyaxis"
        case .scale: return "arrow.up.left.and.arrow.down.right"
        case .hue: return "paintpalette.fill"
        case .pitch: return "tuningfork"
        case .beat: return "metronome.fill"
        }
    }

    var colors: [Color] {
        switch shelf {
        case .words: return [Color(hex: 0xFF8A3D), Color(hex: 0xFF4F81)]
        case .numbers: return [Color(hex: 0x6C7BFF), Color(hex: 0x38D6FF)]
        case .senses: return [Color(hex: 0x37E38F), Color(hex: 0x1FA7A0)]
        }
    }

    var accent: Color { colors[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// The best possible score for one run.
    var maxScore: Int {
        switch self {
        case .borderline: return BorderlineGame.maxScore
        case .fourfold: return FourfoldGame.maxScore
        case .topTen: return TopTenGame.maxScore
        case .critter: return CritterGame.maxScore
        case .rare: return RareGame.maxScore
        case .price: return PriceGame.maxScore
        case .ballpark: return BallparkGame.maxScore
        case .trend: return TrendGame.maxScore
        case .scale: return ScaleGame.maxScore
        case .hue: return HueGame.maxScore
        case .pitch: return PitchGame.maxScore
        case .beat: return BeatGame.maxScore
        }
    }

    /// UserDefaults key the high score is stored under.
    var scoreKey: String { "highscore.\(rawValue)" }
}
