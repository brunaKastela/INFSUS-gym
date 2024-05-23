import Foundation
import Fluent
import Vapor

struct CreateUser: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("surname", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("phone_number", .string, .required)
            .field("date_of_birth", .datetime, .required)
            .field("user_type_id", .uuid, .required, .references("user_types", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .delete()
    }

}

