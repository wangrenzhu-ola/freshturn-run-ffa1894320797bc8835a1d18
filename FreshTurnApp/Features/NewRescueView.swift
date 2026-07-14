import FreshTurnCore
import SwiftUI
import UIKit

private enum RescueStage {
    case capture
    case recognizing
    case textReview
    case candidateReview
}

private enum PickerSource: String, Identifiable {
    case camera
    case library

    var id: String { rawValue }
    var uiSource: UIImagePickerController.SourceType { self == .camera ? .camera : .photoLibrary }
}

struct NewRescueView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var repository: RescueRepository

    @State private var stage: RescueStage
    @State private var pickerSource: PickerSource?
    @State private var receiptText = ""
    @State private var candidates: [ReceiptCandidate] = []
    @State private var cloudConsent = false
    @State private var isParsing = false
    @State private var errorMessage: String?
    @State private var receiptLabel = "Grocery receipt"

    private let ocrService = ReceiptOCRService()
    private let parser = KimiReceiptParser()

    init(startManually: Bool) {
        _stage = State(initialValue: startManually ? .candidateReview : .capture)
        _candidates = State(initialValue: startManually ? [Self.blankCandidate()] : [])
    }

    var body: some View {
        NavigationView {
            ZStack {
                FreshTurnTheme.oat.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacyPromiseHeader()
                        stageContent
                        if let errorMessage = errorMessage {
                            ParsingRecoveryCard(
                                message: errorMessage,
                                retry: retryParsing,
                                continueManually: continueManually,
                                cancel: cancelWithoutSaving
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitle("New Rescue", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancelWithoutSaving)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(item: $pickerSource) { source in
            ReceiptImagePicker(sourceType: source.uiSource, onSelect: recognize)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var stageContent: some View {
        switch stage {
        case .capture:
            CaptureOptions(
                useCamera: { pickerSource = .camera },
                importPhoto: { pickerSource = .library },
                continueManually: continueManually
            )
        case .recognizing:
            RecognizingCard()
        case .textReview:
            ReceiptTextReview(
                receiptText: $receiptText,
                cloudConsent: $cloudConsent,
                isParsing: isParsing,
                parse: parseApprovedText,
                continueManually: continueManually
            )
        case .candidateReview:
            CandidateReview(
                receiptLabel: $receiptLabel,
                candidates: $candidates,
                sourceContext: receiptText,
                addCandidate: addCandidate,
                removeCandidate: removeCandidate,
                save: saveRescue
            )
        }
    }

    private func recognize(_ image: UIImage) {
        errorMessage = nil
        stage = .recognizing
        ocrService.recognizeText(in: image) { result in
            switch result {
            case .success(let text):
                receiptText = ReceiptTextPrivacy.redactedPreview(from: text)
                stage = .textReview
            case .failure(let error):
                errorMessage = error.localizedDescription
                stage = .capture
            }
        }
    }

    private func parseApprovedText() {
        guard cloudConsent, !receiptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isParsing = true
        errorMessage = nil
        parser.parse(text: receiptText) { result in
            isParsing = false
            switch result {
            case .success(let parsed):
                candidates = parsed
                stage = .candidateReview
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func retryParsing() {
        if stage == .textReview && cloudConsent {
            parseApprovedText()
        } else {
            errorMessage = nil
            stage = .capture
        }
    }

    private func continueManually() {
        errorMessage = nil
        if candidates.isEmpty { candidates = [Self.blankCandidate()] }
        stage = .candidateReview
    }

    private func addCandidate() {
        candidates.append(Self.blankCandidate())
    }

    private func removeCandidate(at index: Int) {
        guard candidates.indices.contains(index) else { return }
        candidates.remove(at: index)
    }

    private func saveRescue() {
        let ready = candidates.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !ready.isEmpty else {
            errorMessage = "Add a name for at least one item before saving."
            return
        }
        repository.addSprint(receiptLabel: receiptLabel, candidates: ready)
        presentationMode.wrappedValue.dismiss()
    }

    private func cancelWithoutSaving() {
        candidates = []
        receiptText = ""
        presentationMode.wrappedValue.dismiss()
    }

    private static func blankCandidate() -> ReceiptCandidate {
        ReceiptCandidate(name: "", sourceLine: "", confidence: .abstained, correctionState: .manual)
    }
}
