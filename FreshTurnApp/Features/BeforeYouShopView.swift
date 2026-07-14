import FreshTurnCore
import SwiftUI

struct BeforeYouShopView: View {
    @EnvironmentObject private var repository: RescueRepository

    let addManually: () -> Void
    @State private var selectedItem: RescueItem?

    private var unresolvedItems: [RescueItem] {
        repository.sprints
            .filter { !$0.isArchived }
            .flatMap(\.items)
            .filter { $0.resolution == nil }
    }

    var body: some View {
        ZStack {
            FreshTurnTheme.oat.ignoresSafeArea()
            if unresolvedItems.isEmpty {
                ShopEmptyState(addManually: addManually)
                    .padding(20)
            } else {
                List {
                    Section {
                        Text("Check what is still on hand before buying more. Add a note in item details when there’s something you don’t want to rebuy.")
                            .font(.subheadline)
                            .foregroundColor(FreshTurnTheme.muted)
                            .listRowBackground(FreshTurnTheme.paper)
                    }
                    ForEach(StorageLocation.allCases) { location in
                        let items = unresolvedItems
                            .filter { $0.storageLocation == location }
                            .sorted { $0.useFirstDate < $1.useFirstDate }
                        if !items.isEmpty {
                            Section(header: Text(location.title)) {
                                ForEach(items) { item in
                                    ShopCheckRow(item: item) {
                                        selectedItem = item
                                    }
                                    .listRowBackground(FreshTurnTheme.paper)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Before You Shop", displayMode: .inline)
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
                .environmentObject(repository)
        }
    }
}

private struct ShopCheckRow: View {
    let item: RescueItem
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(FreshTurnTheme.ink)
                    Text("Planned \(item.useFirstDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(FreshTurnTheme.muted)
                    if !item.shoppingNote.isEmpty {
                        Label(item.shoppingNote, systemImage: "note.text")
                            .font(.caption)
                            .foregroundColor(FreshTurnTheme.tomato)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(FreshTurnTheme.muted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(item.name), \(item.storageLocation.title)")
        .accessibilityHint("Open to resolve, edit, or add a shopping note")
    }
}

private struct ShopEmptyState: View {
    let addManually: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "basket")
                .font(.system(size: 42))
                .foregroundColor(FreshTurnTheme.leaf)
            Text("Nothing to carry forward")
                .font(.title2.weight(.bold))
            Text("Your active rescues have no unresolved items. Check the fridge yourself, or add one thing you noticed.")
                .multilineTextAlignment(.center)
                .foregroundColor(FreshTurnTheme.muted)
            Button("Add an Item Manually", action: addManually)
                .buttonStyle(SecondaryActionStyle())
        }
        .padding(22)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }
}

