import SwiftUI

/// Flat outlines of real things, used by Scale It. An outline is looked up
/// by key (see `ScalePairs`). Each one knows its own proportions, so it can
/// be drawn at any height.
///
/// Three kinds exist:
///   - "img.<asset>": a picture from the asset catalog, filled with one colour.
///   - "disc...", "ball...", "ring": round things.
///   - "b.<name>" and "m.<name>": buildings and mountains drawn as vector shapes.
struct SilhouetteView: View {
    let key: String
    /// Height in points. The width follows from the outline's proportions.
    let height: CGFloat
    let color: Color

    var body: some View {
        let width = max(height * Silhouettes.aspect(for: key), 1)
        Group {
            if let name = Silhouettes.imageName(for: key) {
                Image(name)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(color)
            } else {
                SilhouetteShape(key: key)
                    .fill(color, style: FillStyle(eoFill: Silhouettes.usesEvenOdd(key)))
                    .overlay(
                        // Seams, bands and holes, drawn as darker lines.
                        SilhouetteDetail(key: key)
                            .stroke(
                                Color.black.opacity(0.32),
                                style: StrokeStyle(lineWidth: max(1, height * 0.03), lineCap: .round, lineJoin: .round)
                            )
                    )
            }
        }
        .frame(width: width, height: max(height, 1))
    }
}

/// The filled outline.
struct SilhouetteShape: Shape {
    let key: String

    func path(in rect: CGRect) -> Path {
        Silhouettes.path(for: key, in: rect)
    }
}

/// Lines drawn on top of an outline (the seams of a ball, for example).
struct SilhouetteDetail: Shape {
    let key: String

    func path(in rect: CGRect) -> Path {
        Silhouettes.detail(for: key, in: rect)
    }
}

enum Silhouettes {

    // MARK: - Lookup

    static func imageName(for key: String) -> String? {
        key.hasPrefix("img.") ? String(key.dropFirst(4)) : nil
    }

    /// Outlines with an opening cut through them. Their paths list the
    /// opening as a second outline, which the even-odd rule leaves empty.
    static func usesEvenOdd(_ key: String) -> Bool {
        key == "b.eiffel" || key == "b.arc"
    }

    /// Width divided by height.
    static func aspect(for key: String) -> CGFloat {
        if let name = imageName(for: key) {
            return imageAspects[name] ?? 1
        }
        if key.hasPrefix("disc") || key.hasPrefix("ball") || key == "ring" {
            return 1
        }
        if let ridge = ridges[key] {
            return ridge.aspect
        }
        if let profile = towers[key] {
            return 2 * (profile.map { $0.1 }.max() ?? 0.25)
        }
        return customAspects[key] ?? 0.5
    }

    private static let imageAspects: [String: CGFloat] = [
        "s_giraffe": 0.938, "s_elephant": 1.217, "s_penguin": 1.011, "s_person": 0.33,
        "s_flamingo": 0.781, "s_camel": 1.032, "s_llama": 0.928
    ]

    private static let customAspects: [String: CGFloat] = [
        "b.petronas": 0.3, "b.arch": 1.0, "b.eye": 0.9, "b.liberty": 0.5,
        "b.taj": 1.1, "b.opera": 2.7, "b.pisa": 0.52
    ]

    // MARK: - Drawing space

