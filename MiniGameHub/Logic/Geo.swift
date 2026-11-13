import Foundation

/// A point on a unit sphere. With the globe facing the viewer at latitude 0,
/// longitude 0: x points east, y points north, z points at the viewer.
struct Vec3: Equatable {
    var x: Double
    var y: Double
    var z: Double

    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    init(latitude: Double, longitude: Double) {
        let phi = latitude * .pi / 180
        let lambda = longitude * .pi / 180
        x = cos(phi) * sin(lambda)
        y = sin(phi)
        z = cos(phi) * cos(lambda)
    }

    func dot(_ other: Vec3) -> Double {
        x * other.x + y * other.y + z * other.z
    }
}

/// Great-circle maths for the globe game.
enum Geo {
    static let earthRadiusKm = 6371.0

    static func distanceKm(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        distanceKm(Vec3(latitude: lat1, longitude: lon1), Vec3(latitude: lat2, longitude: lon2))
    }

    static func distanceKm(_ first: Vec3, _ second: Vec3) -> Double {
        earthRadiusKm * acos(min(1, max(-1, first.dot(second))))
    }
}

/// Turns the globe so a chosen place faces the viewer.
struct GlobeOrientation {
    private let sinLat: Double
    private let cosLat: Double
    private let sinLon: Double
    private let cosLon: Double

    init(latitude: Double, longitude: Double) {
        let phi = latitude * .pi / 180
        let lambda = longitude * .pi / 180
        sinLat = sin(phi)
        cosLat = cos(phi)
        sinLon = sin(lambda)
        cosLon = cos(lambda)
    }

    /// Where a point ends up after turning. It is visible when z is positive.
    func rotate(_ point: Vec3) -> Vec3 {
        let x1 = point.x * cosLon - point.z * sinLon
        let z1 = point.x * sinLon + point.z * cosLon
        let y2 = point.y * cosLat - z1 * sinLat
        let z2 = point.y * sinLat + z1 * cosLat
        return Vec3(x: x1, y: y2, z: z2)
    }
}
