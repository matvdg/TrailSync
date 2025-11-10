#if !os(macOS) && !os(tvOS)
import HealthKit
import SwiftUI
import CoreLocation

struct WorkoutRow: View {
    
    @State var isLoading = false
    @State var isLoadingMap = false
    
    @Binding var locations: [CLLocation]
    @Binding var showWorkoutMapView: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var workout: HKWorkout
    
    private let workoutRepository = WorkoutRepository()
    private let trailRepository = TrailRepository()
    
    private var distance: String {
        workout.totalDistance?.doubleValue(for: .meter()).toString ?? "_"
    }
    
    private var duration: String {
        workout.duration.toDurationString
    }
    
    var body: some View {
        
        HStack(spacing: 16) {
            
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
                    Feedback.selectionChanged.play()
                    Task {
                        do {
                            isLoadingMap = true
                            locations = try await workoutRepository.getLocations(for: workout)
                            showWorkoutMapView = true
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
                .modifier(ButtonStyleProminentModifier())
                Button {
                    Feedback.selectionChanged.play()
                    Task {
                        do {
                            isLoading = true
                            let locations = try await workoutRepository.getLocations(for: workout)
                            trailRepository.create(from: workout, locations: locations, context: context)
                            isLoading = false
                            dismiss()
                        } catch {
                            print(error)
                            isLoading = false
                        }
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
                .modifier(ButtonStyleProminentModifier())
            }
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
    }
    
    
}

@available(iOS, deprecated: 17.0)
@available(watchOS, deprecated: 10.0)
#Preview {
    
    @Previewable @State var locations: [CLLocation] = []
    @Previewable @State var showWorkoutMapView: Bool = false
    
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
            WorkoutRow(locations: $locations, showWorkoutMapView: $showWorkoutMapView, workout: mockWorkout, )
            WorkoutRow(locations: $locations, showWorkoutMapView: $showWorkoutMapView, workout: mockWorkout2)
            WorkoutRow(locations: $locations, showWorkoutMapView: $showWorkoutMapView, workout: mockWorkout3)
            WorkoutRow(locations: $locations, showWorkoutMapView: $showWorkoutMapView, workout: mockWorkout4)
        }
    }
}
#endif
