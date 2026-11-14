import SwiftUI
import UIKit

struct DeepCatchView: View {
    @StateObject private var game: RareGame
    private let mode: PlayMode
    @State private var text = ""
    /// The clock only runs once the player has pressed Start.
    @State private var started = false

    private let kind = GameKind.deep
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    /// Every point is ten metres of line.
    static let metresPerPoint = 10
    static var maxDepth: Int { RareGame.maxScore * metresPerPoint }

    private var depth: Int { game.score * Self.metresPerPoint }

    init(mode: PlayMode = .free) {
        self.mode = mode
        _game = StateObject(wrappedValue: RareGame(mode: mode))
    }

    var body: some View {
        GameChrome(
            kind: kind,
            mode: mode,
            status: "Depth \(NumberText.grouped(Double(depth))) m",
            score: game.score,
            isFinished: game.isFinished,
            onRestart: {
                text = ""
                game.restart()
            }
        ) {
            GameColumn {
                WaterColumn(depth: Double(depth), maxDepth: Double(Self.maxDepth))

                if started {
                    roundContent
                } else {
                    intro
                        .transition(Motion.rise)
                }
            }
        }
        .onReceive(clock) { now in
            if started {
                game.tick(now: now)
            }
        }
    }

    private var intro: some View {
        VStack(spacing: 12) {
            Text("How deep can your line go?")
                .bodyText(20, weight: .bold)
                .multilineTextAlignment(.center)
            Text("\(RareGame.rounds) prompts, \(Int(RareGame.secondsPerPrompt)) seconds each. Any answer that fits lowers the hook. Obvious answers sink it 100 metres. The rarest sink it 1,000.")
                .caption()
                .multilineTextAlignment(.center)
            Button("Cast off") {
                withAnimation(Motion.settle) {
                    started = true
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
        }
        .panel()
    }

    @ViewBuilder
    private var roundContent: some View {
        VStack(spacing: 12) {
            Text("PROMPT \(game.roundIndex + 1) OF \(RareGame.rounds)").eyebrow()
            Text(game.prompt.text)
                .bodyText(23, weight: .bold)
                .multilineTextAlignment(.center)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.fillStrong)
                    Capsule()
                        .fill(game.timeLeft > 8 ? kind.accent : Theme.bad)
                        .frame(width: geometry.size.width * CGFloat(game.timeLeft / RareGame.secondsPerPrompt))
                        // The clock ticks ten times a second. Gliding
                        // between ticks keeps the bar from stepping.
                        .animation(.linear(duration: 0.1), value: game.timeLeft)
                }
            }
            .frame(height: 6)
            .accessibilityLabel("\(Int(game.timeLeft.rounded(.up))) seconds left")
        }
        .panel()

        if game.roundOver {
            reveal
                .transition(Motion.rise)
        } else {
            HStack(spacing: 8) {
                AnswerField(placeholder: "Your answer", text: $text, onSubmit: submit)
                Button("Drop", action: submit)
                    .buttonStyle(PrimaryButtonStyle(kind: kind))
                    .frame(width: 90)
            }
            if !game.rejected.isEmpty {
                Text("No bite: " + game.rejected.joined(separator: ", "))
                    .font(.system(size: 13))
                    .foregroundColor(Theme.bad)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var reveal: some View {
        VStack(spacing: 8) {
            if let answer = game.accepted {
                Image(Self.catchArt(tier: answer.tier))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                Text(RarePrompts.tierNames[answer.tier - 1].uppercased() + " ANSWER")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(kind.accent)
                Text(answer.name)
                    .bodyText(24, weight: .bold)
                    .multilineTextAlignment(.center)
                Text("\(NumberText.grouped(Double(game.lastPoints * Self.metresPerPoint))) m deeper")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.good)
            } else {
                Text("Out of time").bodyText(22, weight: .bold)
                Text("The hook stays where it is.").caption()
            }
            if !game.rarestExamples.isEmpty {
                Text("Among the rarest answers: " + game.rarestExamples.joined(separator: ", "))
                    .caption()
                    .multilineTextAlignment(.center)
            }
            Button(game.roundIndex + 1 >= RareGame.rounds ? "Reel in" : "Next prompt") {
                text = ""
                withAnimation(Motion.settle) {
                    game.next()
                }
            }
            .buttonStyle(PrimaryButtonStyle(kind: kind))
            .padding(.top, 4)

            if game.roundIndex + 1 >= RareGame.rounds {
                diveLog
            }
        }
        .panel()
    }

    /// The whole dive, shown after the last prompt.
    private var diveLog: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DIVE LOG").eyebrow()
            ForEach(game.log) { entry in
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.answer ?? "No answer")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(entry.answer == nil ? Theme.bad : .white)
                        Text(entry.prompt)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer(minLength: 4)
                    Text(entry.points > 0 ? "\(NumberText.grouped(Double(entry.points * Self.metresPerPoint))) m" : "0 m")
                        .font(.system(size: 15, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(entry.points > 0 ? Theme.good : Theme.textSecondary)
                }
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Rarer answers hook bigger things.
    private static func catchArt(tier: Int) -> String {
        switch tier {
        case 1: return "sea_fish"
        case 2: return "sea_tropical"
        case 3: return "sea_squid"
        case 4: return "sea_shark"
        default: return "sea_whale"
        }
    }

    private func submit() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var accepted = false
        withAnimation(Motion.settle) {
            accepted = game.submit(text)
        }
        if accepted {
            Feedback.success()
        } else {
            Feedback.failure()
        }
        text = ""
    }
}

/// A slice of ocean with a fishing line. The hook sinks as the score grows.
private struct WaterColumn: View {
    let depth: Double
    let maxDepth: Double

