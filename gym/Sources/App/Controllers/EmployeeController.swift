import Foundation
import Vapor

struct EmployeeController {

    func getMembers(req: Request) throws -> EventLoopFuture<[UserSafeDTO]> {
        User.query(on: req.db)
            .filter(\User.$userType.$id, .equal, UUID(uuidString: UserTypes.member.rawValue)!)
            .with(\.$userType)
            .all()
            .map { users in
                users.map { user in
                    UserSafeDTO(
                        id: user.id!,
                        name: user.name,
                        surname: user.surname,
                        email: user.email,
                        phoneNumber: user.phoneNumber,
                        dateOfBirth: user.dateOfBirth,
                        userTypeId: user.$userType.id,
                        userTypeName: user.userType.title
                    )
                }
            }
    }

    func getSubscriptions(req: Request) throws -> EventLoopFuture<[SubscriptionResponseDTO]> {
        return Subscription.query(on: req.db)
            .with(\.$member)
            .with(\.$member) { member in
                member.with(\.$userType)
            }
            .with(\.$membership)
            .with(\.$subscriptionType)
            .all()
            .flatMapThrowing { subscriptions in
                subscriptions.map { subscription in
                    SubscriptionResponseDTO(
                        subscriptionId: subscription.id,
                        member: UserSafeDTO(
                            id: subscription.member.id,
                            name: subscription.member.name,
                            surname: subscription.member.surname,
                            email: subscription.member.email,
                            phoneNumber: subscription.member.phoneNumber,
                            dateOfBirth: subscription.member.dateOfBirth,
                            userTypeId: subscription.member.userType.id,
                            userTypeName: subscription.member.userType.title
                        ),
                        membership: subscription.membership,
                        subscriptionType: subscription.subscriptionType,
                        validFrom: subscription.validFrom,
                        validUntil: subscription.validUntil,
                        approved: subscription.approved
                    )
                }
            }
    }

    func approveSubscription(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Subscription
            .find(req.parameters.get("subscriptionId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { subscription in
                subscription.approved = true
                return subscription.update(on: req.db).transform(to: .ok)
            }
    }
}
