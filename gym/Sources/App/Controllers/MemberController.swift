import Foundation
import Vapor

struct MemberController {

    func getSubscriptions(req: Request) throws -> EventLoopFuture<[SubscriptionResponseDTO]> {
        guard let memberId = req.parameters.get("memberId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Subscription.query(on: req.db)
            .with(\.$member)
            .with(\.$member) { member in
                member.with(\.$userType)
            }
            .with(\.$membership)
            .with(\.$subscriptionType)
            .filter(\.$member.$id, .equal ,memberId)
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
                            userTypeId: subscription.member.$userType.id,
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

    func getMemberships(req: Request) throws -> EventLoopFuture<[Membership]> {
        Membership.query(on: req.db).all()
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
                    guard
                        let subscription = subscription,
                            let userId = user.id else {
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

                    return Subscription
                        .query(on: req.db)
                        .filter(\.$member.$id, .equal, userId)
                        .filter(\.$validFrom, .lessThanOrEqual, endDate)
                        .filter(\.$validUntil, .greaterThanOrEqual, startDate)
                        .filter(\.$approved, .equal, true)
                        .first()
                        .flatMap { existingSubscription in
                            if let _ = existingSubscription {
                                let errorReason = "There is already an approved subscription covering this date period"
                                return req.eventLoop.makeFailedFuture(Abort(.conflict, reason: errorReason))
                            } else {
                                let newSubscription = Subscription(
                                    memberId: user.id!,
                                    membershipId: membership.id!,
                                    validFrom: startDate,
                                    validUntil: endDate,
                                    subscriptionTypeId: subscription.id!
                                )

                                return newSubscription.save(on: req.db)
                                    .transform(to: .ok)
                            }
                        }
                }
            }
        }
    }

    func getReservations(req: Request) throws -> EventLoopFuture<[ReservationResponse]> {
        guard let memberId = req.parameters.get("memberId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Reservation.query(on: req.db)
            .with(\.$user)
            .with(\.$timeslotLocation) { timeslotLocation in
                timeslotLocation
                    .with(\.$timeslot)
                    .with(\.$location)
            }
            .filter(\.$user.$id, .equal, memberId)
            .all()
            .flatMapThrowing { reservations in
                let reservationResponses = try reservations.map { reservation in
                    guard let userId = reservation.user.id,
                          let reservationId = reservation.id else {
                        throw Abort(.internalServerError)
                    }

                    return ReservationResponse(
                        userId: userId,
                        reservationId: reservationId,
                        timeslot: TimeslotResponse(
                            id:  reservation.timeslotLocation.id,
                            location: reservation.timeslotLocation.location,
                            timeslot: reservation.timeslotLocation.timeslot,
                            currentCapacity: reservation.timeslotLocation.currentCapacity
                        )
                    )
                }
                return reservationResponses
            }
    }

    func makeReservation(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let reservationDTO = try req.content.decode(ReservationDTO.self)

        guard let userId: UUID = reservationDTO.userId,
              let timeslotLocationId: UUID = reservationDTO.timeslotLocationId else {
            throw Abort(.badRequest)
        }

        return TimeslotLocation.query(on: req.db)
            .filter(\TimeslotLocation.$id, .equal, timeslotLocationId)
            .with(\.$location)
            .with(\.$timeslot)
            .first()
            .flatMap { timeslotLocation -> EventLoopFuture<Void> in
                guard let timeslotLocation = timeslotLocation else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound))
                }

                guard timeslotLocation.currentCapacity < timeslotLocation.location.capacity else {
                    let errorReason = "Timeslot location is full"
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: errorReason))
                }

                return Subscription.query(on: req.db)
                    .filter(\.$member.$id, .equal, userId)
                    .filter(\.$validFrom, .lessThanOrEqual, timeslotLocation.timeslot.startTime)
                    .filter(\.$validUntil, .greaterThanOrEqual, timeslotLocation.timeslot.endTime)
                    .filter(\.$approved, .equal, true)
                    .first()
                    .flatMap { subscription -> EventLoopFuture<Void> in
                        guard subscription != nil else {
                            let errorReason = "User does not have a valid subscription for the timeslot"
                            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: errorReason))
                        }

                        let reservation = Reservation(
                            userID: userId,
                            timeslotLocationID: timeslotLocation.id!
                        )

                        return reservation.save(on: req.db).flatMap {
                            timeslotLocation.currentCapacity += 1
                            return timeslotLocation.save(on: req.db).transform(to: ())
                        }
                    }
            }
            .transform(to: .created)
    }

    func deleteReservation(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let reservationId = req.parameters.get("reservationId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Reservation.find(reservationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { reservation in
                let timeslotLocationId = reservation.$timeslotLocation.id

                return TimeslotLocation.find(timeslotLocationId, on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMap { timeslotLocation in
                        timeslotLocation.currentCapacity -= 1
                        return timeslotLocation.save(on: req.db)
                            .flatMap {
                                reservation.delete(on: req.db)
                                    .transform(to: .noContent)
                            }
                    }
            }
    }
}
