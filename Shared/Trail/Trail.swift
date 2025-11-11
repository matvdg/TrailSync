import Foundation
import SwiftData
import CoreLocation
#if canImport(HealthKit)
import HealthKit
#endif


@Model
final class Trail {
    
    var name: String = ""
    var timestamp: Date = Date()
    
    // Encoded track data holding compressed location points (latitude, longitude, elevation, timestamp)
    // This is used for performance and simplicity instead of storing individual Location objects
    var encodedTrack: Data?
    
    @MainActor
    var locations: [TrailLocation] { (try? TrailLocation.decode(encodedTrack ?? Data())) ?? [] }
    
    // HKWorkout properties
    var activityType: String = ""
    
    var workoutActivityType: WorkoutActivity {
        WorkoutActivity(rawValue: activityType)!
    }
    
    var duration: TimeInterval = 0
    var totalDistance: Double = 0
    
    var isFav: Bool = false

    @MainActor
    init(name: String,
         timestamp: Date = .now,
         activityType: String,
         duration: TimeInterval,
         totalDistance: Double,
         locations: [CLLocation]
    ) {
        self.name = name
        self.timestamp = timestamp
        self.activityType = activityType
        self.duration = duration
        self.totalDistance = totalDistance
        self.encodedTrack = try? TrailLocation.encode(locations)
    }

#if !os(macOS) && !os(tvOS)
    @MainActor
    convenience init(workout: HKWorkout, locations: [CLLocation]) {
        let activityTypeName = WorkoutActivity.activity(from: workout.workoutActivityType).id
        let duration = workout.duration
        let totalDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
        let date = workout.startDate.toDateStyleShortString
        self.init(
            name: date,
            timestamp: workout.startDate,
            activityType: activityTypeName,
            duration: duration,
            totalDistance: totalDistance,
            locations: locations
        )
    }
#endif
    
}
