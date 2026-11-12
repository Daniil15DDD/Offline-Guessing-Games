import Foundation

struct MapPoint: Equatable {
    var x: Double  // longitude in degrees
    var y: Double  // latitude in degrees
}

struct Country: Identifiable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    /// Coastline pieces, biggest first.
    let rings: [[MapPoint]]

    /// Other names people type for this country.
    var spellings: [String] {
        [name] + (Atlas.aliases[name] ?? [])
    }
}

/// The countries used by Borderline, parsed once from `CountryData`.
enum Atlas {
    static let countries: [Country] = parse(CountryData.raw)

    static let aliases: [String: [String]] = [
        "United States": ["USA", "US", "America", "United States of America"],
        "United Kingdom": ["UK", "Britain", "Great Britain", "England"],
        "United Arab Emirates": ["UAE", "Emirates"],
        "DR Congo": ["Democratic Republic of the Congo", "DRC", "Congo Kinshasa", "Zaire"],
        "Republic of the Congo": ["Congo", "Congo Brazzaville"],
        "Ivory Coast": ["Cote d'Ivoire"],
        "Myanmar": ["Burma"],
        "Netherlands": ["Holland"],
        "Eswatini": ["Swaziland"],
        "Czechia": ["Czech Republic"],
        "Timor-Leste": ["East Timor"],
        "North Macedonia": ["Macedonia"],
        "Turkey": ["Turkiye"],
        "Russia": ["Russian Federation"],
        "South Korea": ["Korea", "Republic of Korea"],
        "North Korea": ["DPRK"],
        "Bosnia and Herzegovina": ["Bosnia"],
        "Central African Republic": ["CAR"],
        "Dominican Republic": ["DR"],
        "Papua New Guinea": ["PNG"],
        "New Zealand": ["NZ", "Aotearoa"],
        "Trinidad and Tobago": ["Trinidad"],
        "Gambia": ["The Gambia"],
        "Bahamas": ["The Bahamas"],
        "Vietnam": ["Viet Nam"],
        "Laos": ["Lao"],
        "Syria": ["Syrian Arab Republic"]
    ]

    static func parse(_ raw: String) -> [Country] {
        var result: [Country] = []
        for line in raw.split(separator: "\n") {
            let fields = line.split(separator: ";", omittingEmptySubsequences: false)
            guard fields.count == 4,
                  let latitude = Double(fields[1]),
                  let longitude = Double(fields[2]) else { continue }
            var rings: [[MapPoint]] = []
            for ringText in fields[3].split(separator: "|") {
                let numbers = ringText.split(separator: " ").compactMap { Double($0) }
                var ring: [MapPoint] = []
                ring.reserveCapacity(numbers.count / 2)
                var index = 0
                while index + 1 < numbers.count {
                    ring.append(MapPoint(x: numbers[index] / 100, y: numbers[index + 1] / 100))
                    index += 2
                }
                if ring.count >= 3 {
                    rings.append(ring)
                }
            }
            guard !rings.isEmpty else { continue }
            result.append(Country(
                id: result.count,
                name: String(fields[0]),
                latitude: latitude,
                longitude: longitude,
                rings: rings
            ))
        }
        return result
    }
}
