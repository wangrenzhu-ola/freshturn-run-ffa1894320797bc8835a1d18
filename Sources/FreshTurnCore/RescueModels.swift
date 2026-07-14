import Foundation

public enum StorageLocation: String, Codable, CaseIterable, Identifiable {
    case fridge
    case freezer
    case counter

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .fridge: return "Fridge"
        case .freezer: return "Freezer"
        case .counter: return "Counter"
        }
    }
}

public enum CandidateConfidence: String, Codable, CaseIterable {
    case high
    case review
    case abstained

    public var title: String {
        switch self {
        case .high: return "High confidence"
        case .review: return "Please review"
        case .abstained: return "Needs a name"
        }
    }
}

public enum CorrectionState: String, Codable {
    case confirmed
    case corrected
    case manual
}

public enum ItemResolution: String, Codable, CaseIterable, Identifiable {
    case used
    case frozen
    case discarded
    case stillHere

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .used: return "Used"
        case .frozen: return "Frozen"
        case .discarded: return "Discarded"
        case .stillHere: return "Still Here"
        }
    }
}

public struct ReceiptCandidate: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var sourceLine: String
    public var category: String
    public var confidence: CandidateConfidence
    public var storageLocation: StorageLocation
    public var useFirstDate: Date
    public var correctionState: CorrectionState

    public init(
        id: UUID = UUID(),
        name: String,
        sourceLine: String,
        category: String = "Other",
        confidence: CandidateConfidence = .review,
        storageLocation: StorageLocation = .fridge,
        useFirstDate: Date = Date(),
        correctionState: CorrectionState = .manual
    ) {
        self.id = id
        self.name = name
        self.sourceLine = sourceLine
        self.category = category
        self.confidence = confidence
        self.storageLocation = storageLocation
        self.useFirstDate = useFirstDate
        self.correctionState = correctionState
    }
}

public struct RescueItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var sourceLine: String
    public var category: String
    public var confidence: CandidateConfidence
    public var correctionState: CorrectionState
    public var storageLocation: StorageLocation
    public var addedAt: Date
    public var useFirstDate: Date
    public var resolution: ItemResolution?
    public var resolvedAt: Date?
    public var shoppingNote: String

    public init(candidate: ReceiptCandidate, addedAt: Date = Date()) {
        id = candidate.id
        name = candidate.name
        sourceLine = candidate.sourceLine
        category = candidate.category
        confidence = candidate.confidence
        correctionState = candidate.correctionState
        storageLocation = candidate.storageLocation
        self.addedAt = addedAt
        useFirstDate = candidate.useFirstDate
        resolution = nil
        resolvedAt = nil
        shoppingNote = ""
    }
}

public struct RescueSprint: Identifiable, Codable, Equatable {
    public var id: UUID
    public var createdAt: Date
    public var receiptLabel: String
    public var items: [RescueItem]
    public var isArchived: Bool

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        receiptLabel: String,
        items: [RescueItem],
        isArchived: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.receiptLabel = receiptLabel
        self.items = items
        self.isArchived = isArchived
    }

    public var resolvedCount: Int {
        items.filter { $0.resolution != nil }.count
    }

    public var isFullyResolved: Bool {
        !items.isEmpty && resolvedCount == items.count
    }
}

