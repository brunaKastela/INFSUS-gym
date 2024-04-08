import Foundation
import Fluent
import FluentPostgresDriver

struct CreateSubscriptionType: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscription_types")
            .id()
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscription_types").delete()
    }

}
