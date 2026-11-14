import SwiftUI

/// Where a tap on the menu leads: a game, in daily mode or free play.
struct GameRoute: Hashable {
    let kind: GameKind
    let mode: PlayMode
}

/// The main menu: every game in a list, grouped by what it tests. A switch
/// at the top chooses between today's daily puzzles and free play.
struct HubView: View {
    @EnvironmentObject private var scores: HighScoreStore
    @EnvironmentObject private var daily: DailyStore
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(Haptics.enabledKey) private var hapticsEnabled = true
    @AppStorage(Sound.enabledKey) private var soundEnabled = true
    @AppStorage("hub.showDaily") private var showDaily = true
    @State private var showStats = DemoMode.flag("stats")
    @State private var path: [GameRoute] = []
    @State private var confirmReset = false

    private static let sections: [(title: String, kinds: [GameKind])] = [
        ("Knowledge", [.globe, .fourfold, .topTen, .critter, .deep]),
        ("Numbers", [.price, .ballpark, .trend, .scale]),
        ("Senses", [.hue, .pitch, .beat])
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(spacing: 14) {
                        Picker("Mode", selection: $showDaily) {
                            Text("Daily").tag(true)
                            Text("Free Play").tag(false)
                        }
                        .pickerStyle(.segmented)

                        summary
                    }

                    ForEach(Self.sections, id: \.title) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                                .accessibilityAddTraits(.isHeader)

                            VStack(spacing: 0) {
                                ForEach(Array(section.kinds.enumerated()), id: \.element) { index, kind in
                                    link(for: kind)
                                    if index < section.kinds.count - 1 {
                                        Rectangle()
                                            .fill(Theme.hairline)
                                            .frame(height: 0.5)
                                            .padding(.leading, 88)
                                    }
                                }
                            }
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                                    .strokeBorder(Theme.hairline, lineWidth: 0.5)
                            )
                        }
                    }

                    Label("Everything works offline. Nothing leaves this iPhone.", systemImage: "lock.fill")
                        .font(.footnote)
                        .foregroundColor(Theme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
                .animation(Motion.quick, value: showDaily)
            }
            .background(Backdrop(colors: [Color(hex: 0x5E5CE6), Color(hex: 0x0A84FF)]))
            .navigationTitle("Guessing Games")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showStats = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                    .accessibilityLabel("Your stats")

                    Menu {
                        Toggle(isOn: $soundEnabled) {
                            Label("Sound Effects", systemImage: "speaker.wave.2")
                        }
                        Toggle(isOn: $hapticsEnabled) {
                            Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                        }
                        Divider()
                        Button(role: .destructive) {
                            confirmReset = true
                        } label: {
                            Label("Reset Scores and Stats", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route.kind {
                case .globe: GettingWarmerView(mode: route.mode)
                case .fourfold: FourfoldView(mode: route.mode)
                case .topTen: TopTenView(mode: route.mode)
                case .critter: CritterCluesView(mode: route.mode)
                case .deep: DeepCatchView(mode: route.mode)
                case .price: PricePointView(mode: route.mode)
                case .ballpark: BallparkView(mode: route.mode)
                case .trend: TrendlineView(mode: route.mode)
                case .scale: ScaleItView(mode: route.mode)
                case .hue: HueRecallView(mode: route.mode)
                case .pitch: PitchMatchView(mode: route.mode)
                case .beat: BeatKeeperView(mode: route.mode)
                }
            }
        }
        .tint(.white)
        .onAppear(perform: openRequestedGame)
        .sheet(isPresented: $showStats) {
            StatsSheet()
        }
        .onChange(of: scenePhase) { phase in
            // Midnight may have passed while the app was in the background.
            if phase == .active {
                daily.refresh()
            }
        }
        .confirmationDialog(
            "Reset all scores and stats?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset Scores", role: .destructive) {
                scores.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func link(for kind: GameKind) -> some View {
        if showDaily {
            let done = daily.score(for: kind.rawValue)
            NavigationLink(value: GameRoute(kind: kind, mode: .daily(day: daily.day))) {
                GameRow(kind: kind, state: done.map { .done(score: $0) } ?? .play(best: nil))
            }
            .buttonStyle(RowButtonStyle())
            // One go a day.
            .disabled(done != nil)
        } else {
            let best = scores.best(for: kind)
            NavigationLink(value: GameRoute(kind: kind, mode: .free)) {
                GameRow(kind: kind, state: .play(best: best > 0 ? best : nil))
            }
            .buttonStyle(RowButtonStyle())
        }
    }

    // MARK: - Summary

    private var totalBest: Int {
        GameKind.allCases.reduce(0) { $0 + scores.best(for: $1) }
    }

    private var totalMax: Int {
        GameKind.allCases.reduce(0) { $0 + $1.maxScore }
    }

    private var today: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased()
    }

    @ViewBuilder
    private var summary: some View {
        let total = GameKind.allCases.count
        if showDaily {
            let done = daily.finishedCount
            HStack(spacing: 16) {
                ZStack {
                    ProgressRing(fraction: Double(done) / Double(max(total, 1)))
                    Text("\(done)")
                        .font(.title3.bold())
                        .monospacedDigit()
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 3) {
                    Text(today).eyebrow()
                    Text(done == total ? "All done for today" : (done == 0 ? "\(total) puzzles today" : "\(total - done) puzzles left today"))
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill").foregroundColor(Theme.near)
                        Text(daily.streak == 1 ? "1 day streak" : "\(daily.streak) day streak")
                            .foregroundColor(Theme.textSecondary)
                    }
                    .font(.subheadline)
                }
                Spacer(minLength: 0)
            }
            .panel()
            .accessibilityElement(children: .combine)
        } else {
            HStack(spacing: 16) {
                ZStack {
                    ProgressRing(fraction: totalMax > 0 ? Double(totalBest) / Double(totalMax) : 0, tint: Theme.star)
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundColor(Theme.star)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 3) {
                    Text("YOUR BEST SCORES").eyebrow()
                    Text("\(NumberText.grouped(Double(totalBest))) points")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("out of \(NumberText.grouped(Double(totalMax))) across \(total) games")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .panel()
            .accessibilityElement(children: .combine)
        }
    }

    /// Launching with `-startGame globe` (or any other game's raw name from
    /// `GameKind`) opens that game directly in free play. Handy while testing.
    private func openRequestedGame() {
        guard path.isEmpty,
              let raw = UserDefaults.standard.string(forKey: "startGame"),
              let kind = GameKind(rawValue: raw) else { return }
        path = [GameRoute(kind: kind, mode: .free)]
    }
}

/// One game in the list: its icon, what it is, and a way in.
private struct GameRow: View {
    enum Status {
        /// Ready to play. `best` is the high score, if there is one.
        case play(best: Int?)
        /// Today's daily is finished with this score.
        case done(score: Int)
    }

    let kind: GameKind
    let state: Status

    var body: some View {
        HStack(spacing: 14) {
            GameIcon(kind: kind, size: 58)

            VStack(alignment: .leading, spacing: 3) {
                Text(kind.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(kind.tagline)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 6)

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    @ViewBuilder
    private var trailing: some View {
        switch state {
        case .play(let best):
            VStack(spacing: 5) {
                Text("PLAY")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(kind.accent)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.fillStrong))
                if let best = best {
                    Text("Best \(best)")
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundColor(Theme.textSecondary)
                }
            }
        case .done(let score):
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.good)
                    Text("\(score)")
                        .monospacedDigit()
                        .foregroundColor(.white)
                }
                .font(.headline)
                Text("of \(kind.maxScore)")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }

    private var spoken: String {
        switch state {
        case .play(let best):
            if let best = best {
                return "\(kind.title). \(kind.tagline) Best \(best) of \(kind.maxScore)."
            }
            return "\(kind.title). \(kind.tagline)"
        case .done(let score):
            return "\(kind.title). Finished today with \(score) of \(kind.maxScore)."
        }
    }
}

/// Rows light up under the finger, the way rows in iOS lists do.
private struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white.opacity(configuration.isPressed ? 0.1 : 0))
            .animation(configuration.isPressed ? nil : Motion.quick, value: configuration.isPressed)
    }
}

