// Mini Game Hub, all in one file.
//
// How to use:
//   1. Xcode > File > New > Project > iOS > App.
//      Interface: SwiftUI. Language: Swift. Minimum deployment: iOS 16 or later.
//   2. Delete the two Swift files Xcode created (ContentView.swift and
//      <YourProjectName>App.swift).
//   3. Add this file to the project and press Run.
//
// This file is generated from the sources in the MiniGameHub folder by
// CopyPaste/regenerate.py. Edit those sources, not this copy.

import SwiftUI
import SpriteKit
import Combine
import UIKit

// ==========================================================================
// MARK: - MiniGameHubApp.swift
// ==========================================================================

@main
struct MiniGameHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var scores = HighScoreStore()

    var body: some Scene {
        WindowGroup {
            HubView()
                .environmentObject(scores)
                .preferredColorScheme(.dark)
        }
    }
}

/// Keeps the app in portrait no matter how the project's orientation
/// checkboxes are set. All three games are laid out for a tall screen.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }
}

// ==========================================================================
// MARK: - Shared/GameKind.swift
// ==========================================================================

/// The games available in the hub. Add a case here (and a destination in
/// `HubView`) to add another game.
enum GameKind: String, CaseIterable, Identifiable, Hashable {
    case runner
    case merge
    case snake

    var id: String { rawValue }

    var title: String {
        switch self {
        case .runner: return "Moon Dash"
        case .merge: return "Tile Fuse"
        case .snake: return "Neon Snake"
        }
    }

    var tagline: String {
        switch self {
        case .runner: return "Endless runner. Jump the rocks, dodge the drones."
        case .merge: return "Slide the grid. Matching tiles fuse and double."
        case .snake: return "Eat, grow, and stay away from the walls."
        }
    }

    /// Shown over the game before the first input.
    var hint: String {
        switch self {
        case .runner: return "Tap to jump. Tap again in the air to double jump."
        case .merge: return "Swipe to slide the tiles."
        case .snake: return "Swipe to steer. Tap to start."
        }
    }

    /// SF Symbol used on the hub card.
    var symbol: String {
        switch self {
        case .runner: return "figure.run"
        case .merge: return "square.grid.2x2.fill"
        case .snake: return "scribble.variable"
        }
    }

    var colors: [Color] {
        switch self {
        case .runner: return [Color(hex: 0x6C7BFF), Color(hex: 0x38D6FF)]
        case .merge: return [Color(hex: 0xFF8A3D), Color(hex: 0xFF4F81)]
        case .snake: return [Color(hex: 0x37E38F), Color(hex: 0x1FA7A0)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Real-time games can be paused. The puzzle game has no clock.
    var supportsPause: Bool {
        switch self {
        case .runner, .snake: return true
        case .merge: return false
        }
    }

    /// UserDefaults key the high score is stored under.
    var scoreKey: String { "highscore.\(rawValue)" }
}

// ==========================================================================
// MARK: - Shared/Theme.swift
// ==========================================================================

enum Theme {
    static let background = Color(hex: 0x0E1018)
    static let surface = Color(hex: 0x1A1D2B)
    static let surfaceRaised = Color(hex: 0x262A3D)
    static let textSecondary = Color(hex: 0x9AA3BD)

    static let skBackground = SKColor(hex: 0x0E1018)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension SKColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    /// Linear blend between two colors. `t` is clamped to 0...1.
    static func blend(_ from: SKColor, _ to: SKColor, _ t: CGFloat) -> SKColor {
        let k = min(max(t, 0), 1)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return SKColor(
            red: r1 + (r2 - r1) * k,
            green: g1 + (g2 - g1) * k,
            blue: b1 + (b2 - b1) * k,
            alpha: a1 + (a2 - a1) * k
        )
    }
}

/// Small textures drawn in code so the app ships without image assets.
enum TextureFactory {
    static func verticalGradient(height: CGFloat, top: SKColor, bottom: SKColor) -> SKTexture {
        let size = CGSize(width: 4, height: max(height, 4))
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    static func roundedSquare(side: CGFloat, cornerRadius: CGFloat) -> SKTexture {
        let length = max(side, 2)
        let size = CGSize(width: length, height: length)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            SKColor.white.setFill()
            UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: size),
                cornerRadius: min(cornerRadius, length / 2)
            ).fill()
        }
        return SKTexture(image: image)
    }
}

// ==========================================================================
// MARK: - Shared/Haptics.swift
// ==========================================================================

/// Thin wrapper around the system feedback generators. Respects the
/// "Haptics" switch on the hub screen.
enum Haptics {
    static let enabledKey = "settings.hapticsEnabled"

    private static var isEnabled: Bool {
        // Defaults to on until the player turns it off.
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

    static func tap() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func bump() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func failure() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// ==========================================================================
// MARK: - Shared/HighScoreStore.swift
// ==========================================================================

/// Offline high scores. Everything lives in UserDefaults on the device, so
/// no network or account is ever needed.
final class HighScoreStore: ObservableObject {
    @Published private(set) var scores: [GameKind: Int] = [:]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var loaded: [GameKind: Int] = [:]
        for kind in GameKind.allCases {
            loaded[kind] = defaults.integer(forKey: kind.scoreKey)
        }
        scores = loaded
    }

    func best(for kind: GameKind) -> Int {
        scores[kind] ?? 0
    }

    /// Saves `score` if it beats the stored best. Returns true for a new record.
    @discardableResult
    func submit(_ score: Int, for kind: GameKind) -> Bool {
        guard score > best(for: kind) else { return false }
        scores[kind] = score
        defaults.set(score, forKey: kind.scoreKey)
        return true
    }

    func resetAll() {
        for kind in GameKind.allCases {
            defaults.removeObject(forKey: kind.scoreKey)
        }
        scores = [:]
    }
}

// ==========================================================================
// MARK: - Shared/GameSession.swift
// ==========================================================================

/// State shared between a SpriteKit scene (which runs the game) and the
/// SwiftUI screen around it (which draws the score bar and the overlays).
final class GameSession: ObservableObject {
    enum Phase {
        case ready      // waiting for the first input
        case playing
        case paused
        case gameOver
    }

    @Published var score: Int = 0
    @Published var phase: Phase = .ready
    @Published var isNewBest: Bool = false
    @Published var canUndo: Bool = false

    // Each setter only publishes when the value really changes. Scenes call
    // these every frame, and SwiftUI should not redraw for nothing.

    func setScore(_ value: Int) {
        if score != value { score = value }
    }

    func setPhase(_ value: Phase) {
        if phase != value { phase = value }
    }

    func setCanUndo(_ value: Bool) {
        if canUndo != value { canUndo = value }
    }

    /// Clears the round and moves to `phase` (`.ready` or `.playing`).
    func startFresh(as phase: Phase, score: Int = 0) {
        setScore(score)
        setCanUndo(false)
        if isNewBest { isNewBest = false }
        setPhase(phase)
    }

    func begin() {
        setPhase(.playing)
    }

    func finish() {
        setPhase(.gameOver)
    }
}

/// What the SwiftUI layer needs from every game scene.
protocol HubGameScene: AnyObject {
    var session: GameSession? { get set }
    /// Throw away the current round and set up a new one.
    func restart()
}

/// Owns one scene and its session for the lifetime of a game screen.
final class SceneHost<S: SKScene & HubGameScene>: ObservableObject {
    let session = GameSession()
    let scene: S

