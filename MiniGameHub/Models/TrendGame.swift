import Foundation
import Combine

/// Trendline: the first part of a real chart is shown. Draw where you think
/// the line went next, then see the real data.
final class TrendGame: ObservableObject {
    static let rounds = 3
    static let maxScore = rounds * 100

    @Published private(set) var series: TrendSeries
    @Published private(set) var roundIndex = 0
    /// The player's value for each hidden point. Nil until drawn.
    @Published private(set) var drawn: [Double?] = []
    @Published private(set) var revealed = false
    /// Average distance from the real line, as a share of the chart height.
    @Published private(set) var averageGap = 0.0
    @Published private(set) var lastPoints = 0
    @Published private(set) var score = 0
    @Published private(set) var isFinished = false

    private let allSeries: [TrendSeries]
    private var queue: [Int] = []

    init(series: [TrendSeries] = TrendSeriesData.all) {
        precondition(!series.isEmpty, "Trendline needs charts")
        self.allSeries = series
        self.series = series[0]
        deal()
    }

    func restart() {
        score = 0
        roundIndex = 0
        isFinished = false
        deal()
    }

    private func deal() {
        queue = Deck.draw("trend", count: allSeries.count, take: Self.rounds)
        startRound()
    }

    private func startRound() {
        series = allSeries[queue[min(roundIndex, queue.count - 1)]]
        drawn = Array(repeating: nil, count: series.hiddenCount)
        revealed = false
        averageGap = 0
        lastPoints = 0
    }

    var canSubmit: Bool {
        !revealed && !drawn.isEmpty && drawn.allSatisfy { $0 != nil }
    }

    /// Sets the player's value for one hidden point (0 is the first hidden one).
    func setValue(_ value: Double, at hiddenIndex: Int) {
        guard !revealed, drawn.indices.contains(hiddenIndex), value.isFinite else { return }
        drawn[hiddenIndex] = min(series.axisMax, max(series.axisMin, value))
    }

    func clearDrawing() {
        guard !revealed else { return }
        drawn = Array(repeating: nil, count: series.hiddenCount)
    }

    func submit() {
        guard canSubmit else { return }
        let values = drawn.compactMap { $0 }
        averageGap = Self.gap(drawn: values, series: series)
        lastPoints = Scoring.closeness(error: averageGap, perfect: 0.01, zero: 0.2)
        score += lastPoints
        revealed = true
    }

    static func gap(drawn: [Double], series: TrendSeries) -> Double {
        let real = Array(series.values.suffix(series.hiddenCount))
        let height = series.axisMax - series.axisMin
        guard drawn.count == real.count, !real.isEmpty, height > 0 else { return 1 }
        var total = 0.0
        for index in real.indices {
            total += abs(drawn[index] - real[index]) / height
        }
        return total / Double(real.count)
    }

    func next() {
        guard revealed, !isFinished else { return }
        if roundIndex + 1 >= min(Self.rounds, queue.count) {
            isFinished = true
        } else {
            roundIndex += 1
            startRound()
        }
    }
}
