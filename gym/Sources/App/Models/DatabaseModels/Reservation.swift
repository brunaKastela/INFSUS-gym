import Foundation
import Fluent
import Vapor

final class Reservation: Model, Content {

    static let schema = "reservations"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "timeslot_location_id")
    var timeslotLocation: TimeslotLocation

    init() { }

    init(
        userID: UUID,
        timeslotLocationID: UUID
    ) {
        self.$user.id = userID
        self.$timeslotLocation.id = timeslotLocationID
    }
}