/// Best score, plays and average for every game.
private struct StatsSheet: View {
    @EnvironmentObject private var scores: HighScoreStore
    @EnvironmentObject private var daily: DailyStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 10) {
                        summary("\(scores.totalPlays)", "Games played")
                        summary("\(daily.streak)", "Day streak")
                        summary("\(daily.finishedCount)", "Dailies today")
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(GameKind.allCases.enumerated()), id: \.element) { index, kind in
                            HStack(spacing: 12) {
                                GameIcon(kind: kind, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(kind.title)
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text(detail(for: kind))
                                        .font(.footnote)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                Spacer(minLength: 4)
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text("\(scores.best(for: kind))")
                                        .font(.body.weight(.semibold))
                                        .monospacedDigit()
                                        .foregroundColor(.white)
                                    Text("of \(kind.maxScore)")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .accessibilityElement(children: .combine)

                            if index < GameKind.allCases.count - 1 {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 0.5)
                                    .padding(.leading, 66)
                            }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.surfaceRaised))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Theme.surface.ignoresSafeArea())
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(.white)
    }

    private func detail(for kind: GameKind) -> String {
        let plays = scores.playCount(for: kind)
        guard plays > 0, let average = scores.average(for: kind) else {
            return "Not played yet"
        }
        return plays == 1 ? "1 game, scored \(average)" : "\(plays) games, average \(average)"
    }

    private func summary(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surfaceRaised))
        .accessibilityElement(children: .combine)
    }
}
