import Foundation

/// Word categories that Fourfold builds new puzzles from.
///
/// A word that fits more than one category is listed in every one of them
/// (MERCURY is a planet, a metal and a Roman god). The generator relies on
/// that to check each new puzzle has exactly one solution, so keep it true
/// when adding words.
enum WordBank {
    static let categories: [WordGroup] = raw.map { title, words in
        WordGroup(title: title, words: words.split(separator: " ").map(String.init))
    }

    private static let raw: [(String, String)] = [
        ("Planets", "MERCURY VENUS EARTH MARS JUPITER SATURN URANUS NEPTUNE"),
        ("Metals", "IRON COPPER TIN LEAD ZINC NICKEL SILVER GOLD MERCURY"),
        ("Roman gods", "MARS VENUS JUPITER SATURN NEPTUNE MERCURY APOLLO DIANA VULCAN JUNO"),
        ("Birds", "ROBIN CRANE SWIFT FINCH EAGLE HERON RAVEN WREN SWALLOW DUCK TURKEY KIWI ROOK KITE"),
        ("Golf words", "BIRDIE EAGLE PAR DRIVER IRON PUTTER BOGEY TEE GREEN"),
        ("Colours", "RED BLUE GREEN ORANGE PURPLE YELLOW PINK VIOLET GOLD SILVER"),
        ("Fruits", "ORANGE LEMON LIME KIWI PLUM PEACH CHERRY APPLE PEAR MANGO DATE FIG"),
        ("Herbs", "BASIL THYME PARSLEY DILL SAGE MINT ROSEMARY OREGANO CHIVES"),
        ("Shades of green", "OLIVE MINT EMERALD SAGE LIME JADE FOREST"),
        ("Trees", "OAK PINE ELM ASH BIRCH MAPLE CEDAR WILLOW PALM OLIVE"),
        ("Dog breeds", "BOXER POODLE BEAGLE HUSKY COLLIE PUG CORGI TERRIER"),
        ("Card games", "BRIDGE SNAP POKER RUMMY HEARTS SPADES WHIST"),
        ("Card suits", "HEARTS SPADES CLUBS DIAMONDS"),
        ("Gemstones", "RUBY OPAL TOPAZ GARNET EMERALD JADE DIAMOND PEARL AMBER"),
        ("Chess pieces", "KING QUEEN ROOK KNIGHT BISHOP PAWN"),
        ("Playing cards", "KING QUEEN JACK ACE JOKER"),
        ("Units of time", "SECOND MINUTE HOUR DAY WEEK MONTH YEAR DECADE"),
        ("Weather", "RAIN FOG HAIL SLEET SNOW WIND STORM CLOUD"),
        ("Rodents", "RAT MOUSE HAMSTER BEAVER SQUIRREL GERBIL"),
        ("Computer words", "MOUSE WINDOW DESKTOP CLOUD KEYBOARD MONITOR SERVER"),
        ("Bodies of water", "LAKE POND OCEAN STREAM RIVER SEA BAY"),
        ("Bread", "BAGEL ROLL PITA BAGUETTE BUN LOAF NAAN"),
        ("Hairstyles", "BUN BOB FRINGE PONYTAIL BRAID MOHAWK PERM"),
        ("Gymnastics moves", "FLIP VAULT CARTWHEEL SPLIT ROLL HANDSTAND"),
        ("Musical instruments", "FLUTE CELLO HARP TRUMPET VIOLIN DRUM PIANO GUITAR ORGAN"),
        ("Parts of a ship", "DECK HULL MAST BOW STERN KEEL ANCHOR BRIDGE"),
        ("Baby animals", "KITTEN CALF FOAL CUB PUPPY LAMB CHICK"),
        ("Parts of the leg", "SHIN KNEE THIGH ANKLE CALF HEEL"),
        ("Shoes", "BOOT CLOG LOAFER SANDAL SNEAKER SLIPPER"),
        ("Kitchen tools", "WHISK LADLE GRATER PEELER SPATULA TONGS SIEVE"),
        ("Coffee drinks", "LATTE MOCHA ESPRESSO AMERICANO CAPPUCCINO MACCHIATO"),
        ("Nuts", "ALMOND CASHEW PECAN PISTACHIO WALNUT PEANUT CHESTNUT"),
        ("Shades of brown", "TAN CHESTNUT HAZEL UMBER MOCHA BEIGE"),
        ("School subjects", "MATHS HISTORY ART CHEMISTRY PHYSICS BIOLOGY MUSIC"),
        ("Fish", "SALMON TROUT COD PIKE TUNA BASS PERCH SOLE RAY"),
        ("Measuring tools", "RULER THERMOMETER COMPASS TAPE SCALE GAUGE"),
        ("Monarchs", "EMPEROR SULTAN TSAR PHARAOH KING QUEEN RULER"),
        ("Pasta shapes", "PENNE FUSILLI RIGATONI FARFALLE SPAGHETTI LINGUINE RAVIOLI"),
        ("Dances", "TANGO SALSA WALTZ RUMBA SAMBA POLKA FOXTROT"),
        ("Dips and sauces", "PESTO GUACAMOLE HUMMUS MAYO SALSA KETCHUP MUSTARD"),
        ("Radio alphabet", "ALPHA BRAVO DELTA ECHO TANGO FOXTROT ROMEO JULIET OSCAR VICTOR"),
        ("Greek letters", "ALPHA BETA GAMMA DELTA OMEGA SIGMA THETA"),
        ("Snakes", "COBRA VIPER MAMBA ADDER PYTHON BOA"),
        ("Islands", "CRETE BALI MALTA CUBA JAVA CYPRUS"),
        ("Programming languages", "PYTHON JAVA SWIFT RUST RUBY"),
        ("Things in space", "COMET ASTEROID NEBULA GALAXY STAR PLANET MOON"),
        ("Pirate things", "PARROT TREASURE PLANK EYEPATCH HOOK"),
        ("Boxing punches", "JAB HOOK CROSS UPPERCUT"),
        ("Cheeses", "BRIE CHEDDAR FETA GOUDA EDAM STILTON"),
        ("Punctuation", "COMMA COLON PERIOD HYPHEN DASH"),
        ("Touchscreen gestures", "SWIPE TAP PINCH SCROLL"),
        ("Farm animals", "COW GOAT PIG HEN SHEEP HORSE DUCK TURKEY"),
        ("Spices", "CUMIN PAPRIKA NUTMEG SAFFRON CINNAMON GINGER MUSTARD"),
        ("Fabrics", "SILK DENIM WOOL LINEN COTTON VELVET SATIN"),
        ("Currencies", "DOLLAR EURO YEN POUND PESO RUPEE FRANC"),
        ("Units of weight", "OUNCE GRAM TON STONE POUND"),
        ("Rock", "GRANITE MARBLE SLATE FLINT STONE"),
        ("Big cats", "LION TIGER JAGUAR PANTHER LEOPARD CHEETAH"),
        ("Zodiac signs", "LEO ARIES LIBRA GEMINI TAURUS VIRGO PISCES"),
        ("Tools", "HAMMER WRENCH SAW DRILL PLIERS CHISEL PLANE LEVEL"),
        ("Vehicles", "TRAIN TRUCK FERRY TRAM BUS PLANE"),
        ("Months", "MAY MARCH JUNE AUGUST APRIL JULY"),
        ("Ways to walk", "STROLL STRIDE TRUDGE WANDER MARCH"),
        ("Countries", "CUBA MALTA TURKEY CHAD PERU CHILE CYPRUS"),
        ("Flowers", "ROSE LILY TULIP DAISY ORCHID VIOLET IRIS"),
        ("Parts of the eye", "IRIS PUPIL LENS RETINA CORNEA"),
        ("Camera kit", "LENS FLASH SHUTTER TRIPOD ZOOM"),
        ("Sports", "TENNIS GOLF RUGBY HOCKEY CRICKET SQUASH"),
        ("Insects", "ANT BEE WASP MOTH CRICKET BEETLE FLY"),
        ("Vegetables", "CARROT ONION LEEK SQUASH PEA KALE BEET"),
        ("Rooms", "KITCHEN ATTIC CELLAR STUDY LOUNGE PANTRY"),
        ("Furniture", "TABLE CHAIR SOFA DESK BED STOOL BENCH"),
        ("Drinks", "TEA COFFEE JUICE WATER MILK COCOA SODA"),
        ("Desserts", "CAKE PIE TART FUDGE MOUSSE TRIFLE"),
        ("Clothing", "SHIRT SKIRT JACKET COAT SCARF DRESS"),
        ("Shapes", "CIRCLE SQUARE TRIANGLE OVAL DIAMOND STAR"),
        ("Baseball words", "PITCH BUNT STRIKE STEAL BASE DIAMOND"),
        ("Music words", "PITCH TEMPO CHORD SCALE NOTE BEAT"),
        ("Body parts", "ARM LEG HAND FOOT EAR NOSE"),
        ("Units of length", "INCH FOOT YARD MILE METRE"),
        ("Bedding", "SHEET PILLOW DUVET QUILT BLANKET"),
        ("Sea animals", "WHALE SHARK SEAL CRAB SQUID OCTOPUS"),
        ("Parts of a fish", "FIN GILL TAIL SCALE"),
        ("Things with keys", "PIANO KEYBOARD MAP LOCK"),
        ("Light", "RAY GLOW FLASH SHINE BEAM"),
        ("Wood", "PLANK BEAM LOG STUMP BOARD"),
        ("Board game kit", "DICE TOKEN BOARD SPINNER"),
        ("Video game words", "LEVEL BOSS LIFE QUEST"),
        ("Pizza toppings", "MUSHROOM PEPPERONI PINEAPPLE ANCHOVY OLIVE"),
        ("Toys", "KITE DOLL PUZZLE YOYO MARBLE"),
        ("Gases", "OXYGEN HELIUM NEON ARGON RADON"),
        ("Jobs", "NURSE PILOT CHEF JUDGE BAKER FARMER"),
        ("Feelings", "JOY ANGER FEAR PRIDE ENVY HOPE"),
        ("Seasons", "SPRING SUMMER AUTUMN WINTER"),
        ("Jump", "LEAP HOP SPRING BOUND VAULT"),
        ("Tableware", "PLATE BOWL CUP FORK SPOON KNIFE"),
        ("Mythical creatures", "DRAGON UNICORN GRIFFIN PHOENIX MERMAID")
    ]

