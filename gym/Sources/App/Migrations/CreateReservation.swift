import Foundation
import Fluent
import FluentPostgresDriver
import Vapor

struct CreateReservation: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("reservations")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("timeslot_location_id", .uuid, .required, .references("timeslot_location", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("reservations").delete()
    }

}