    init(scene: S) {
        self.scene = scene
        scene.scaleMode = .resizeFill
        scene.session = session
    }
}

// ==========================================================================
// MARK: - Shared/GameScreen.swift
// ==========================================================================

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

// ==========================================================================
// MARK: - Hub/HubView.swift
// ==========================================================================

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

// ==========================================================================
// MARK: - Logic/MoveDirection.swift
// ==========================================================================

/// A swipe direction, shared by the puzzle and the snake.
enum MoveDirection: String, Codable, CaseIterable {
    case up, down, left, right

    var opposite: MoveDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var isHorizontal: Bool {
        self == .left || self == .right
    }

    /// Grid step with y growing upward (SpriteKit orientation).
    var dx: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        case .up, .down: return 0
        }
    }

    var dy: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        case .left, .right: return 0
        }
    }

    /// Picks the dominant axis of a drag. `dy` is positive when the finger
    /// moved up the screen.
    static func from(dx: CGFloat, dy: CGFloat) -> MoveDirection {
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        }
        return dy > 0 ? .up : .down
    }
}

// ==========================================================================
// MARK: - Logic/MergeBoard.swift
// ==========================================================================

struct MergeTile: Codable, Equatable, Identifiable {
    let id: Int
    var value: Int
    /// Row 0 is the top row.
    var row: Int
    var col: Int
}

/// Rules for the sliding puzzle, with no drawing code. Every move reports
/// exactly which tiles travelled where so the scene can animate them.
struct MergeBoard: Codable, Equatable {

    /// An existing tile travelling to a cell.
    struct Slide: Equatable {
        let id: Int
        let row: Int
        let col: Int
    }

    /// Two tiles (`consumed`) replaced by one new tile (`result`).
    struct Fusion: Equatable {
        let result: MergeTile
        let consumed: [Int]
    }

    struct Outcome: Equatable {
        var slides: [Slide] = []
        var fusions: [Fusion] = []
        var gained = 0
        var changed = false
    }

    let side: Int
    private(set) var tiles: [MergeTile] = []
    private(set) var score = 0
    private var nextID = 1

    init(side: Int = 4) {
        self.side = side
    }

    /// Builds a board from rows of values, top row first. 0 means empty.
    init(rows: [[Int]]) {
        self.side = rows.count
        for (r, line) in rows.enumerated() {
            for (c, value) in line.enumerated() where value > 0 {
                tiles.append(MergeTile(id: nextID, value: value, row: r, col: c))
                nextID += 1
            }
        }
    }

    /// A new game: an empty board with two starting tiles.
    static func fresh(side: Int = 4) -> MergeBoard {
        var board = MergeBoard(side: side)
        board.spawn()
        board.spawn()
        return board
    }

    /// Values as rows, top row first. 0 means empty.
    var grid: [[Int]] {
        var result = Array(repeating: Array(repeating: 0, count: side), count: side)
        for tile in tiles where isInside(tile) {
            result[tile.row][tile.col] = tile.value
        }
        return result
    }

    var highestValue: Int {
        tiles.map(\.value).max() ?? 0
    }

    /// False once the board is full and no neighbours match.
    var canMove: Bool {
        if tiles.count < side * side { return true }
        let values = grid
        for r in 0..<side {
            for c in 0..<side {
                if c + 1 < side, values[r][c] == values[r][c + 1] { return true }
                if r + 1 < side, values[r][c] == values[r + 1][c] { return true }
            }
        }
        return false
    }

    /// True when the saved data describes a board this code can play.
    var isValid: Bool {
        guard side >= 2, tiles.count <= side * side else { return false }
        var seen = Set<Int>()
        for tile in tiles {
            guard isInside(tile), tile.value > 0 else { return false }
            guard seen.insert(tile.row * side + tile.col).inserted else { return false }
        }
        return true
    }

    /// Drops a 2 (90%) or a 4 (10%) on a random empty cell.
    @discardableResult
    mutating func spawn() -> MergeTile? {
        let values = grid
        var empty: [(Int, Int)] = []
        for r in 0..<side {
            for c in 0..<side where values[r][c] == 0 {
                empty.append((r, c))
            }
        }
        guard let (row, col) = empty.randomElement() else { return nil }
        let tile = MergeTile(
            id: nextID,
            value: Int.random(in: 0..<10) == 0 ? 4 : 2,
            row: row,
            col: col
        )
        nextID += 1
        tiles.append(tile)
        return tile
    }

    /// Slides every tile as far as it goes. Equal neighbours fuse once per
    /// move. If nothing can move the board is left untouched.
    mutating func slide(_ direction: MoveDirection) -> Outcome {
        var outcome = Outcome()
        var placed: [MergeTile] = []
        var newID = nextID

        let horizontal = direction.isHorizontal
        // Tiles nearest the wall they are heading for are settled first.
        let towardStart = direction == .left || direction == .up

        for line in 0..<side {
            let lineTiles = tiles
                .filter { horizontal ? $0.row == line : $0.col == line }
                .sorted { a, b in
                    let pa = horizontal ? a.col : a.row
                    let pb = horizontal ? b.col : b.row
                    return towardStart ? pa < pb : pa > pb
                }

            var slot = 0
            var fusable: Int? = nil  // index in `placed` that may still fuse

            for tile in lineTiles {
                if let index = fusable, placed[index].value == tile.value {
                    let target = placed[index]
                    let fused = MergeTile(
                        id: newID,
                        value: tile.value * 2,
                        row: target.row,
                        col: target.col
                    )
                    newID += 1
                    outcome.slides.append(Slide(id: tile.id, row: target.row, col: target.col))
                    outcome.fusions.append(Fusion(result: fused, consumed: [target.id, tile.id]))
                    outcome.gained += fused.value
                    outcome.changed = true
                    placed[index] = fused
                    fusable = nil
                } else {
                    let along = towardStart ? slot : side - 1 - slot
                    let row = horizontal ? line : along
                    let col = horizontal ? along : line
                    if tile.row != row || tile.col != col {
                        outcome.changed = true
                    }
                    var moved = tile
                    moved.row = row
                    moved.col = col
                    outcome.slides.append(Slide(id: tile.id, row: row, col: col))
                    placed.append(moved)
                    fusable = placed.count - 1
                    slot += 1
                }
            }
        }

        guard outcome.changed else { return Outcome() }
        tiles = placed
        score += outcome.gained
        nextID = newID
        return outcome
    }

    private func isInside(_ tile: MergeTile) -> Bool {
        tile.row >= 0 && tile.row < side && tile.col >= 0 && tile.col < side
    }
}

// ==========================================================================
// MARK: - Logic/SnakeEngine.swift
// ==========================================================================

struct GridPoint: Hashable {
    var x: Int
    var y: Int
}

/// Rules for the snake game, with no drawing code. y grows upward.
struct SnakeEngine {
    enum StepResult: Equatable {
        case moved
        case ate
        case died
        /// The snake covers the whole board. There is nowhere left to go.
        case filled
    }

    let cols: Int
    let rows: Int
    /// Head first.
    private(set) var body: [GridPoint]
    private(set) var heading: MoveDirection = .right
    private(set) var food: GridPoint?
    private(set) var isDead = false
    private(set) var eaten = 0

    private var pendingTurns: [MoveDirection] = []
    private var occupied: Set<GridPoint>

    /// Starts with a three-cell snake in the middle, heading right.
    /// Pass `food` to place the first food by hand (used by the tests).
    init(cols: Int, rows: Int, food: GridPoint? = nil) {
        let cx = max(cols, 5) / 2
        let cy = max(rows, 5) / 2
        self.init(
            cols: cols,
            rows: rows,
            body: [
                GridPoint(x: cx, y: cy),
                GridPoint(x: cx - 1, y: cy),
                GridPoint(x: cx - 2, y: cy)
            ],
            heading: .right,
            food: food
        )
    }

