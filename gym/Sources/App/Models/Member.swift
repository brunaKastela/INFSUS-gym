import Fluent
import Vapor

final class Member: Model, Content {

    static let schema = "members"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "emergency_contact_number")
    var emergencyContactNumber: String

    @Field(key: "date_of_birth")
    var dateOfBirth: Date

    @Children(for: \.$member)
    var subscriptions: [Subscription]

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        emergencyContactNumber: String,
        dateOfBirth: Date
    ) {
        self.id = id
        self.$user.id = userId
        self.emergencyContactNumber = emergencyContactNumber
        self.dateOfBirth = dateOfBirth
    }
}
