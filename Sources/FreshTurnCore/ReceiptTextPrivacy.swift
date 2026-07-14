import Foundation

public enum ReceiptTextPrivacy {
    public static func redactedPreview(from recognizedText: String) -> String {
        let sensitiveMarkers = ["visa", "mastercard", "amex", "card ending", "loyalty", "member id"]
        return recognizedText
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
            .filter { line in
                let lowered = line.lowercased()
                let hasSensitiveMarker = sensitiveMarkers.contains { lowered.contains($0) }
                let longDigitRun = lowered.range(of: #"\d{10,}"#, options: .regularExpression) != nil
                return !hasSensitiveMarker && !longDigitRun
            }
            .joined(separator: "\n")
    }
}
