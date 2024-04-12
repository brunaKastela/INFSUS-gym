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

    @Field(key: "date_of_birth")
    var dateOfBirth: Date

    @Parent(key: "user_type_id")
    var userType: UserType

    @Children(for: \Subscription.$member)
    var subscriptions: [Subscription]

    init() {}

    init(
        name: String,
        surname: String, 
        email: String,
        phoneNumber: String,
        userTypeId: UUID,
        dateOfBirth: Date
    ) {
        self.name = name
        self.surname = surname
        self.email = email
        self.phoneNumber = phoneNumber
        self.$userType.id = userTypeId
        self.dateOfBirth = dateOfBirth
    }
}
