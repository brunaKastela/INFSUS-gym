import Foundation
import Fluent
import FluentPostgresDriver

final class CreateMembership: Migration {

    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("memberships")
            .id()
            .field("title", .string)
            .field("description", .string)
            .field("weeklyPrice", .float)
            .field("monthlyPrice", .float)
            .field("yearlyPrice", .float)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("memberships")
            .delete()
    }

}