    /// Which categories each word belongs to.
    static let membership: [String: [Int]] = {
        var result: [String: [Int]] = [:]
        for (index, category) in categories.enumerated() {
            for word in category.words {
                result[word, default: []].append(index)
            }
        }
        return result
    }()
}

extension GroupPuzzles {
    /// How many different puzzles Fourfold deals from. The first few are the
    /// hand-written ones in `all`. The rest are built from `WordBank`.
    static let poolSize = 1000

    /// Puzzle `number`, always the same for the same number.
    static func puzzle(number: Int) -> GroupPuzzle {
        if number >= 0 && number < all.count {
            return all[number]
        }
        return generated(seed: number)
    }

    /// Builds a puzzle from four random categories, retrying until it has
    /// exactly one solution. Puzzles with a word that could fit two of the
    /// groups are preferred, because those are the interesting ones.
    static func generated(seed: Int) -> GroupPuzzle {
        var generator = SeededGenerator(seed: Daily.seed("fourfold.generated", seed))
        let bank = WordBank.categories
        var fallback: GroupPuzzle?

        for attempt in 0..<300 {
            let chosen = Array(Array(bank.indices).shuffled(using: &generator).prefix(4))
            var groups: [(String, String)] = []
            var words: [String] = []
            for index in chosen {
                let picked = Array(bank[index].words.shuffled(using: &generator).prefix(4))
                groups.append((bank[index].title, picked.joined(separator: " ")))
                words += picked
            }
            guard Set(words).count == 16, solutionCount(words: words) == 1 else { continue }

            let puzzle = GroupPuzzle(groups)
            // A "trap" is a word that also belongs to another chosen group.
            let hasTrap = words.contains { word in
                (WordBank.membership[word] ?? []).filter { chosen.contains($0) }.count > 1
            }
            if hasTrap || attempt >= 120 {
                return puzzle
            }
            if fallback == nil {
                fallback = puzzle
            }
        }
        return fallback ?? all[abs(seed) % all.count]
    }

