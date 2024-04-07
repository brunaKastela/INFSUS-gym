import Foundation
import Fluent
import Vapor

final class Subscription: Model, Content {

    static var schema = "subscriptions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "member_id")
    var member: Member

    @Parent(key: "membership_id")
    var membership: Membership

    @Field(key: "valid_from")
    var validFrom: Date

    @Field(key: "valid_until")
    var validUntil: Date

    @Field(key: "subscription_type")
    var subscriptionType: SubscriptionType

    init() {}

    init(
        id: UUID? = nil,
        memberId: UUID,
        membershipId: UUID,
        validFrom: Date,
        validUntil: Date,
        subscriptionType: SubscriptionType
    ) {
        self.id = id
        self.$member.id = memberId
        self.$membership.id = membershipId
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.subscriptionType = subscriptionType
    }
}
