import FreshTurnCore
import Foundation

enum KimiParserError: LocalizedError {
    case unavailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Cloud parsing is unavailable. No items were saved. You can retry or continue manually."
        case .invalidResponse:
            return "The parser returned an unreadable result. No items were saved. Review the text or continue manually."
        }
    }
}

final class KimiReceiptParser {
    private struct RequestBody: Encodable {
        let receiptText: String
        let locale: String
    }

    private struct ResponseBody: Decodable {
        let candidates: [CandidateBody]
    }

    private struct CandidateBody: Decodable {
        let name: String?
        let sourceLine: String
        let category: String?
        let confidence: String?
    }

    private let session: URLSession
    private let proxyURL: URL?

    init(session: URLSession = .shared, bundle: Bundle = .main) {
        self.session = session
        let configured = bundle.object(forInfoDictionaryKey: "KIMI_PROXY_URL") as? String
        proxyURL = configured.flatMap(URL.init(string:))
    }

    func parse(text: String, completion: @escaping (Result<[ReceiptCandidate], Error>) -> Void) {
        guard let proxyURL = proxyURL else {
            completion(.failure(KimiParserError.unavailable))
            return
        }
        var request = URLRequest(url: proxyURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(RequestBody(receiptText: text, locale: "en-US"))

        session.dataTask(with: request) { data, response, error in
            let result: Result<[ReceiptCandidate], Error>
            if error != nil || (response as? HTTPURLResponse)?.statusCode != 200 {
                result = .failure(KimiParserError.unavailable)
            } else if let data = data,
                      let body = try? JSONDecoder().decode(ResponseBody.self, from: data),
                      !body.candidates.isEmpty {
                let candidates = body.candidates.map { value in
                    let confidence = CandidateConfidence(rawValue: value.confidence ?? "") ?? .review
                    return ReceiptCandidate(
                        name: value.name ?? "",
                        sourceLine: value.sourceLine,
                        category: value.category ?? "Other",
                        confidence: value.name == nil ? .abstained : confidence,
                        correctionState: .confirmed
                    )
                }
                result = .success(candidates)
            } else {
                result = .failure(KimiParserError.invalidResponse)
            }
            DispatchQueue.main.async { completion(result) }
        }.resume()
    }
}

