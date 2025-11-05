import SwiftUI
import HealthKit

struct WorkoutView: View {
    
    enum Sorting: String, Identifiable, CaseIterable, Equatable {
        case date, distance, duration
        var id: String { rawValue }
        var localized: LocalizedStringKey { LocalizedStringKey(rawValue.capitalized) }
    }
    
    var workoutActivity: WorkoutActivity
    
    @State private var sorting: Sorting = .date
    @State private var minDistance: Double = 0
    @State private var workouts: [HKWorkout] = []
    
    private let workoutManager = WorkoutManager.shared
    
    private var sortedWorkouts: [HKWorkout] {
        // Sort
        var sortedWorkouts = workouts.sorted {
            switch sorting {
            case .date : return $0.startDate > $1.startDate
            case .distance: return $0.totalDistance?.doubleValue(for: .meter()) ?? 0 > $1.totalDistance?.doubleValue(for: .meter()) ?? 0
            case .duration: return $0.duration > $1.duration
            }
        }
        // Filter by activity
        sortedWorkouts = sortedWorkouts.filter { $0.workoutActivityType == workoutActivity.activity }
        
        // Filter by minDistance
        
        sortedWorkouts = sortedWorkouts.filter { $0.totalDistance?.doubleValue(for: .meter()) ?? 0 >= minDistance }
        
        // Remove non importable workouts (without distance)
        sortedWorkouts = sortedWorkouts.filter { $0.totalDistance != nil }
        return sortedWorkouts
    }
    
    var body: some View {
                    
            VStack {
                HStack(alignment: .center, spacing: 8) {
                    if minDistance == 0 {
                        Text("DisplayAll")
                    } else {
                        Text("HideLessThan \(minDistance.toString)")
                    }
                    Slider(value: $minDistance, in: 0...20000, onEditingChanged: { _ in
                    })
                }
                .padding(.horizontal, 45)
                Text("Results \(sortedWorkouts.count)").font(.footnote)
                List {
                    
                    ForEach(sortedWorkouts, id: \.self) { workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
            .onAppear {
                guard workoutManager.isAvailable else { return }
                Task {
                    do {
                        workouts = try await workoutManager.getWorkouts(for: workoutActivity.activity)
                    } catch {
                        print(error)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        ForEach(Sorting.allCases) { sort in
                            Button {
                                sorting = sort
                            } label: {
                                HStack {
                                    Text(sort.localized)
                                    Spacer()
                                    if sorting == sort {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.primary)
                                            .bold()
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutView(workoutActivity: .cycling)
    }
}
