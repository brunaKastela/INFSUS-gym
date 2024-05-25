import Foundation
import Vapor

struct MemberController {

    func getSubscriptions(req: Request) throws -> EventLoopFuture<[Subscription]> {
        guard let memberId = req.parameters.get("memberId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Subscription.query(on: req.db)
            .filter(\Subscription.$member.$id, .equal, memberId)
            .all()
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

                    return newSubscription.save(on: req.db)
                        .transform(to: .ok)
                }
            }
        }
    }

    func getReservations(req: Request) throws -> EventLoopFuture<[ReservationResponse]> {
        return Reservation.query(on: req.db)
            .with(\.$user)
            .with(\.$timeslotLocation) { timeslotLocation in
                timeslotLocation
                    .with(\.$timeslot)
                    .with(\.$location)
            }
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

        guard let userId: UUID = reservationDTO.userId else { throw Abort(.badRequest)}

        return TimeslotLocation.find(reservationDTO.timeslotLocationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { timeslotLocation in
                let reservation = Reservation(
                    userID: userId,
                    timeslotLocationID: timeslotLocation.id!
                )

                return reservation.save(on: req.db)
                    .flatMap {
                        timeslotLocation.currentCapacity += 1
                        return timeslotLocation.save(on: req.db)
                    }
                    .transform(to: .created)
            }
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
