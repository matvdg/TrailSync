import HealthKit
import SwiftUI
import CoreLocation

struct WorkoutRow: View {
    
    @State var showMap = false
    @State var isLoading = false
    @State var isLoadingMap = false
    @State var locations: [CLLocation] = []
    
    var workout: HKWorkout
    
    private let workoutManager = WorkoutManager.shared
 
    private var distance: String {
        workout.totalDistance?.doubleValue(for: .meter()).toString ?? "_"
    }
    
    private var duration: String {
        workout.duration.toDurationString
    }
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            WorkoutActivity.activity(from: workout.workoutActivityType).icon.imageScale(.large)
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(workout.startDate.toDateStyleShortString).fontWeight(.bold)
                HStack(alignment: .center, spacing: 8) {
                    if distance != "_" {
                        Text(distance)
                        Text("•")
                    }
                    Text(duration)
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            HStack(alignment: .center, spacing: 8) {
                Button {
                    Feedback.selected()
                    Task {
                        do {
                            isLoadingMap = true
                            locations = try await workoutManager.getLocations(for: workout)
                            guard !locations.isEmpty else { return }
                            showMap = true
                            isLoadingMap = false
                        } catch {
                            print(error)
                            isLoadingMap = false
                        }
                    }
                } label: {
                    if isLoadingMap {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Image(systemName: "map.fill")
                    }
                }
                .disabled(isLoadingMap)
                .buttonStyle(.borderedProminent)
                Button {
                    Feedback.selected()
                    if locations.isEmpty {
                        Task {
                            do {
                                isLoading = true
                                locations = try await workoutManager.getLocations(for: workout)
                                // TODO
//                                trailsToImport.insert(Trail(gpx: Gpx(name: name, description: description, locations: locations, date: Date())), at: 0)
                                isLoading = false
                            } catch {
                                print(error)
                                isLoading = false
                            }
                        }
                    } else {
                        //TODO
//                        trailsToImport.insert(Trail(gpx: Gpx(name: name, description: description, locations: locations, date: Date())), at: 0)
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Image(systemName: "arrow.down.doc.fill")
                    }
                }
                .disabled(isLoading)
                .buttonStyle(.borderedProminent)                
            }
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
        .navigationDestination(isPresented: $showMap, destination: {
            WorkoutMapView(coordinates: locations)
        })
    }
    
}

@available(iOS, deprecated: 17.0)
#Preview {
    let mockWorkout = HKWorkout(
        activityType: .hiking,
        start: Date().addingTimeInterval(-3600),
        end: Date(),
        duration: 3600,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 450),
        totalDistance: HKQuantity(unit: .meter(), doubleValue: 7500),
        metadata: [HKMetadataKeyIndoorWorkout : false]
    )
    
    let mockWorkout2 = HKWorkout(
        activityType: .running,
        start: Date().addingTimeInterval(-3600),
        end: Date(),
        duration: 3600*3,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 1000),
        totalDistance: HKQuantity(unit: .meter(), doubleValue: 17500),
        metadata: [HKMetadataKeyIndoorWorkout : false]
    )
    
    let mockWorkout3 = HKWorkout(
        activityType: .cycling,
        start: Date().addingTimeInterval(-3600*24),
        end: Date(),
        duration: 3800,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 1000),
        totalDistance: HKQuantity(unit: .meter(), doubleValue: 23000),
        metadata: [HKMetadataKeyIndoorWorkout : false]
    )
    
    let mockWorkout4 = HKWorkout(
        activityType: .walking,
        start: Date().addingTimeInterval(-3600*48),
        end: Date(),
        duration: 3623,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 1000),
        totalDistance: HKQuantity(unit: .meter(), doubleValue: 1200),
        metadata: [HKMetadataKeyIndoorWorkout : false]
    )
    
    return NavigationStack {
        List {
            WorkoutRow(workout: mockWorkout)
            WorkoutRow(workout: mockWorkout2)
            WorkoutRow(workout: mockWorkout3)
            WorkoutRow(workout: mockWorkout4)
        }
    }
}
