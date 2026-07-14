import Combine
import Foundation

public final class RescueRepository: ObservableObject {
    @Published public private(set) var sprints: [RescueSprint]
    @Published public private(set) var persistenceError: String?

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil) {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.fileURL = fileURL ?? baseURL
            .appendingPathComponent("FreshTurn", isDirectory: true)
            .appendingPathComponent("rescue-sprints.json")
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        sprints = []
        persistenceError = nil
        load()
    }

    public func addSprint(receiptLabel: String, candidates: [ReceiptCandidate]) {
        let cleaned = candidates.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !cleaned.isEmpty else { return }
        sprints.insert(
            RescueSprint(receiptLabel: receiptLabel, items: cleaned.map { RescueItem(candidate: $0) }),
            at: 0
        )
        save()
    }

    public func updateItem(_ item: RescueItem) {
        guard let location = itemLocation(id: item.id) else { return }
        sprints[location.sprint].items[location.item] = item
        save()
    }

    public func resolve(itemID: UUID, as resolution: ItemResolution, at date: Date = Date()) {
        guard let location = itemLocation(id: itemID) else { return }
        sprints[location.sprint].items[location.item].resolution = resolution
        sprints[location.sprint].items[location.item].resolvedAt = date
        save()
    }

    public func markStillHere(itemID: UUID, nextDate: Date) {
        guard let location = itemLocation(id: itemID) else { return }
        sprints[location.sprint].items[location.item].resolution = nil
        sprints[location.sprint].items[location.item].resolvedAt = nil
        sprints[location.sprint].items[location.item].useFirstDate = nextDate
        save()
    }

    public func archive(sprintID: UUID) {
        guard let index = sprints.firstIndex(where: { $0.id == sprintID && $0.isFullyResolved }) else { return }
        sprints[index].isArchived = true
        save()
    }

    public func reload() {
        load()
    }

    private func itemLocation(id: UUID) -> (sprint: Int, item: Int)? {
        for sprintIndex in sprints.indices {
            if let itemIndex = sprints[sprintIndex].items.firstIndex(where: { $0.id == id }) {
                return (sprintIndex, itemIndex)
            }
        }
        return nil
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            sprints = []
            return
        }
        do {
            sprints = try decoder.decode([RescueSprint].self, from: Data(contentsOf: fileURL))
            persistenceError = nil
        } catch {
            sprints = []
            persistenceError = "Your saved rescues could not be reopened. Nothing new was written."
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(sprints)
            try data.write(to: fileURL, options: .atomic)
            persistenceError = nil
        } catch {
            persistenceError = "FreshTurn could not save this change locally. Please try again."
        }
    }
}
