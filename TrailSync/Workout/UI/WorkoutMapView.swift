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
            let center: CLLocationCoordinate2D
            if coords.count == 1 {
                center = coords[0]
            } else {
                let lat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
                let lon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
                center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self._position = State(initialValue: .region(region))
        } else {
            self._position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        Map(position: $position) {
            if !coordinates.isEmpty {
                MapPolygon(coordinates: coordinates.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 2)
                    .foregroundStyle(.blue.opacity(0.3))
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
    WorkoutMapView(coordinates: [CLLocation(latitude: 1, longitude: 2)])
}
