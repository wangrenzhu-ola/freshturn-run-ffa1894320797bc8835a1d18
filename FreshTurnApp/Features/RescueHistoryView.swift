import FreshTurnCore
import SwiftUI

struct RescueHistoryView: View {
    @EnvironmentObject private var repository: RescueRepository

    let startReceiptRescue: () -> Void

    var body: some View {
        ZStack {
            FreshTurnTheme.oat.ignoresSafeArea()
            if repository.sprints.isEmpty {
                RescueHistoryEmpty(startReceiptRescue: startReceiptRescue)
                    .padding(20)
            } else {
                List {
                    let active = repository.sprints.filter { !$0.isArchived }
                    let archived = repository.sprints.filter(\.isArchived)
                    if !active.isEmpty {
                        Section(header: Text("Active receipt rescues")) {
                            ForEach(active) { sprint in
                                SprintRow(sprint: sprint, archive: archive)
                                    .listRowBackground(FreshTurnTheme.paper)
                            }
                        }
                    }
                    if !archived.isEmpty {
                        Section(header: Text("Archived")) {
                            ForEach(archived) { sprint in
                                SprintRow(sprint: sprint, archive: archive)
                                    .listRowBackground(FreshTurnTheme.paper)
                            }
                        }
                    }
                    Section(header: Text("Local totals")) {
                        AggregateCountsRow(sprints: repository.sprints)
                            .listRowBackground(FreshTurnTheme.paper)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Rescue Sprints", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: startReceiptRescue) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Start a new receipt rescue")
            }
        }
    }

    private func archive(_ sprint: RescueSprint) {
        repository.archive(sprintID: sprint.id)
    }
}

private struct SprintRow: View {
    let sprint: RescueSprint
    let archive: (RescueSprint) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(sprint.receiptLabel)
                        .font(.headline)
                    Text(sprint.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(FreshTurnTheme.muted)
                }
                Spacer()
                Text("\(sprint.resolvedCount)/\(sprint.items.count)")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(sprint.isFullyResolved ? FreshTurnTheme.leaf : FreshTurnTheme.tomato)
            }
            ProgressView(value: Double(sprint.resolvedCount), total: Double(max(1, sprint.items.count)))
                .accentColor(sprint.isFullyResolved ? FreshTurnTheme.leaf : FreshTurnTheme.tomato)
            ForEach(sprint.items.filter { $0.resolution != nil }) { item in
                HStack {
                    Text(item.name)
                        .font(.caption)
                    Spacer()
                    Text(item.resolution?.title ?? "")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(FreshTurnTheme.leaf)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.name), marked \(item.resolution?.title.lowercased() ?? "resolved")")
            }
            if sprint.isFullyResolved && !sprint.isArchived {
                Button("Archive Completed Rescue") {
                    archive(sprint)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(FreshTurnTheme.leaf)
                .accessibilityHint("Keeps aggregate counts and resolution history on this device")
            }
        }
        .padding(.vertical, 5)
    }
}

private struct AggregateCountsRow: View {
    let sprints: [RescueSprint]

    var body: some View {
        let counts = RescueLogic.aggregateCounts(in: sprints)
        HStack {
            count(value: counts.confirmed, label: "Confirmed")
            Spacer()
            count(value: counts.corrected, label: "Corrected")
            Spacer()
            count(value: counts.resolved, label: "Resolved")
        }
        .padding(.vertical, 6)
    }

    private func count(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title2.monospacedDigit().weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            Text(label)
                .font(.caption)
                .foregroundColor(FreshTurnTheme.muted)
        }
    }
}

private struct RescueHistoryEmpty: View {
    let startReceiptRescue: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42))
                .foregroundColor(FreshTurnTheme.leaf)
            Text("One receipt, one finish line")
                .font(.title2.weight(.bold))
            Text("A rescue ends when this trip’s perishables are resolved. FreshTurn never asks you to maintain a full pantry.")
                .multilineTextAlignment(.center)
                .foregroundColor(FreshTurnTheme.muted)
            Button("Start a Receipt Rescue", action: startReceiptRescue)
                .buttonStyle(PrimaryActionStyle())
        }
        .padding(22)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }
}
