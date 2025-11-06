import SwiftUI
import CoreLocation

struct TrailView: View {
    
    @Bindable var trail: Trail
    
    var body: some View {
        VStack {
            if let locations = trail.sortedCLLocations {
                NavigationLink {
                    WorkoutMapView(coordinates: locations)
                } label: {
                    WorkoutMapView(coordinates: locations)
                        .disabled(true)
                        .frame(maxHeight: 200)
                }
            }
            Form {
                TextField("Name", text: $trail.name)
                Label(trail.timestamp.toDateStyleMediumWithTimeString, systemImage: "calendar.badge.clock")
                HStack {
                    trail.workoutActivityType.icon.foregroundStyle(Color.accentColor)
                    Text(trail.totalDistance.toString)
                    Text("•")
                    Text(trail.duration.toDurationString)
                }
                Button {
                    trail.isFav.toggle()
                } label: {
                    Label(trail.isFav ? "RemoveFromFavorites" : "AddToFavorites", systemImage: trail.isFav ? "star.slash" : "star")
                }
            }
            .formStyle(.grouped)
            Spacer()
        }
        .navigationTitle(trail.name)
    }
}

#Preview {
    let trail = Trail(name: "Rando", activityType: WorkoutActivity.hiking.id, duration: 3877, totalDistance: 12233, locations: [
        Location(location: CLLocation(latitude: 42.83191, longitude: 1.03097)),
        Location(location: CLLocation(latitude: 42.82659, longitude: 1.03883)),
        Location(location: CLLocation(latitude: 42.81841, longitude: 1.04140)),
        Location(location: CLLocation(latitude: 42.80900, longitude: 1.04951)),
        Location(location: CLLocation(latitude: 42.80427, longitude: 1.05286)),
        Location(location: CLLocation(latitude: 42.80031, longitude: 1.05951)),
        Location(location: CLLocation(latitude: 42.79801, longitude: 1.06728)),
        Location(location: CLLocation(latitude: 42.79747, longitude: 1.07239)),
        Location(location: CLLocation(latitude: 42.79527, longitude: 1.07904)),
        Location(location: CLLocation(latitude: 42.79533, longitude: 1.08393))
    ])
    NavigationStack {
        TrailView(trail: trail)
    }
}
