import Foundation

struct WordGroup: Equatable {
    let title: String
    let words: [String]
}

struct GroupPuzzle: Equatable {
    /// Four groups of four words, easiest first.
    let groups: [WordGroup]

    init(_ groups: [(String, String)]) {
        self.groups = groups.map { title, words in
            WordGroup(title: title, words: words.split(separator: " ").map(String.init))
        }
    }

    var words: [String] {
        groups.flatMap(\.words)
    }
}

/// Puzzles for Fourfold. Each one is written so that some words look like
/// they belong in two groups, but only one full solution exists.
enum GroupPuzzles {
    static let all: [GroupPuzzle] = [
        GroupPuzzle([
            ("Citrus fruits", "LEMON LIME ORANGE GRAPEFRUIT"),
            ("Herbs", "BASIL THYME PARSLEY DILL"),
            ("Shades of green", "OLIVE MINT EMERALD SAGE"),
            ("___ tree", "FAMILY PALM SHOE CHRISTMAS")
        ]),
        GroupPuzzle([
            ("Dog breeds", "BOXER POODLE BEAGLE HUSKY"),
            ("Olympic sports", "FENCING ROWING DIVING ARCHERY"),
            ("Card games", "BRIDGE SNAP POKER RUMMY"),
            ("Things with keys", "PIANO KEYBOARD MAP LOCK")
        ]),
        GroupPuzzle([
            ("Planets", "MARS VENUS SATURN MERCURY"),
            ("Metals", "IRON COPPER TIN LEAD"),
            ("Birds", "ROBIN CRANE SWIFT FINCH"),
            ("Golf words", "BIRDIE EAGLE PAR DRIVER")
        ]),
        GroupPuzzle([
            ("Units of time", "SECOND MINUTE HOUR DECADE"),
            ("Chess pieces", "ROOK KNIGHT BISHOP PAWN"),
            ("Playing cards", "KING QUEEN JACK ACE"),
            ("Tiny", "MINI SLIGHT WEE PETITE")
        ]),
        GroupPuzzle([
            ("Weather", "RAIN FOG HAIL SLEET"),
            ("Rodents", "RAT HAMSTER BEAVER SQUIRREL"),
            ("Bodies of water", "LAKE POND OCEAN STREAM"),
            ("Computer words", "MOUSE WINDOW DESKTOP CLOUD")
        ]),
        GroupPuzzle([
            ("Breakfast foods", "PANCAKE WAFFLE CEREAL OMELETTE"),
            ("Bread", "BAGEL ROLL PITA BAGUETTE"),
            ("Hairstyles", "BUN BOB FRINGE PONYTAIL"),
            ("Gymnastics moves", "FLIP VAULT CARTWHEEL SPLIT")
        ]),
        GroupPuzzle([
            ("Musical instruments", "FLUTE CELLO HARP TRUMPET"),
            ("Parts of a ship", "DECK HULL MAST BOW"),
            ("Things with strings", "PUPPET KITE YOYO APRON"),
            ("Things you can draw", "CURTAIN BATH SWORD CONCLUSION")
        ]),
        GroupPuzzle([
            ("Kitchen tools", "WHISK LADLE GRATER PEELER"),
            ("Shoes", "BOOT CLOG LOAFER SANDAL"),
            ("Baby animals", "KITTEN CALF FOAL CUB"),
            ("Parts of the leg", "SHIN KNEE THIGH ANKLE")
        ]),
        GroupPuzzle([
            ("Coffee drinks", "LATTE MOCHA ESPRESSO AMERICANO"),
            ("Nuts", "ALMOND CASHEW PECAN PISTACHIO"),
            ("Shades of brown", "TAN CHESTNUT HAZEL UMBER"),
            ("Sun ___", "BURN FLOWER RISE GLASSES")
        ]),
        GroupPuzzle([
            ("School subjects", "MATHS HISTORY ART CHEMISTRY"),
            ("Parts of a fish", "FIN GILL TAIL SCALE"),
            ("Measuring tools", "RULER THERMOMETER COMPASS TAPE"),
            ("Monarchs", "EMPEROR SULTAN TSAR PHARAOH")
        ]),
        GroupPuzzle([
            ("Pasta shapes", "PENNE FUSILLI RIGATONI FARFALLE"),
            ("Dips and sauces", "PESTO GUACAMOLE HUMMUS MAYO"),
            ("Dances", "TANGO SALSA WALTZ RUMBA"),
            ("Radio alphabet", "ALPHA BRAVO DELTA ECHO")
        ]),
        GroupPuzzle([
            ("Gemstones", "RUBY OPAL TOPAZ GARNET"),
            ("Snakes", "COBRA VIPER MAMBA ADDER"),
            ("Islands", "CRETE BALI MALTA CUBA"),
            ("Programming languages", "PYTHON JAVA SWIFT RUST")
        ]),
        GroupPuzzle([
            ("Things in space", "COMET ASTEROID NEBULA GALAXY"),
            ("Pirate things", "PARROT TREASURE PLANK EYEPATCH"),
            ("Boxing punches", "JAB HOOK CROSS UPPERCUT"),
            ("___ light", "MOON SUN FLASH SPOT")
        ]),
        GroupPuzzle([
            ("Cheeses", "BRIE CHEDDAR FETA GOUDA"),
            ("Punctuation", "COMMA COLON PERIOD HYPHEN"),
            ("Touchscreen gestures", "SWIPE TAP PINCH SCROLL"),
            ("Small amounts in cooking", "DASH CUP SPOONFUL DROP")
        ]),
        GroupPuzzle([
            ("Farm animals", "COW GOAT PIG HEN"),
            ("Spices", "CUMIN PAPRIKA NUTMEG SAFFRON"),
            ("Fabrics", "SILK DENIM WOOL LINEN"),
            ("Things you knit", "SCARF MITTEN SWEATER BLANKET")
        ]),
        GroupPuzzle([
            ("Currencies", "DOLLAR EURO YEN POUND"),
            ("Toys", "KITE DOLL PUZZLE YOYO"),
            ("Units of weight", "OUNCE GRAM TON STONE"),
            ("Rock", "GRANITE MARBLE SLATE FLINT")
        ]),
        GroupPuzzle([
            ("Big cats", "LION TIGER JAGUAR PANTHER"),
            ("Fish", "SALMON TROUT COD PIKE"),
            ("Tools", "HAMMER WRENCH SAW DRILL"),
            ("Zodiac signs", "LEO ARIES LIBRA GEMINI")
        ]),
        GroupPuzzle([
            ("Board game kit", "DICE TOKEN BOARD SPINNER"),
            ("Light", "RAY GLOW FLASH SHINE"),
            ("Wood", "PLANK BEAM LOG STUMP"),
            ("Write down", "JOT NOTE RECORD ENTER")
        ]),
        GroupPuzzle([
            ("Pizza toppings", "MUSHROOM PEPPERONI PINEAPPLE ANCHOVY"),
            ("Vehicles", "TRAIN TRUCK FERRY TRAM"),
            ("Video game words", "LEVEL BOSS LIFE QUEST"),
            ("Woodworking tools", "CHISEL PLANE CLAMP SANDER")
        ]),
        GroupPuzzle([
            ("Months", "MAY MARCH JUNE AUGUST"),
            ("Ways to walk", "STROLL STRIDE TRUDGE WANDER"),
            ("Helper verbs", "MIGHT COULD SHOULD WOULD"),
            ("Majestic", "GRAND NOBLE REGAL STATELY")
        ])
    ]
}
