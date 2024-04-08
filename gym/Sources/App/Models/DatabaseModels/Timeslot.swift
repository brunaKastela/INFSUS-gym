import Foundation
import Fluent
import Vapor

final class Timeslot: Model, Content {

    static var schema = "timeslots"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "start_time")
    var startTime: Date

    @Field(key: "end_time")
    var endTime: Date

    @Siblings(through: Reservation.self, from: \.$timeslot, to: \.$user)
    var users: [User]

    @Siblings(through: TimeslotLocationCapacity.self, from: \.$timeslot, to: \.$location)
    var locations: [Location]

    init() {}

    init(
        startTime: Date,
        endTime: Date
    ) {
        self.startTime = startTime
        self.endTime = endTime
    }
}
