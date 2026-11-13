import Foundation

struct PriceItem: Equatable {
    let name: String
    let detail: String
    /// US dollars.
    let price: Double
    /// Name of the picture in the asset catalog.
    let art: String
}

/// Items for Price Point.
///
/// These are rough reference prices for a typical mid-range version of each
/// item in a US shop, chosen for the game. They are not live prices and are
/// not taken from any particular shop. Edit them freely.
enum PriceItems {
    static let all: [PriceItem] = [
        PriceItem(name: "Dozen large eggs", detail: "Supermarket own brand", price: 3.50, art: "p_eggs"),
        PriceItem(name: "Gallon of milk", detail: "Whole milk", price: 4.00, art: "p_milk"),
        PriceItem(name: "Loaf of sandwich bread", detail: "Sliced, standard size", price: 3.00, art: "p_bread"),
        PriceItem(name: "Pound of butter", detail: "Four sticks, salted", price: 5.00, art: "p_butter"),
        PriceItem(name: "Bunch of bananas", detail: "About two pounds", price: 1.20, art: "p_bananas"),
        PriceItem(name: "Bag of ground coffee", detail: "12 ounces, medium roast", price: 9.00, art: "p_coffee"),
        PriceItem(name: "Jar of honey", detail: "12 ounces", price: 6.00, art: "p_honey"),
        PriceItem(name: "Chocolate bar", detail: "Standard size, milk chocolate", price: 2.00, art: "p_chocolate"),
        PriceItem(name: "Block of cheddar cheese", detail: "8 ounces", price: 4.00, art: "p_cheese"),
        PriceItem(name: "Frozen pizza", detail: "Family size, pepperoni", price: 7.00, art: "p_pizza"),
        PriceItem(name: "Bag of white rice", detail: "5 pounds, long grain", price: 6.00, art: "p_rice"),
        PriceItem(name: "Toilet paper", detail: "Pack of 12 rolls", price: 10.00, art: "p_toiletpaper"),
        PriceItem(name: "Toothbrushes", detail: "Pack of two, manual", price: 5.00, art: "p_toothbrush"),
        PriceItem(name: "Scented candle", detail: "Large jar", price: 25.00, art: "p_candle"),
        PriceItem(name: "Pack of AA batteries", detail: "8 alkaline batteries", price: 9.00, art: "p_batteries"),
        PriceItem(name: "LED light bulbs", detail: "Pack of four, 60 watt equivalent", price: 10.00, art: "p_bulb"),
        PriceItem(name: "LED flashlight", detail: "Handheld, batteries included", price: 20.00, art: "p_flashlight"),
        PriceItem(name: "Movie ticket", detail: "One adult, evening showing", price: 12.00, art: "p_ticket"),
        PriceItem(name: "Hardcover novel", detail: "New release, full price", price: 28.00, art: "p_book"),
        PriceItem(name: "Board game", detail: "Family strategy game", price: 35.00, art: "p_boardgame"),
        PriceItem(name: "Teddy bear", detail: "Medium, about 12 inches", price: 20.00, art: "p_teddy"),
        PriceItem(name: "Plain cotton T-shirt", detail: "Single shirt, basic brand", price: 15.00, art: "p_tshirt"),
        PriceItem(name: "Pair of jeans", detail: "Mid-range brand", price: 50.00, art: "p_jeans"),
        PriceItem(name: "Running shoes", detail: "Mid-range pair", price: 120.00, art: "p_runners"),
        PriceItem(name: "Hiking boots", detail: "Mid-range, waterproof", price: 140.00, art: "p_boots"),
        PriceItem(name: "Winter coat", detail: "Mid-range, insulated", price: 150.00, art: "p_coat"),
        PriceItem(name: "Sunglasses", detail: "Mid-range, polarised", price: 60.00, art: "p_sunglasses"),
        PriceItem(name: "Umbrella", detail: "Full size", price: 20.00, art: "p_umbrella"),
        PriceItem(name: "School backpack", detail: "Padded straps, laptop sleeve", price: 50.00, art: "p_backpack"),
        PriceItem(name: "Carry-on suitcase", detail: "Hard shell, four wheels", price: 130.00, art: "p_suitcase"),
        PriceItem(name: "Wristwatch", detail: "Basic analogue, leather strap", price: 50.00, art: "p_watch"),
        PriceItem(name: "Non-stick frying pan", detail: "10 inch", price: 30.00, art: "p_pan"),
        PriceItem(name: "Chef's knife", detail: "8 inch, mid-range", price: 50.00, art: "p_knife"),
        PriceItem(name: "Ceramic teapot", detail: "Holds about four cups", price: 25.00, art: "p_teapot"),
        PriceItem(name: "Wooden dining chair", detail: "A single chair", price: 80.00, art: "p_chair"),
        PriceItem(name: "Three-seat sofa", detail: "Mid-range, fabric", price: 800.00, art: "p_sofa"),
        PriceItem(name: "Queen bed frame", detail: "Wooden, mattress not included", price: 300.00, art: "p_bed"),
        PriceItem(name: "Alarm clock", detail: "Classic twin bell", price: 15.00, art: "p_alarm"),
        PriceItem(name: "Toolbox", detail: "19 inch plastic, empty", price: 25.00, art: "p_toolbox"),
        PriceItem(name: "Claw hammer", detail: "16 ounce, fibreglass handle", price: 15.00, art: "p_hammer"),
        PriceItem(name: "55 inch television", detail: "4K, mid-range", price: 450.00, art: "p_tv"),
        PriceItem(name: "Laptop", detail: "Mid-range, 15 inch", price: 800.00, art: "p_laptop"),
        PriceItem(name: "Games console", detail: "Current generation, standard model", price: 500.00, art: "p_console"),
        PriceItem(name: "Mechanical keyboard", detail: "Full size, mid-range", price: 90.00, art: "p_keyboard"),
        PriceItem(name: "Wireless mouse", detail: "Basic office model", price: 25.00, art: "p_mouse"),
        PriceItem(name: "Wireless headphones", detail: "Over-ear, mid-range", price: 150.00, art: "p_headphones"),
        PriceItem(name: "Smartphone", detail: "Mid-range, unlocked", price: 500.00, art: "p_phone"),
        PriceItem(name: "Digital camera", detail: "Entry-level mirrorless, with lens", price: 700.00, art: "p_camera"),
        PriceItem(name: "Basketball", detail: "Full size, indoor and outdoor", price: 30.00, art: "p_basketball"),
        PriceItem(name: "Football", detail: "Soccer ball, size 5", price: 25.00, art: "p_soccer"),
        PriceItem(name: "Tennis racket", detail: "Adult, mid-range", price: 80.00, art: "p_tennis"),
        PriceItem(name: "Skateboard", detail: "Complete board, beginner", price: 70.00, art: "p_skateboard"),
        PriceItem(name: "Hybrid bicycle", detail: "Adult, entry level from a bike shop", price: 550.00, art: "p_bicycle"),
        PriceItem(name: "Two-person tent", detail: "Three season, for backpacking", price: 120.00, art: "p_tent"),
        PriceItem(name: "Electric guitar", detail: "Beginner model", price: 200.00, art: "p_guitar"),
        PriceItem(name: "Digital piano", detail: "88 weighted keys, entry level", price: 500.00, art: "p_piano"),
        PriceItem(name: "Student trumpet", detail: "Brass, with case", price: 300.00, art: "p_trumpet")
    ]
}
