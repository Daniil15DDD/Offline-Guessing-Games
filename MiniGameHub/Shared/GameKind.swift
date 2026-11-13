import SwiftUI

/// The games available in the hub. To add one: add a case here, give it a
/// screen, and add that screen to the `switch` in `HubView`.
enum GameKind: String, CaseIterable, Identifiable, Hashable {
    case globe
    case fourfold
    case topTen
    case critter
    case deep
    case price
    case ballpark
    case trend
    case scale
    case hue
    case pitch
    case beat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .globe: return "Getting Warmer"
        case .fourfold: return "Fourfold"
        case .topTen: return "Ten Count"
        case .critter: return "Critter Clues"
        case .deep: return "Deep Catch"
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
        case .globe: return "Name countries. Hotter colours mean closer."
        case .fourfold: return "Sort sixteen words into four hidden groups."
        case .topTen: return "Name everything on a top-ten list."
        case .critter: return "Find the mystery animal from its traits."
        case .deep: return "Rarer answers sink your line deeper."
        case .price: return "See the item. Guess what it costs."
        case .ballpark: return "Estimate big numbers. Close counts."
        case .trend: return "Draw where a real chart went next."
        case .scale: return "Resize one thing to match another."
        case .hue: return "Memorise a colour, then match it."
        case .pitch: return "Hear a note, then tune yours to match."
        case .beat: return "Hear a beat, then keep it going."
        }
    }

    /// Picture shown on the hub tile (in the asset catalog).
    var art: String {
        switch self {
        case .globe: return "hub_globe"
        case .fourfold: return "hub_fourfold"
        case .topTen: return "hub_topten"
        case .critter: return "hub_critter"
        case .deep: return "hub_deep"
        case .price: return "hub_price"
        case .ballpark: return "hub_ballpark"
        case .trend: return "hub_trend"
        case .scale: return "hub_scale"
        case .hue: return "hub_hue"
        case .pitch: return "hub_pitch"
        case .beat: return "hub_beat"
        }
    }

    /// Each game has its own two-colour identity.
    var colors: [Color] {
        switch self {
        case .globe: return [Color(hex: 0x4F7CFF), Color(hex: 0x2CC4E8)]
        case .fourfold: return [Color(hex: 0x8B5CF6), Color(hex: 0xEC4899)]
        case .topTen: return [Color(hex: 0xF5A524), Color(hex: 0xF9622A)]
        case .critter: return [Color(hex: 0xFF8A3D), Color(hex: 0xFF4F81)]
        case .deep: return [Color(hex: 0x1BB3C8), Color(hex: 0x2A4BD7)]
        case .price: return [Color(hex: 0x2FC98D), Color(hex: 0x0E9AA0)]
        case .ballpark: return [Color(hex: 0xF43F5E), Color(hex: 0xFB8B3C)]
        case .trend: return [Color(hex: 0x6366F1), Color(hex: 0x38A9F0)]
        case .scale: return [Color(hex: 0x74B816), Color(hex: 0x169C4B)]
        case .hue: return [Color(hex: 0xE85FAE), Color(hex: 0xF2A93B)]
        case .pitch: return [Color(hex: 0xA855F7), Color(hex: 0x3B82F6)]
        case .beat: return [Color(hex: 0xF76584), Color(hex: 0x8E3BE0)]
        }
    }

    var accent: Color { colors[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// The best possible score for one run.
    var maxScore: Int {
        switch self {
        case .globe: return GlobeGame.maxScore
        case .fourfold: return FourfoldGame.maxScore
        case .topTen: return TopTenGame.maxScore
        case .critter: return CritterGame.maxScore
        case .deep: return RareGame.maxScore
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
