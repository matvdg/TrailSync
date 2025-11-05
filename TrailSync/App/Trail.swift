import Foundation
import SwiftData

@Model
final class Trail {
    
    var timestamp: Date = Date()
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
 
