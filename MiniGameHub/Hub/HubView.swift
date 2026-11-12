import SwiftUI

/// The main menu: one card per game, each showing the saved best score.
struct HubView: View {
    @EnvironmentObject private var scores: HighScoreStore
    @AppStorage(Haptics.enabledKey) private var hapticsEnabled = true
    @State private var path: [GameKind] = []
    @State private var confirmReset = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    header

                    ForEach(GameKind.Shelf.allCases) { shelf in
                        Text(shelf.rawValue.uppercased())
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                            .padding(.top, 10)

                        ForEach(GameKind.allCases.filter { $0.shelf == shelf }) { kind in
                            NavigationLink(value: kind) {
                                GameCard(kind: kind, best: scores.best(for: kind))
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }

                    settings
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Theme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: GameKind.self) { kind in
                switch kind {
                case .borderline: BorderlineView()
                case .fourfold: FourfoldView()
                case .topTen: TopTenView()
                case .critter: CritterCluesView()
                case .rare: RareFindView()
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                Text("WORKS OFFLINE")
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(Theme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.surface))

            Text("Guessing Games")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Twelve quick games. Your best scores stay on this iPhone.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
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
        .padding(.top, 16)
    }

    /// Launching with `-startGame borderline` (or any other game's raw
    /// name from `GameKind`) opens that game directly. Handy while testing.
    private func openRequestedGame() {
        guard path.isEmpty,
              let raw = UserDefaults.standard.string(forKey: "startGame"),
              let kind = GameKind(rawValue: raw) else { return }
        path = [kind]
    }
}

private struct GameCard: View {
    let kind: GameKind
    let best: Int

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(kind.gradient)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: kind.symbol)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(kind.title)
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(kind.tagline)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            VStack(spacing: 2) {
                Text("BEST")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                Text("\(best)")
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(kind.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("of \(kind.maxScore)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(minWidth: 50)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(kind.title). Best score \(best) of \(kind.maxScore).")
    }
}

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
