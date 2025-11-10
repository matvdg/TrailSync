import Foundation
import CoreLocation

/// This struct handles compact encoding/decoding of GPS points for SwiftData storage efficiency.
struct TrailLocation: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let date: Date

    /// Filters and sorts an array of CLLocation objects to ensure only valid and accurate locations with precise altitude are processed.
    /// This helps maintain data integrity when working with HealthKit and SwiftData by removing invalid or poor-quality location points,
    /// and keeps only locations with valid and precise altitude, making elevation graphs cleaner.
    static func filterAndSort(_ locations: [CLLocation]) -> [CLLocation] {
        // Diagnostic counters for filtered out points
        var invalidCoordinateCount = 0
        var badHorizontalAccuracyCount = 0

        let filtered = locations.filter { location in
            let coordinate = location.coordinate
            let validCoordinate = CLLocationCoordinate2DIsValid(coordinate)
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            let horizontalAccuracy = location.horizontalAccuracy

            var isValid = true

            if !validCoordinate || abs(lat) > 90 || abs(lon) > 180 || (lat == 0 && lon == 0) {
                invalidCoordinateCount += 1
                print("❌ Filtered out invalid coordinate: latitude=\(lat), longitude=\(lon) at \(location.timestamp)")
                isValid = false
            }
            if horizontalAccuracy < 0 || horizontalAccuracy > 50 {
                badHorizontalAccuracyCount += 1
                print("❌ Filtered out due to horizontal accuracy: \(horizontalAccuracy) at \(location.timestamp)")
                isValid = false
            }
            return isValid
        }
        .sorted { $0.timestamp < $1.timestamp }

        // Diagnostic summary log - can be commented out or removed later
        print("ℹ️  Filtering summary: total points : \(locations.count) Invalid coordinates filtered out: \(invalidCoordinateCount), Bad horizontal accuracy filtered out: \(badHorizontalAccuracyCount), Total valid points retained: \(filtered.count), first = \(locations.first!.timestamp), last = \(locations.last!.timestamp)")

        return filtered
    }

    /// Encodes an array of CLLocation objects into Data using JSONEncoder.
    static func encode(_ locations: [CLLocation]) throws -> Data {
        let filteredLocations = filterAndSort(locations)
        let trailLocations = filteredLocations.map { location in
            let validAltitude = (location.verticalAccuracy < 0 || location.verticalAccuracy > 10) ? nil : location.altitude
            return TrailLocation(latitude: location.coordinate.latitude,
                          longitude: location.coordinate.longitude,
                          altitude: validAltitude,
                          date: location.timestamp)
        }
        return try JSONEncoder().encode(trailLocations)
    }

    /// Decodes Data into an array of TrailLocation objects.
    static func decode(_ data: Data) throws -> [TrailLocation] {
        try JSONDecoder().decode([TrailLocation].self, from: data)
    }
}

extension Array where Element == TrailLocation {
    func toCLLocations() -> [CLLocation] {
        map { trailLocation in
            CLLocation(coordinate: CLLocationCoordinate2D(latitude: trailLocation.latitude,
                                                          longitude: trailLocation.longitude),
                       altitude: trailLocation.altitude ?? 0,
                       horizontalAccuracy: kCLLocationAccuracyBest,
                       verticalAccuracy: trailLocation.altitude == nil ? -1 : kCLLocationAccuracyBest,
                       timestamp: trailLocation.date
            )
        }
    }
}
