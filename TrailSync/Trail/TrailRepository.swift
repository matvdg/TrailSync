import Foundation
import HealthKit
import SwiftData

class TrailRepository {
    
    func create(from workout: HKWorkout, locations: [Location], context: ModelContext) {
        let trail = Trail(workout: workout, locations: locations)
        context.insert(trail)
        do { try context.save() } catch { print("Save error:", error) }
    }
}
