import Foundation

/// Sound effects. They can be switched off on the menu. The notes in Pitch
/// Match and the clicks in Beat Keeper are part of those games and always play.
enum Sound {
    static let enabledKey = "settings.soundEnabled"

    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

    static func correct() {
        guard isEnabled else { return }
        TonePlayer.shared.play(notes: [(660, 0.08), (880, 0.14)])
    }

    static func wrong() {
        guard isEnabled else { return }
        TonePlayer.shared.play(notes: [(233, 0.09), (185, 0.16)])
    }

    static func win() {
        guard isEnabled else { return }
        TonePlayer.shared.play(notes: [(523, 0.1), (659, 0.1), (784, 0.1), (1047, 0.24)])
    }
}

/// What the games call when something happens: a haptic and a sound together.
enum Feedback {
    static func tap() {
        Haptics.tap()
    }

    static func bump() {
        Haptics.bump()
    }

    static func success() {
        Haptics.success()
        Sound.correct()
    }

    static func failure() {
        Haptics.failure()
        Sound.wrong()
    }

    static func win() {
        Haptics.success()
        Sound.win()
    }
}
