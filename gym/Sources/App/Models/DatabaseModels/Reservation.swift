import Foundation
import Fluent
import Vapor

final class Reservation: Model, Content {

    static let schema = "reservations"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "timeslot_id")
    var timeslot: Timeslot

    init() { }

    init(
        userID: UUID,
        timeslotID: UUID
    ) {
        self.$user.id = userID
        self.$timeslot.id = timeslotID
    }
}
