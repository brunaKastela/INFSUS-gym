import Foundation
import Fluent
import FluentPostgresDriver

struct CreateUserType: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_types")
            .id()
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_types").delete()
    }

}
