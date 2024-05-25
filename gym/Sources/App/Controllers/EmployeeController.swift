import Foundation
import Vapor

struct EmployeeController {

    func getMembers(req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db)
            .filter(\User.$userType.$id, .equal, UUID(uuidString: UserTypes.member.rawValue)!)
            .all()
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
