import Foundation
import Vapor

struct TimeslotResponse: Content {
    var id: UUID?
    let location: Location
    let timeslot: Timeslot
    let currentCapacity: Int
}
