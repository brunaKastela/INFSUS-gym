import Foundation
import Vapor

struct SubscriptionDTO: Content {
    var userId: UUID?
    var membershipId: UUID?
    var subscriptionTypeId: UUID?
}

struct SubscriptionResponseDTO: Content {

    var subscriptionId: UUID?
    var member: UserSafeDTO
    var membership: Membership
    var subscriptionType: SubscriptionType
    var validFrom: Date
    var validUntil: Date
    var approved: Bool
}
