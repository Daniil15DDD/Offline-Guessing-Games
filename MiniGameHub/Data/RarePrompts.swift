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
        RarePrompt("Name a country in Europe", [
            "France, Germany, Italy, Spain, United Kingdom=UK=Britain=Great Britain=England",
            "Portugal, Greece, Netherlands=Holland, Ireland, Sweden, Switzerland, Poland, Russia",
            "Norway, Denmark, Belgium, Austria, Finland, Ukraine, Turkey=Turkiye, Iceland, Croatia, Czechia=Czech Republic, Hungary, Romania",
            "Bulgaria, Serbia, Slovakia, Slovenia, Lithuania, Latvia, Estonia, Belarus, Albania, Luxembourg, Malta, Cyprus, Monaco, Bosnia and Herzegovina=Bosnia",
            "Moldova, North Macedonia=Macedonia, Montenegro, Kosovo, Andorra, Liechtenstein, San Marino, Vatican City=Vatican, Georgia, Armenia, Azerbaijan, Kazakhstan"
        ]),
        RarePrompt("Name a country in Asia", [
            "China, Japan, India",
            "South Korea=Korea, Thailand, Vietnam, Indonesia, Philippines, Pakistan",
            "Malaysia, Singapore, Nepal, Bangladesh, Sri Lanka, Iran, Iraq, Saudi Arabia, Turkey=Turkiye, Israel, North Korea, Mongolia, Afghanistan",
            "Cambodia, Laos, Myanmar=Burma, Kazakhstan, Uzbekistan, Qatar, United Arab Emirates=UAE, Kuwait, Jordan, Lebanon, Syria, Yemen, Oman, Bhutan, Maldives, Taiwan",
            "Kyrgyzstan, Tajikistan, Turkmenistan, Brunei, Timor-Leste=East Timor, Bahrain, Armenia, Azerbaijan, Georgia, Cyprus, Palestine"
        ]),
        RarePrompt("Name a sign of the zodiac", [
            "Leo, Aries",
            "Scorpio, Gemini, Taurus",
            "Virgo, Cancer, Pisces",
            "Libra, Aquarius",
            "Sagittarius, Capricorn"
        ]),
        RarePrompt("Name a breed of cat", [
            "Siamese, Persian",
            "Maine Coon, Bengal, Sphynx, Ragdoll",
            "British Shorthair, Russian Blue, Scottish Fold",
            "Abyssinian, Burmese, Birman, Norwegian Forest=Norwegian Forest Cat, Siberian, Manx, Savannah, Himalayan, American Shorthair",
            "Devon Rex, Cornish Rex, Oriental Shorthair=Oriental, Exotic Shorthair, Tonkinese, Turkish Angora, Turkish Van, Balinese, Bombay, Chartreux, Egyptian Mau, Ocicat, Munchkin, Somali, Korat, Singapura, Burmilla, Ragamuffin, Selkirk Rex, LaPerm, Toyger, Peterbald"
        ]),
        RarePrompt("Name a type of cheese", [
            "Cheddar, Mozzarella",
            "Brie, Parmesan=Parmigiano, Swiss=Emmental=Emmentaler, Feta",
            "Gouda, Camembert, Blue cheese=Blue, Cream cheese, Goat cheese=Chevre, Ricotta, Cottage cheese",
            "Halloumi, Gruyere, Provolone, Edam, Stilton, Gorgonzola, Roquefort, Mascarpone, Monterey Jack=Jack, Colby, Manchego, Pecorino, Paneer, Havarti",
            "Wensleydale, Red Leicester, Double Gloucester, Caerphilly, Cheshire, Lancashire, Jarlsberg, Munster=Muenster, Taleggio, Fontina, Asiago, Burrata, Raclette, Comte, Reblochon, Limburger, Cotija, Queso fresco, Oaxaca, Port Salut, Epoisses, Morbier, Tilsit, Brunost=Gjetost, Quark, Labneh, Kefalotyri"
        ]),
        RarePrompt("Name an insect", [
            "Ant, Bee=Honeybee, Fly=Housefly",
            "Butterfly, Mosquito, Wasp, Ladybug=Ladybird",
            "Beetle, Grasshopper, Moth, Cricket, Dragonfly, Cockroach=Roach",
            "Flea, Termite, Hornet, Caterpillar, Firefly=Lightning bug, Praying mantis=Mantis, Bumblebee, Locust, Cicada, Earwig, Aphid, Gnat, Stick insect",
            "Weevil, Mayfly, Lacewing, Damselfly, Stink bug=Shield bug, Midge, Louse=Lice, Bedbug=Bed bug, Silverfish, Horsefly, Scarab, Stag beetle, Dung beetle, Katydid, Water strider=Pond skater, Thrips, Leafhopper, Crane fly=Daddy longlegs, Sawfly, Glowworm=Glow worm"
        ]),
        RarePrompt("Name a bird", [
            "Eagle, Robin, Pigeon, Sparrow",
            "Owl, Parrot, Duck, Crow, Penguin, Seagull=Gull, Chicken=Hen",
            "Swan, Hawk, Flamingo, Blue jay=Jay, Cardinal, Hummingbird, Peacock=Peafowl, Ostrich, Goose, Turkey, Woodpecker, Falcon, Dove, Raven",
            "Pelican, Heron, Stork, Kingfisher, Magpie, Blackbird, Starling, Swallow, Finch, Wren, Canary, Toucan, Vulture, Emu, Crane, Puffin, Albatross, Cuckoo, Kiwi, Macaw, Cockatoo, Budgie=Budgerigar=Parakeet, Quail, Pheasant",
            "Osprey, Kestrel, Condor, Ibis, Egret, Cormorant, Lapwing, Nightingale, Thrush, Skylark=Lark, Swift, Nuthatch, Chickadee, Oriole, Tanager, Warbler, Bittern, Grouse, Partridge, Curlew, Plover, Sandpiper, Avocet, Gannet, Tern, Petrel, Loon, Grebe, Kookaburra, Cassowary, Rhea, Roadrunner, Hoopoe, Shoebill, Secretary bird, Kea, Kakapo, Bee-eater, Waxwing, Goldfinch, Chaffinch, Bullfinch, Dunnock, Jackdaw, Rook, Mockingbird, Whippoorwill"
        ]),
        RarePrompt("Name a flower", [
            "Rose, Daisy, Tulip, Sunflower",
            "Lily, Daffodil, Orchid, Dandelion",
            "Carnation, Poppy, Lavender, Violet, Iris, Marigold, Pansy, Lilac, Hibiscus, Jasmine, Buttercup, Bluebell",
            "Peony, Hydrangea, Chrysanthemum=Mum, Geranium, Begonia, Petunia, Magnolia, Snowdrop, Crocus, Hyacinth, Foxglove, Primrose, Azalea, Camellia, Gardenia, Lotus, Forget-me-not, Sweet pea, Dahlia, Zinnia, Honeysuckle",
            "Anemone, Aster, Freesia, Gladiolus, Delphinium, Lupin=Lupine, Snapdragon, Hollyhock, Nasturtium, Ranunculus, Columbine=Aquilegia, Amaryllis, Bougainvillea, Clematis, Wisteria, Edelweiss, Protea, Heather, Cornflower, Cosmos, Verbena, Lobelia, Gerbera, Hellebore, Cyclamen, Fuchsia, Baby's breath=Gypsophila, Larkspur, Periwinkle, Yarrow, Rhododendron, Oleander, Frangipani=Plumeria, Bird of paradise"
        ]),
        RarePrompt("Name a Greek god or goddess", [
            "Zeus, Poseidon",
            "Athena, Hades, Apollo, Aphrodite",
            "Ares, Hera, Hermes, Artemis",
            "Demeter, Dionysus, Hephaestus, Persephone, Eros, Hestia",
            "Nike, Pan, Helios, Selene, Eos, Hecate, Hypnos, Thanatos, Nemesis, Iris, Tyche, Morpheus, Asclepius, Gaia, Uranus, Cronus=Kronos, Rhea, Nyx, Eris, Hebe, Aeolus, Boreas, Atlas, Prometheus"
        ]),
        RarePrompt("Name an Olympic sport", [
            "Swimming, Athletics=Track and field=Track=Running, Gymnastics",
            "Football=Soccer, Basketball, Tennis, Boxing, Cycling",
            "Volleyball, Diving, Rowing, Weightlifting, Wrestling, Judo, Fencing, Archery, Golf, Skiing=Alpine skiing, Ice hockey=Hockey, Figure skating",
            "Table tennis=Ping pong, Badminton, Sailing, Shooting, Taekwondo, Rugby=Rugby sevens, Handball, Water polo, Equestrian=Horse riding, Triathlon, Surfing, Skateboarding, Snowboarding, Curling, Speed skating, Bobsleigh=Bobsled, Field hockey",
            "Canoeing=Canoe=Kayaking, Modern pentathlon=Pentathlon, Sport climbing=Climbing, Artistic swimming=Synchronised swimming=Synchronized swimming, Trampoline=Trampolining, BMX, Breaking=Breakdancing, Luge, Skeleton, Biathlon, Nordic combined, Ski jumping, Cross-country skiing, Marathon swimming, Beach volleyball, Rhythmic gymnastics, Short track=Short track speed skating, Freestyle skiing, Mountain biking, Karate, Baseball, Softball"
        ]),
        RarePrompt("Name a metal", [
            "Gold, Silver, Iron",
            "Copper, Steel, Aluminium=Aluminum",
            "Bronze, Lead, Tin, Zinc, Titanium, Platinum, Nickel, Brass",
            "Mercury, Tungsten, Magnesium, Chromium=Chrome, Cobalt, Lithium, Sodium, Potassium, Calcium, Uranium, Pewter",
            "Palladium, Rhodium, Iridium, Osmium, Manganese, Vanadium, Molybdenum, Zirconium, Bismuth, Gallium, Indium, Cadmium, Barium, Beryllium, Caesium=Cesium, Rubidium, Strontium, Thallium, Tantalum, Niobium, Hafnium, Rhenium, Ruthenium, Scandium, Yttrium, Plutonium, Thorium, Radium, Electrum, Solder, Nichrome"
        ]),
        RarePrompt("Name a capital city in Asia", [
            "Tokyo, Beijing",
            "Seoul, Bangkok, New Delhi=Delhi",
            "Singapore, Manila, Jakarta, Hanoi, Kuala Lumpur, Baghdad, Tehran, Kabul",
            "Islamabad, Dhaka, Kathmandu, Colombo, Riyadh, Doha, Abu Dhabi, Jerusalem, Damascus, Beirut, Amman, Ankara, Pyongyang, Taipei, Phnom Penh, Ulaanbaatar=Ulan Bator",
            "Vientiane, Naypyidaw=Naypyitaw, Thimphu, Male, Muscat, Manama, Kuwait City, Sanaa, Tashkent, Astana, Bishkek, Dushanbe, Ashgabat, Baku, Yerevan, Tbilisi, Dili, Bandar Seri Begawan, Nicosia"
        ]),
        RarePrompt("Name a kitchen tool", [
            "Knife, Fork, Spoon",
            "Spatula, Whisk, Frying pan=Pan, Saucepan=Pot",
            "Ladle, Tongs, Peeler, Grater, Colander=Strainer, Chopping board=Cutting board, Can opener=Tin opener, Rolling pin",
            "Sieve, Corkscrew, Measuring cup=Measuring jug, Garlic press, Potato masher=Masher, Bottle opener, Kettle, Wok, Chopsticks, Kitchen scissors=Scissors, Timer, Funnel, Skewer",
            "Zester, Mandoline, Pestle and mortar=Pestle=Mortar, Baster, Mezzaluna, Melon baller, Pastry brush, Dough scraper=Bench scraper, Potato ricer=Ricer, Nutcracker, Egg slicer, Apple corer=Corer, Cleaver, Skimmer, Spurtle, Meat tenderiser=Meat tenderizer=Mallet, Thermometer, Piping bag, Trivet, Salad spinner"
        ]),
        RarePrompt("Name a US president", [
            "George Washington=Washington, Abraham Lincoln=Lincoln",
            "Barack Obama=Obama, Donald Trump=Trump, Joe Biden=Biden, John F. Kennedy=Kennedy=JFK, Franklin Roosevelt=Roosevelt=FDR=Franklin D. Roosevelt",
            "Thomas Jefferson=Jefferson, Ronald Reagan=Reagan, Bill Clinton=Clinton, George W. Bush=Bush, Richard Nixon=Nixon, Theodore Roosevelt=Teddy Roosevelt, John Adams=Adams",
            "George H. W. Bush=Bush senior, Jimmy Carter=Carter, Dwight Eisenhower=Eisenhower, Harry Truman=Truman, Lyndon Johnson=LBJ=Lyndon B. Johnson, Gerald Ford=Ford, Woodrow Wilson=Wilson, Ulysses Grant=Grant=Ulysses S. Grant, Andrew Jackson=Jackson, James Madison=Madison, James Monroe=Monroe, John Quincy Adams=Quincy Adams",
            "Millard Fillmore=Fillmore, Franklin Pierce=Pierce, John Tyler=Tyler, James Polk=Polk=James K. Polk, Zachary Taylor=Taylor, James Buchanan=Buchanan, Rutherford Hayes=Hayes=Rutherford B. Hayes, James Garfield=Garfield, Chester Arthur=Arthur=Chester A. Arthur, Benjamin Harrison, William Henry Harrison, Grover Cleveland=Cleveland, William McKinley=McKinley, William Taft=Taft=William Howard Taft, Warren Harding=Harding=Warren G. Harding, Calvin Coolidge=Coolidge, Herbert Hoover=Hoover, Martin Van Buren=Van Buren, Andrew Johnson"
        ]),
        RarePrompt("Name a continent", [
            "Africa, Asia",
            "Europe, North America=America",
            "South America, Australia=Oceania=Australasia",
            "",
            "Antarctica"
        ]),
        RarePrompt("Name a noble gas", [
            "Helium, Neon",
            "",
            "Argon",
            "Krypton, Radon",
            "Xenon, Oganesson"
        ]),
        RarePrompt("Name a river", [
            "Nile, Amazon",
            "Mississippi, Thames",
            "Danube, Rhine, Seine, Ganges, Yangtze, Colorado, Congo, Missouri",
            "Volga, Mekong, Euphrates, Tigris, Indus, Hudson, Zambezi, Niger, Jordan, Tiber, Rio Grande, Yellow River=Yellow=Huang He, Ohio, Columbia, Yukon, Murray, Loire, Elbe, Severn, Po, Rhone, Tagus, Ebro, Orinoco, Parana",
            "Dnieper, Don, Vistula, Oder, Douro, Garonne, Shannon, Clyde, Tyne, Mersey, Trent, Ob, Lena, Yenisei, Amur, Irrawaddy, Brahmaputra, Salween, Limpopo, Orange, Senegal, Okavango, Darling, Mackenzie, St Lawrence=Saint Lawrence, Snake, Platte, Arkansas, Tennessee, Potomac, Delaware, Susquehanna, Sacramento, Fraser, Magdalena, Uruguay, Paraguay, Tocantins, Madeira, Ural, Kama, Dniester, Pechora, Tarim, Helmand, Amu Darya, Syr Darya"
        ]),
        RarePrompt("Name a desert", [
            "Sahara",
            "Gobi, Mojave",
            "Kalahari, Arabian, Atacama",
            "Namib, Sonoran, Antarctic=Antarctica, Great Victoria, Thar, Negev",
            "Taklamakan, Karakum, Kyzylkum, Chihuahuan, Great Basin, Patagonian, Syrian, Nubian, Libyan, Simpson, Gibson, Great Sandy, Tanami, Dasht-e Kavir, Dasht-e Lut=Lut, Sinai, Danakil, Painted, Black Rock"
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
