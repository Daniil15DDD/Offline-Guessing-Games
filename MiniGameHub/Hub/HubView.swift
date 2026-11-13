import SwiftUI

/// The main menu: a tile per game, each showing the saved best score.
struct HubView: View {
    @EnvironmentObject private var scores: HighScoreStore
    @AppStorage(Haptics.enabledKey) private var hapticsEnabled = true
    @State private var path: [GameKind] = []
    @State private var confirmReset = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(GameKind.allCases) { kind in
                            NavigationLink(value: kind) {
                                GameTile(kind: kind, best: scores.best(for: kind))
                            }
                            .buttonStyle(TileButtonStyle())
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
            .navigationDestination(for: GameKind.self) { kind in
                switch kind {
                case .globe: GettingWarmerView()
                case .fourfold: FourfoldView()
                case .topTen: TopTenView()
                case .critter: CritterCluesView()
                case .deep: DeepCatchView()
                case .price: PricePointView()
                case .ballpark: BallparkView()
                case .trend: TrendlineView()
                case .scale: ScaleItView()
                case .hue: HueRecallView()
                case .pitch: PitchMatchView()
                case .beat: BeatKeeperView()
                }
            }
        }
        .tint(.white)
        .onAppear(perform: openRequestedGame)
        .confirmationDialog(
            "Reset all high scores?",
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

            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundColor(Color(hex: 0xF5C542))
                Text("\(NumberText.grouped(Double(totalBest))) points across \(GameKind.allCases.count) games")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    private var settings: some View {
        VStack(spacing: 0) {
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
                    Label("Reset high scores", systemImage: "arrow.counterclockwise")
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
    /// `GameKind`) opens that game directly. Handy while testing.
    private func openRequestedGame() {
        guard path.isEmpty,
              let raw = UserDefaults.standard.string(forKey: "startGame"),
              let kind = GameKind(rawValue: raw) else { return }
        path = [kind]
    }
}

private struct GameTile: View {
    let kind: GameKind
    let best: Int

    private var progress: CGFloat {
        kind.maxScore > 0 ? CGFloat(min(best, kind.maxScore)) / CGFloat(kind.maxScore) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
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
                        .frame(width: max(geometry.size.width * progress, best > 0 ? 6 : 0))
                }
            }
            .frame(height: 6)
            .padding(.top, 8)

            Text(best > 0 ? "Best \(best) of \(kind.maxScore)" : "Not played yet")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title). \(kind.tagline) Best score \(best) of \(kind.maxScore).")
    }
}

private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
