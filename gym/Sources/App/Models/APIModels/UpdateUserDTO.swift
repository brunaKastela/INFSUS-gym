import Foundation
import Vapor

struct UpdateUserDTO: Content {
    var id: UUID?
    var name: String?
    var surname: String?
    var email: String?
    var phoneNumber: String?
    var dateOfBirth: Date?
    var userTypeId: UUID?
    var password: String?
}
