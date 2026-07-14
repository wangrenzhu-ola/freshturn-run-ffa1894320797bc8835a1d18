import SwiftUI

struct PrivacyPromiseHeader: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.title2)
                .foregroundColor(FreshTurnTheme.leaf)
            VStack(alignment: .leading, spacing: 4) {
                Text("Your image stays on this device")
                    .font(.headline)
                    .foregroundColor(FreshTurnTheme.ink)
                Text("Vision reads the receipt here. Only the redacted text you approve can go to the parser; the image is never uploaded.")
                    .font(.footnote)
                    .foregroundColor(FreshTurnTheme.muted)
            }
        }
        .padding(16)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }
}

struct CaptureOptions: View {
    let useCamera: () -> Void
    let importPhoto: () -> Void
    let continueManually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Start with this shop")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            Text("FreshTurn looks only for likely perishables. You’ll edit every suggestion before one explicit save.")
                .foregroundColor(FreshTurnTheme.muted)
            Button(action: useCamera) {
                Label("Photograph Receipt", systemImage: "camera.fill")
            }
            .buttonStyle(PrimaryActionStyle())
            Button(action: importPhoto) {
                Label("Import Receipt Photo", systemImage: "photo.fill")
            }
            .buttonStyle(SecondaryActionStyle())
            Button("Skip Receipt and Add Manually", action: continueManually)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(FreshTurnTheme.leaf)
                .frame(maxWidth: .infinity)
        }
    }
}

struct RecognizingCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: FreshTurnTheme.tomato))
            Text("Reading receipt text on device…")
                .font(.headline)
            Text("Nothing is being saved or uploaded.")
                .font(.footnote)
                .foregroundColor(FreshTurnTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(FreshTurnTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.cardRadius, style: .continuous))
    }
}

struct ReceiptTextReview: View {
    @Binding var receiptText: String
    @Binding var cloudConsent: Bool

    let isParsing: Bool
    let parse: () -> Void
    let continueManually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review exactly what can be sent")
                .font(.title2.weight(.bold))
                .foregroundColor(FreshTurnTheme.ink)
            TextEditor(text: $receiptText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 190)
                .padding(8)
                .background(FreshTurnTheme.paper)
                .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.smallRadius, style: .continuous))
                .accessibilityLabel("Recognized and redacted receipt text")
            Button("Done Editing Text") {
                dismissFreshTurnKeyboard()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(FreshTurnTheme.leaf)
            Toggle(isOn: $cloudConsent) {
                Text("Send this text—not the image—to the Kimi-backed proxy for transient parsing.")
                    .font(.subheadline)
            }
            .toggleStyle(SwitchToggleStyle(tint: FreshTurnTheme.tomato))
            Button(action: parse) {
                if isParsing {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Find Likely Perishables")
                }
            }
            .buttonStyle(PrimaryActionStyle())
            .disabled(!cloudConsent || receiptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isParsing)
            Button("Continue Manually Without Cloud", action: continueManually)
                .buttonStyle(SecondaryActionStyle())
        }
    }
}

struct ParsingRecoveryCard: View {
    let message: String
    let retry: () -> Void
    let continueManually: () -> Void
    let cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ErrorBanner(message: message)
            Button("Retry Parsing", action: retry)
                .buttonStyle(SecondaryActionStyle())
            Button("Continue Manually", action: continueManually)
                .buttonStyle(PrimaryActionStyle())
            Button("Cancel Without Saving", action: cancel)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(FreshTurnTheme.muted)
                .frame(maxWidth: .infinity)
        }
    }
}

