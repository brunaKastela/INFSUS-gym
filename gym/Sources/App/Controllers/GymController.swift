import Foundation
import Vapor

struct GymController {

    func getLocations(req: Request) throws -> EventLoopFuture<[Location]> {
        Location.query(on: req.db).all()
    }

    func getLocation(req: Request) throws -> EventLoopFuture<Location> {
        Location
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func getTimeslotLocation(req: Request) throws -> EventLoopFuture<[TimeslotResponse]> {
        guard let locationId = req.parameters.get("id", as: UUID.self),
              let dateString = req.parameters.get("date"),
              let date = ISO8601DateFormatter().date(from: dateString) else {
            throw Abort(.badRequest)
        }

        let calendar = Calendar.current
        let startOfDay: Date = calendar.startOfDay(for: date)

        return Location.find(locationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { location in
                let openingTime = calendar.date(bySettingHour: location.opening, minute: 0, second: 0, of: startOfDay)!
                let closingTime = calendar.date(bySettingHour: location.closing - 1, minute: 0, second: 0, of: startOfDay)!

                return TimeslotLocation.query(on: req.db)
                    .join(parent: \TimeslotLocation.$timeslot)
                    .filter(\TimeslotLocation.$location.$id, .equal, locationId)
                    .filter(Timeslot.self, \Timeslot.$startTime, .greaterThanOrEqual, openingTime)
                    .filter(Timeslot.self, \Timeslot.$startTime, .lessThanOrEqual, closingTime)
                    .all()
                    .flatMap { timeslotLocations in
                        return timeslotLocations.map { timeslotLocation in
                            timeslotLocation.$timeslot.get(on: req.db).map { timeslot in
                                return TimeslotResponse(
                                    id: timeslotLocation.id,
                                    location: location,
                                    timeslot: timeslot,
                                    currentCapacity: timeslotLocation.currentCapacity
                                )
                            }
                        }.flatten(on: req.eventLoop)
                    }
            }
    }
}