    /// Starts from an explicit position. `body` is head first.
    init(cols: Int, rows: Int, body: [GridPoint], heading: MoveDirection, food: GridPoint? = nil) {
        self.cols = max(cols, 5)
        self.rows = max(rows, 5)
        self.body = body
        self.heading = heading
        occupied = Set(body)
        if let food = food, !occupied.contains(food) {
            self.food = food
        } else {
            placeFood()
        }
    }

    /// Queues a turn for the next step. Reversing straight back into the
    /// body is ignored. Two turns can be buffered for quick corner moves.
    mutating func turn(_ direction: MoveDirection) {
        let reference = pendingTurns.last ?? heading
        guard direction != reference,
              direction != reference.opposite,
              pendingTurns.count < 2 else { return }
        pendingTurns.append(direction)
    }

    mutating func step() -> StepResult {
        guard !isDead else { return .died }
        if !pendingTurns.isEmpty {
            heading = pendingTurns.removeFirst()
        }

        let head = body[0]
        let next = GridPoint(x: head.x + heading.dx, y: head.y + heading.dy)

        guard next.x >= 0, next.x < cols, next.y >= 0, next.y < rows else {
            isDead = true
            return .died
        }

        let willEat = next == food
        let tail = body[body.count - 1]
        // Moving into the cell the tail is about to leave is allowed.
        let hitsBody = occupied.contains(next) && (willEat || next != tail)
        if hitsBody {
            isDead = true
            return .died
        }

        body.insert(next, at: 0)
        if willEat {
            occupied.insert(next)
            eaten += 1
            placeFood()
            return food == nil ? .filled : .ate
        }

        body.removeLast()
        occupied.remove(tail)
        occupied.insert(next)
        return .moved
    }

    private mutating func placeFood() {
        var free: [GridPoint] = []
        free.reserveCapacity(cols * rows - occupied.count)
        for x in 0..<cols {
            for y in 0..<rows {
                let point = GridPoint(x: x, y: y)
                if !occupied.contains(point) {
                    free.append(point)
                }
            }
        }
        food = free.randomElement()
    }
}

// ==========================================================================
// MARK: - Games/MoonDash/RunnerGameView.swift
// ==========================================================================

struct RunnerGameView: View {
    @StateObject private var host = SceneHost(
        scene: RunnerScene(size: CGSize(width: 390, height: 640))
    )

    var body: some View {
        GameScreen(
            kind: .runner,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            SpriteView(scene: host.scene, isPaused: host.session.phase == .paused)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

// ==========================================================================
// MARK: - Games/MoonDash/RunnerScene.swift
// ==========================================================================

/// Moon Dash: a one-button endless runner.
///
/// Everything is drawn with shapes and simulated by hand (no physics engine),
/// which keeps the jump feel exact and the collisions forgiving. Distances
/// are measured in "units": one unit is one point on a 390 point wide
/// screen, so the game plays the same on every iPhone.
final class RunnerScene: SKScene, HubGameScene {

    weak var session: GameSession?

    // MARK: Tuning (units, seconds)

    private enum Tuning {
        static let gravity: CGFloat = -2100
        static let jumpVelocity: CGFloat = 760
        static let doubleJumpVelocity: CGFloat = 640
        /// Letting go early caps the upward speed, giving a short hop.
        static let jumpCutVelocity: CGFloat = 260
        static let startSpeed: CGFloat = 270
        static let maxSpeed: CGFloat = 760
        static let acceleration: CGFloat = 5.5
        static let idleScrollSpeed: CGFloat = 45
        static let unitsPerPoint: CGFloat = 14
        static let playerWidth: CGFloat = 36
        static let bodyHeight: CGFloat = 32
        static let legHeight: CGFloat = 9
    }

    private enum ObstacleKind {
        case rock, wideRock, crystal, highDrone, lowDrone
    }

    private struct Obstacle {
        let node: SKNode
        let width: CGFloat
        let height: CGFloat
        /// Height of the bottom edge above the ground.
        let lift: CGFloat
        let bobAmplitude: CGFloat
        let bobPhase: CGFloat
    }

    private struct Scenery {
        let node: SKNode
        let parallax: CGFloat
        let halfWidth: CGFloat
    }

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var unit: CGFloat = 1
    private var groundY: CGFloat = 0
    private var playerX: CGFloat = 0
    private var scenerySpan: CGFloat = 0

    // MARK: Run state

    private var lastTime: TimeInterval = 0
    private var runSpeed: CGFloat = 0
    private var distance: CGFloat = 0
    private var distanceToNextSpawn: CGFloat = 0
    private var playerLift: CGFloat = 0
    private var velocityY: CGFloat = 0
    private var jumpsUsed = 0
    private var isDead = false
    private var stride: CGFloat = 0
    private var clock: CGFloat = 0

    // MARK: Nodes

    private var player = SKNode()
    private var playerShell = SKShapeNode()
    private var frontLeg = SKSpriteNode()
    private var backLeg = SKSpriteNode()
    private var shadow = SKShapeNode()
    private var obstacles: [Obstacle] = []
    private var scenery: [Scenery] = []

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 100, size.height > 240 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildWorld()
        resetRun()
    }

    func restart() {
        guard builtSize != .zero else { return }
        resetRun()
    }

    private func resetRun() {
        removeAllActions()
        for obstacle in obstacles {
            obstacle.node.removeFromParent()
        }
        obstacles.removeAll()

        runSpeed = Tuning.startSpeed * unit
        distance = 0
        distanceToNextSpawn = size.width * 0.9
        playerLift = 0
        velocityY = 0
        jumpsUsed = 0
        isDead = false
        stride = 0

        player.removeAllActions()
        player.zRotation = 0
        player.alpha = 1
        playerShell.fillColor = SKColor(hex: 0xF2F4FF)
        placePlayer()

        session?.startFresh(as: .ready)
    }

    // MARK: - World building

    private func buildWorld() {
        removeAllChildren()
        removeAllActions()
        obstacles.removeAll()
        scenery.removeAll()

        builtSize = size
        unit = size.width / 390
        groundY = max(size.height * 0.27, 96 * unit)
        playerX = size.width * 0.2
        scenerySpan = size.width + 360 * unit
        backgroundColor = SKColor(hex: 0x070A1A)

        let skyTop = max(size.height, groundY + 1)

        let sky = SKSpriteNode(texture: TextureFactory.verticalGradient(
            height: size.height,
            top: SKColor(hex: 0x05071A),
            bottom: SKColor(hex: 0x2A2F6B)
        ))
        sky.anchorPoint = .zero
        sky.size = size
        sky.zPosition = -100
        addChild(sky)

        for _ in 0..<46 {
            let side = CGFloat.random(in: 1.2...2.6) * unit
            let star = SKSpriteNode(color: .white, size: CGSize(width: side, height: side))
            star.alpha = CGFloat.random(in: 0.25...0.9)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: groundY...skyTop)
            )
            star.zPosition = -95
            addChild(star)
        }

        let planet = SKShapeNode(circleOfRadius: 28 * unit)
        planet.fillColor = SKColor(hex: 0x7FB8FF)
        planet.strokeColor = .clear
        planet.position = CGPoint(x: size.width * 0.78, y: groundY + (skyTop - groundY) * 0.74)
        planet.zPosition = -90
        addChild(planet)

        let ring = SKShapeNode(ellipseOf: CGSize(width: 92 * unit, height: 20 * unit))
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xD6E6FF, alpha: 0.75)
        ring.lineWidth = 2.5 * unit
        ring.zRotation = -0.35
        planet.addChild(ring)

