import Foundation

/// Great-circle maths for the map game.
enum Geo {
    static let earthRadiusKm = 6371.0

    static func distanceKm(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let p1 = lat1 * .pi / 180
        let p2 = lat2 * .pi / 180
        let dp = (lat2 - lat1) * .pi / 180
        let dl = (lon2 - lon1) * .pi / 180
        let a = sin(dp / 2) * sin(dp / 2) + cos(p1) * cos(p2) * sin(dl / 2) * sin(dl / 2)
        return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(max(0, 1 - a)))
    }

    /// Initial compass bearing from point 1 to point 2, in degrees clockwise
    /// from north (0 up to, but not including, 360).
    static func bearing(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let p1 = lat1 * .pi / 180
        let p2 = lat2 * .pi / 180
        let dl = (lon2 - lon1) * .pi / 180
        let y = sin(dl) * cos(p2)
        let x = cos(p1) * sin(p2) - sin(p1) * cos(p2) * cos(dl)
        let degrees = atan2(y, x) * 180 / .pi
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    static func compass(_ bearing: Double) -> String {
        let names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((bearing + 22.5) / 45) % 8
        return names[max(0, index)]
    }

    /// 100 when on target, falling to 0 on the far side of the planet.
    static func proximity(km: Double) -> Int {
        let farthest = Double.pi * earthRadiusKm
        return Int((max(0, 1 - km / farthest) * 100).rounded())
    }
}
