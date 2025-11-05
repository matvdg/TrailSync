import MapKit
import SwiftUI
import CoreLocation

struct WorkoutMapView: View {
    
    var coordinates: [CLLocation]
    
    @State private var position: MapCameraPosition

    init(coordinates: [CLLocation]) {
        self.coordinates = coordinates

        if !coordinates.isEmpty {
            let coords = coordinates.map { $0.coordinate }
            if let minLat = coords.map(\.latitude).min(),
               let maxLat = coords.map(\.latitude).max(),
               let minLon = coords.map(\.longitude).min(),
               let maxLon = coords.map(\.longitude).max() {

                let center = CLLocationCoordinate2D(
                    latitude: (minLat + maxLat) / 2,
                    longitude: (minLon + maxLon) / 2
                )

                let latDelta = (maxLat - minLat) * 1.5
                let lonDelta = (maxLon - minLon) * 1.5

                let region = MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                )

                self._position = State(initialValue: .region(region))
            } else {
                self._position = State(initialValue: .automatic)
            }
        } else {
            self._position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        Map(position: $position) {
            if !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates.map { $0.coordinate })
                    .stroke(.red, lineWidth: 5)
            }
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutMapView(coordinates: [
            CLLocation(latitude: 42.83191, longitude: 1.03097),
            CLLocation(latitude: 42.82659, longitude: 1.03883),
            CLLocation(latitude: 42.81841, longitude: 1.04140),
            CLLocation(latitude: 42.80900, longitude: 1.04951),
            CLLocation(latitude: 42.80427, longitude: 1.05286),
            CLLocation(latitude: 42.80031, longitude: 1.05951),
            CLLocation(latitude: 42.79801, longitude: 1.06728),
            CLLocation(latitude: 42.79747, longitude: 1.07239),
            CLLocation(latitude: 42.79527, longitude: 1.07904),
            CLLocation(latitude: 42.79533, longitude: 1.08393)
        ])}
}
