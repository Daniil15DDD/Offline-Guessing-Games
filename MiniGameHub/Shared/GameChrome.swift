import SwiftUI
import UIKit

/// The frame every game sits in: the system navigation bar, a strip with
/// the round and the scores, the game itself, and the result card when a
/// run ends. It also saves high scores, so the games never touch storage.
struct GameChrome<Content: View>: View {
    private let kind: GameKind
    private let mode: PlayMode
    private let status: String
    private let score: Int
    private let isFinished: Bool
    private let onRestart: () -> Void
    private let content: () -> Content

    @EnvironmentObject private var scores: HighScoreStore
    @EnvironmentObject private var daily: DailyStore
    @Environment(\.dismiss) private var dismiss
    @State private var isNewBest = false
    @State private var showRules = DemoMode.flag("rules")

    init(
        kind: GameKind,
        mode: PlayMode = .free,
        status: String,
        score: Int,
        isFinished: Bool,
        onRestart: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.kind = kind
        self.mode = mode
        self.status = status
        self.score = score
        self.isFinished = isFinished
        self.onRestart = onRestart
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                strip
            }
            .background(Backdrop(colors: kind.colors))
            .overlay {
                ZStack(alignment: .bottom) {
                    if isFinished {
                        // Dim the game so the result is the one thing to read.
                        Color.black.opacity(0.55)
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .zIndex(1)

                        if StarRating.stars(for: fraction) >= 2 && !UIAccessibility.isReduceMotionEnabled {
                            ConfettiView(colors: kind.colors + [.white, Theme.star])
                                .ignoresSafeArea()
                                .zIndex(2)
                        }

                        ResultCard(
                            kind: kind,
                            isDaily: mode.isDaily,
                            score: score,
                            best: max(scores.best(for: kind), score),
                            isNewBest: isNewBest,
                            streak: daily.streak,
                            shareText: shareText,
                            onRestart: {
                                isNewBest = false
                                onRestart()
                            },
                            onLeave: { dismiss() }
                        )
                        // Comes up from the bottom edge and leaves the same way.
                        .transition(Motion.sheet)
                        .zIndex(3)
                    }
                }
                .animation(Motion.settle, value: isFinished)
            }
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            // The strip below supplies the bar's material, so the two read
            // as one surface.
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showRules = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("How to play")
                }
            }
            .onChange(of: isFinished) { finished in
                guard finished else { return }
                hideKeyboard()
                isNewBest = scores.finishRun(score, for: kind)
                if let day = mode.day {
                    daily.record(score, for: kind.rawValue, day: day)
                }
                if isNewBest || StarRating.stars(for: fraction) >= 2 {
                    Feedback.win()
                }
            }
            .onDisappear {
                // Leaving part-way through still banks what was earned.
                scores.submit(score, for: kind)
            }
            .sheet(isPresented: $showRules) {
                RulesSheet(kind: kind)
            }
    }

    /// Score as a share of the best possible score.
    private var fraction: Double {
        kind.maxScore > 0 ? Double(score) / Double(kind.maxScore) : 0
    }

    /// Plain text for the share button.
    private var shareText: String {
        var lines = ["Guessing Games"]
        if let day = mode.day {
            lines.append("\(kind.title), daily puzzle \(day + 1)")
        } else {
            lines.append(kind.title)
        }
        let stars = StarRating.stars(for: fraction)
        lines.append("\(score) of \(kind.maxScore) points, \(stars) of 3 stars")
        return lines.joined(separator: "\n")
    }

    /// Sits directly under the navigation bar and shares its material.
    private var strip: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.isDaily ? "DAILY PUZZLE" : "FREE PLAY")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(kind.accent)
                Text(status)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 8)

            stat("SCORE", score)
            Rectangle()
                .fill(Theme.hairline)
                .frame(width: 0.5, height: 26)
            stat("BEST", max(scores.best(for: kind), score))
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.hairline).frame(height: 0.5)
        }
    }

    private func stat(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundColor(Theme.textSecondary)
            Text("\(value)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(Motion.quick, value: value)
        }
        .frame(minWidth: 44, alignment: .trailing)
        .accessibilityElement(children: .combine)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Result

/// The card that rises from the bottom when a run ends.
private struct ResultCard: View {
    let kind: GameKind
    let isDaily: Bool
    let score: Int
    let best: Int
    let isNewBest: Bool
    let streak: Int
    let shareText: String
    let onRestart: () -> Void
    let onLeave: () -> Void

    /// The number on show, which counts up to the score.
    @State private var shownScore = 0.0

    private var fraction: Double {
        kind.maxScore > 0 ? Double(score) / Double(kind.maxScore) : 0
    }

    private var headline: String {
        if isNewBest { return "New best" }
        if isDaily { return "Today's result" }
        switch StarRating.stars(for: fraction) {
        case 3: return "Outstanding"
        case 2: return "Well played"
        case 1: return "Not bad"
        default: return "Finished"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            StarRating(fraction: fraction)

            Text(headline)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .padding(.top, 14)

            CountingText(value: shownScore)
                .font(.system(size: 68, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(LinearGradient(colors: kind.colors, startPoint: .top, endPoint: .bottom))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .accessibilityLabel("\(score) points")

            Text("out of \(kind.maxScore)  ·  best \(best)")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)

            if isDaily {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundColor(Theme.near)
                    Text(streak == 1 ? "1 day streak" : "\(streak) day streak")
                        .foregroundColor(.white)
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.fill))
                .padding(.top, 14)

                Text("A new daily puzzle arrives at midnight.")
                    .font(.footnote)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }

            VStack(spacing: 10) {
                if isDaily {
                    // One go per day: no "Play again" here.
                    Button("Done", action: onLeave)
                        .buttonStyle(PrimaryButtonStyle(kind: kind))
                    ShareLink(item: shareText) {
                        Label("Share result", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                } else {
                    Button("Play again", action: onRestart)
                        .buttonStyle(PrimaryButtonStyle(kind: kind))
                    HStack(spacing: 10) {
                        Button("Menu", action: onLeave)
                            .buttonStyle(SecondaryButtonStyle())
                        ShareLink(item: shareText) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
            .padding(.top, 22)
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .onAppear {
            if UIAccessibility.isReduceMotionEnabled {
                shownScore = Double(score)
            } else {
                withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
                    shownScore = Double(score)
                }
            }
        }
    }
}

/// A whole number that can be animated, so it counts up rather than jumps.
struct CountingText: View, Animatable {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value.rounded()))")
    }
}

// MARK: - Buttons

/// The one filled button on a screen, in the game's colours.
struct PrimaryButtonStyle: ButtonStyle {
    let kind: GameKind

    func makeBody(configuration: Configuration) -> some View {
        StyledButtonLabel(
            configuration: configuration,
            fill: AnyShapeStyle(LinearGradient(colors: kind.colors, startPoint: .top, endPoint: .bottom))
        )
    }
}

/// A quieter grey button for everything else.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledButtonLabel(configuration: configuration, fill: AnyShapeStyle(Theme.fillStrong))
    }
}

