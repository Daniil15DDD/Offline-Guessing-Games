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
            weightKg: row.6
        )
    }

    private static let rows: [(String, String, String, String, Int, String, Double)] = [
        ("African elephant", "Mammal", "Herbivore", "Land", 4, "Africa", 6000),
        ("Lion", "Mammal", "Carnivore", "Land", 4, "Africa, Asia", 190),
        ("Tiger", "Mammal", "Carnivore", "Land", 4, "Asia", 220),
        ("Cheetah", "Mammal", "Carnivore", "Land", 4, "Africa, Asia", 50),
        ("Snow leopard", "Mammal", "Carnivore", "Land", 4, "Asia", 45),
        ("Jaguar", "Mammal", "Carnivore", "Land", 4, "South America, North America", 80),
        ("Giraffe", "Mammal", "Herbivore", "Land", 4, "Africa", 1200),
        ("Zebra", "Mammal", "Herbivore", "Land", 4, "Africa", 350),
        ("White rhinoceros", "Mammal", "Herbivore", "Land", 4, "Africa", 2000),
        ("Hippopotamus", "Mammal", "Herbivore", "Both", 4, "Africa", 1500),
        ("Gorilla", "Mammal", "Herbivore", "Land", 2, "Africa", 160),
        ("Chimpanzee", "Mammal", "Omnivore", "Land", 2, "Africa", 50),
        ("Giant panda", "Mammal", "Herbivore", "Land", 4, "Asia", 100),
        ("Red panda", "Mammal", "Herbivore", "Land", 4, "Asia", 5),
        ("Polar bear", "Mammal", "Carnivore", "Both", 4, "North America, Europe, Asia", 450),
        ("Brown bear", "Mammal", "Omnivore", "Land", 4, "North America, Europe, Asia", 300),
        ("Gray wolf", "Mammal", "Carnivore", "Land", 4, "North America, Europe, Asia", 40),
        ("Red fox", "Mammal", "Omnivore", "Land", 4, "North America, Europe, Asia", 6),
        ("Moose", "Mammal", "Herbivore", "Land", 4, "North America, Europe, Asia", 450),
        ("American bison", "Mammal", "Herbivore", "Land", 4, "North America", 700),
        ("Raccoon", "Mammal", "Omnivore", "Land", 4, "North America", 7),
        ("Red kangaroo", "Mammal", "Herbivore", "Land", 2, "Oceania", 60),
        ("Koala", "Mammal", "Herbivore", "Land", 4, "Oceania", 10),
        ("Platypus", "Mammal", "Carnivore", "Both", 4, "Oceania", 1.5),
        ("Tasmanian devil", "Mammal", "Carnivore", "Land", 4, "Oceania", 8),
        ("Dromedary camel", "Mammal", "Herbivore", "Land", 4, "Africa, Asia", 500),
        ("Llama", "Mammal", "Herbivore", "Land", 4, "South America", 130),
        ("Sloth", "Mammal", "Herbivore", "Land", 4, "South America, North America", 5),
        ("Capybara", "Mammal", "Herbivore", "Both", 4, "South America", 50),
        ("Walrus", "Mammal", "Carnivore", "Both", 4, "North America, Europe, Asia", 1000),
        ("Sea otter", "Mammal", "Carnivore", "Both", 4, "North America, Asia", 30),
        ("Blue whale", "Mammal", "Carnivore", "Water", 0, "Oceans", 120000),
        ("Orca", "Mammal", "Carnivore", "Water", 0, "Oceans", 4000),
        ("Bottlenose dolphin", "Mammal", "Carnivore", "Water", 0, "Oceans", 200),
        ("Bald eagle", "Bird", "Carnivore", "Land", 2, "North America", 5),
        ("Snowy owl", "Bird", "Carnivore", "Land", 2, "North America, Europe, Asia", 2),
        ("Emperor penguin", "Bird", "Carnivore", "Both", 2, "Antarctica", 30),
        ("Ostrich", "Bird", "Omnivore", "Land", 2, "Africa", 110),
        ("Emu", "Bird", "Omnivore", "Land", 2, "Oceania", 40),
        ("Kiwi", "Bird", "Omnivore", "Land", 2, "Oceania", 2.5),
        ("Indian peafowl", "Bird", "Omnivore", "Land", 2, "Asia", 5),
        ("Toco toucan", "Bird", "Omnivore", "Land", 2, "South America", 0.6),
        ("Scarlet macaw", "Bird", "Herbivore", "Land", 2, "South America, North America", 1),
        ("Mute swan", "Bird", "Herbivore", "Both", 2, "Europe, Asia", 11),
        ("Nile crocodile", "Reptile", "Carnivore", "Both", 4, "Africa", 400),
        ("American alligator", "Reptile", "Carnivore", "Both", 4, "North America", 250),
        ("Komodo dragon", "Reptile", "Carnivore", "Land", 4, "Asia", 70),
        ("King cobra", "Reptile", "Carnivore", "Land", 0, "Asia", 6),
        ("Green anaconda", "Reptile", "Carnivore", "Both", 0, "South America", 60),
        ("Green sea turtle", "Reptile", "Herbivore", "Water", 4, "Oceans", 150),
        ("Galapagos tortoise", "Reptile", "Herbivore", "Land", 4, "South America", 200),
        ("Panther chameleon", "Reptile", "Carnivore", "Land", 4, "Africa", 0.15),
        ("Poison dart frog", "Amphibian", "Carnivore", "Land", 4, "South America, North America", 0.005),
        ("Axolotl", "Amphibian", "Carnivore", "Water", 4, "North America", 0.2),
        ("Great white shark", "Fish", "Carnivore", "Water", 0, "Oceans", 1000),
        ("Atlantic salmon", "Fish", "Carnivore", "Water", 0, "Oceans", 5),
        ("Clownfish", "Fish", "Omnivore", "Water", 0, "Oceans", 0.03),
        ("Seahorse", "Fish", "Carnivore", "Water", 0, "Oceans", 0.01),
        ("Giant Pacific octopus", "Invertebrate", "Carnivore", "Water", 8, "Oceans", 30),
        ("American lobster", "Invertebrate", "Carnivore", "Water", 10, "Oceans", 1),
        ("Honeybee", "Invertebrate", "Herbivore", "Land", 6, "Europe, Africa, Asia", 0.0001),
        ("Monarch butterfly", "Invertebrate", "Herbivore", "Land", 6, "North America", 0.0005),
        ("Goliath birdeater spider", "Invertebrate", "Carnivore", "Land", 8, "South America", 0.15),
        ("Emperor scorpion", "Invertebrate", "Carnivore", "Land", 8, "Africa", 0.03),
        ("Garden snail", "Invertebrate", "Herbivore", "Land", 0, "Europe", 0.01)
    ]
}
