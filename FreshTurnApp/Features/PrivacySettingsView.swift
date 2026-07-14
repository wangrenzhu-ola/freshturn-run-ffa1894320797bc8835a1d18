import SwiftUI

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Receipt capture")) {
                PrivacyRow(
                    icon: "viewfinder",
                    title: "On-device recognition",
                    detail: "Apple Vision reads the receipt image on this device. FreshTurn does not upload the image."
                )
                PrivacyRow(
                    icon: "text.quote",
                    title: "Text-only cloud boundary",
                    detail: "For each scan, you review redacted text and explicitly approve sending it to a secret-safe Kimi-backed proxy."
                )
            }

            Section(header: Text("Saved on this device")) {
                PrivacyRow(
                    icon: "externaldrive.fill",
                    title: "Confirmed rescues only",
                    detail: "Structured items, edits, notes, dates, and resolution history stay in local app storage. Nothing is saved before Save Rescue."
                )
            }

            Section(header: Text("AI and planning boundaries")) {
                PrivacyRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "You confirm every suggestion",
                    detail: "Parser output can abstain and is always editable. A parser failure leaves the manual rescue flow available."
                )
                PrivacyRow(
                    icon: "cross.case",
                    title: "Not food-safety advice",
                    detail: "Use-first dates are planning reminders. FreshTurn never decides whether food is safe, spoiled, or edible."
                )
            }

            Section(footer: Text("FreshTurn requests camera or photo access only when you choose that receipt source. It does not request tracking, microphone, contacts, or location access.")) {
                Label("No account · No tracking · No receipt image upload", systemImage: "checkmark.shield.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(FreshTurnTheme.leaf)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Privacy & Boundaries", displayMode: .inline)
    }
}

private struct PrivacyRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(FreshTurnTheme.tomato)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(FreshTurnTheme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(FreshTurnTheme.muted)
            }
        }
        .padding(.vertical, 5)
    }
}

