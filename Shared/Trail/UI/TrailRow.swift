import SwiftUI
import MapKit

struct TrailRow: View {
    
    @Bindable var trail: Trail
    
    var body: some View {
        
        HStack {
            
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    trail.workoutActivityType.icon
                    Text(trail.name)
                        .font(.headline)
                }
                
                HStack {
                    Text(trail.totalDistance.toString)
                    Text("•")
                    Text(trail.duration.toDurationString)
                }
                .font(.subheadline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
            
            Spacer()
            
            FavButton(isFav: $trail.isFav)
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
    }
    
}

// MARK: Preview
#Preview {
    NavigationStack {
        List {
            TrailRow(trail: Trail(name: "Rando", activityType: WorkoutActivity.hiking.id, duration: 3877, totalDistance: 12233, locations: [
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
            ]))
        }
        .navigationTitle("Trails")
    }
}
