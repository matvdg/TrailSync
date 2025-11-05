import UIKit

class Feedback {
    
    class func selected() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    class func success() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    class func failed() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
}
