import Foundation
import SwiftData

extension ModelContainer {
    
    @MainActor
    static let shared: ModelContainer = {
        //        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        //            try? FileManager.default.removeItem(at: url)
        //            print("🧹 Local SwiftData store purged to force CloudKit zone recreation")
        //        }
        
        let schema = Schema([Trail.self])
        
        /// ⚠️ At least ONE launch on real device (real iPhone or Mac) in DEBUG before Prod to push Schemas changes -> then Deploy Schema Changes to Production on CloudKit console before Production!
        /// TO DO THAT set false BELOW ⬇️
#if (targetEnvironment(simulator) || DEBUG) && false
        // DEBUG = isStoredInMemoryOnly: true, cloudKitDatabase: .none with MOCK DATA
        return ModelContainer.getSimulatorSharedContainer(schema: schema)
#else
        let config: ModelConfiguration
        // PRODUCTION = isStoredInMemoryOnly: false, cloudKitDatabase: .automatic = .private("iCloud.fr.matvdg.patfiDB")
        // If iCloud disabled OR if simulator - no iCloud (only on REAL devices)
        // So in that case: isStoredInMemoryOnly: false, cloudKitDatabase: .automatic = .none
        config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            let container =  try ModelContainer(for: schema, configurations: [config])
            print("ℹ️ CloudKit container:", container.configurations.first!.cloudKitContainerIdentifier ?? "❌ none")
            return container
        } catch {
            fatalError("Failed to load SwiftData ModelContainer: \(error)")
        }
#endif
    }()
    
    @MainActor
    static func getSimulatorSharedContainer(schema: Schema) -> ModelContainer {
        
        /// Quick access to mock/empty data for DEBUG ONLY
        let mockDataEnabled = true
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        if mockDataEnabled {
            
            
            do {
                try container.mainContext.save()
            }
            catch {
                print(error)
            }
        }
        return container
    }
}
