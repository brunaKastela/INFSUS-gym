import Foundation
import Fluent
import Vapor
import Crypto

final class User: Model, Content, Authenticatable {

    static var schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String?

    @Field(key: "surname")
    var surname: String?

    @Field(key: "password_hash")
    var passwordHash: String?

    @Field(key: "email")
    var email: String?

    @Field(key: "phone_number")
    var phoneNumber: String?

    @Field(key: "date_of_birth")
    var dateOfBirth: Date?

    @Parent(key: "user_type_id")
    var userType: UserType

    @Children(for: \Subscription.$member)
    var subscriptions: [Subscription]

    enum InitError: Error {
        case passwordHashingFailed
    }

    init() {}

    init(
        name: String?,
        surname: String?,
        email: String?,
        phoneNumber: String?,
        userTypeId: UUID?,
        dateOfBirth: Date?,
        password: String?
    ) throws {
        self.name = name
        self.surname = surname
        self.email = email
        self.phoneNumber = phoneNumber
        self.$userType.id = userTypeId ?? UUID(uuidString: "71BEAC26-4426-4620-9F74-DA6DCA89D792")!
        self.dateOfBirth = dateOfBirth

        guard
            let password,
            let hashedPassword = try? Bcrypt.hash(password) else {
            throw InitError.passwordHashingFailed
        }

        self.passwordHash = hashedPassword
    }

    var isAdmin: Bool {
        userType.id == UUID(uuidString: "5A60DA33-BBCD-4F0F-B95B-D445F29D9EC7")!
    }

    var isEmployee: Bool {
        userType.id == UUID(uuidString: "26519AEA-35B9-49A3-8E56-FCBB370E617D")!
    }

    var isMember: Bool {
        userType.id == UUID(uuidString: "71BEAC26-4426-4620-9F74-DA6DCA89D792")!
    }
}