    @State private var drifting = false

    /// Sea life at fixed depths: picture, how far across (0 to 1), depth in
    /// metres, drawn size.
    private let life: [(String, CGFloat, Double, CGFloat)] = [
        ("sea_tropical", 0.16, 250, 30),
        ("sea_turtle", 0.82, 600, 38),
        ("sea_dolphin", 0.26, 1150, 44),
        ("sea_fish", 0.78, 1700, 30),
        ("sea_jelly", 0.14, 2500, 34),
        ("sea_shark", 0.80, 3100, 50),
        ("sea_squid", 0.22, 4000, 40),
        ("sea_octopus", 0.84, 4900, 40),
        ("sea_whale", 0.24, 5800, 58),
        ("sea_crab", 0.70, 6800, 28),
        ("sea_coral", 0.10, 6850, 34),
        ("sea_shell", 0.90, 6880, 24)
    ]

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let surface: CGFloat = 44
            let floorHeight: CGFloat = 14
            let water = height - surface - floorHeight
            let y: (Double) -> CGFloat = { metres in
                surface + water * CGFloat(min(max(metres / maxDepth, 0), 1))
            }
            let hookY = y(depth)
            let lineX = width * 0.5

            ZStack(alignment: .topLeading) {
                // Sky, water and sea bed.
                LinearGradient(
                    colors: [Color(hex: 0x8FD3FF), Color(hex: 0xD8F1FF)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: surface)

                LinearGradient(
                    stops: [
                        .init(color: Color(hex: 0x25B7D3), location: 0),
                        .init(color: Color(hex: 0x1466B8), location: 0.18),
                        .init(color: Color(hex: 0x102E7A), location: 0.5),
                        .init(color: Color(hex: 0x070B2A), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height - surface)
                .offset(y: surface)

                Rectangle()
                    .fill(Color(hex: 0x2A2440))
                    .frame(height: floorHeight)
                    .offset(y: height - floorHeight)

                // Depth marks.
                ForEach([1000, 2000, 3000, 4000, 5000, 6000], id: \.self) { mark in
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 8, height: 1)
                        Text("\(NumberText.grouped(Double(mark)))")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .offset(x: 0, y: y(Double(mark)) - 5)
                }

                ForEach(Array(life.enumerated()), id: \.offset) { index, item in
                    Image(item.0)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.3, height: item.3)
                        .opacity(0.9)
                        .position(x: width * item.1, y: min(y(item.2), height - floorHeight - item.3 * 0.35))
                        .offset(x: drifting ? (index % 2 == 0 ? 7 : -7) : (index % 2 == 0 ? -7 : 7))
                }

                // Boat, line and hook.
                Image("sea_boat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .position(x: lineX + 6, y: surface - 16)

                Path { path in
                    path.move(to: CGPoint(x: lineX, y: surface - 8))
                    path.addLine(to: CGPoint(x: lineX, y: hookY))
                }
                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)

                Image("sea_hook")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .position(x: lineX, y: hookY + 12)

                Text("\(NumberText.grouped(depth)) m")
                    .font(.system(size: 13, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .position(x: lineX + 58, y: max(hookY + 12, surface + 14))
            }
            // A weight on a line: slow to get going, with a little bob as
            // the line takes up the slack.
            .animation(UIAccessibility.isReduceMotionEnabled ? .easeInOut(duration: 0.2) : .spring(response: 1.0, dampingFraction: 0.8), value: depth)
        }
        .frame(height: 270)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5)
        )
        .onAppear {
            // The sea life drifts gently. Left still when the player has
            // asked the system for less motion.
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                drifting = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your hook is \(Int(depth)) metres down")
    }
}
