import Foundation
import HealthKit
import SwiftUI
import CoreLocation

class WorkoutManager {
    
    @MainActor static let shared = WorkoutManager()
    
    private let store = HKHealthStore()
    private let workoutType = HKObjectType.workoutType()
    private let workoutRouteType = HKSeriesType.workoutRoute()
    private var typesToRead: Set<HKObjectType> { [workoutType, workoutRouteType] }
    
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable()}
    
    func getWorkouts(for activityType: HKWorkoutActivityType) async throws -> [HKWorkout] {
        
        // Check if workout type is supported
        guard isAvailable else {
            // Handle HealthKit not available on the device
            print("HealthKit not available on the device")
            return []
        }
        
        // Request permissions
        try await store.requestAuthorization(toShare: [], read: typesToRead)
        
        return try await executeWorkoutsSampleQuery(for: activityType)
    }
    
    private func executeWorkoutsSampleQuery(for activityType: HKWorkoutActivityType) async throws -> [HKWorkout] {
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForWorkouts(with: activityType)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let workouts = results as? [HKWorkout] {
                    continuation.resume(returning: workouts)
                } else {
                    continuation.resume(returning: [])
                }
            }
            store.execute(query)
        }
    }
    
    
    func getLocations(for workout: HKWorkout) async throws -> [CLLocation] {
        if let route = try await executeWorkoutQuery(workout: workout) {
            return try await executeWorkoutRouteQuery(route: route)
        } else {
            return []
        }
    }
    
    
    private func executeWorkoutQuery(workout: HKWorkout) async throws -> HKWorkoutRoute? {
        return try await withCheckedThrowingContinuation { continuation in
            
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKSampleQuery(sampleType: workoutRouteType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let route = results?.first as? HKWorkoutRoute {
                    continuation.resume(returning: route)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }
    
    actor LocationCollector {
        private(set) var all = [CLLocation]()
        func add(_ locs: [CLLocation]) {
            all.append(contentsOf: locs)
        }
    }

    private func executeWorkoutRouteQuery(route: HKWorkoutRoute) async throws -> [CLLocation] {
        return try await withCheckedThrowingContinuation { continuation in
            let collector = LocationCollector()

            let query = HKWorkoutRouteQuery(route: route) { _, locations, done, error in
                Task {
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    if let locs = locations {
                        await collector.add(locs)
                    }

                    if done {
                        continuation.resume(returning: await collector.all)
                    }
                }
            }

            store.execute(query)
        }
    }
}
