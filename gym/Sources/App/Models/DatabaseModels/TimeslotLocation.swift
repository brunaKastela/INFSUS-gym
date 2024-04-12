import Foundation
import Fluent
import Vapor

final class TimeslotLocation: Model, Content {

    static var schema = "timeslot_location"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "timeslot_id")
    var timeslot: Timeslot

    @Parent(key: "location_id")
    var location: Location

    @Field(key: "current_capacity")
    var currentCapacity: Int

    init () {}

    init(
        timeslotId: UUID,
        locationId: UUID
    ) {
        self.timeslot.id = timeslotId
        self.location.id = locationId
    }
}
