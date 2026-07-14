import Foundation

public enum RescueLogic {
    public static func todayItems(in sprints: [RescueSprint], limit: Int = 3) -> [RescueItem] {
        sprints
            .filter { !$0.isArchived }
            .flatMap(\.items)
            .filter { $0.resolution == nil }
            .sorted {
                if $0.useFirstDate == $1.useFirstDate {
                    return $0.addedAt < $1.addedAt
                }
                return $0.useFirstDate < $1.useFirstDate
            }
            .prefix(max(0, limit))
            .map { $0 }
    }

    public static func unresolvedByLocation(
        in sprints: [RescueSprint]
    ) -> [(location: StorageLocation, items: [RescueItem])] {
        let active = sprints
            .filter { !$0.isArchived }
            .flatMap(\.items)
            .filter { $0.resolution == nil }

        return StorageLocation.allCases.compactMap { location in
            let items = active.filter { $0.storageLocation == location }
                .sorted { $0.useFirstDate < $1.useFirstDate }
            return items.isEmpty ? nil : (location, items)
        }
    }

    public static func aggregateCounts(in sprints: [RescueSprint]) -> (confirmed: Int, corrected: Int, resolved: Int) {
        let items = sprints.flatMap(\.items)
        return (
            items.filter { $0.correctionState == .confirmed }.count,
            items.filter { $0.correctionState != .confirmed }.count,
            items.filter { $0.resolution != nil }.count
        )
    }
}

