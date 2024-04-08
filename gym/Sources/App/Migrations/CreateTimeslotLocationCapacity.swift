import Foundation
import Fluent
import FluentPostgresDriver

struct CreateTimeslotLocationCapacity: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslot_location_capacity")
            .id()
            .field("timeslot_id", .uuid, .required, .references("timeslots", "id", onDelete: .cascade))
            .field("location_id", .uuid, .required, .references("locations", "id", onDelete: .cascade))
            .field("current_capacity", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslot_location_capacity").delete()
    }

}
