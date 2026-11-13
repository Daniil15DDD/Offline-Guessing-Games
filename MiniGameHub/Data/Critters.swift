import Foundation

struct Critter: Identifiable, Equatable {
    let id: Int
    let name: String
    let group: String      // Mammal, Bird, Reptile, Amphibian, Fish, Invertebrate
    let diet: String       // Herbivore, Carnivore, Omnivore
    let home: String       // Land, Water, Both
    let legs: Int
    let regions: [String]  // where it lives in the wild
    let weightKg: Double   // typical adult
    /// Name of the picture in the asset catalog.
    let art: String
}

/// Animals for Critter Clues. Weights are typical adult figures, rounded.
enum Critters {
    static let all: [Critter] = rows.enumerated().map { index, row in
        Critter(
            id: index,
            name: row.0,
            group: row.1,
            diet: row.2,
            home: row.3,
            legs: row.4,
            regions: row.5.components(separatedBy: ", "),
            weightKg: row.6,
            art: row.7
        )
    }

    private static let rows: [(String, String, String, String, Int, String, Double, String)] = [
        ("African elephant", "Mammal", "Herbivore", "Land", 4, "Africa", 6000, "a_elephant"),
        ("Lion", "Mammal", "Carnivore", "Land", 4, "Africa, Asia", 190, "a_lion"),
        ("Tiger", "Mammal", "Carnivore", "Land", 4, "Asia", 220, "a_tiger"),
        ("Leopard", "Mammal", "Carnivore", "Land", 4, "Africa, Asia", 60, "a_leopard"),
        ("Giraffe", "Mammal", "Herbivore", "Land", 4, "Africa", 1200, "a_giraffe"),
        ("Zebra", "Mammal", "Herbivore", "Land", 4, "Africa", 350, "a_zebra"),
        ("White rhinoceros", "Mammal", "Herbivore", "Land", 4, "Africa", 2000, "a_rhino"),
        ("Hippopotamus", "Mammal", "Herbivore", "Both", 4, "Africa", 1500, "a_hippo"),
        ("Gorilla", "Mammal", "Herbivore", "Land", 2, "Africa", 160, "a_gorilla"),
        ("Giant panda", "Mammal", "Herbivore", "Land", 4, "Asia", 100, "a_panda"),
        ("Polar bear", "Mammal", "Carnivore", "Both", 4, "North America, Europe, Asia", 450, "a_polarbear"),
        ("Brown bear", "Mammal", "Omnivore", "Land", 4, "North America, Europe, Asia", 300, "a_bear"),
        ("Gray wolf", "Mammal", "Carnivore", "Land", 4, "North America, Europe, Asia", 40, "a_wolf"),
        ("Red fox", "Mammal", "Omnivore", "Land", 4, "North America, Europe, Asia", 6, "a_fox"),
        ("Moose", "Mammal", "Herbivore", "Land", 4, "North America, Europe, Asia", 450, "a_moose"),
        ("American bison", "Mammal", "Herbivore", "Land", 4, "North America", 700, "a_bison"),
        ("Bighorn sheep", "Mammal", "Herbivore", "Land", 4, "North America", 90, "a_ram"),
        ("Raccoon", "Mammal", "Omnivore", "Land", 4, "North America", 7, "a_raccoon"),
        ("Striped skunk", "Mammal", "Omnivore", "Land", 4, "North America", 3, "a_skunk"),
        ("North American beaver", "Mammal", "Herbivore", "Both", 4, "North America", 20, "a_beaver"),
        ("Red kangaroo", "Mammal", "Herbivore", "Land", 2, "Oceania", 60, "a_kangaroo"),
        ("Koala", "Mammal", "Herbivore", "Land", 4, "Oceania", 10, "a_koala"),
        ("Dromedary camel", "Mammal", "Herbivore", "Land", 4, "Africa, Asia", 500, "a_camel"),
        ("Water buffalo", "Mammal", "Herbivore", "Land", 4, "Asia", 900, "a_buffalo"),
        ("Llama", "Mammal", "Herbivore", "Land", 4, "South America", 130, "a_llama"),
        ("Sloth", "Mammal", "Herbivore", "Land", 4, "South America, North America", 5, "a_sloth"),
        ("Red deer", "Mammal", "Herbivore", "Land", 4, "Europe, Asia", 160, "a_deer"),
        ("Wild boar", "Mammal", "Omnivore", "Land", 4, "Europe, Asia", 90, "a_boar"),
        ("European badger", "Mammal", "Omnivore", "Land", 4, "Europe, Asia", 10, "a_badger"),
        ("European hedgehog", "Mammal", "Omnivore", "Land", 4, "Europe", 0.8, "a_hedgehog"),
        ("European rabbit", "Mammal", "Herbivore", "Land", 4, "Europe", 1.8, "a_rabbit"),
        ("Harbor seal", "Mammal", "Carnivore", "Both", 4, "North America, Europe, Asia", 85, "a_seal"),
        ("Sea otter", "Mammal", "Carnivore", "Both", 4, "North America, Asia", 30, "a_otter"),
        ("Blue whale", "Mammal", "Carnivore", "Water", 0, "Oceans", 120000, "a_whale"),
        ("Bottlenose dolphin", "Mammal", "Carnivore", "Water", 0, "Oceans", 200, "a_dolphin"),
        ("Bald eagle", "Bird", "Carnivore", "Land", 2, "North America", 5, "a_eagle"),
        ("Wild turkey", "Bird", "Omnivore", "Land", 2, "North America", 7, "a_turkey"),
        ("Snowy owl", "Bird", "Carnivore", "Land", 2, "North America, Europe, Asia", 2, "a_owl"),
        ("Mallard duck", "Bird", "Omnivore", "Both", 2, "North America, Europe, Asia", 1.1, "a_duck"),
        ("Emperor penguin", "Bird", "Carnivore", "Both", 2, "Antarctica", 30, "a_penguin"),
        ("Indian peafowl", "Bird", "Omnivore", "Land", 2, "Asia", 5, "a_peacock"),
        ("Scarlet macaw", "Bird", "Herbivore", "Land", 2, "South America, North America", 1, "a_parrot"),
        ("Mute swan", "Bird", "Herbivore", "Both", 2, "Europe, Asia", 11, "a_swan"),
        ("Greater flamingo", "Bird", "Omnivore", "Both", 2, "Africa, Asia, Europe", 3, "a_flamingo"),
        ("Nile crocodile", "Reptile", "Carnivore", "Both", 4, "Africa", 400, "a_crocodile"),
        ("Komodo dragon", "Reptile", "Carnivore", "Land", 4, "Asia", 70, "a_lizard"),
        ("King cobra", "Reptile", "Carnivore", "Land", 0, "Asia", 6, "a_snake"),
        ("Green sea turtle", "Reptile", "Herbivore", "Water", 4, "Oceans", 150, "a_turtle"),
        ("Poison dart frog", "Amphibian", "Carnivore", "Land", 4, "South America, North America", 0.005, "a_frog"),
        ("Great white shark", "Fish", "Carnivore", "Water", 0, "Oceans", 1000, "a_shark"),
        ("Atlantic salmon", "Fish", "Carnivore", "Water", 0, "Oceans", 5, "a_fish"),
        ("Clownfish", "Fish", "Omnivore", "Water", 0, "Oceans", 0.03, "a_tropical"),
        ("Giant Pacific octopus", "Invertebrate", "Carnivore", "Water", 8, "Oceans", 30, "a_octopus"),
        ("American lobster", "Invertebrate", "Carnivore", "Water", 10, "Oceans", 1, "a_lobster"),
        ("Honeybee", "Invertebrate", "Herbivore", "Land", 6, "Europe, Africa, Asia", 0.0001, "a_bee"),
        ("Monarch butterfly", "Invertebrate", "Herbivore", "Land", 6, "North America", 0.0005, "a_butterfly"),
        ("Goliath birdeater spider", "Invertebrate", "Carnivore", "Land", 8, "South America", 0.15, "a_spider"),
        ("Emperor scorpion", "Invertebrate", "Carnivore", "Land", 8, "Africa", 0.03, "a_scorpion"),
        ("Garden snail", "Invertebrate", "Herbivore", "Land", 0, "Europe", 0.01, "a_snail")
    ]
}
