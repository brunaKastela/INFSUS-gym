import Foundation
import Vapor

struct SubscriptionDTO: Content {
    var userId: UUID?
    var membershipId: UUID?
    var subscriptionTypeId: UUID?
}
