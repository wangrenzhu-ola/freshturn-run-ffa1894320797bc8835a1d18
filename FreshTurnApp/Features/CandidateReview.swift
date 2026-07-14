import FreshTurnCore
import SwiftUI

struct CandidateReview: View {
    @Binding var receiptLabel: String
    @Binding var candidates: [ReceiptCandidate]

    let sourceContext: String
    let addCandidate: () -> Void
    let removeCandidate: (Int) -> Void
    let save: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Confirm your rescue")
                .font(.title2.weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            Text("Edit names, storage, and planning dates. Suggestions are not saved until you tap Save Rescue.")
                .font(.subheadline)
                .foregroundColor(FreshTurnTheme.muted)
            TextField("Receipt label", text: $receiptLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            sourceReference
            candidateGroups
            Button(action: addCandidate) {
                Label("Add Another Item", systemImage: "plus.circle.fill")
            }
            .buttonStyle(SecondaryActionStyle())
            Button("Save Rescue", action: save)
                .buttonStyle(PrimaryActionStyle())
                .accessibilityHint("Saves only the reviewed items to this device")
            Button("Done Editing") {
                dismissFreshTurnKeyboard()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(FreshTurnTheme.leaf)
            .frame(maxWidth: .infinity)
            Text("Planning dates are reminders—not food-safety or edibility advice.")
                .font(.footnote)
                .foregroundColor(FreshTurnTheme.muted)
        }
    }

    @ViewBuilder
    private var sourceReference: some View {
        if !sourceContext.isEmpty {
            DisclosureGroup("Recognized text kept for reference") {
                Text(sourceContext)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(FreshTurnTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var candidateGroups: some View {
        ForEach(categoryOrder, id: \.self) { category in
            VStack(alignment: .leading, spacing: 10) {
                Text(category.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundColor(FreshTurnTheme.leaf)
                ForEach(indices(for: category), id: \.self) { index in
                    CandidateEditor(candidate: $candidates[index]) {
                        removeCandidate(index)
                    }
                }
            }
        }
    }

    private var categoryOrder: [String] {
        let preferred = ["Produce", "Chilled", "Bakery", "Other"]
        let existing = Set(candidates.map { normalizedCategory($0.category) })
        return preferred.filter(existing.contains) + existing.filter { !preferred.contains($0) }.sorted()
    }

    private func indices(for category: String) -> [Int] {
        candidates.indices.filter { normalizedCategory(candidates[$0].category) == category }
    }

    private func normalizedCategory(_ value: String) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return "Other" }
        switch clean.lowercased() {
        case "produce": return "Produce"
        case "chilled", "dairy": return "Chilled"
        case "bakery": return "Bakery"
        case "other": return "Other"
        default: return clean.capitalized
        }
    }
}

private struct CandidateEditor: View {
    @Binding var candidate: ReceiptCandidate
    let remove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(candidate.confidence.title.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundColor(candidate.confidence == .high ? FreshTurnTheme.leaf : FreshTurnTheme.tomato)
                Spacer()
                Button(action: remove) { Image(systemName: "trash") }
                    .foregroundColor(FreshTurnTheme.tomato)
                    .accessibilityLabel("Delete this candidate")
            }
            TextField("Perishable name", text: $candidate.name, onEditingChanged: markCorrected)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Candidate item name")
            if !candidate.sourceLine.isEmpty {
                Text("Receipt: \(candidate.sourceLine)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(FreshTurnTheme.muted)
            }
            Picker("Storage", selection: $candidate.storageLocation) {
                ForEach(StorageLocation.allCases) { location in
                    Text(location.title).tag(location)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: candidate.storageLocation) { _ in
                markCorrected()
            }
            DatePicker("Use-first plan", selection: $candidate.useFirstDate, displayedComponents: .date)
                .font(.subheadline)
                .onChange(of: candidate.useFirstDate) { _ in
                    markCorrected()
                }
        }
        .padding(16)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }

    private func markCorrected(_ isEditing: Bool) {
        guard isEditing else { return }
        markCorrected()
    }

    private func markCorrected() {
        guard candidate.correctionState == .confirmed else { return }
        candidate.correctionState = .corrected
    }
}
