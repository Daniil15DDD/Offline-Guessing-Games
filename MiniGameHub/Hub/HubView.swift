import SwiftUI

/// Where a tap on the menu leads: a game, in daily mode or free play.
struct GameRoute: Hashable {
    let kind: GameKind
    let mode: PlayMode
}

/// The main menu: a tile per game. A switch at the top chooses between
/// today's daily puzzles and free play.
struct HubView: View {
    @EnvironmentObject private var scores: HighScoreStore
    @EnvironmentObject private var daily: DailyStore
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(Haptics.enabledKey) private var hapticsEnabled = true
    @AppStorage(Sound.enabledKey) private var soundEnabled = true
    @State private var showStats = DemoMode.flag("stats")
    @AppStorage("hub.showDaily") private var showDaily = true
    @State private var path: [GameRoute] = []
    @State private var confirmReset = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    modeSwitch

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(GameKind.allCases) { kind in
                            if showDaily {
                                let done = daily.score(for: kind.rawValue)
                                NavigationLink(value: GameRoute(kind: kind, mode: .daily(day: daily.day))) {
                                    GameTile(kind: kind, footer: done.map { "Today: \($0) of \(kind.maxScore)" } ?? "Play today's puzzle",
                                             progress: done.map { fraction($0, of: kind.maxScore) } ?? 0, isDone: done != nil)
                                }
                                .buttonStyle(TileButtonStyle())
                                .disabled(done != nil)
                            } else {
                                let best = scores.best(for: kind)
                                NavigationLink(value: GameRoute(kind: kind, mode: .free)) {
                                    GameTile(kind: kind, footer: best > 0 ? "Best \(best) of \(kind.maxScore)" : "Not played yet",
                                             progress: fraction(best, of: kind.maxScore), isDone: false)
                                }
                                .buttonStyle(TileButtonStyle())
                            }
                        }
                    }

                    settings
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
            .background(
                ZStack {
                    Theme.background
                    RadialGradient(
                        colors: [Color(hex: 0x4F5BD5, opacity: 0.35), Color(hex: 0x4F5BD5, opacity: 0)],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 480
                    )
                }
                .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
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
            Button("Reset scores", role: .destructive) {
                scores.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var totalBest: Int {
        GameKind.allCases.reduce(0) { $0 + scores.best(for: $1) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                Text("WORKS OFFLINE")
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.12)))

            Text("Guessing Games")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            if showDaily {
                HStack(spacing: 14) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.good)
                        Text("\(daily.finishedCount) of \(GameKind.allCases.count) done today")
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill").foregroundColor(Color(hex: 0xFF8A3D))
                        Text(daily.streak == 1 ? "1 day streak" : "\(daily.streak) day streak")
                    }
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundColor(Color(hex: 0xF5C542))
                    Text("\(NumberText.grouped(Double(totalBest))) points across \(GameKind.allCases.count) games")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
    }

    /// Daily or free play.
    private var modeSwitch: some View {
        HStack(spacing: 4) {
            switchButton("Daily", systemImage: "calendar", isOn: showDaily) {
                showDaily = true
            }
            switchButton("Free play", systemImage: "infinity", isOn: !showDaily) {
                showDaily = false
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.1)))
    }

    private func switchButton(_ title: String, systemImage: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(isOn ? Color(hex: 0x14172A) : .white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(isOn ? Color.white : Color.clear))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func fraction(_ score: Int, of maximum: Int) -> CGFloat {
        maximum > 0 ? CGFloat(min(max(score, 0), maximum)) / CGFloat(maximum) : 0
    }

    private var settings: some View {
        VStack(spacing: 0) {
            Button {
                showStats = true
            } label: {
                HStack {
                    Label("Your stats", systemImage: "chart.bar.fill")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider().background(Color.white.opacity(0.08))

            Toggle(isOn: $soundEnabled) {
                Label("Sound effects", systemImage: "speaker.wave.2.fill")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .tint(Color(hex: 0x6C7BFF))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.08))

            Toggle(isOn: $hapticsEnabled) {
                Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .tint(Color(hex: 0x6C7BFF))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.08))

            Button {
                confirmReset = true
            } label: {
                HStack {
                    Label("Reset scores and stats", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer()
                }
                .foregroundColor(Color(hex: 0xFF6B81))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
        )
        .padding(.top, 6)
    }

    /// Launching with `-startGame globe` (or any other game's raw name from
    /// `GameKind`) opens that game directly in free play. Handy while testing.
    private func openRequestedGame() {
        if DemoMode.flag("sound") { Sound.win() }
        guard path.isEmpty,
              let raw = UserDefaults.standard.string(forKey: "startGame"),
              let kind = GameKind(rawValue: raw) else { return }
        path = [GameRoute(kind: kind, mode: .free)]
    }
}

private struct GameTile: View {
    let kind: GameKind
    /// The line under the progress bar.
    let footer: String
    /// How full the bar is, from 0 to 1.
    let progress: CGFloat
    /// Today's daily is finished: show a tick and dim the tile.
    let isDone: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(kind.art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
            }

            Spacer(minLength: 6)

            Text(kind.title)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(kind.tagline)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(height: 32, alignment: .topLeading)
                .padding(.top, 2)

            // Best score as a bar.
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.22))
                    Capsule()
                        .fill(Color.white)
                        .frame(width: max(geometry.size.width * progress, progress > 0 ? 6 : 0))
                }
            }
            .frame(height: 6)
            .padding(.top, 8)

            Text(footer)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 5)
        }
        .padding(14)
        .frame(height: 214)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous).fill(kind.gradient)
        )
        .overlay(
            // A soft highlight across the top edge.
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.5
                )
        )
        .shadow(color: kind.colors[1].opacity(0.35), radius: 12, x: 0, y: 8)
        .saturation(isDone ? 0.55 : 1)
        .opacity(isDone ? 0.75 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title). \(kind.tagline) \(footer).")
    }
}

private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Best score, plays and average for every game.
private struct StatsSheet: View {
    @EnvironmentObject private var scores: HighScoreStore
    @EnvironmentObject private var daily: DailyStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Your stats")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Theme.surfaceRaised))
                    }
                    .accessibilityLabel("Close")
                }

                HStack(spacing: 10) {
                    summary("\(scores.totalPlays)", "games played")
                    summary("\(daily.streak)", "day streak")
                    summary("\(daily.finishedCount)", "dailies today")
                }

                ForEach(GameKind.allCases) { kind in
                    HStack(spacing: 12) {
                        Image(kind.art)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(kind.title)
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text(detail(for: kind)).caption()
                        }
                        Spacer(minLength: 4)
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(scores.best(for: kind))")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(kind.gradient)
                            Text("best of \(kind.maxScore)")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surfaceRaised))
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(20)
        }
        .background(Theme.surface.ignoresSafeArea())
    }

    private func detail(for kind: GameKind) -> String {
        let plays = scores.playCount(for: kind)
        guard plays > 0, let average = scores.average(for: kind) else {
            return "Not played yet"
        }
        return plays == 1 ? "1 game, scored \(average)" : "\(plays) games, average \(average)"
    }

    private func summary(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surfaceRaised))
    }
}
