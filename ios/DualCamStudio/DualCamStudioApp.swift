import SwiftUI

@main
struct DualCamStudioApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(.dark)
                .tint(.pink)
        }
    }
}
