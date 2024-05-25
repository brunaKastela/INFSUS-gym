import Foundation
import Vapor

struct ReservationDTO: Content {

    var userId: UUID?
    var timeslotLocationId: UUID?
}