/// A view (not just a style) so it can read whether the button is enabled.
private struct StyledButtonLabel: View {
    let configuration: ButtonStyleConfiguration
    let fill: AnyShapeStyle

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous).fill(fill))
            .opacity(isEnabled ? 1 : 0.4)
            .pressable(configuration.isPressed)
    }
}

/// For cards and tiles that act as buttons: they only need the press.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.pressable(configuration.isPressed)
    }
}

extension View {
    /// What a finger going down looks like everywhere in the app: the view
    /// sinks a little at once, then springs back when let go.
    func pressable(_ isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1)
            .brightness(isPressed ? -0.06 : 0)
            .animation(isPressed ? Motion.press : Motion.quick, value: isPressed)
    }

    /// The translucent card most game content sits on.
    func panel(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 0.5)
            )
    }

    /// One line in a list of guesses or suggestions.
    func row() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill))
    }

    /// Small grey caption text.
    func caption() -> some View {
        self
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(Theme.textSecondary)
    }

    /// Standard white body text.
    func bodyText(_ size: CGFloat = 16, weight: Font.Weight = .semibold) -> some View {
        self
            .font(.system(size: size, weight: weight))
            .foregroundColor(.white)
    }

    /// A small heading in capitals above a group of things.
    func eyebrow() -> some View {
        self
            .font(.caption2.weight(.semibold))
            .foregroundColor(Theme.textSecondary)
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
            .font(.system(size: 17))
            .foregroundColor(.white)
            .tint(.white)
            .keyboardType(numeric ? .decimalPad : .default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit(onSubmit)
            .padding(.horizontal, 14)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous).fill(Theme.fill))
    }
}

/// "+83" after a round. It pops in, because it is the pay-off of a guess.
struct PointsBadge: View {
    let points: Int

    @State private var shown = false

    var body: some View {
        Text("+\(points)")
            .font(.system(size: 34, weight: .bold))
            .monospacedDigit()
            .foregroundColor(points >= 70 ? Theme.good : (points >= 30 ? Theme.near : Theme.bad))
            .scaleEffect(shown || UIAccessibility.isReduceMotionEnabled ? 1 : 0.6)
            .opacity(shown ? 1 : 0)
            .onAppear {
                withAnimation(Motion.bounce.delay(0.1)) {
                    shown = true
                }
            }
            .accessibilityLabel("\(points) points")
    }
}

/// The scrolling column most games lay their content out in.
struct GameColumn<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
