import SwiftUI
import UIKit

@main
struct MiniGameHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var scores = HighScoreStore()
    @StateObject private var daily = DailyStore()

    var body: some Scene {
        WindowGroup {
            HubView()
                .environmentObject(scores)
                .environmentObject(daily)
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
