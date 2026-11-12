import Foundation

struct RareAnswer: Equatable {
    /// The first spelling is the one shown. The rest are also accepted.
    let spellings: [String]
    /// 1 is the most obvious answer, 5 is the rarest.
    let tier: Int
    var name: String { spellings[0] }
}

struct RarePrompt: Equatable {
    let text: String
    let answers: [RareAnswer]

    /// `tiers` holds five comma-separated lists, most obvious first.
    /// Use "=" between alternative spellings of the same answer.
    init(_ text: String, _ tiers: [String]) {
        self.text = text
        var answers: [RareAnswer] = []
        for (index, list) in tiers.enumerated() {
            for item in list.components(separatedBy: ", ") where !item.isEmpty {
                answers.append(RareAnswer(
                    spellings: item.components(separatedBy: "="),
                    tier: index + 1
                ))
            }
        }
        self.answers = answers
    }
}

/// Prompts for Rare Find.
///
/// The online games this genre comes from rank answers by how often real
/// players give them. This app is offline, so the tiers here are the
/// author's own estimate of how obvious each answer is.
enum RarePrompts {
    static let points = [10, 30, 60, 85, 100]
    static let tierNames = ["Common", "Familiar", "Uncommon", "Rare", "Very rare"]

    static let all: [RarePrompt] = [
        RarePrompt("Name a planet in our solar system", [
            "Earth, Mars",
            "Jupiter, Saturn",
            "Venus",
            "Mercury, Neptune",
            "Uranus"
        ]),
        RarePrompt("Name a fruit", [
            "Apple, Banana, Orange",
            "Strawberry, Grape=Grapes, Mango, Pineapple, Watermelon",
            "Pear, Peach, Cherry, Kiwi, Lemon, Blueberry, Raspberry",
            "Plum, Apricot, Papaya, Pomegranate, Fig, Lime, Melon=Cantaloupe, Coconut, Grapefruit, Blackberry, Nectarine, Tangerine=Mandarin=Clementine, Avocado, Passion fruit, Guava",
            "Lychee, Persimmon, Dragon fruit=Pitaya, Kumquat, Quince, Starfruit=Carambola, Durian, Jackfruit, Mulberry, Gooseberry, Cranberry, Date, Elderberry, Tamarind, Rambutan"
        ]),
        RarePrompt("Name a European capital city", [
            "Paris, London",
            "Rome, Berlin, Madrid",
            "Amsterdam, Vienna, Athens, Lisbon, Dublin, Moscow",
            "Prague, Brussels, Stockholm, Oslo, Copenhagen, Budapest, Warsaw, Helsinki, Kyiv=Kiev, Bern",
            "Ljubljana, Bratislava, Tallinn, Riga, Vilnius, Valletta, Reykjavik, Zagreb, Sofia, Bucharest, Belgrade, Tirana, Skopje, Podgorica, Sarajevo, Chisinau, Minsk, Luxembourg, Andorra la Vella, Vaduz, Monaco, San Marino, Nicosia"
        ]),
        RarePrompt("Name a musical instrument", [
            "Guitar, Piano, Drums=Drum",
            "Violin, Flute, Trumpet",
            "Saxophone=Sax, Cello, Clarinet, Harp, Bass guitar=Bass, Keyboard, Ukulele",
            "Trombone, Oboe, Tuba, Banjo, Harmonica, Accordion, Viola, Xylophone, Organ, Recorder, Tambourine, Double bass, Mandolin, French horn=Horn",
            "Bassoon, Sitar, Bagpipes=Bagpipe, Theremin, Didgeridoo, Glockenspiel, Marimba, Lute, Harpsichord, Piccolo, Zither, Kalimba, Triangle, Cymbals=Cymbal, Castanets, Maracas, Bongos, Lyre, Dulcimer"
        ]),
        RarePrompt("Name an animal you might see on an African safari", [
            "Lion, Elephant",
            "Giraffe, Zebra",
            "Rhino=Rhinoceros, Hippo=Hippopotamus, Leopard, Cheetah",
            "Hyena, Buffalo=Cape buffalo, Wildebeest=Gnu, Crocodile, Gazelle, Antelope, Warthog, Baboon, Ostrich",
            "Impala, Meerkat, Wild dog=African wild dog, Kudu, Oryx, Jackal, Aardvark, Vulture, Springbok, Mongoose, Eland, Serval, Caracal, Pangolin, Honey badger"
        ]),
        RarePrompt("Name a sport played with a ball", [
            "Football=Soccer, Basketball",
            "Tennis, Baseball, Golf",
            "Volleyball, Rugby, Cricket, American football, Table tennis=Ping pong",
            "Hockey=Field hockey, Bowling, Handball, Softball, Squash, Pool=Billiards=Snooker, Water polo, Lacrosse, Netball, Dodgeball",
            "Polo, Croquet, Pickleball, Racquetball, Bocce=Boules=Petanque, Hurling, Gaelic football, Kickball, Padel, Jai alai, Sepak takraw, Korfball, Australian rules football=Aussie rules, Bandy"
        ]),
        RarePrompt("Name a chemical element", [
            "Oxygen, Hydrogen, Gold",
            "Carbon, Iron, Helium, Silver",
            "Nitrogen, Sodium, Calcium, Copper, Neon, Uranium, Lithium",
            "Potassium, Magnesium, Zinc, Lead, Mercury, Aluminium=Aluminum, Chlorine, Sulfur=Sulphur, Silicon, Platinum, Titanium, Tin, Nickel, Fluorine, Phosphorus, Iodine, Argon, Plutonium",
            "Boron, Beryllium, Cobalt, Chromium, Manganese, Krypton, Xenon, Radon, Radium, Tungsten, Bismuth, Arsenic, Selenium, Bromine, Barium, Caesium=Cesium, Strontium, Gallium, Germanium, Zirconium, Palladium, Cadmium, Antimony, Iridium, Osmium, Polonium, Francium, Thorium, Scandium, Vanadium, Rubidium, Yttrium, Niobium, Molybdenum, Tellurium, Hafnium, Tantalum, Rhenium, Thallium, Astatine, Neodymium, Europium, Einsteinium, Americium, Curium, Californium"
        ]),
        RarePrompt("Name a vegetable", [
            "Carrot, Potato, Broccoli",
            "Tomato, Onion, Lettuce, Cucumber, Corn=Sweetcorn",
            "Spinach, Peas=Pea, Pepper=Bell pepper, Cabbage, Cauliflower, Celery, Mushroom, Garlic",
            "Zucchini=Courgette, Eggplant=Aubergine, Pumpkin, Beetroot=Beet, Asparagus, Kale, Radish, Leek, Sweet potato, Green beans=Green bean, Brussels sprouts=Brussels sprout, Squash, Turnip",
            "Artichoke, Parsnip, Okra, Fennel, Kohlrabi, Rutabaga=Swede, Chard=Swiss chard, Bok choy=Pak choi, Arugula=Rocket, Watercress, Shallot, Endive, Celeriac, Yam, Daikon, Radicchio, Rhubarb"
        ]),
        RarePrompt("Name an ocean or sea", [
            "Pacific=Pacific Ocean, Atlantic=Atlantic Ocean",
            "Indian=Indian Ocean, Mediterranean=Mediterranean Sea",
            "Arctic=Arctic Ocean, Caribbean=Caribbean Sea, Dead Sea, Red Sea, Black Sea",
            "Southern=Southern Ocean=Antarctic Ocean, North Sea, Baltic=Baltic Sea, Caspian=Caspian Sea, Arabian Sea, South China Sea",
            "Aegean=Aegean Sea, Adriatic=Adriatic Sea, Bering Sea, Coral Sea, Tasman Sea, Sea of Japan, Irish Sea, Yellow Sea, Ionian Sea, Barents Sea, Sargasso Sea, Aral Sea, Sea of Galilee, Timor Sea, Celtic Sea, Andaman Sea, Labrador Sea, Beaufort Sea, Tyrrhenian Sea, Sea of Okhotsk, East China Sea, Philippine Sea, Java Sea, Norwegian Sea, Weddell Sea, Ross Sea"
        ]),
        RarePrompt("Name a US state", [
            "California, Texas, New York, Florida",
            "Hawaii, Alaska, Washington, Nevada, Colorado",
            "Arizona, Illinois, Ohio, Georgia, Michigan, Virginia, Oregon, New Jersey, Massachusetts, Pennsylvania",
            "Utah, Tennessee, Kentucky, Louisiana, Minnesota, Wisconsin, Indiana, Missouri, North Carolina, South Carolina, Maryland, Montana, Kansas, Oklahoma, Alabama, Mississippi, Maine, New Mexico, Iowa, Idaho",
            "Delaware, Rhode Island, Vermont, New Hampshire, Connecticut, West Virginia, Wyoming, Nebraska, North Dakota, South Dakota, Arkansas"
        ]),
        RarePrompt("Name a country in South America", [
            "Brazil, Argentina",
            "Peru, Chile, Colombia",
            "Venezuela, Ecuador",
            "Bolivia, Uruguay, Paraguay",
            "Guyana, Suriname"
        ]),
        RarePrompt("Name a dog breed", [
            "Labrador=Labrador retriever=Lab, German shepherd=Alsatian, Poodle",
            "Golden retriever, Bulldog, Beagle, Chihuahua, Husky=Siberian husky, Pug",
            "Dalmatian, Rottweiler, Dachshund=Sausage dog, Boxer, Border collie=Collie, Great Dane, Corgi, Doberman, Shih tzu, Yorkshire terrier=Yorkie, Greyhound, Pit bull=Pitbull, French bulldog=Frenchie, Cocker spaniel=Spaniel",
            "St Bernard, Pomeranian, Maltese, Jack Russell=Jack Russell terrier, Schnauzer, Akita, Shiba inu, Bichon frise, Basset hound, Bloodhound, Whippet, Newfoundland, Mastiff, Samoyed, Chow chow, Boston terrier, Cavalier King Charles spaniel, Australian shepherd, Bernese mountain dog, Malamute=Alaskan malamute, Weimaraner, Vizsla, Pointer, Irish setter=Setter, Old English sheepdog=Sheepdog, West Highland terrier=Westie, Scottish terrier=Scottie",
            "Saluki, Borzoi, Basenji, Komondor, Papillon, Lhasa apso, Pekingese, Affenpinscher, Keeshond, Leonberger, Xoloitzcuintli=Xolo, Rhodesian ridgeback, Irish wolfhound, Afghan hound, Airedale terrier=Airedale, Shar pei, Havanese, Puli, Kelpie, Great Pyrenees, Cane corso, Belgian malinois=Malinois"
        ]),
        RarePrompt("Name a bone in the human body", [
            "Skull, Rib=Ribs, Spine=Backbone",
            "Femur=Thigh bone, Kneecap=Patella, Jaw=Jawbone=Mandible",
            "Tibia=Shin bone, Collarbone=Clavicle, Pelvis=Hip bone, Humerus",
            "Fibula, Radius, Ulna, Shoulder blade=Scapula, Sternum=Breastbone, Vertebra=Vertebrae, Tailbone=Coccyx",
            "Stapes=Stirrup, Hyoid, Sacrum, Phalanges=Phalanx, Metacarpals=Metacarpal, Metatarsals=Metatarsal, Carpals=Carpal, Tarsals=Tarsal, Talus, Calcaneus=Heel bone, Scaphoid, Incus=Anvil, Malleus=Hammer, Maxilla, Cheekbone=Zygomatic, Atlas"
        ]),
        RarePrompt("Name a currency", [
            "Dollar=US dollar, Euro",
            "Pound=Pound sterling, Yen",
            "Peso, Rupee, Franc=Swiss franc, Yuan=Renminbi",
            "Ruble=Rouble, Won, Krona=Krone=Kroner=Kronor, Dinar, Rand, Real, Lira, Dirham, Shekel, Baht",
            "Zloty, Forint, Ringgit, Rupiah, Dong, Riyal=Rial, Koruna, Leu, Lev, Hryvnia, Taka, Kwacha, Naira, Shilling, Birr, Cedi, Tenge, Lari, Dram, Manat, Som, Kyat, Kip, Riel, Tugrik, Sol, Bolivar, Guarani, Quetzal, Lempira, Colon, Gourde, Pula, Metical, Kwanza, Dalasi, Ariary"
        ]),
        RarePrompt("Name a pasta shape", [
            "Spaghetti, Penne, Macaroni",
            "Lasagne=Lasagna, Fusilli, Ravioli",
            "Linguine, Fettuccine, Tagliatelle, Farfalle=Bow tie=Bowtie, Rigatoni, Tortellini",
            "Orzo, Cannelloni, Conchiglie=Shells, Rotini, Ziti, Angel hair=Capellini, Pappardelle, Orecchiette, Vermicelli",
            "Bucatini, Cavatappi, Gemelli, Ditalini, Radiatori, Campanelle, Strozzapreti, Paccheri, Trofie, Casarecce, Mafaldine, Tortelloni, Manicotti, Cavatelli, Stelline, Anelli, Rotelle, Agnolotti, Tagliolini"
        ]),
        RarePrompt("Name a play by Shakespeare", [
            "Romeo and Juliet, Hamlet",
            "Macbeth, A Midsummer Night's Dream=Midsummer Night's Dream",
            "Othello, King Lear, The Tempest, Julius Caesar",
            "Twelfth Night, Much Ado About Nothing, The Merchant of Venice, The Taming of the Shrew, As You Like It, Richard III, Henry V, Antony and Cleopatra",
            "Coriolanus, Cymbeline, Pericles, Timon of Athens, Titus Andronicus, Troilus and Cressida, The Winter's Tale, Measure for Measure, All's Well That Ends Well, The Comedy of Errors, Love's Labour's Lost, The Two Gentlemen of Verona, The Merry Wives of Windsor, Richard II, King John, Henry VIII, Henry IV, Henry VI"
        ]),
        RarePrompt("Name a gemstone", [
            "Diamond, Ruby",
            "Emerald, Sapphire",
            "Pearl, Opal, Amethyst",
            "Topaz, Jade, Garnet, Turquoise, Amber, Aquamarine",
            "Peridot, Citrine, Tanzanite, Moonstone, Onyx, Tourmaline, Zircon, Lapis lazuli=Lapis, Alexandrite, Spinel, Agate, Jasper, Malachite, Obsidian, Morganite, Beryl, Quartz=Rose quartz, Tiger's eye, Carnelian, Bloodstone, Sunstone, Iolite, Kunzite, Jet"
        ]),
        RarePrompt("Name a herb or spice", [
            "Pepper=Black pepper, Basil, Cinnamon",
            "Oregano, Parsley, Mint, Ginger",
            "Thyme, Rosemary, Paprika, Cumin, Chili=Chilli=Chili powder, Coriander=Cilantro, Turmeric",
            "Nutmeg, Sage, Dill, Cloves=Clove, Saffron, Vanilla, Bay leaf=Bay leaves=Bay, Chives, Cardamom, Cayenne, Curry powder=Curry, Mustard seed=Mustard, Tarragon",
            "Fennel seed=Fennel, Star anise=Anise=Aniseed, Sumac, Marjoram, Fenugreek, Allspice, Caraway, Lemongrass, Juniper, Mace, Lovage, Savory, Chervil, Za'atar=Zaatar, Nigella, Asafoetida, Galangal, Wasabi, Horseradish, Lavender, Sorrel"
        ]),
        RarePrompt("Name a kind of tree", [
            "Oak, Pine, Palm",
            "Maple, Apple=Apple tree, Willow, Birch",
            "Fir, Cedar, Elm, Cherry=Cherry blossom, Redwood=Sequoia, Spruce, Ash",
            "Beech, Sycamore, Cypress, Chestnut, Walnut, Olive, Poplar, Eucalyptus, Baobab, Magnolia, Aspen, Hazel, Holly, Yew, Banyan, Mahogany, Teak, Lemon, Orange, Fig, Coconut",
            "Larch, Alder, Hornbeam, Hawthorn, Rowan, Linden=Lime, Juniper, Hickory, Ginkgo, Acacia, Monkey puzzle, Jacaranda, Hemlock, Tamarack, Mangrove, Ebony, Balsa, Sassafras, Dogwood, Mulberry, London plane=Plane, Elder, Cottonwood, Kapok, Kauri"
        ]),
        RarePrompt("Name a country in Africa", [
            "South Africa, Egypt, Nigeria",
            "Kenya, Morocco, Ethiopia, Ghana",
            "Tanzania, Uganda, Algeria, Madagascar, Zimbabwe, Sudan, Tunisia, Libya, Somalia, Senegal",
            "Angola, Cameroon, Ivory Coast=Cote d'Ivoire, Mali, Zambia, Mozambique, Namibia, Botswana, Rwanda, DR Congo=Democratic Republic of the Congo=DRC=Congo, Niger, Chad, Liberia, Sierra Leone, South Sudan, Malawi, Mauritius, Seychelles",
            "Burkina Faso, Benin, Togo, Gabon, Guinea, Guinea-Bissau, Equatorial Guinea, Eritrea, Djibouti, Burundi, Lesotho, Eswatini=Swaziland, Gambia=The Gambia, Mauritania, Central African Republic, Republic of the Congo=Congo Brazzaville, Cape Verde=Cabo Verde, Comoros, Sao Tome and Principe=Sao Tome"
        ]),
        RarePrompt("Name a card game", [
            "Poker, Solitaire=Patience, Go Fish, Blackjack=Twenty-one",
            "Snap, Rummy=Gin rummy=Gin, Hearts, War",
            "Bridge, Crazy Eights, Spades, Old Maid, Cribbage",
            "Whist, Canasta, Baccarat, Euchre, Pinochle, Texas hold'em=Hold'em, Speed=Spit, Cheat=I doubt it, Slapjack, Pontoon",
            "Piquet, Skat, Bezique, Briscola, Scopa, Durak, Klondike, FreeCell, Spider, Belote, Oh Hell, Pitch, President, Egyptian Rat Screw, Big Two, Mau-Mau, Sheepshead, Five Hundred, Napoleon=Nap, Faro, Tute"
        ])
    ]
}
