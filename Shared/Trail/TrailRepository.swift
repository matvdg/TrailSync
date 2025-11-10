
import Foundation
import SwiftData
import CoreLocation
#if canImport(HealthKit)
import HealthKit
#endif

class TrailRepository {
    
#if os(watchOS) || os(iOS) || os(visionOS)
    func create(from workout: HKWorkout, locations: [CLLocation], context: ModelContext) {
        let trail = Trail(workout: workout, locations: locations)
        context.insert(trail)
        do { try context.save() } catch { print("Save error:", error) }
    }
    #endif
    
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
