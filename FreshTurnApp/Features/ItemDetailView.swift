import FreshTurnCore
import SwiftUI

struct ItemDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var repository: RescueRepository

    @State private var draft: RescueItem

    init(item: RescueItem) {
        _draft = State(initialValue: item)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Confirmed item")) {
                    TextField("Item name", text: $draft.name)
                        .accessibilityLabel("Item name")
                    Picker("Storage", selection: $draft.storageLocation) {
                        ForEach(StorageLocation.allCases) { location in
                            Text(location.title).tag(location)
                        }
                    }
                    DatePicker("Use-first plan", selection: $draft.useFirstDate, displayedComponents: .date)
                }

                Section(header: Text("Receipt provenance")) {
                    Text(draft.sourceLine.isEmpty ? "Manual entry" : draft.sourceLine)
                        .font(.system(.body, design: .monospaced))
                    Text(draft.confidence.title)
                        .foregroundColor(FreshTurnTheme.muted)
                }

                Section(header: Text("Before your next shop")) {
                    TextField("Optional note — for example, don’t rebuy", text: $draft.shoppingNote)
                }

                Section(header: Text("Resolve"), footer: Text("Still Here keeps the item active and moves its planning date to tomorrow.")) {
                    ResolutionActionRow(itemID: draft.id, dismiss: dismiss)
                }

                Section {
                    Text("This date helps you plan; it does not determine whether food is safe to eat.")
                        .font(.footnote)
                        .foregroundColor(FreshTurnTheme.muted)
                }
            }
            .navigationBarTitle("Item Details", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func save() {
        if draft.name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            draft.correctionState = .corrected
            repository.updateItem(draft)
            dismiss()
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

private struct ResolutionActionRow: View {
    @EnvironmentObject private var repository: RescueRepository

    let itemID: UUID
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                resolutionButton(.used, icon: "fork.knife")
                resolutionButton(.frozen, icon: "snowflake")
            }
            HStack(spacing: 10) {
                resolutionButton(.discarded, icon: "trash")
                Button(action: keepStillHere) {
                    Label("Still Here", systemImage: "arrow.forward.circle")
                        .frame(maxWidth: .infinity)
                }
                .accessibilityLabel("Mark still here and plan for tomorrow")
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func resolutionButton(_ resolution: ItemResolution, icon: String) -> some View {
        Button {
            repository.resolve(itemID: itemID, as: resolution)
            dismiss()
        } label: {
            Label(resolution.title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .accessibilityLabel("Mark item \(resolution.title.lowercased())")
    }

    private func keepStillHere() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        repository.markStillHere(itemID: itemID, nextDate: tomorrow)
        dismiss()
    }
}
