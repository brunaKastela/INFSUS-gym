import Foundation
import Fluent
import FluentPostgresDriver

struct CreateTimeslot: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslots")
            .id()
            .field("start_time", .datetime, .required)
            .field("end_time", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("timeslots").delete()
    }

}

