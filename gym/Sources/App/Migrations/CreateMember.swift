import Foundation
import Fluent
import FluentPostgresDriver

struct CreateMember: Migration {

    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("members")
            .id()
            .field("user_id", .uuid, .references("users", "id"))
            .field("emergency_contact_number", .string)
            .field("date_of_birth", .date)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("members")
            .delete()
    }

}
