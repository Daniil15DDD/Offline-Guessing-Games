import UIKit

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
