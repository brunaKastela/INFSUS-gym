import Foundation
import Fluent
import Vapor

final class Subscription: Model, Content {

    static var schema = "subscriptions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "member_id")
    var member: User

    @Parent(key: "membership_id")
    var membership: Membership

    @Field(key: "valid_from")
    var validFrom: Date

    @Field(key: "valid_until")
    var validUntil: Date

    @Parent(key: "subscription_type_id")
    var subscriptionType: SubscriptionType

    init() {}

    init(
        memberId: UUID,
        membershipId: UUID,
        validFrom: Date,
        validUntil: Date,
        subscriptionType: SubscriptionType
    ) {
        self.$member.id = memberId
        self.$membership.id = membershipId
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.subscriptionType = subscriptionType
    }
}
