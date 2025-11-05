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
    @Relationship(deleteRule: .cascade, inverse: \Location.trail) var locations: [Location]? = []

    // HKWorkout properties
    var activityType: String = ""
    var duration: TimeInterval = 0
    var totalDistance: Double = 0

    init(name: String,
         timestamp: Date = .now,
         activityType: String,
         duration: TimeInterval,
         totalDistance: Double,
         locations: [Location]? = nil
    ) {
        self.name = name
        self.timestamp = timestamp
        self.activityType = activityType
        self.duration = duration
        self.totalDistance = totalDistance
        self.locations = locations
    }

#if canImport(HealthKit)
    @MainActor
    convenience init(workout: HKWorkout, locations: [Location]) {
        let activityTypeName = WorkoutActivity.activity(from: workout.workoutActivityType).id
        let duration = workout.duration
        let totalDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
        self.init(
            name: activityTypeName,
            timestamp: workout.startDate,
            activityType: activityTypeName,
            duration: duration,
            totalDistance: totalDistance,
            locations: locations
        )
    }
#endif
}

@Model
final class Location {
    var timestamp: Date = Date()
    var latitude: Double = 0
    var longitude: Double = 0
    var altitude: Double?
    var horizontalAccuracy: Double?
    var trail: Trail?

    init(location: CLLocation) {
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude ?? 0,
            horizontalAccuracy: horizontalAccuracy ?? 0,
            verticalAccuracy: -1,
            timestamp: timestamp
        )
    }
}