    /// Counts the ways sixteen words can be split into four groups that each
    /// fit one category in the bank. Stops counting at `limit`.
    static func solutionCount(words: [String], limit: Int = 2) -> Int {
        guard words.count == 16 else { return 0 }
        let position = Dictionary(uniqueKeysWithValues: words.enumerated().map { ($1, $0) })
        guard position.count == 16 else { return 0 }

        // Every set of four puzzle words that share a category, as a bit mask.
        var candidates = Set<Int>()
        for category in WordBank.categories {
            let present = category.words.compactMap { position[$0] }
            guard present.count >= 4 else { continue }
            for a in 0..<(present.count - 3) {
                for b in (a + 1)..<(present.count - 2) {
                    for c in (b + 1)..<(present.count - 1) {
                        for d in (c + 1)..<present.count {
                            candidates.insert(1 << present[a] | 1 << present[b] | 1 << present[c] | 1 << present[d])
                        }
                    }
                }
            }
        }
        let masks = Array(candidates)

        func count(covered: Int) -> Int {
            if covered == 0xFFFF { return 1 }
            // Always extend with the lowest word not yet placed.
            var lowest = 0
            while covered & (1 << lowest) != 0 { lowest += 1 }
            var total = 0
            for mask in masks where mask & (1 << lowest) != 0 && mask & covered == 0 {
                total += count(covered: covered | mask)
                if total >= limit { return total }
            }
            return total
        }
        return count(covered: 0)
    }
}
