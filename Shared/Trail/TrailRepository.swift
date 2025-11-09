import Foundation
import HealthKit
import SwiftData

class TrailRepository {
    
    func create(from workout: HKWorkout, locations: [Location], context: ModelContext) {
        let trail = Trail(workout: workout, locations: locations)
        context.insert(trail)
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    func delete(trailID: PersistentIdentifier, container: ModelContainer) {

        Task.detached(priority: .userInitiated) {
            let backgroundContext = ModelContext(container)
            if let trailToDelete = backgroundContext.model(for: trailID) as? Trail {
                backgroundContext.delete(trailToDelete)
                do {
                    try backgroundContext.save()
                } catch {
                    print("Save error:", error)
                }
            }
        }
    }
    
}
