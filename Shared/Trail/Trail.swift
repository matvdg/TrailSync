import Foundation
import MapKit
import SwiftData
import CoreLocation
#if canImport(HealthKit)
import HealthKit
internal import CoreGraphics
#endif


@Model
final class Trail {
    
    var name: String = ""
    var timestamp: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \Location.trail) var locations: [Location]?
    
    var sortedCLLocations: [CLLocation]? {
        guard let locations else { return nil }
        return locations
            .filter { loc in
                CLLocationCoordinate2DIsValid(loc.coordinate) &&
                abs(loc.latitude) <= 90 &&
                abs(loc.longitude) <= 180 &&
                !(loc.latitude == 0 && loc.longitude == 0)
            }
            .sorted { $0.timestamp < $1.timestamp}
            .map { $0.clLocation }
    }
    
    // HKWorkout properties
    var activityType: String = ""
    
    var workoutActivityType: WorkoutActivity {
        WorkoutActivity(rawValue: activityType)!
    }
    
    var duration: TimeInterval = 0
    var totalDistance: Double = 0
    
    var isFav: Bool = false

    init(name: String,
         timestamp: Date = .now,
         activityType: String,
         duration: TimeInterval,
         totalDistance: Double,
         locations: [Location]
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