        addHills(count: 4, color: SKColor(hex: 0x1B2150), width: 250...320, height: 110...170,
                 parallax: 0.12, z: -80)
        addHills(count: 5, color: SKColor(hex: 0x262D63), width: 180...260, height: 55...95,
                 parallax: 0.3, z: -70)

        let ground = SKSpriteNode(
            color: SKColor(hex: 0x2B3157),
            size: CGSize(width: size.width, height: groundY)
        )
        ground.anchorPoint = .zero
        ground.zPosition = -20
        addChild(ground)

        let edge = SKSpriteNode(
            color: SKColor(hex: 0x9AA3D9),
            size: CGSize(width: size.width, height: 3 * unit)
        )
        edge.anchorPoint = CGPoint(x: 0, y: 1)
        edge.position = CGPoint(x: 0, y: groundY)
        edge.zPosition = -19
        addChild(edge)

        // Craters scroll at full speed, which is what sells the motion.
        let craterCount = 7
        for index in 0..<craterCount {
            let width = CGFloat.random(in: 30...72) * unit
            let crater = SKShapeNode(ellipseOf: CGSize(width: width, height: width * 0.22))
            crater.fillColor = SKColor(hex: 0x1F2446)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: scenerySpan * (CGFloat(index) + CGFloat.random(in: 0.1...0.9)) / CGFloat(craterCount),
                y: CGFloat.random(in: (groundY * 0.15)...(groundY - 16 * unit))
            )
            crater.zPosition = -18
            addChild(crater)
            scenery.append(Scenery(node: crater, parallax: 1, halfWidth: width / 2))
        }

        shadow = SKShapeNode(ellipseOf: CGSize(width: 34 * unit, height: 7 * unit))
        shadow.fillColor = SKColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: playerX, y: groundY - 3 * unit)
        shadow.zPosition = 5
        addChild(shadow)

        buildPlayer()
    }

    private func addHills(
        count: Int,
        color: SKColor,
        width: ClosedRange<CGFloat>,
        height: ClosedRange<CGFloat>,
        parallax: CGFloat,
        z: CGFloat
    ) {
        for index in 0..<count {
            let hillWidth = CGFloat.random(in: width) * unit
            let hillHeight = CGFloat.random(in: height) * unit
            // An ellipse centred on the horizon: the ground hides its lower half.
            let hill = SKShapeNode(ellipseOf: CGSize(width: hillWidth, height: hillHeight * 2))
            hill.fillColor = color
            hill.strokeColor = .clear
            hill.position = CGPoint(
                x: scenerySpan * (CGFloat(index) + CGFloat.random(in: 0.1...0.6)) / CGFloat(count),
                y: groundY
            )
            hill.zPosition = z
            addChild(hill)
            scenery.append(Scenery(node: hill, parallax: parallax, halfWidth: hillWidth / 2))
        }
    }

    private func buildPlayer() {
        let width = Tuning.playerWidth * unit
        let bodyHeight = Tuning.bodyHeight * unit
        let legHeight = Tuning.legHeight * unit

        // The node's origin sits between the feet.
        player = SKNode()
        player.zPosition = 10

        let legSize = CGSize(width: 8 * unit, height: legHeight + 3 * unit)
        backLeg = SKSpriteNode(color: SKColor(hex: 0x9AA3D9), size: legSize)
        backLeg.anchorPoint = CGPoint(x: 0.5, y: 0)
        backLeg.position = CGPoint(x: -width * 0.2, y: 0)
        player.addChild(backLeg)

        frontLeg = SKSpriteNode(color: SKColor(hex: 0xC3CAF0), size: legSize)
        frontLeg.anchorPoint = CGPoint(x: 0.5, y: 0)
        frontLeg.position = CGPoint(x: width * 0.2, y: 0)
        player.addChild(frontLeg)

        let pack = SKShapeNode(
            rect: CGRect(x: -width / 2 - 5 * unit, y: legHeight + bodyHeight * 0.2,
                         width: 8 * unit, height: bodyHeight * 0.5),
            cornerRadius: 3 * unit
        )
        pack.fillColor = SKColor(hex: 0x9AA3D9)
        pack.strokeColor = .clear
        player.addChild(pack)

        playerShell = SKShapeNode(
            rect: CGRect(x: -width / 2, y: legHeight, width: width, height: bodyHeight),
            cornerRadius: 10 * unit
        )
        playerShell.fillColor = SKColor(hex: 0xF2F4FF)
        playerShell.strokeColor = .clear
        player.addChild(playerShell)

        let visor = SKShapeNode(
            rect: CGRect(x: -width * 0.06, y: legHeight + bodyHeight * 0.42,
                         width: width * 0.5, height: bodyHeight * 0.36),
            cornerRadius: 5 * unit
        )
        visor.fillColor = SKColor(hex: 0x141A38)
        visor.strokeColor = .clear
        player.addChild(visor)

        let eye = SKShapeNode(circleOfRadius: 2.6 * unit)
        eye.fillColor = SKColor(hex: 0x5CF2E3)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: width * 0.3, y: legHeight + bodyHeight * 0.6)
        player.addChild(eye)

        let antenna = SKSpriteNode(
            color: SKColor(hex: 0xF2F4FF),
            size: CGSize(width: 2 * unit, height: 9 * unit)
        )
        antenna.anchorPoint = CGPoint(x: 0.5, y: 0)
        antenna.position = CGPoint(x: -width * 0.2, y: legHeight + bodyHeight - unit)
        player.addChild(antenna)

        let beacon = SKShapeNode(circleOfRadius: 3 * unit)
        beacon.fillColor = SKColor(hex: 0xFF5D73)
        beacon.strokeColor = .clear
        beacon.position = CGPoint(x: -width * 0.2, y: legHeight + bodyHeight + 10 * unit)
        player.addChild(beacon)

        addChild(player)
        placePlayer()
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let session = session, builtSize != .zero else { return }
        switch session.phase {
        case .ready:
            session.begin()
            jump()
        case .playing:
            jump()
        case .paused, .gameOver:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cutJump()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cutJump()
    }

    private func jump() {
        guard !isDead, jumpsUsed < 2 else { return }
        let isDoubleJump = jumpsUsed == 1 || playerLift > 0
        if isDoubleJump {
            // Falling off nothing is impossible here, so any mid-air jump is
            // the second one.
            jumpsUsed = 2
            velocityY = Tuning.doubleJumpVelocity * unit
            emitPuff()
        } else {
            jumpsUsed = 1
            velocityY = Tuning.jumpVelocity * unit
        }
        Haptics.tap()
    }

    private func cutJump() {
        let cap = Tuning.jumpCutVelocity * unit
        if velocityY > cap {
            velocityY = cap
        }
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        let delta: CGFloat
        if lastTime == 0 {
            delta = 0
        } else {
            // Clamp so a hitch or a resume never teleports the world.
            delta = CGFloat(min(max(currentTime - lastTime, 0), 1.0 / 30.0))
        }
        lastTime = currentTime

        guard let session = session, builtSize != .zero else { return }
        clock += delta

        switch session.phase {
        case .ready:
            scrollScenery(by: Tuning.idleScrollSpeed * unit * delta)
            stride += delta * 0.5
            placePlayer()
        case .playing:
            if !isDead {
                step(delta, session: session)
            }
        case .paused, .gameOver:
            break
        }
    }

    private func step(_ delta: CGFloat, session: GameSession) {
        runSpeed = min(Tuning.maxSpeed * unit, runSpeed + Tuning.acceleration * unit * delta)
        let travel = runSpeed * delta
        distance += travel
        stride += delta * (runSpeed / (Tuning.startSpeed * unit))

        // Player
        if playerLift > 0 || velocityY > 0 {
            velocityY += Tuning.gravity * unit * delta
            playerLift += velocityY * delta
            if playerLift <= 0 {
                playerLift = 0
                velocityY = 0
                jumpsUsed = 0
            }
        }
        placePlayer()

        // World
        scrollScenery(by: travel)
        moveObstacles(by: travel)

        distanceToNextSpawn -= travel
        if distanceToNextSpawn <= 0 {
            spawnObstacle(score: session.score)
        }

        session.setScore(Int(distance / (Tuning.unitsPerPoint * unit)))

        if collides() {
            die()
        }
    }

    private func placePlayer() {
        player.position = CGPoint(x: playerX, y: groundY + playerLift)

        let airborne = playerLift > 0
        if airborne {
            let tilt = max(-1, min(1, velocityY / (Tuning.jumpVelocity * unit)))
            player.zRotation = tilt * 0.16
            frontLeg.position.y = 3 * unit
            backLeg.position.y = 3 * unit
        } else {
            player.zRotation = 0
            // Two-frame run cycle.
            let frontUp = Int(stride * 11) % 2 == 0
            frontLeg.position.y = frontUp ? 4 * unit : 0
            backLeg.position.y = frontUp ? 0 : 4 * unit
        }

        let shrink = max(0.45, 1 - playerLift / (220 * unit))
        shadow.xScale = shrink
        shadow.alpha = shrink
    }

    private func scrollScenery(by travel: CGFloat) {
        for item in scenery {
            item.node.position.x -= travel * item.parallax
            if item.node.position.x < -item.halfWidth {
                item.node.position.x += scenerySpan
            }
        }
    }

    private func moveObstacles(by travel: CGFloat) {
        var index = 0
        while index < obstacles.count {
            let obstacle = obstacles[index]
            obstacle.node.position.x -= travel
            if obstacle.bobAmplitude > 0 {
                obstacle.node.position.y = groundY + obstacle.lift
                    + sin(clock * 4 + obstacle.bobPhase) * obstacle.bobAmplitude
            }
            if obstacle.node.position.x < -obstacle.width {
                obstacle.node.removeFromParent()
                obstacles.remove(at: index)
            } else {
                index += 1
            }
        }
    }

    // MARK: - Obstacles

    private func spawnObstacle(score: Int) {
        var choices: [ObstacleKind] = [.rock, .rock, .rock]
        if score > 120 {
            choices += [.wideRock, .highDrone]
        }
        if score > 350 {
            choices += [.crystal, .lowDrone, .highDrone]
        }
        let kind = choices.randomElement() ?? .rock

        let obstacle: Obstacle
        switch kind {
        case .rock:
            let width = CGFloat.random(in: 28...44) * unit
            let height = CGFloat.random(in: 26...48) * unit
            obstacle = Obstacle(node: makeRock(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .wideRock:
            let width = CGFloat.random(in: 62...84) * unit
            let height = CGFloat.random(in: 28...38) * unit
            obstacle = Obstacle(node: makeRock(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .crystal:
            let width = CGFloat.random(in: 24...30) * unit
            let height = CGFloat.random(in: 70...88) * unit
            obstacle = Obstacle(node: makeCrystal(width: width, height: height),
                                width: width, height: height, lift: 0,
                                bobAmplitude: 0, bobPhase: 0)
        case .highDrone:
            // High enough to run under. Jumping into it is the mistake.
            let width = 44 * unit
            let height = 20 * unit
            obstacle = Obstacle(node: makeDrone(width: width, height: height),
                                width: width, height: height, lift: 62 * unit,
                                bobAmplitude: 5 * unit,
                                bobPhase: CGFloat.random(in: 0...6))
        case .lowDrone:
            // Too low to run under. Jump over it.
            let width = 44 * unit
            let height = 20 * unit
            obstacle = Obstacle(node: makeDrone(width: width, height: height),
                                width: width, height: height, lift: 16 * unit,
                                bobAmplitude: 5 * unit,
                                bobPhase: CGFloat.random(in: 0...6))
        }

        obstacle.node.position = CGPoint(
            x: size.width + obstacle.width / 2 + 20 * unit,
            y: groundY + obstacle.lift
        )
        obstacle.node.zPosition = 0
        addChild(obstacle.node)
        obstacles.append(obstacle)

        // The gap is measured in seconds so it stays fair as speed rises.
        // A full jump lasts about 0.72 s, so 0.9 s always leaves room to land.
        let longest = max(1.25, 1.75 - CGFloat(score) / 1200)
        let gapTime = CGFloat.random(in: 0.9...longest)
        distanceToNextSpawn = runSpeed * gapTime + obstacle.width
    }

    private func makeRock(width: CGFloat, height: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.38, y: height * 0.62))
        path.addLine(to: CGPoint(x: -width * 0.08, y: height))
        path.addLine(to: CGPoint(x: width * 0.26, y: height * 0.82))
        path.addLine(to: CGPoint(x: width / 2, y: height * 0.3))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let rock = SKShapeNode(path: path)
        rock.fillColor = SKColor(hex: 0x6B739F)
        rock.strokeColor = SKColor(hex: 0xA9B1DE)
        rock.lineWidth = 1.5 * unit
        rock.lineJoin = .round
        return rock
    }

    private func makeCrystal(width: CGFloat, height: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.3, y: height * 0.72))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.72))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let crystal = SKShapeNode(path: path)
        crystal.fillColor = SKColor(hex: 0x3FD9CE)
        crystal.strokeColor = SKColor(hex: 0xB8FFF8)
        crystal.lineWidth = 1.5 * unit
        crystal.lineJoin = .round

        let facet = SKShapeNode(rect: CGRect(x: -unit, y: 0, width: 2 * unit, height: height * 0.9))
        facet.fillColor = SKColor(hex: 0xB8FFF8, alpha: 0.6)
        facet.strokeColor = .clear
        crystal.addChild(facet)
        return crystal
    }

    private func makeDrone(width: CGFloat, height: CGFloat) -> SKNode {
        // Origin at the bottom centre, like the ground obstacles.
        let drone = SKNode()

        let hull = SKShapeNode(ellipseOf: CGSize(width: width, height: height * 0.7))
        hull.fillColor = SKColor(hex: 0xFF5D73)
        hull.strokeColor = SKColor(hex: 0xFFB3BE)
        hull.lineWidth = 1.5 * unit
        hull.position = CGPoint(x: 0, y: height * 0.35)
        drone.addChild(hull)

        let dome = SKShapeNode(ellipseOf: CGSize(width: width * 0.42, height: height * 0.7))
        dome.fillColor = SKColor(hex: 0xFFD9DE)
        dome.strokeColor = .clear
        dome.position = CGPoint(x: 0, y: height * 0.65)
        dome.zPosition = -1
        drone.addChild(dome)

        let light = SKShapeNode(circleOfRadius: 2.5 * unit)
        light.fillColor = SKColor(hex: 0xFFF3A6)
        light.strokeColor = .clear
        light.position = CGPoint(x: -width * 0.28, y: height * 0.35)
        light.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.25),
            .fadeAlpha(to: 1, duration: 0.25)
        ])))
        drone.addChild(light)
        return drone
    }

    // MARK: - Collision

    private func collides() -> Bool {
        let width = Tuning.playerWidth * unit
        let playerTop = (Tuning.legHeight + Tuning.bodyHeight) * unit
        // Hit boxes are smaller than the art so near misses feel fair.
        let playerBox = CGRect(
            x: playerX - width / 2 + 5 * unit,
            y: groundY + playerLift + 4 * unit,
            width: width - 10 * unit,
            height: playerTop - 9 * unit
        )
        let inset = 4 * unit
        for obstacle in obstacles {
            let box = CGRect(
                x: obstacle.node.position.x - obstacle.width / 2 + inset,
                y: obstacle.node.position.y,
                width: obstacle.width - inset * 2,
                height: obstacle.height - inset
            )
            if playerBox.intersects(box) {
                return true
            }
        }
        return false
    }

    private func die() {
        isDead = true
        Haptics.failure()
        playerShell.fillColor = SKColor(hex: 0xFF5D73)

        let flash = SKSpriteNode(color: .white, size: size)
        flash.anchorPoint = .zero
        flash.alpha = 0.55
        flash.zPosition = 50
        addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.25), .removeFromParent()]))

        player.run(.group([
            .rotate(byAngle: 0.9, duration: 0.3),
            .moveBy(x: -14 * unit, y: 18 * unit, duration: 0.3)
        ]))

        run(.sequence([
            .wait(forDuration: 0.55),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    private func emitPuff() {
        let puff = SKShapeNode(circleOfRadius: 9 * unit)
        puff.fillColor = SKColor(hex: 0x5CF2E3, alpha: 0.7)
        puff.strokeColor = .clear
        puff.position = CGPoint(x: playerX - 6 * unit, y: groundY + playerLift)
        puff.zPosition = 9
        addChild(puff)
        puff.run(.sequence([
            .group([
                .scale(to: 1.9, duration: 0.25),
                .fadeOut(withDuration: 0.25),
                .moveBy(x: -18 * unit, y: -10 * unit, duration: 0.25)
            ]),
            .removeFromParent()
        ]))
    }
}

// ==========================================================================
// MARK: - Games/TileFuse/MergeGameView.swift
// ==========================================================================

struct MergeGameView: View {
    @StateObject private var host = SceneHost(
        scene: MergeScene(size: CGSize(width: 390, height: 640))
    )
    @State private var confirmNewGame = false

    var body: some View {
        GameScreen(
            kind: .merge,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            ZStack(alignment: .bottom) {
                SpriteView(scene: host.scene)

                HStack(spacing: 12) {
                    Button {
                        host.scene.undo()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!host.session.canUndo)
                    .opacity(host.session.canUndo ? 1 : 0.4)

                    Button {
                        confirmNewGame = true
                    } label: {
                        Label("New game", systemImage: "plus")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .confirmationDialog(
            "Start a new game?",
            isPresented: $confirmNewGame,
            titleVisibility: .visible
        ) {
            Button("New game", role: .destructive) {
                host.scene.restart()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current board will be cleared.")
        }
    }
}

// ==========================================================================
// MARK: - Games/TileFuse/MergeScene.swift
// ==========================================================================

/// Tile Fuse: swipe to slide every tile. Two equal tiles that meet fuse into
/// one worth double. The rules live in `MergeBoard`. This scene animates the
/// moves it reports, reads swipes, and saves the board after every move so a
/// game in progress survives leaving the screen or closing the app.
final class MergeScene: SKScene, HubGameScene {

    weak var session: GameSession? {
        didSet { syncSession() }
    }

    private enum Tuning {
        static let slideDuration: TimeInterval = 0.11
        static let swipeDistance: CGFloat = 22
        static let saveKey = "tilefuse.savedBoard"
    }

    // MARK: State

    private var board: MergeBoard = MergeScene.loadSavedBoard() ?? MergeBoard.fresh()
    private var previousBoard: MergeBoard?
    private var isFinishing = false
    private var touchStart: CGPoint?
    private var swipeHandled = false

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var boardSide: CGFloat = 0
    private var boardOrigin: CGPoint = .zero
    private var cell: CGFloat = 0
    private var gap: CGFloat = 0

    // MARK: Nodes

    private var boardNode = SKNode()
    /// Holds every tile, including ones still sliding away after a fusion.
    private var tileLayer = SKNode()
    private var tileNodes: [Int: SKNode] = [:]

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 150, size.height > 300 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildBoard()
    }

    /// This game has no "ready" phase: the board is live as soon as it shows.
    private func syncSession() {
        session?.startFresh(as: .playing, score: board.score)
    }

    func restart() {
        removeAllActions()
        board = MergeBoard.fresh()
        previousBoard = nil
        isFinishing = false
        save()
        syncSession()
        if builtSize != .zero {
            rebuildTiles(animated: true)
        }
    }

    /// Takes back the last move (one level).
    func undo() {
        guard let previous = previousBoard,
              !isFinishing,
              session?.phase == .playing else { return }
        board = previous
        previousBoard = nil
        session?.setCanUndo(false)
        session?.setScore(board.score)
        save()
        rebuildTiles(animated: false)
        Haptics.tap()
    }

    // MARK: - Board

    private func buildBoard() {
        removeAllChildren()
        builtSize = size
        backgroundColor = Theme.skBackground

        let count = CGFloat(board.side)
        // Leave room at the bottom for the Undo and New game buttons.
        boardSide = min(size.width - 32, size.height - 150, 440)
        gap = boardSide * 0.03
        cell = (boardSide - gap * (count + 1)) / count
        let centred = (size.height - boardSide) / 2 + 24
        boardOrigin = CGPoint(
            x: (size.width - boardSide) / 2,
            y: min(max(100, centred), size.height - boardSide - 12)
        )

        boardNode = SKNode()
        addChild(boardNode)

        let backdrop = SKShapeNode(
            rect: CGRect(x: boardOrigin.x, y: boardOrigin.y, width: boardSide, height: boardSide),
            cornerRadius: boardSide * 0.04
        )
        backdrop.fillColor = SKColor(hex: 0x1A1D2B)
        backdrop.strokeColor = .clear
        backdrop.zPosition = 0
        boardNode.addChild(backdrop)

        for row in 0..<board.side {
            for col in 0..<board.side {
                let slot = SKShapeNode(
                    rectOf: CGSize(width: cell, height: cell),
                    cornerRadius: cell * 0.16
                )
                slot.fillColor = SKColor(hex: 0x242838)
                slot.strokeColor = .clear
                slot.position = center(row: row, col: col)
                slot.zPosition = 1
                boardNode.addChild(slot)
            }
        }

        tileLayer = SKNode()
        tileLayer.zPosition = 2
        boardNode.addChild(tileLayer)
        rebuildTiles(animated: false)
    }

    private func center(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + gap + CGFloat(col) * (cell + gap) + cell / 2,
            y: boardOrigin.y + boardSide - gap - CGFloat(row) * (cell + gap) - cell / 2
        )
    }

    private func rebuildTiles(animated: Bool) {
        // Clearing the layer also drops tiles that were mid-animation.
        tileLayer.removeAllChildren()
        tileNodes.removeAll()
        for tile in board.tiles {
            let node = makeTileNode(tile)
            tileLayer.addChild(node)
            tileNodes[tile.id] = node
            if animated {
                appear(node, after: 0)
            }
        }
    }

    private func makeTileNode(_ tile: MergeTile) -> SKNode {
        let node = SKShapeNode(
            rectOf: CGSize(width: cell, height: cell),
            cornerRadius: cell * 0.16
        )
        node.fillColor = MergeScene.color(for: tile.value)
        node.strokeColor = .clear
        node.position = center(row: tile.row, col: tile.col)
        node.zPosition = 2

        let text = "\(tile.value)"
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        switch text.count {
        case 1, 2: label.fontSize = cell * 0.44
        case 3: label.fontSize = cell * 0.36
        case 4: label.fontSize = cell * 0.29
        default: label.fontSize = cell * 0.23
        }
        label.zPosition = 1
        node.addChild(label)
        return node
    }

    /// One colour per tile value, cool for small tiles and hot for big ones.
    private static func color(for value: Int) -> SKColor {
        switch value {
        case 2: return SKColor(hex: 0x39415F)
        case 4: return SKColor(hex: 0x4A5488)
        case 8: return SKColor(hex: 0x2F6FDB)
        case 16: return SKColor(hex: 0x2B9FD9)
        case 32: return SKColor(hex: 0x1FB8A6)
        case 64: return SKColor(hex: 0x2FB866)
        case 128: return SKColor(hex: 0xD9A72B)
        case 256: return SKColor(hex: 0xE88A2E)
        case 512: return SKColor(hex: 0xEB6238)
        case 1024: return SKColor(hex: 0xE8457A)
        case 2048: return SKColor(hex: 0xB14DE8)
        default: return SKColor(hex: 0x7B4DFF)
        }
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = touches.first?.location(in: self)
        swipeHandled = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = touchStart, !swipeHandled else { return }
        let location = touch.location(in: self)
        let dx = location.x - start.x
        let dy = location.y - start.y
        guard max(abs(dx), abs(dy)) >= Tuning.swipeDistance else { return }
        swipeHandled = true  // one move per swipe
        move(MoveDirection.from(dx: dx, dy: dy))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = nil
    }

    // MARK: - Moves

    private func move(_ direction: MoveDirection) {
        guard let session = session,
              session.phase == .playing,
              !isFinishing,
              builtSize != .zero else { return }

        let before = board
        let outcome = board.slide(direction)
        guard outcome.changed else { return }

        previousBoard = before
        session.setCanUndo(true)

        let consumed = Set(outcome.fusions.flatMap { $0.consumed })
        for slide in outcome.slides {
            guard let node = tileNodes[slide.id] else { continue }
            let glide = SKAction.move(
                to: center(row: slide.row, col: slide.col),
                duration: Tuning.slideDuration
            )
            glide.timingMode = .easeOut
            if consumed.contains(slide.id) {
                // Slides under its partner, then is replaced by the fused tile.
                tileNodes[slide.id] = nil
                node.run(.sequence([glide, .removeFromParent()]), withKey: "slide")
            } else {
                node.run(glide, withKey: "slide")
            }
        }

        for fusion in outcome.fusions {
            let node = makeTileNode(fusion.result)
            node.zPosition = 3
            node.alpha = 0
            tileLayer.addChild(node)
            tileNodes[fusion.result.id] = node
            node.run(.sequence([
                .wait(forDuration: Tuning.slideDuration),
                .fadeIn(withDuration: 0.01),
                .scale(to: 1.14, duration: 0.07),
                .scale(to: 1, duration: 0.08)
            ]))
        }

        if let spawned = board.spawn() {
            let node = makeTileNode(spawned)
            tileLayer.addChild(node)
            tileNodes[spawned.id] = node
            appear(node, after: Tuning.slideDuration)
        }

        session.setScore(board.score)
        if outcome.fusions.isEmpty {
            Haptics.tap()
        } else {
            Haptics.bump()
        }

        if board.canMove {
            save()
        } else {
            finish()
        }
    }

    private func appear(_ node: SKNode, after delay: TimeInterval) {
        node.setScale(0.2)
        node.alpha = 0
        node.run(.sequence([
            .wait(forDuration: delay),
            .group([
                .fadeIn(withDuration: 0.08),
                .scale(to: 1, duration: 0.12)
            ])
        ]))
    }

    private func finish() {
        isFinishing = true
        previousBoard = nil
        session?.setCanUndo(false)
        // A finished board is not worth resuming.
        UserDefaults.standard.removeObject(forKey: Tuning.saveKey)
        Haptics.failure()
        run(.sequence([
            .wait(forDuration: 0.7),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    // MARK: - Saving

    private func save() {
        guard let data = try? JSONEncoder().encode(board) else { return }
        UserDefaults.standard.set(data, forKey: Tuning.saveKey)
    }

    private static func loadSavedBoard() -> MergeBoard? {
        guard let data = UserDefaults.standard.data(forKey: Tuning.saveKey),
              let saved = try? JSONDecoder().decode(MergeBoard.self, from: data),
              saved.side == 4,
              saved.isValid,
              saved.canMove,
              !saved.tiles.isEmpty else { return nil }
        return saved
    }
}

// ==========================================================================
// MARK: - Games/NeonSnake/SnakeGameView.swift
// ==========================================================================

struct SnakeGameView: View {
    @StateObject private var host = SceneHost(
        scene: SnakeScene(size: CGSize(width: 390, height: 640))
    )

    var body: some View {
        GameScreen(
            kind: .snake,
            session: host.session,
            onRestart: { host.scene.restart() }
        ) {
            SpriteView(scene: host.scene, isPaused: host.session.phase == .paused)
        }
    }
}

// ==========================================================================
// MARK: - Games/NeonSnake/SnakeScene.swift
// ==========================================================================

/// Neon Snake: swipe to steer, eat to grow, do not hit the walls or yourself.
/// The rules live in `SnakeEngine`. This scene draws them and reads swipes.
final class SnakeScene: SKScene, HubGameScene {

    weak var session: GameSession?

    private enum Tuning {
        static let columns = 16
        static let maxRows = 26
        static let pointsPerFood = 10
        static let slowestStep: TimeInterval = 0.17
        static let fastestStep: TimeInterval = 0.075
        static let speedUpPerFood: TimeInterval = 0.004
        /// How far a finger must travel before it counts as a swipe.
        static let swipeDistance: CGFloat = 16
    }

    // MARK: Layout

    private var builtSize: CGSize = .zero
    private var rows = 20
    private var cell: CGFloat = 20

    // MARK: State

    private var engine: SnakeEngine?
    private var lastTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0
    private var isDying = false
    private var touchAnchor: CGPoint?

    // MARK: Nodes

    private var boardNode = SKNode()
    private var segmentNodes: [SKSpriteNode] = []
    private var segmentTexture: SKTexture?
    private var eyes = SKNode()
    private var foodNode = SKShapeNode()

    private let headColor = SKColor(hex: 0xC8FF6B)
    private let neckColor = SKColor(hex: 0x4BE38A)
    private let tailColor = SKColor(hex: 0x1F8F8B)

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        rebuildIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuildIfNeeded()
    }

    private func rebuildIfNeeded() {
        guard size.width > 150, size.height > 260 else { return }
        let changed = abs(size.width - builtSize.width) > 0.5
            || abs(size.height - builtSize.height) > 0.5
        guard changed else { return }
        buildBoard()
        resetRound()
    }

    func restart() {
        guard builtSize != .zero else { return }
        resetRound()
    }

    private func resetRound() {
        removeAllActions()
        boardNode.removeAllActions()
        boardNode.position = boardOrigin
        engine = SnakeEngine(cols: Tuning.columns, rows: rows)
        accumulator = 0
        isDying = false
        touchAnchor = nil
        render()
        session?.startFresh(as: .ready)
    }

    // MARK: - Board

    private var boardSize: CGSize {
        CGSize(width: cell * CGFloat(Tuning.columns), height: cell * CGFloat(rows))
    }

    private var boardOrigin: CGPoint {
        CGPoint(
            x: ((size.width - boardSize.width) / 2).rounded(),
            y: ((size.height - boardSize.height) / 2).rounded()
        )
    }

    private func buildBoard() {
        removeAllChildren()
        removeAllActions()
        segmentNodes.removeAll()

        builtSize = size
        backgroundColor = Theme.skBackground

        let margin: CGFloat = 12
        cell = floor((size.width - margin * 2) / CGFloat(Tuning.columns))
        rows = max(8, min(Tuning.maxRows, Int((size.height - margin * 2) / cell)))

        boardNode = SKNode()
        boardNode.position = boardOrigin
        addChild(boardNode)

        let boardSize = self.boardSize
        let columns = Tuning.columns
        let rowCount = rows
        let cellSide = cell
        let image = UIGraphicsImageRenderer(size: boardSize).image { context in
            SKColor(hex: 0x141829).setFill()
            context.fill(CGRect(origin: .zero, size: boardSize))
            SKColor(hex: 0x191E33).setFill()
            for x in 0..<columns {
                for y in 0..<rowCount where (x + y) % 2 == 0 {
                    context.fill(CGRect(
                        x: CGFloat(x) * cellSide,
                        y: CGFloat(y) * cellSide,
                        width: cellSide,
                        height: cellSide
                    ))
                }
            }
        }
        let floorNode = SKSpriteNode(texture: SKTexture(image: image))
        floorNode.anchorPoint = .zero
        floorNode.size = boardSize
        floorNode.zPosition = 0
        boardNode.addChild(floorNode)

        let border = SKShapeNode(
            rect: CGRect(origin: .zero, size: boardSize).insetBy(dx: -3, dy: -3),
            cornerRadius: 6
        )
        border.fillColor = .clear
        border.strokeColor = SKColor(hex: 0x37E38F, alpha: 0.55)
        border.lineWidth = 2
        border.zPosition = 1
        boardNode.addChild(border)

        segmentTexture = TextureFactory.roundedSquare(side: cell - 2, cornerRadius: cell * 0.28)

        foodNode = SKShapeNode(circleOfRadius: cell * 0.34)
        foodNode.fillColor = SKColor(hex: 0xFF5D73)
        foodNode.strokeColor = SKColor(hex: 0xFFC2CA)
        foodNode.lineWidth = 1.5
        foodNode.zPosition = 2
        foodNode.run(.repeatForever(.sequence([
            .scale(to: 1.15, duration: 0.45),
            .scale(to: 0.9, duration: 0.45)
        ])))
        boardNode.addChild(foodNode)

        // Eyes ride on the head and turn with it. They face +x by default.
        eyes = SKNode()
        eyes.zPosition = 1
        for side in [CGFloat(-1), CGFloat(1)] {
            let eye = SKShapeNode(circleOfRadius: max(1.5, cell * 0.1))
            eye.fillColor = SKColor(hex: 0x10231B)
            eye.strokeColor = .clear
            eye.position = CGPoint(x: cell * 0.16, y: side * cell * 0.19)
            eyes.addChild(eye)
        }
    }

    private func point(for gridPoint: GridPoint) -> CGPoint {
        CGPoint(
            x: (CGFloat(gridPoint.x) + 0.5) * cell,
            y: (CGFloat(gridPoint.y) + 0.5) * cell
        )
    }

    private func makeSegment() -> SKSpriteNode {
        let node = SKSpriteNode(
            texture: segmentTexture,
            color: neckColor,
            size: CGSize(width: cell - 2, height: cell - 2)
        )
        node.colorBlendFactor = 1
        node.zPosition = 3
        boardNode.addChild(node)
        return node
    }

    private func render() {
        guard let engine = engine else { return }
        let body = engine.body

        while segmentNodes.count < body.count {
            segmentNodes.append(makeSegment())
        }

        for (index, node) in segmentNodes.enumerated() {
            guard index < body.count else {
                node.isHidden = true
                continue
            }
            node.isHidden = false
            node.position = point(for: body[index])
            if index == 0 {
                node.color = headColor
                node.zPosition = 4
            } else {
                let progress = CGFloat(index) / CGFloat(max(body.count - 1, 1))
                node.color = SKColor.blend(neckColor, tailColor, progress)
                node.zPosition = 3
            }
        }

        if let head = segmentNodes.first {
            if eyes.parent !== head {
                eyes.removeFromParent()
                head.addChild(eyes)
            }
            switch engine.heading {
            case .right: eyes.zRotation = 0
            case .up: eyes.zRotation = .pi / 2
            case .left: eyes.zRotation = .pi
            case .down: eyes.zRotation = -.pi / 2
            }
        }

        if let food = engine.food {
            foodNode.isHidden = false
            foodNode.position = point(for: food)
        } else {
            foodNode.isHidden = true
        }
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let session = session, engine != nil else { return }
        touchAnchor = touch.location(in: self)
        if session.phase == .ready {
            session.begin()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let anchor = touchAnchor,
              session?.phase == .playing,
              !isDying else { return }
        let location = touch.location(in: self)
        let dx = location.x - anchor.x
        let dy = location.y - anchor.y
        guard max(abs(dx), abs(dy)) >= Tuning.swipeDistance else { return }
        engine?.turn(MoveDirection.from(dx: dx, dy: dy))
        // Re-anchor so one long drag can make several turns.
        touchAnchor = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAnchor = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAnchor = nil
    }

    // MARK: - Game loop

    private var stepInterval: TimeInterval {
        let eaten = Double(engine?.eaten ?? 0)
        return max(Tuning.fastestStep, Tuning.slowestStep - eaten * Tuning.speedUpPerFood)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastTime == 0 ? 0 : min(max(currentTime - lastTime, 0), 0.1)
        lastTime = currentTime

        guard let session = session, session.phase == .playing, !isDying else { return }

        accumulator += delta
        let interval = stepInterval
        if accumulator >= interval {
            // One move per frame at most, so a hitch never skips cells.
            accumulator = min(accumulator - interval, interval)
            tick(session: session)
        }
    }

    private func tick(session: GameSession) {
        guard let result = engine?.step() else { return }
        switch result {
        case .moved:
            render()
        case .ate:
            render()
            session.setScore((engine?.eaten ?? 0) * Tuning.pointsPerFood)
            Haptics.tap()
            if let head = segmentNodes.first {
                emitRing(at: head.position)
            }
        case .filled:
            render()
            session.setScore((engine?.eaten ?? 0) * Tuning.pointsPerFood)
            Haptics.success()
            session.finish()
        case .died:
            die()
        }
    }

    private func die() {
        isDying = true
        Haptics.failure()

        for node in segmentNodes where !node.isHidden {
            node.color = SKColor(hex: 0xFF5D73)
        }

        let origin = boardOrigin
        boardNode.run(.sequence([
            .moveBy(x: 7, y: 0, duration: 0.04),
            .moveBy(x: -14, y: 0, duration: 0.08),
            .moveBy(x: 10, y: 0, duration: 0.07),
            .move(to: origin, duration: 0.05)
        ]))

        run(.sequence([
            .wait(forDuration: 0.65),
            .run { [weak self] in
                self?.session?.finish()
            }
        ]))
    }

    private func emitRing(at position: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: cell * 0.4)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(hex: 0xC8FF6B)
        ring.lineWidth = 2
        ring.position = position
        ring.zPosition = 5
        boardNode.addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: 2.2, duration: 0.28),
                .fadeOut(withDuration: 0.28)
            ]),
            .removeFromParent()
        ]))
    }
}
