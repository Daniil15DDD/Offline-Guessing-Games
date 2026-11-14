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

    /// How to play, shown from the question mark button in each game.
    var rules: [String] {
        switch self {
        case .globe:
            return [
                "A mystery country is hidden somewhere on the globe.",
                "Name any country. It lights up in a colour that shows how close it is to the answer: pale blue is far away, yellow is nearer, hot pink is next door.",
                "Colour is the only clue, so use each guess to home in.",
                "Drag the globe to turn it. Fewer guesses score more."
            ]
        case .fourfold:
            return [
                "Sixteen words hide four groups of four that belong together.",
                "Tap four words you think share a link, then press Submit.",
                "Watch out for words that seem to fit two groups. Only one full solution works.",
                "\"One away\" means three of your four were right.",
                "You can make four mistakes. Spare mistakes add to your score."
            ]
        case .topTen:
            return [
                "You are shown the title of a top-ten list.",
                "Type anything you think is on it. Right answers drop into their place in the ranking.",
                "Small spelling slips are forgiven.",
                "Five wrong guesses end the round. You score 10 for each answer found."
            ]
        case .critter:
            return [
                "Guess the mystery animal in eight tries.",
                "After each guess, six traits are compared with the answer.",
                "Green means that trait matches. Amber means it partly matches, such as sharing one region but not all.",
                "An arrow on legs or weight tells you whether the answer has more or less."
            ]
        case .deep:
            return [
                "Seven prompts, 25 seconds each. Type any answer that fits.",
                "Every accepted answer lowers your fishing line. Obvious answers sink it 100 metres. The rarest sink it 1,000.",
                "A wrong answer does not end the round, but it costs two seconds.",
                "See how deep you can get by the last prompt."
            ]
        case .price:
            return [
                "You are shown an everyday item. Guess its typical shop price in US dollars.",
                "After each guess you are told whether the real price is higher or lower. \"Close\" means you are within 25 percent.",
                "Land within 5 percent to win. You have six guesses per item.",
                "Fewer guesses score more."
            ]
        case .ballpark:
            return [
                "Three questions with big numbers for answers. You get one guess at each, so think it through.",
                "Type a number and pick thousand, million, billion or trillion if you need to.",
                "You are scored on how many times too big or too small you were. Spot on is 100 points, ten times off is 50.",
                "The calculator is there for working things out. No looking things up."
            ]
        case .trend:
            return [
                "You see the first part of a real chart.",
                "Drag across the shaded area to draw where you think the line went next.",
                "Lock in to see the real data drawn over your line.",
                "The closer your line is to the real one, the more you score."
            ]
        case .scale:
            return [
                "Two things are drawn side by side, but the one on the right is the wrong size.",
                "Drag the slider until the pair looks true to life.",
                "Lock in to see the real sizes.",
                "Within about 6 percent scores 100. Twice or half the right size scores nothing."
            ]
        case .hue:
            return [
                "A colour is shown for three seconds. Remember it.",
                "When it disappears, pick the same colour from memory: drag in the square for strength and brightness, and along the rainbow bar for the hue.",
                "Lock in to see the two side by side.",
                "The closer the match, the more you score."
            ]
        case .pitch:
            return [
                "Turn your sound on. Press the button to hear a note. You can hear it three times.",
                "Move the slider to change your own note, and press \"Hear mine\" to listen to it.",
                "Lock in when the two sound the same.",
                "Within a quarter of a semitone scores 100."
            ]
        case .beat:
            return [
                "A beat plays six times, then stops.",
                "Keep it going: tap the pad six times at the same speed.",
                "Tapping too fast or too slow both lose points.",
                "Within 2 percent of the tempo scores 100."
            ]
        }
    }

    /// SF Symbol drawn on the game's icon.
    var symbol: String {
        switch self {
        case .globe: return "globe.europe.africa.fill"
        case .fourfold: return "square.grid.2x2.fill"
        case .topTen: return "list.number"
        case .critter: return "pawprint.fill"
        case .deep: return "fish.fill"
        case .price: return "tag.fill"
        case .ballpark: return "scope"
        case .trend: return "chart.line.uptrend.xyaxis"
        case .scale: return "ruler.fill"
        case .hue: return "paintpalette.fill"
        case .pitch: return "tuningfork"
        case .beat: return "metronome.fill"
        }
    }

    /// Each game has its own pair of colours, taken from the iOS palette.
    var colors: [Color] {
        switch self {
        case .globe: return [Color(hex: 0x32ADE6), Color(hex: 0x0A84FF)]
        case .fourfold: return [Color(hex: 0xBF5AF2), Color(hex: 0x5E5CE6)]
        case .topTen: return [Color(hex: 0xFFB340), Color(hex: 0xFF7A00)]
        case .critter: return [Color(hex: 0xFF6482), Color(hex: 0xFF375F)]
        case .deep: return [Color(hex: 0x40C8E0), Color(hex: 0x0A6CFF)]
        case .price: return [Color(hex: 0x30D158), Color(hex: 0x1FA046)]
        case .ballpark: return [Color(hex: 0xFF6961), Color(hex: 0xFF3B30)]
        case .trend: return [Color(hex: 0x7D7AFF), Color(hex: 0x3F3CD6)]
        case .scale: return [Color(hex: 0x00C7BE), Color(hex: 0x00998F)]
        case .hue: return [Color(hex: 0xFF7EB6), Color(hex: 0xC644FC)]
        case .pitch: return [Color(hex: 0xDA8FFF), Color(hex: 0xAF52DE)]
        case .beat: return [Color(hex: 0xFF9F0A), Color(hex: 0xFF453A)]
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
