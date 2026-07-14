import FreshTurnCore
import SwiftUI

private enum AppSheet: Identifiable {
    case newRescue
    case manualRescue

    var id: String {
        switch self {
        case .newRescue: return "new-rescue"
        case .manualRescue: return "manual-rescue"
        }
    }
}

struct AppRootView: View {
    @EnvironmentObject private var repository: RescueRepository
    @State private var presentedSheet: AppSheet?

    var body: some View {
        TabView {
            NavigationView {
                TodayView(
                    startReceiptRescue: showNewRescue,
                    addManually: showManualRescue
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem { Label("Today", systemImage: "sun.max.fill") }

            NavigationView {
                BeforeYouShopView(addManually: showManualRescue)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem { Label("Shop Check", systemImage: "basket.fill") }

            NavigationView {
                RescueHistoryView(startReceiptRescue: showNewRescue)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem { Label("Rescues", systemImage: "checklist") }

            NavigationView {
                PrivacySettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem { Label("Privacy", systemImage: "hand.raised.fill") }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .newRescue:
                NewRescueView(startManually: false)
                    .environmentObject(repository)
            case .manualRescue:
                NewRescueView(startManually: true)
                    .environmentObject(repository)
            }
        }
    }

    private func showNewRescue() {
        presentedSheet = .newRescue
    }

    private func showManualRescue() {
        presentedSheet = .manualRescue
    }
}

