import Foundation
import Fluent
import Vapor

final class Location: Model, Content {

    static var schema = "locations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "address")
    var address: String

    @Field(key: "description")
    var description: String

    @Field(key: "capacity")
    var capacity: Int

    @Field(key: "phone_number")
    var phoneNumber: String

    @Field(key: "email")
    var email: String

    @Siblings(through: TimeslotLocation.self, from: \.$location, to: \.$timeslot)
    var timeslots: [Timeslot]

    init () {}

    init(
        address: String,
        description: String,
        capacity: Int,
        phoneNumber: String,
        email: String
    ) {
        self.address = address
        self.description = description
        self.capacity = capacity
        self.phoneNumber = phoneNumber
        self.email = email
    }
}
