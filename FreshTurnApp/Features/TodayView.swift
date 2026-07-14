import FreshTurnCore
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var repository: RescueRepository

    let startReceiptRescue: () -> Void
    let addManually: () -> Void
    @State private var selectedItem: RescueItem?

    private var queue: [RescueItem] {
        RescueLogic.todayItems(in: repository.sprints)
    }

    var body: some View {
        ZStack {
            FreshTurnTheme.oat.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TodayHeader(queueCount: queue.count)
                    if queue.isEmpty {
                        EmptyQueueCard(
                            startReceiptRescue: startReceiptRescue,
                            addManually: addManually
                        )
                    } else {
                        QueueSection(items: queue, selectedItem: $selectedItem)
                        PlanningBoundaryCard()
                    }
                    if let error = repository.persistenceError {
                        ErrorBanner(message: error)
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitle("FreshTurn", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: startReceiptRescue) {
                    Image(systemName: "doc.viewfinder")
                }
                .accessibilityLabel("Start a new receipt rescue")
            }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
                .environmentObject(repository)
        }
    }
}

private struct TodayHeader: View {
    let queueCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("USE FIRST")
                .font(.caption.weight(.bold))
                .tracking(1.8)
                .foregroundColor(FreshTurnTheme.tomato)
            Text(queueCount == 0 ? "Your next small save" : "A short list, on purpose")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            Text("Up to three perishables from your confirmed receipt rescues.")
                .font(.subheadline)
                .foregroundColor(FreshTurnTheme.muted)
        }
    }
}

private struct QueueSection: View {
    let items: [RescueItem]
    @Binding var selectedItem: RescueItem?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    selectedItem = item
                } label: {
                    UseFirstCard(position: index + 1, item: item)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("\(item.name), use first position \(index + 1), \(item.storageLocation.title)")
                .accessibilityHint("Opens item details and resolution choices")
            }
        }
    }
}

private struct UseFirstCard: View {
    let position: Int
    let item: RescueItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(position)")
                .font(.title2.monospacedDigit().weight(.bold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(position == 1 ? FreshTurnTheme.tomato : FreshTurnTheme.leaf)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(FreshTurnTheme.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(FreshTurnTheme.muted)
                }
                ReceiptRule()
                Label(item.storageLocation.title, systemImage: locationIcon(item.storageLocation))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(FreshTurnTheme.leaf)
                Text("Plan for \(item.useFirstDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(FreshTurnTheme.muted)
                Text("Receipt: \(item.sourceLine.isEmpty ? "Manual entry" : item.sourceLine)")
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(2)
                    .foregroundColor(FreshTurnTheme.muted)
            }
        }
        .padding(16)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func locationIcon(_ location: StorageLocation) -> String {
        switch location {
        case .fridge: return "snowflake"
        case .freezer: return "cube.fill"
        case .counter: return "house.fill"
        }
    }
}

private struct EmptyQueueCard: View {
    let startReceiptRescue: () -> Void
    let addManually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .font(.system(size: 38))
                .foregroundColor(FreshTurnTheme.leaf)
            Text("No rescue is waiting")
                .font(.title2.weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            Text("Start with one grocery receipt. You’ll review likely perishables before anything is saved—never a whole-pantry chore.")
                .font(.body)
                .foregroundColor(FreshTurnTheme.muted)
            Button("New Receipt Rescue", action: startReceiptRescue)
                .buttonStyle(PrimaryActionStyle())
            Button("Add One Item Manually", action: addManually)
                .buttonStyle(SecondaryActionStyle())
        }
        .padding(20)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }
}

private struct PlanningBoundaryCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .foregroundColor(FreshTurnTheme.tomato)
            Text("Use-first dates are planning reminders you control. They are not food-safety or edibility advice.")
                .font(.footnote)
                .foregroundColor(FreshTurnTheme.muted)
        }
        .padding(14)
        .background(FreshTurnTheme.tomato.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.smallRadius, style: .continuous))
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundColor(FreshTurnTheme.tomato)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FreshTurnTheme.tomato.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.smallRadius, style: .continuous))
    }
}
