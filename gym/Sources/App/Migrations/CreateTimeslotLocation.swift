import Foundation
import Fluent
import FluentPostgresDriver

struct CreateTimeslotLocation: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslot_location")
            .id()
            .field("timeslot_id", .uuid, .required)
            .field("location_id", .uuid, .required)
            .field("current_capacity", .int, .required)
            .foreignKey("timeslot_id", references: "timeslots", "id", onDelete: .cascade)
            .foreignKey("location_id", references: "locations", "id", onDelete: .cascade)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslot_location").delete()
    }
}

