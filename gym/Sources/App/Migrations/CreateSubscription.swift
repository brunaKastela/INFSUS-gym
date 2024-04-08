import Foundation
import Fluent
import FluentPostgresDriver

struct CreateSubscription: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions")
            .id()
            .field("member_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("membership_id", .uuid, .required, .references("memberships", "id", onDelete: .cascade))
            .field("valid_from", .datetime, .required)
            .field("valid_until", .datetime, .required)
            .field("subscription_type_id", .uuid, .required, .references("subscription_types", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions")
            .delete()
    }

}
