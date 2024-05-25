import Foundation
import Vapor

struct ReservationResponse: Content {
    
    let userId: UUID?
    let reservationId: UUID?
    let timeslot: TimeslotResponse?
}

struct TimeslotResponse: Content {
    var id: UUID?
    let location: Location
    let timeslot: Timeslot
    let currentCapacity: Int
}
