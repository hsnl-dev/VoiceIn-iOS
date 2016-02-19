import Foundation

class People {
    var name: String
    var type: String
    var image: String
    var phoneNumber: String
    
    init(name: String, type: String, location: String, phoneNumber: String, image: String) {
        self.name = name
        self.type = type
        self.phoneNumber = phoneNumber
        self.image = image
    }
}
