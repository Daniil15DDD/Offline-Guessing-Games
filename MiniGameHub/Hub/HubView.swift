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
                VStack(alignment: .leading, spacing: 16) {
                    header

                    ForEach(GameKind.allCases) { kind in
                        NavigationLink(value: kind) {
                            GameCard(kind: kind, best: scores.best(for: kind))
                        }
                        .buttonStyle(CardButtonStyle())
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
                case .runner: RunnerGameView()
                case .merge: MergeGameView()
                case .snake: SnakeGameView()
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

            Text("Mini Game Hub")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Three quick games. Your best scores stay on this iPhone.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.bottom, 6)
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
        .padding(.top, 10)
    }

    /// Launching with `-startGame runner` (or `merge`, `snake`) opens that
    /// game directly. Handy while testing from Xcode's scheme arguments.
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
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(kind.gradient)
                .frame(width: 68, height: 68)
                .overlay(
                    Image(systemName: kind.symbol)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
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
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(kind.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(minWidth: 54)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(kind.title). Best score \(best).")
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
