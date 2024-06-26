import Foundation
import Fluent
import Vapor

final class SubscriptionType: Model, Content {

    static var schema = "subscription_types"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Children(for: \.$subscriptionType)
    var subscriptions: [Subscription]

    init() {}

    init(
        id: UUID? = nil,
        title: String
    ) {
        self.id = id
        self.title = title
    }
}
