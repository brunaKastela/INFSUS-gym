import Foundation
import Fluent
import Vapor

struct CreateUser: Migration {

    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string)
            .field("surname", .string)
            .field("email", .string)
            .field("phone_number", .string)
            .field("user_type", .string)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema("users")
            .delete()
    }

}
