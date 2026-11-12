import Foundation

struct PriceItem: Equatable {
    let name: String
    let detail: String
    /// US dollars.
    let price: Double
}

/// Items for Price Point.
///
/// These are rough reference prices for a typical mid-range version of each
/// item in a US shop, chosen for the game. They are not live prices and are
/// not taken from any particular shop. Edit them freely.
enum PriceItems {
    static let all: [PriceItem] = [
        PriceItem(name: "Dozen large eggs", detail: "Supermarket own brand", price: 3.50),
        PriceItem(name: "Gallon of milk", detail: "Whole milk", price: 4.00),
        PriceItem(name: "Loaf of sandwich bread", detail: "Sliced, standard size", price: 3.00),
        PriceItem(name: "Pound of butter", detail: "Four sticks, salted", price: 5.00),
        PriceItem(name: "Pound of bananas", detail: "Loose, about three bananas", price: 0.60),
        PriceItem(name: "Bag of ground coffee", detail: "12 ounces, medium roast", price: 9.00),
        PriceItem(name: "Bag of white rice", detail: "5 pounds, long grain", price: 6.00),
        PriceItem(name: "Tube of toothpaste", detail: "Standard size, fluoride", price: 4.00),
        PriceItem(name: "Pack of AA batteries", detail: "8 alkaline batteries", price: 9.00),
        PriceItem(name: "LED light bulbs", detail: "Pack of four, 60 watt equivalent", price: 10.00),
        PriceItem(name: "Movie ticket", detail: "One adult, evening showing", price: 12.00),
        PriceItem(name: "Paperback novel", detail: "New release, full price", price: 17.00),
        PriceItem(name: "Hardcover novel", detail: "New release, full price", price: 28.00),
        PriceItem(name: "Board game", detail: "Family strategy game", price: 35.00),
        PriceItem(name: "Plain cotton T-shirt", detail: "Single shirt, basic brand", price: 15.00),
        PriceItem(name: "Pair of jeans", detail: "Mid-range brand", price: 50.00),
        PriceItem(name: "Running shoes", detail: "Mid-range pair", price: 120.00),
        PriceItem(name: "Folding umbrella", detail: "Compact, automatic open", price: 20.00),
        PriceItem(name: "School backpack", detail: "Padded straps, laptop sleeve", price: 50.00),
        PriceItem(name: "Carry-on suitcase", detail: "Hard shell, four wheels", price: 130.00),
        PriceItem(name: "Two-slice toaster", detail: "Basic model", price: 30.00),
        PriceItem(name: "Electric kettle", detail: "1.7 litres, stainless steel", price: 30.00),
        PriceItem(name: "Countertop blender", detail: "Mid-range, glass jug", price: 60.00),
        PriceItem(name: "Microwave oven", detail: "Countertop, 1000 watts", price: 110.00),
        PriceItem(name: "Non-stick frying pan", detail: "10 inch", price: 30.00),
        PriceItem(name: "Chef's knife", detail: "8 inch, mid-range", price: 50.00),
        PriceItem(name: "Desk lamp", detail: "LED, adjustable arm", price: 30.00),
        PriceItem(name: "Office chair", detail: "Mesh back, adjustable", price: 180.00),
        PriceItem(name: "Queen mattress", detail: "Mid-range memory foam", price: 700.00),
        PriceItem(name: "Cordless drill", detail: "With battery and charger", price: 100.00),
        PriceItem(name: "Gallon of wall paint", detail: "Interior, mid-range", price: 40.00),
        PriceItem(name: "Car tyre", detail: "One all-season tyre for a family car", price: 150.00),
        PriceItem(name: "USB-C charging cable", detail: "6 feet, braided", price: 12.00),
        PriceItem(name: "Wireless mouse", detail: "Basic office model", price: 25.00),
        PriceItem(name: "Mechanical keyboard", detail: "Full size, mid-range", price: 90.00),
        PriceItem(name: "Wireless earbuds", detail: "Mid-range, with charging case", price: 80.00),
        PriceItem(name: "55 inch television", detail: "4K, mid-range", price: 450.00),
        PriceItem(name: "Laptop", detail: "Mid-range, 15 inch", price: 800.00),
        PriceItem(name: "Games console", detail: "Current generation, standard model", price: 500.00),
        PriceItem(name: "Yoga mat", detail: "Standard thickness", price: 25.00),
        PriceItem(name: "Basketball", detail: "Full size, indoor and outdoor", price: 30.00),
        PriceItem(name: "Bicycle helmet", detail: "Adult, mid-range", price: 45.00),
        PriceItem(name: "Hybrid bicycle", detail: "Adult, entry level from a bike shop", price: 550.00),
        PriceItem(name: "Two-person tent", detail: "Three season, for backpacking", price: 120.00),
        PriceItem(name: "Sleeping bag", detail: "Three season, synthetic fill", price: 60.00),
        PriceItem(name: "Acoustic guitar", detail: "Beginner model", price: 200.00),
        PriceItem(name: "Digital piano", detail: "88 weighted keys, entry level", price: 500.00)
    ]
}
