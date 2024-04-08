import Foundation
import Fluent
import FluentPostgresDriver

final class CreateLocation: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("locations")
            .id()
            .field("address", .string, .required)
            .field("description", .string, .required)
            .field("capacity", .int, .required)
            .field("phone_number", .string, .required)
            .field("email", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("locations")
            .delete()
    }
}
