import Foundation
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var name: String?
    var surname: String?
    var email: String?
    var phoneNumber: String?
    var dateOfBirth: Date?
    var userTypeId: UUID?
    var password: String?
}

struct UserSafeDTO: Content {

    var id: UUID?
    var name: String?
    var surname: String?
    var email: String?
    var phoneNumber: String?
    var dateOfBirth: Date?
    var userTypeId: UUID?
    var userTypeName: String?
    var password: String?
}

struct CreateUserRequest: Content {
    var name: String
    var surname: String
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date
    var password: String
    var userTypeId: UUID
}
