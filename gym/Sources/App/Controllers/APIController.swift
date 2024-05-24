import Foundation
import Vapor

struct APIController: RouteCollection {

    func boot(routes: Vapor.RoutesBuilder) throws {
        let gymMember = routes.grouped("gym", "member")

        gymMember.post("createAccount", use: createAccount)
        gymMember.get("account", ":memberId", use: account)
        gymMember.get("subscriptions",":memberId", use: getSubscriptions)

        let gymAdmin = routes.grouped("gym", "admin")

        gymAdmin.get("members", use: members)
        gymAdmin.post("members", use: addMember)
        gymAdmin.get("members", ":memberId", use: member)
        gymAdmin.put("members", use: updateMember)
        gymAdmin.delete("members", ":memberId", use: deleteMember)

        let gymMemberships = routes.grouped("gym", "memberships")
        gymMemberships.get(use: getMemberships)
        gymMemberships.get("types", use: getSubscriptionTypes)
        gymMemberships.post(use: subscribeToMembership)
    }
}

extension APIController {

    func createAccount(req: Request) throws -> EventLoopFuture<User> {
        let member = try req.content.decode(UserDTO.self)

        guard let password = member.password else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }

        let user = try? User(
            name: member.name,
            surname: member.surname,
            email: member.email,
            phoneNumber: member.phoneNumber,
            userTypeId: member.userTypeId,
            dateOfBirth: member.dateOfBirth,
            password: password
        )

        guard let user = user else { throw Abort(.badRequest, reason: "Internal error") }
        return user.create(on: req.db).map { user }
    }

    func account(req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}

extension APIController {

    func getMemberships(req: Request) throws -> EventLoopFuture<[Membership]> {
        Membership.query(on: req.db).all()
    }

    func getSubscriptions(req: Request) throws -> EventLoopFuture<[Subscription]> {
        guard let memberId = req.parameters.get("memberId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Subscription.query(on: req.db)
            .filter(\Subscription.$member.$id, .equal, memberId)
            .all()
    }

    func getSubscriptionTypes(req: Request) throws -> EventLoopFuture<[SubscriptionType]> {
        SubscriptionType.query(on: req.db).all()
    }

    func subscribeToMembership(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let subscriptionDTO = try req.content.decode(SubscriptionDTO.self)

        return User.find(subscriptionDTO.userId, on: req.db).flatMap { user -> EventLoopFuture<HTTPStatus> in
            guard let user = user else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }

            return Membership.find(subscriptionDTO.membershipId, on: req.db).flatMap { membership -> EventLoopFuture<HTTPStatus> in
                guard let membership = membership else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound))
                }

                return SubscriptionType.find(subscriptionDTO.subscriptionTypeId, on: req.db).flatMap { subscription -> EventLoopFuture<HTTPStatus> in
                    guard let subscription = subscription else {
                        return req.eventLoop.makeFailedFuture(Abort(.notFound))
                    }

                    let startDate: Date = Date()
                    var endDate: Date?

                    if subscription.title == "weekly" {
                        endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)
                    } else if subscription.title == "monthly" {
                        endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)
                    } else if subscription.title == "yearly" {
                        endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)
                    } else {
                        return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid subscription type"))
                    }

                    guard let endDate = endDate else {
                        return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
                    }

                    let newSubscription = Subscription(
                        memberId: user.id!,
                        membershipId: membership.id!,
                        validFrom: startDate,
                        validUntil: endDate,
                        subscriptionTypeId: subscription.id!
                    )

                    // Save the new subscription and transform the result to an appropriate HTTPStatus
                    return newSubscription.save(on: req.db)
                        .transform(to: .ok)
                }
            }
        }
    }
}

extension APIController {

    func members(req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }

    func addMember(req: Request) throws -> EventLoopFuture<User> {
        let member = try req.content.decode(User.self)

        return member.create(on: req.db).map { member }
    }

    func member(req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateMember(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let updateUserDTO = try req.content.decode(UserDTO.self)

        return User.find(updateUserDTO.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { existingUser in
                if let name = updateUserDTO.name {
                    existingUser.name = name
                }
                if let surname = updateUserDTO.surname {
                    existingUser.surname = surname
                }
                if let email = updateUserDTO.email {
                    existingUser.email = email
                }
                if let phoneNumber = updateUserDTO.phoneNumber {
                    existingUser.phoneNumber = phoneNumber
                }
                if let dateOfBirth = updateUserDTO.dateOfBirth {
                    existingUser.dateOfBirth = dateOfBirth
                }
                if let userTypeId = updateUserDTO.userTypeId {
                    existingUser.$userType.id = userTypeId
                }

                return existingUser.update(on: req.db).transform(to: .ok)
            }
    }

    func deleteMember(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }.transform(to: .ok)
    }
}
