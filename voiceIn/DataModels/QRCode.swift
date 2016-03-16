import Foundation

class QRCode: NSObject {
    var company: String!
    var name: String!
    var phoneNumber: String!
    var qrCodeUuid: String!
    
    init(company: String, name: String, phoneNumber: String, qrCodeUuid: String) {
        self.company = company
        self.name = name
        self.phoneNumber = phoneNumber
        self.qrCodeUuid = qrCodeUuid
    }
}
