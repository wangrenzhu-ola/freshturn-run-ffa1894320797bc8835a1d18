import FreshTurnCore
import SwiftUI

@main
struct FreshTurnApp: App {
    @StateObject private var repository = RescueRepository()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(repository)
                .accentColor(FreshTurnTheme.tomato)
        }
    }
}

