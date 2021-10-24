import Foundation
import Firebase

struct User {
    let email: String
    let name: String
    let createAt: Timestamp
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as! String
        self.createAt = dic["createdAt"] as! Timestamp
        self.name = dic["name"] as! String
    }
}
