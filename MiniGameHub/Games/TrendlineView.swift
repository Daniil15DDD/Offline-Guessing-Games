import SwiftUI

struct TrendlineView: View {
    @StateObject private var game: TrendGame
    private let mode: PlayMode
    /// Last hidden point touched during the current drag, for filling gaps.
    @State private var lastTouched: Int?

    private let kind = GameKind.trend

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: TrendGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Chart \(game.roundIndex + 1) of \(TrendGame.rounds)",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: { game.restart() }
        ) {
            GameColumn {
                VStack(spacing: 4) {
                    Text(game.series.title)
                        .bodyText(21, weight: .heavy)
                        .multilineTextAlignment(.center)
                    Text(game.series.unit)
                        .caption()
                        .multilineTextAlignment(.center)
                }

                chart
                    .frame(height: 300)
                    .panel(padding: 10)

                if game.revealed {
                    reveal
                } else {
                    Text("Drag across the shaded area to draw what happened after \(String(game.series.years[game.series.shown - 1])).")
                        .caption()
                        .multilineTextAlignment(.center)
                    HStack(spacing: 10) {
                        Button("Clear") {
                            game.clearDrawing()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Lock in") {
                            game.submit()
                            if game.lastPoints >= 70 {
                                Haptics.success()
                            } else {
                                Haptics.bump()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(kind: kind))
                        .disabled(!game.canSubmit)
                    }
                }
            }
        }
    }

    private var reveal: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                Label("Your line", systemImage: "circle.fill").foregroundColor(kind.accent)
                Label("Real data", systemImage: "circle.fill").foregroundColor(Theme.good)
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            Text("Source: \(game.series.source)")
                .caption()
                .multilineTextAlignment(.center)
            PointsBadge(points: game.lastPoints)
            Button(game.roundIndex + 1 >= TrendGame.rounds ? "See result" : "Next chart") {
                game.next()
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    // MARK: - Chart

    private var chart: some View {
        GeometryReader { geometry in
            let series = game.series
            let plot = CGRect(
                x: 44,
                y: 8,
                width: max(geometry.size.width - 54, 10),
                height: max(geometry.size.height - 34, 10)
            )
            let count = series.values.count
            let step = plot.width / CGFloat(max(count - 1, 1))
            let xFor: (Int) -> CGFloat = { index in plot.minX + step * CGFloat(index) }
            let yFor: (Double) -> CGFloat = { value in
                let share = (value - series.axisMin) / (series.axisMax - series.axisMin)
                return plot.maxY - CGFloat(share) * plot.height
            }

            ZStack(alignment: .topLeading) {
                // Area the player draws in.
                Rectangle()
                    .fill(kind.accent.opacity(0.12))
                    .frame(width: plot.maxX - xFor(series.shown - 1), height: plot.height)
                    .offset(x: xFor(series.shown - 1), y: plot.minY)

                // Frame and axis labels.
                Path { path in
                    path.move(to: CGPoint(x: plot.minX, y: plot.minY))
                    path.addLine(to: CGPoint(x: plot.minX, y: plot.maxY))
                    path.addLine(to: CGPoint(x: plot.maxX, y: plot.maxY))
                }
                .stroke(Theme.textSecondary.opacity(0.6), lineWidth: 1)

                axisLabel(NumberText.plain(series.axisMax), x: 0, y: plot.minY - 6, width: 40, alignment: .trailing)
                axisLabel(NumberText.plain(series.axisMin), x: 0, y: plot.maxY - 8, width: 40, alignment: .trailing)
                axisLabel(String(series.years[0]), x: plot.minX - 20, y: plot.maxY + 4, width: 40, alignment: .center)
                axisLabel(String(series.years[series.shown - 1]), x: xFor(series.shown - 1) - 20, y: plot.maxY + 4, width: 40, alignment: .center)
                axisLabel(String(series.years[count - 1]), x: plot.maxX - 34, y: plot.maxY + 4, width: 40, alignment: .trailing)

                // The part of the real line that is always visible.
                line(points: (0..<series.shown).map { CGPoint(x: xFor($0), y: yFor(series.values[$0])) })
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // The player's line, joined on to the last real point.
                line(points: playerPoints(xFor: xFor, yFor: yFor))
                    .stroke(kind.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 5]))

                ForEach(Array(game.drawn.enumerated()), id: \.offset) { index, value in
                    if let value = value {
                        Circle()
                            .fill(kind.accent)
                            .frame(width: 9, height: 9)
                            .position(x: xFor(series.shown + index), y: yFor(value))
                    }
                }

                if game.revealed {
                    line(points: ((series.shown - 1)..<count).map { CGPoint(x: xFor($0), y: yFor(series.values[$0])) })
                        .stroke(Theme.good, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        draw(at: drag.location, plot: plot, step: step)
                    }
                    .onEnded { _ in
                        lastTouched = nil
                    }
            )
        }
    }

    private func axisLabel(_ text: String, x: CGFloat, y: CGFloat, width: CGFloat, alignment: Alignment) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundColor(Theme.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: width, alignment: alignment)
            .offset(x: x, y: y)
    }

    private func line(points: [CGPoint]) -> Path {
        var path = Path()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func playerPoints(xFor: (Int) -> CGFloat, yFor: (Double) -> CGFloat) -> [CGPoint] {
        let series = game.series
        var points = [CGPoint(x: xFor(series.shown - 1), y: yFor(series.values[series.shown - 1]))]
        for (index, value) in game.drawn.enumerated() {
            guard let value = value else { break }
            points.append(CGPoint(x: xFor(series.shown + index), y: yFor(value)))
        }
        return points.count > 1 ? points : []
    }

    private func draw(at location: CGPoint, plot: CGRect, step: CGFloat) {
        let series = game.series
        guard !game.revealed, step > 0 else { return }
        let column = Int(((location.x - plot.minX) / step).rounded())
        let hidden = column - series.shown
        guard hidden >= 0, hidden < series.hiddenCount else { return }
        let share = Double((plot.maxY - location.y) / plot.height)
        let value = series.axisMin + share * (series.axisMax - series.axisMin)

        // A fast drag can skip columns. Fill them with a straight line.
        if let last = lastTouched, abs(last - hidden) > 1, let from = game.drawn[last] {
            let low = min(last, hidden)
            let high = max(last, hidden)
            for index in (low + 1)..<high {
                let t = Double(index - last) / Double(hidden - last)
                game.setValue(from + (value - from) * t, at: index)
            }
        }
        game.setValue(value, at: hidden)
        lastTouched = hidden
    }
}
