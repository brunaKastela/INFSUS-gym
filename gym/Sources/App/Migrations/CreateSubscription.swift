import Foundation
import Fluent
import FluentPostgresDriver

final class CreateSubscription: Migration {

    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("subscriptions")
            .id()
            .field("member_id", .uuid, .references("members", "id"))
            .field("membership_id", .uuid, .references("memberships", "id"))
            .field("valid_from", .date)
            .field("valid_until", .date)
            .field("subscription_type", .string)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("subscriptions")
            .delete()
    }

}