    /// Maps "outline units" to screen points. In outline units x is measured
    /// from the centre line, y from the ground (0) up to the top (1), and one
    /// unit is the outline's full height.
    private struct Frame {
        let rect: CGRect

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.midX + x * rect.height, y: rect.maxY - y * rect.height)
        }

        func length(_ value: CGFloat) -> CGFloat {
            value * rect.height
        }

        func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
            var path = Path()
            for (index, item) in points.enumerated() {
                if index == 0 {
                    path.move(to: point(item.0, item.1))
                } else {
                    path.addLine(to: point(item.0, item.1))
                }
            }
            path.closeSubpath()
            return path
        }

        func ellipse(x: CGFloat, y: CGFloat, radiusX: CGFloat, radiusY: CGFloat) -> Path {
            let centre = point(x, y)
            return Path(ellipseIn: CGRect(
                x: centre.x - length(radiusX),
                y: centre.y - length(radiusY),
                width: length(radiusX) * 2,
                height: length(radiusY) * 2
            ))
        }

        /// A shape that is the same on both sides, given as (height, half
        /// width) pairs from the ground up.
        func tower(_ profile: [(CGFloat, CGFloat)], offset: CGFloat = 0) -> Path {
            var points: [(CGFloat, CGFloat)] = profile.map { (offset - $0.1, $0.0) }
            points += profile.reversed().map { (offset + $0.1, $0.0) }
            return polygon(points)
        }
    }

    // MARK: - Paths

    static func path(for key: String, in rect: CGRect) -> Path {
        let frame = Frame(rect: rect)

        if key.hasPrefix("disc") || key.hasPrefix("ball") {
            return Path(ellipseIn: rect)
        }
        if key == "ring" {
            let width = rect.width * 0.07
            return Path(ellipseIn: rect.insetBy(dx: width / 2, dy: width / 2))
                .strokedPath(StrokeStyle(lineWidth: width))
        }
        if let ridge = ridges[key] {
            var points: [(CGFloat, CGFloat)] = ridge.points.map { ((($0.0) - 0.5) * ridge.aspect, $0.1) }
            points.append((ridge.aspect / 2, 0))
            points.insert((-ridge.aspect / 2, 0), at: 0)
            return frame.polygon(points)
        }
        if let profile = towers[key] {
            // Openings are added as extra outlines and cut out by the
            // even-odd fill rule (see `usesEvenOdd`).
            var path = frame.tower(profile)
            if key == "b.eiffel" {
                // The open arch between the legs.
                path.addPath(frame.polygon([
                    (-0.105, 0), (-0.085, 0.07), (-0.045, 0.115), (0, 0.13), (0.045, 0.115), (0.085, 0.07), (0.105, 0)
                ]))
            }
            if key == "b.arc" {
                // One archway: straight sides with a round top.
                var opening: [(CGFloat, CGFloat)] = [(-0.146, 0)]
                for step in 0...16 {
                    let angle = CGFloat.pi * (1 - CGFloat(step) / 16)
                    opening.append((cos(angle) * 0.146, 0.42 + sin(angle) * 0.146))
                }
                opening.append((0.146, 0))
                path.addPath(frame.polygon(opening))
            }
            return path
        }

        switch key {
        case "b.petronas":
            let single: [(CGFloat, CGFloat)] = [
                (0, 0.05), (0.6, 0.05), (0.7, 0.042), (0.78, 0.032), (0.84, 0.02), (0.88, 0.01), (1, 0.002)
            ]
            var path = frame.tower(single, offset: -0.085)
            path.addPath(frame.tower(single, offset: 0.085))
            path.addPath(frame.polygon([(-0.04, 0.37), (0.04, 0.37), (0.04, 0.4), (-0.04, 0.4)]))
            return path

        case "b.arch":
            // A curved line from foot to foot, thickened into a band.
            var line = Path()
            let steps = 40
            for step in 0...steps {
                let x = -0.47 + 0.94 * CGFloat(step) / CGFloat(steps)
                let y = 0.97 * (1 - pow(abs(x) / 0.47, 2.2))
                if step == 0 {
                    line.move(to: frame.point(x, y))
                } else {
                    line.addLine(to: frame.point(x, y))
                }
            }
            return line.strokedPath(StrokeStyle(lineWidth: frame.length(0.06), lineCap: .butt, lineJoin: .round))

        case "b.eye":
            let centreY: CGFloat = 0.555
            let radius: CGFloat = 0.42
            var path = frame.ellipse(x: 0, y: centreY, radiusX: radius, radiusY: radius)
                .strokedPath(StrokeStyle(lineWidth: frame.length(0.045)))
            var lines = Path()
            for spoke in 0..<8 {
                let angle = CGFloat(spoke) * .pi / 8
                lines.move(to: frame.point(-cos(angle) * radius, centreY - sin(angle) * radius))
                lines.addLine(to: frame.point(cos(angle) * radius, centreY + sin(angle) * radius))
            }
            path.addPath(lines.strokedPath(StrokeStyle(lineWidth: frame.length(0.012))))
            // The A-frame it hangs from, and the hub.
            var legs = Path()
            legs.move(to: frame.point(-0.2, 0))
            legs.addLine(to: frame.point(0, centreY))
            legs.addLine(to: frame.point(0.2, 0))
            path.addPath(legs.strokedPath(StrokeStyle(lineWidth: frame.length(0.03), lineCap: .butt, lineJoin: .round)))
            path.addPath(frame.ellipse(x: 0, y: centreY, radiusX: 0.045, radiusY: 0.045))
            path.addPath(frame.polygon([(-0.3, 0), (0.3, 0), (0.3, 0.03), (-0.3, 0.03)]))
            return path

        case "b.liberty":
            var path = frame.polygon([(-0.24, 0), (0.24, 0), (0.2, 0.1), (-0.2, 0.1)])
            path.addPath(frame.polygon([(-0.12, 0.1), (0.12, 0.1), (0.095, 0.5), (-0.095, 0.5)]))
            path.addPath(frame.polygon([(-0.115, 0.46), (0.115, 0.46), (0.115, 0.5), (-0.115, 0.5)]))
            // Robe, head and crown.
            path.addPath(frame.polygon([
                (-0.085, 0.5), (0.085, 0.5), (0.06, 0.8), (0.035, 0.85), (-0.035, 0.85), (-0.06, 0.8)
            ]))
            path.addPath(frame.ellipse(x: 0, y: 0.875, radiusX: 0.03, radiusY: 0.034))
            for degrees in stride(from: -60.0, through: 60.0, by: 30.0) {
                let angle = CGFloat(degrees) * .pi / 180
                let tipX = sin(angle) * 0.075
                let tipY = 0.88 + cos(angle) * 0.075
                let baseX = sin(angle) * 0.028
                let baseY = 0.88 + cos(angle) * 0.028
                path.addPath(frame.polygon([
                    (baseX - cos(angle) * 0.009, baseY + sin(angle) * 0.009),
                    (tipX, tipY),
                    (baseX + cos(angle) * 0.009, baseY - sin(angle) * 0.009)
                ]))
            }
            // Raised arm with the torch, and the arm holding the tablet.
            path.addPath(frame.polygon([(-0.055, 0.815), (-0.028, 0.83), (-0.075, 0.965), (-0.1, 0.955)]))
            path.addPath(frame.polygon([(-0.118, 0.955), (-0.062, 0.955), (-0.074, 0.972), (-0.106, 0.972)]))
            path.addPath(frame.ellipse(x: -0.09, y: 0.987, radiusX: 0.017, radiusY: 0.02))
            path.addPath(frame.polygon([(0.04, 0.8), (0.078, 0.78), (0.09, 0.7), (0.056, 0.69), (0.046, 0.76)]))
            return path

        case "b.taj":
            // The main building with its onion dome.
            var path = frame.tower([
                (0, 0.3), (0.45, 0.3), (0.45, 0.17), (0.5, 0.17), (0.53, 0.2), (0.62, 0.215), (0.72, 0.19),
                (0.82, 0.13), (0.9, 0.06), (0.94, 0.02), (1, 0.004)
            ])
            // Small side domes and the four minarets.
            for side in [CGFloat(-1), CGFloat(1)] {
                path.addPath(frame.tower([(0.45, 0.06), (0.52, 0.065), (0.6, 0.04), (0.64, 0.004)], offset: side * 0.21))
                path.addPath(frame.tower([(0, 0.022), (0.56, 0.017), (0.56, 0.027), (0.6, 0.027), (0.66, 0.003)], offset: side * 0.5))
            }
            path.addPath(frame.polygon([(-0.55, 0), (0.55, 0), (0.55, 0.06), (-0.55, 0.06)]))
            return path

        case "b.opera":
            // A long platform with a row of pointed shells on top.
            var path = frame.polygon([(-1.35, 0), (1.35, 0), (1.3, 0.2), (-1.3, 0.2)])
            let sails: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (-1.25, -0.72, -0.6, 0.62), (-0.95, -0.28, -0.12, 0.86), (-0.5, 0.26, 0.42, 1.0),
                (0.4, 0.9, 0.98, 0.62), (0.82, 1.2, 1.27, 0.42)
            ]
            for sail in sails {
                var shell = Path()
                shell.move(to: frame.point(sail.0, 0.18))
                shell.addQuadCurve(
                    to: frame.point(sail.2, sail.3),
                    control: frame.point(sail.0 + (sail.2 - sail.0) * 0.25, sail.3 * 0.95)
                )
                shell.addQuadCurve(
                    to: frame.point(sail.1, 0.18),
                    control: frame.point(sail.2 - 0.02, 0.18 + (sail.3 - 0.18) * 0.45)
                )
                shell.closeSubpath()
                path.addPath(shell)
            }
            return path

        case "b.pisa":
            // A round tower that leans to the right, with a narrower belfry.
            var path = frame.polygon([(-0.19, 0), (0.13, 0), (0.2, 0.86), (-0.12, 0.86)])
            path.addPath(frame.polygon([(-0.07, 0.86), (0.155, 0.86), (0.165, 1.0), (-0.06, 1.0)]))
            return path

        default:
            return frame.polygon([(-0.2, 0), (0.2, 0), (0.2, 1), (-0.2, 1)])
        }
    }

    // MARK: - Details

    static func detail(for key: String, in rect: CGRect) -> Path {
        // Detail units: the centre of the shape is (0, 0) and its edge is 1 away.
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.midX + x * rect.width / 2, y: rect.midY - y * rect.height / 2)
        }
        func arc(_ path: inout Path, centreX: CGFloat, centreY: CGFloat, radius: CGFloat, from: CGFloat, to: CGFloat) {
            let steps = 24
            for step in 0...steps {
                let angle = (from + (to - from) * CGFloat(step) / CGFloat(steps)) * .pi / 180
                let spot = point(centreX + cos(angle) * radius, centreY + sin(angle) * radius)
                if step == 0 {
                    path.move(to: spot)
                } else {
                    path.addLine(to: spot)
                }
            }
        }
        var path = Path()

        switch key {
        case "ball.basketball":
            path.move(to: point(0, 1)); path.addLine(to: point(0, -1))
            path.move(to: point(-1, 0)); path.addLine(to: point(1, 0))
            arc(&path, centreX: -1.25, centreY: 0, radius: 0.95, from: -48, to: 48)
            arc(&path, centreX: 1.25, centreY: 0, radius: 0.95, from: 132, to: 228)
        case "ball.tennis":
            arc(&path, centreX: -1.05, centreY: 0, radius: 0.85, from: -58, to: 58)
            arc(&path, centreX: 1.05, centreY: 0, radius: 0.85, from: 122, to: 238)
        case "ball.baseball":
            arc(&path, centreX: -1.3, centreY: 0, radius: 1.05, from: -42, to: 42)
            arc(&path, centreX: 1.3, centreY: 0, radius: 1.05, from: 138, to: 222)
        case "ball.volleyball":
            arc(&path, centreX: 0, centreY: 1.3, radius: 1.1, from: 222, to: 318)
            arc(&path, centreX: -1.15, centreY: -0.65, radius: 1.1, from: -18, to: 78)
            arc(&path, centreX: 1.15, centreY: -0.65, radius: 1.1, from: 102, to: 198)
        case "ball.soccer":
            // A pentagon in the middle with a seam running out from each corner.
            let corners = (0..<5).map { index -> (CGFloat, CGFloat) in
                let angle = (90 + CGFloat(index) * 72) * .pi / 180
                return (cos(angle), sin(angle))
            }
            for (index, corner) in corners.enumerated() {
                let next = corners[(index + 1) % 5]
                path.move(to: point(corner.0 * 0.38, corner.1 * 0.38))
                path.addLine(to: point(next.0 * 0.38, next.1 * 0.38))
                path.move(to: point(corner.0 * 0.38, corner.1 * 0.38))
                path.addLine(to: point(corner.0 * 0.95, corner.1 * 0.95))
            }
        case "ball.cricket":
            arc(&path, centreX: -2.2, centreY: 0, radius: 2.3, from: -24, to: 24)
            arc(&path, centreX: 2.2, centreY: 0, radius: 2.3, from: 156, to: 204)
        case "ball.pool":
            arc(&path, centreX: 0, centreY: 0.1, radius: 0.42, from: 0, to: 360)
        case "ball.bowling":
            arc(&path, centreX: -0.18, centreY: 0.42, radius: 0.06, from: 0, to: 360)
            arc(&path, centreX: 0.16, centreY: 0.44, radius: 0.06, from: 0, to: 360)
            arc(&path, centreX: 0.02, centreY: 0.14, radius: 0.07, from: 0, to: 360)
        case "ball.golf":
            for row in -2...2 {
                for column in -2...2 where abs(row) + abs(column) <= 3 {
                    arc(&path, centreX: CGFloat(column) * 0.3, centreY: CGFloat(row) * 0.3, radius: 0.03, from: 0, to: 360)
                }
            }
        case "disc.banded":
            for height in [CGFloat(0.42), CGFloat(0.1), CGFloat(-0.3)] {
                let half = (1 - height * height).squareRoot() * 0.97
                path.move(to: point(-half, height))
                path.addLine(to: point(half, height))
            }
        case "disc.moon":
            arc(&path, centreX: -0.3, centreY: 0.3, radius: 0.2, from: 0, to: 360)
            arc(&path, centreX: 0.35, centreY: -0.15, radius: 0.14, from: 0, to: 360)
            arc(&path, centreX: -0.1, centreY: -0.5, radius: 0.1, from: 0, to: 360)
        case "b.pisa":
            // The rows of arches, tilted with the tower.
            for level in 1...6 {
                let y = CGFloat(level) * 0.123
                let lean = y * 0.0814
                let left = CGPoint(x: rect.midX + (-0.19 + lean) * rect.height, y: rect.maxY - y * rect.height)
                let right = CGPoint(x: rect.midX + (0.13 + lean) * rect.height, y: rect.maxY - y * rect.height)
                path.move(to: left)
                path.addLine(to: right)
            }
        default:
            break
        }
        return path
    }

    // MARK: - Buildings that are the same on both sides

    /// (height, half width) pairs from the ground up, in outline units.
    private static let towers: [String: [(CGFloat, CGFloat)]] = [
        "b.burj": [
            (0, 0.09), (0.15, 0.085), (0.15, 0.075), (0.3, 0.07), (0.3, 0.06), (0.45, 0.055), (0.45, 0.045),
            (0.6, 0.04), (0.6, 0.03), (0.72, 0.026), (0.72, 0.018), (0.82, 0.014), (0.82, 0.007), (1, 0.002)
        ],
        "b.skytree": [
            (0, 0.055), (0.3, 0.03), (0.52, 0.022), (0.52, 0.04), (0.56, 0.04), (0.56, 0.02), (0.68, 0.018),
            (0.68, 0.03), (0.71, 0.03), (0.71, 0.012), (0.78, 0.01), (1, 0.003)
        ],
        "b.shanghai": [
            (0, 0.065), (0.2, 0.061), (0.5, 0.051), (0.8, 0.04), (0.95, 0.031), (1, 0.016)
        ],
        "b.cn": [
            (0, 0.06), (0.05, 0.035), (0.3, 0.02), (0.6, 0.012), (0.6, 0.036), (0.62, 0.042), (0.66, 0.042),
            (0.68, 0.025), (0.7, 0.012), (0.8, 0.008), (1, 0.002)
        ],
        "b.wtc": [
            (0, 0.058), (0.77, 0.042), (0.77, 0.02), (0.79, 0.012), (1, 0.003)
        ],
        "b.taipei": [
            (0, 0.075), (0.25, 0.055),
            (0.25, 0.045), (0.325, 0.058), (0.325, 0.045), (0.4, 0.058), (0.4, 0.045), (0.475, 0.058),
            (0.475, 0.045), (0.55, 0.058), (0.55, 0.045), (0.625, 0.058), (0.625, 0.045), (0.7, 0.058),
            (0.7, 0.045), (0.775, 0.058), (0.775, 0.045), (0.85, 0.058),
            (0.85, 0.03), (0.9, 0.02), (0.9, 0.008), (1, 0.003)
        ],
        "b.empire": [
            (0, 0.11), (0.06, 0.11), (0.06, 0.085), (0.2, 0.085), (0.2, 0.07), (0.66, 0.07), (0.66, 0.06),
            (0.72, 0.06), (0.72, 0.045), (0.8, 0.045), (0.8, 0.03), (0.86, 0.025), (0.86, 0.012), (0.9, 0.01),
            (0.9, 0.004), (1, 0.002)
        ],
        "b.eiffel": [
            (0, 0.19), (0.05, 0.17), (0.17, 0.1), (0.175, 0.112), (0.19, 0.112), (0.195, 0.095), (0.35, 0.055),
            (0.355, 0.064), (0.37, 0.064), (0.375, 0.05), (0.6, 0.025), (0.85, 0.012), (0.85, 0.02),
            (0.87, 0.02), (0.87, 0.01), (1, 0.003)
        ],
        "b.chrysler": [
            (0, 0.1), (0.1, 0.1), (0.1, 0.075), (0.62, 0.075), (0.62, 0.062), (0.7, 0.062), (0.72, 0.052),
            (0.76, 0.045), (0.8, 0.036), (0.84, 0.026), (0.88, 0.016), (0.9, 0.008), (1, 0.002)
        ],
        "b.shard": [
            (0, 0.11), (0.95, 0.012), (1, 0.004)
        ],
        "b.needle": [
            (0, 0.09), (0.03, 0.05), (0.45, 0.018), (0.78, 0.03), (0.8, 0.12), (0.83, 0.13), (0.86, 0.11),
            (0.88, 0.05), (0.9, 0.03), (0.92, 0.01), (1, 0.002)
        ],
        "b.obelisk": [
            (0, 0.05), (0.9, 0.031), (1, 0.001)
        ],
        "b.pyramid": [
            (0, 0.83), (1, 0.001)
        ],
        "b.stpeters": [
            (0, 0.42), (0.33, 0.42), (0.33, 0.2), (0.4, 0.2), (0.4, 0.17), (0.55, 0.17), (0.6, 0.16),
            (0.7, 0.13), (0.8, 0.085), (0.86, 0.04), (0.86, 0.025), (0.93, 0.025), (0.95, 0.012), (1, 0.003)
        ],
        "b.bigben": [
            (0, 0.085), (0.62, 0.085), (0.62, 0.097), (0.78, 0.097), (0.78, 0.075), (0.82, 0.06),
            (0.86, 0.06), (0.9, 0.035), (0.95, 0.015), (1, 0.003)
        ],
        "b.arc": [
            (0, 0.45), (0.9, 0.45), (0.9, 0.47), (1, 0.47)
        ]
    ]

    // MARK: - Mountains

    /// A skyline from left (0) to right (1). The outline is closed along the
    /// ground. `aspect` is width divided by height.
    private static let ridges: [String: (aspect: CGFloat, points: [(CGFloat, CGFloat)])] = [
        "m.everest": (1.35, [(0.18, 0.35), (0.3, 0.5), (0.38, 0.62), (0.5, 1), (0.6, 0.7), (0.72, 0.62), (0.85, 0.3)]),
        "m.k2": (1.2, [(0.25, 0.4), (0.4, 0.75), (0.5, 1), (0.58, 0.8), (0.7, 0.5), (0.85, 0.2)]),
        "m.aconcagua": (1.4, [(0.2, 0.3), (0.34, 0.6), (0.42, 0.88), (0.5, 1), (0.62, 0.9), (0.7, 0.82), (0.8, 0.5), (0.9, 0.25)]),
        "m.denali": (1.5, [(0.15, 0.3), (0.3, 0.62), (0.4, 0.9), (0.46, 1), (0.52, 0.9), (0.58, 0.85), (0.64, 0.92), (0.72, 0.7), (0.86, 0.3)]),
        "m.kilimanjaro": (1.9, [(0.2, 0.35), (0.33, 0.75), (0.4, 0.95), (0.45, 1), (0.6, 1), (0.66, 0.93), (0.75, 0.7), (0.88, 0.3)]),
        "m.elbrus": (1.6, [(0.2, 0.4), (0.36, 0.92), (0.42, 1), (0.48, 0.9), (0.52, 0.86), (0.58, 0.96), (0.63, 0.97), (0.7, 0.8), (0.85, 0.35)]),
        "m.kenya": (1.3, [(0.25, 0.35), (0.38, 0.6), (0.44, 0.9), (0.47, 1), (0.5, 0.88), (0.53, 0.97), (0.57, 0.8), (0.66, 0.55), (0.82, 0.25)]),
        "m.vinson": (1.6, [(0.15, 0.4), (0.3, 0.7), (0.42, 0.92), (0.5, 1), (0.6, 0.9), (0.72, 0.72), (0.86, 0.4)]),
        "m.blanc": (1.5, [(0.12, 0.3), (0.2, 0.42), (0.24, 0.55), (0.28, 0.5), (0.36, 0.78), (0.46, 0.96), (0.52, 1), (0.6, 0.92), (0.7, 0.7), (0.78, 0.55), (0.82, 0.6), (0.9, 0.3)]),
        "m.matterhorn": (1.15, [(0.2, 0.18), (0.35, 0.4), (0.44, 0.75), (0.5, 1), (0.53, 0.93), (0.57, 0.7), (0.68, 0.4), (0.85, 0.15)]),
        "m.rainier": (1.6, [(0.18, 0.35), (0.32, 0.72), (0.42, 0.93), (0.5, 1), (0.58, 0.95), (0.68, 0.75), (0.82, 0.4)]),
        "m.maunakea": (2.0, [(0.25, 0.55), (0.4, 0.9), (0.5, 1), (0.6, 0.9), (0.78, 0.5)]),
        "m.fuji": (1.8, [(0.15, 0.2), (0.3, 0.52), (0.42, 0.9), (0.46, 1), (0.5, 0.97), (0.54, 1), (0.58, 0.9), (0.7, 0.52), (0.85, 0.2)]),
        "m.cook": (1.3, [(0.22, 0.4), (0.36, 0.72), (0.44, 0.88), (0.5, 1), (0.56, 0.92), (0.62, 0.9), (0.74, 0.55), (0.88, 0.22)]),
        "m.olympus": (1.5, [(0.2, 0.45), (0.3, 0.7), (0.36, 0.66), (0.44, 0.95), (0.48, 0.88), (0.52, 1), (0.58, 0.86), (0.64, 0.9), (0.74, 0.6), (0.88, 0.3)]),
        "m.nevis": (1.7, [(0.2, 0.5), (0.3, 0.85), (0.38, 1), (0.55, 0.98), (0.62, 0.85), (0.66, 0.6), (0.8, 0.35)]),
        "m.vesuvius": (1.8, [(0.2, 0.45), (0.32, 0.78), (0.38, 0.72), (0.45, 0.7), (0.55, 0.95), (0.6, 1), (0.66, 0.97), (0.72, 0.8), (0.85, 0.35)]),
        "m.table": (2.0, [(0.08, 0.35), (0.14, 0.85), (0.18, 1), (0.8, 1), (0.84, 0.85), (0.9, 0.4)])
    ]

    /// Every key that can be drawn, for the tests and previews.
    static var vectorKeys: [String] {
        Array(towers.keys) + Array(ridges.keys) + Array(customAspects.keys)
    }
}
