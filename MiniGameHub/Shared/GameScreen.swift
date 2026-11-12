import SwiftUI

/// The frame every game sits in: a score bar on top, the game in the middle,
/// and the "ready", "paused" and "game over" overlays. It also takes care of
/// saving high scores, so the scenes never touch storage.
struct GameScreen<Content: View>: View {
    private let kind: GameKind
    @ObservedObject private var session: GameSession
    private let onRestart: () -> Void
    private let content: () -> Content

    @EnvironmentObject private var scores: HighScoreStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(
        kind: GameKind,
        session: GameSession,
        onRestart: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.kind = kind
        self.session = session
        self.onRestart = onRestart
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            scoreBar
            ZStack {
                content()
                overlay
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeOut(duration: 0.2), value: session.phase)
        }
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: session.phase) { phase in
            if phase == .gameOver {
                commitScore()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            guard newPhase != .active else { return }
            // Leaving the app: bank the score and stop the clock.
            commitScore()
            if session.phase == .playing && kind.supportsPause {
                session.setPhase(.paused)
            }
        }
        .onDisappear {
            commitScore()
        }
    }

    // MARK: - Score bar

    private var scoreBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Theme.surface))
            }
            .accessibilityLabel("Back to menu")

            Text(kind.title)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 4)

            stat("SCORE", session.score)
            stat("BEST", max(scores.best(for: kind), session.score))

            if kind.supportsPause {
                Button {
                    session.setPhase(.paused)
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Theme.surface))
                }
                .disabled(session.phase != .playing)
                .opacity(session.phase == .playing ? 1 : 0.35)
                .accessibilityLabel("Pause")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func stat(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textSecondary)
            Text("\(value)")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(minWidth: 52)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surface))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Overlays

    @ViewBuilder
    private var overlay: some View {
        switch session.phase {
        case .ready:
            VStack {
                Text(kind.hint)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
                    .padding(.top, 26)
                    .padding(.horizontal, 24)
                Spacer()
            }
            .allowsHitTesting(false)  // taps go through to the game
            .transition(.opacity)

        case .playing:
            EmptyView()

        case .paused:
            dimmed {
                panel(title: "Paused", message: nil) {
                    Button("Resume") {
                        session.setPhase(.playing)
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))

                    Button("Restart") {
                        commitScore()
                        onRestart()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Back to menu") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }

        case .gameOver:
            dimmed {
                panel(
                    title: session.isNewBest ? "New best!" : "Game over",
                    message: session.isNewBest
                        ? "You beat your record."
                        : "Best: \(scores.best(for: kind))"
                ) {
                    Button("Play again") {
                        onRestart()
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))

                    Button("Back to menu") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }

    private func dimmed<Inner: View>(@ViewBuilder _ inner: () -> Inner) -> some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            inner()
        }
        .transition(.opacity)
    }

    private func panel<Buttons: View>(
        title: String,
        message: String?,
        @ViewBuilder buttons: () -> Buttons
    ) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            if session.phase == .gameOver {
                Text("\(session.score)")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(kind.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            if let message = message {
                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }

            VStack(spacing: 10) {
                buttons()
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 32)
    }

    // MARK: - High score

    private func commitScore() {
        if scores.submit(session.score, for: kind) {
            session.isNewBest = true
        }
    }
}

// MARK: - Button styles

struct PrimaryButtonStyle: ButtonStyle {
    let kind: GameKind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(kind.gradient))
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Capsule().fill(Theme.surfaceRaised))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
