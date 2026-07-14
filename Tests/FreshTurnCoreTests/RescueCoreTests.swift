import Foundation
import XCTest
@testable import FreshTurnCore

final class RescueCoreTests: XCTestCase {
    func testTodayQueueIsDateOrderedAndLimitedToThree() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let candidates = (0..<4).map { offset in
            ReceiptCandidate(
                name: "Item \(offset)",
                sourceLine: "LINE \(offset)",
                useFirstDate: now.addingTimeInterval(TimeInterval((3 - offset) * 86_400))
            )
        }
        let sprint = RescueSprint(receiptLabel: "Weekly shop", items: candidates.map { RescueItem(candidate: $0) })

        let queue = RescueLogic.todayItems(in: [sprint])

        XCTAssertEqual(queue.count, 3)
        XCTAssertEqual(queue.map(\.name), ["Item 3", "Item 2", "Item 1"])
    }

    func testResolveAdvancesQueueAndPersistsHistory() {
        let fileURL = temporaryFileURL()
        let repository = RescueRepository(fileURL: fileURL)
        let first = ReceiptCandidate(name: "Spinach", sourceLine: "ORG SPIN", useFirstDate: Date())
        let second = ReceiptCandidate(name: "Yogurt", sourceLine: "GRK YGT", useFirstDate: Date().addingTimeInterval(86_400))
        repository.addSprint(receiptLabel: "Market receipt", candidates: [first, second])

        repository.resolve(itemID: first.id, as: .used)

        XCTAssertEqual(RescueLogic.todayItems(in: repository.sprints).first?.id, second.id)
        XCTAssertEqual(repository.sprints.first?.items.first?.resolution, .used)
    }

    func testSavedEditReopensFromDiskWithoutSampleContent() {
        let fileURL = temporaryFileURL()
        let repository = RescueRepository(fileURL: fileURL)
        let candidate = ReceiptCandidate(name: "Peaches", sourceLine: "PCH 2LB")
        repository.addSprint(receiptLabel: "Grocery receipt", candidates: [candidate])
        var edited = try! XCTUnwrap(repository.sprints.first?.items.first)
        edited.name = "White peaches"
        edited.storageLocation = .counter
        repository.updateItem(edited)

        let reopened = RescueRepository(fileURL: fileURL)

        XCTAssertEqual(reopened.sprints.first?.items.first?.name, "White peaches")
        XCTAssertEqual(reopened.sprints.first?.items.first?.storageLocation, .counter)
        XCTAssertEqual(reopened.sprints.count, 1)
    }

    func testStillHereKeepsItemUnresolvedAndMovesPlanningDate() {
        let fileURL = temporaryFileURL()
        let repository = RescueRepository(fileURL: fileURL)
        let candidate = ReceiptCandidate(name: "Bread", sourceLine: "SOURDGH")
        repository.addSprint(receiptLabel: "Bakery", candidates: [candidate])
        let tomorrow = Date().addingTimeInterval(86_400)

        repository.markStillHere(itemID: candidate.id, nextDate: tomorrow)

        XCTAssertNil(repository.sprints.first?.items.first?.resolution)
        let storedDate = try! XCTUnwrap(repository.sprints.first?.items.first?.useFirstDate)
        XCTAssertEqual(storedDate.timeIntervalSince1970, tomorrow.timeIntervalSince1970, accuracy: 1)
    }

    func testReceiptPreviewRemovesPaymentAndLoyaltyLinesButKeepsGroceries() {
        let text = "ORGANIC SPINACH\nVISA 4242\nLOYALTY MEMBER ID 9988\nGREEK YOGURT\n123456789012"

        let redacted = ReceiptTextPrivacy.redactedPreview(from: text)

        XCTAssertEqual(redacted, "ORGANIC SPINACH\nGREEK YOGURT")
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("rescues.json")
    }
}
