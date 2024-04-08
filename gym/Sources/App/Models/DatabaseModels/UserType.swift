import Foundation
import Fluent
import Vapor

final class UserType: Model, Content {

    static var schema = "user_types"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Children(for: \.$userType)
    var users: [User]

    init() {}

    init(
        title: String
    ) {
        self.title = title
    }
}
