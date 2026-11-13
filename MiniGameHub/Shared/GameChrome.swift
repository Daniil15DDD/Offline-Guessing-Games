import SwiftUI

/// The frame every game sits in: a bar with the back button, title and
/// scores, the game itself, and the result panel when a run ends. It also
/// saves high scores, so the games never touch storage.
struct GameChrome<Content: View>: View {
    private let kind: GameKind
    private let status: String
    private let score: Int
    private let isFinished: Bool
    private let onRestart: () -> Void
    private let content: () -> Content

    @EnvironmentObject private var scores: HighScoreStore
    @Environment(\.dismiss) private var dismiss
    @State private var isNewBest = false

    init(
        kind: GameKind,
        status: String,
        score: Int,
        isFinished: Bool,
        onRestart: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.kind = kind
        self.status = status
        self.score = score
        self.isFinished = isFinished
        self.onRestart = onRestart
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            bar
            ZStack {
                content()
                if isFinished {
                    result
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeOut(duration: 0.2), value: isFinished)
        }
        .background(
            ZStack {
                Theme.background
                // A wash of the game's own colour at the top of the screen.
                RadialGradient(
                    colors: [kind.accent.opacity(0.28), kind.accent.opacity(0)],
                    center: .top,
                    startRadius: 0,
                    endRadius: 420
                )
            }
            .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: isFinished) { finished in
            if finished {
                isNewBest = scores.submit(score, for: kind)
                if isNewBest {
                    Haptics.success()
                }
            }
        }
        .onDisappear {
            // Leaving part-way through still banks what was earned.
            scores.submit(score, for: kind)
        }
    }

    private var bar: some View {
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

            VStack(alignment: .leading, spacing: 1) {
                Text(kind.title)
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(status)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 4)

            stat("SCORE", score)
            stat("BEST", max(scores.best(for: kind), score))
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
        .frame(minWidth: 50)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surface))
        .accessibilityElement(children: .combine)
    }

    private var result: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 12) {
                Text(isNewBest ? "New best!" : "Finished")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text("\(score)")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(kind.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text("out of \(kind.maxScore). Your best is \(scores.best(for: kind)).")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    Button("Play again") {
                        isNewBest = false
                        onRestart()
                    }
                    .buttonStyle(PrimaryButtonStyle(kind: kind))

                    Button("Back to menu") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }
}

// MARK: - Shared pieces

struct PrimaryButtonStyle: ButtonStyle {
    let kind: GameKind

    func makeBody(configuration: Configuration) -> some View {
        StyledButtonLabel(configuration: configuration, fill: AnyShapeStyle(kind.gradient), isPrimary: true)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButtonLabel(configuration: configuration, fill: AnyShapeStyle(Theme.surfaceRaised), isPrimary: false)
    }
}

/// A view (not just a style) so it can read whether the button is enabled.
private struct StyledButtonLabel: View {
    let configuration: ButtonStyleConfiguration
    let fill: AnyShapeStyle
    let isPrimary: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.system(size: isPrimary ? 17 : 16, weight: isPrimary ? .bold : .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPrimary ? 14 : 13)
            .background(Capsule().fill(fill))
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.35)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension View {
    /// The rounded dark card most game content sits on.
    func panel(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface))
    }

    /// Small grey caption text.
    func caption() -> some View {
        self
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(Theme.textSecondary)
    }

    /// Standard white body text.
    func bodyText(_ size: CGFloat = 16, weight: Font.Weight = .semibold) -> some View {
        self
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundColor(.white)
    }
}

/// A text box styled for the games.
struct AnswerField: View {
    let placeholder: String
    @Binding var text: String
    var numeric = false
    let onSubmit: () -> Void

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .keyboardType(numeric ? .decimalPad : .default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit(onSubmit)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surfaceRaised))
    }
}

/// "+83" after a round.
struct PointsBadge: View {
    let points: Int

    var body: some View {
        Text("+\(points)")
            .font(.system(size: 30, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundColor(points >= 70 ? Theme.good : (points >= 30 ? Theme.near : Theme.bad))
    }
}

/// The scrolling column most games lay their content out in.
struct GameColumn<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
