import Foundation
import Firebase

struct Feedback {
    
    let message:                    String!
    let rating:                     Double!
    var fromID: String!
    let ref:                        FIRDatabaseReference?
    
    // Initialize from arbitrary data
    init(message: String, rating: Double, fromID: String) {
        self.message                        = message
        self.rating                         = rating
        self.fromID                        = fromID
        self.ref                            = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        message                             = snapshot.value!["message"] as! String
        rating                              = snapshot.value!["rating"] as! Double
        fromID                              = snapshot.value!["fromID"] as! String
        ref                                 = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "message": message,
            "rating": rating,
            "fromID": fromID
        ]
    }
    
}