import Foundation
import Fluent
import Vapor

final class User: Model, Content {

    static var schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "surname")
    var surname: String

    @Field(key: "email")
    var email: String

    @Field(key: "phone_number")
    var phoneNumber: String

    @Enum(key: "userType")
    var userType: UserType

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        surname: String, 
        email: String,
        phoneNumber: String,
        userType: UserType
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.phoneNumber = phoneNumber
        self.userType = userType
    }
}
