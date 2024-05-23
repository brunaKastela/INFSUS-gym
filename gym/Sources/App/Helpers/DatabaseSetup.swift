import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

final class DatabaseSetup {

    var database: Database?

    var locations: [Location] = []
    var memberships: [Membership] = []
    var userTypes: [UserType] = []
    var subscriptionTypes: [SubscriptionType] = []

    func initializeObjects(using database: Database) {
        fillLocations()
        fillMemberships()
        fillUserTypes()
        fillSubscriptionTypes()
        fillTimeslotLocations(using: database)
    }

    func deleteObjects(using database: Database) {
        deleteAllLocations(using: database)
        deleteAllMemberships(using: database)
        deleteAllUserTypes(using: database)
        deleteAllSubscriptionTypes(using: database)
        deleteAllTimeSlots(using: database)
        deleteAllTimeslotLocations(using: database)
        deleteAllUsers(using: database)
        deleteAllReservations(using: database)
    }

    func setUpDatabase(using database: Database) {
        deleteObjects(using: database)
        initializeObjects(using: database)

        createLocations(using: database)
        createMemberships(using: database)
        createUserTypes(using: database)
        createSubscriptionTypes(using: database)
        setUpTimeSlots(using: database)
        fillTimeslotLocations(using: database)
        createRandomUsers(count: 15, using: database)
    }
}

// MARK: - Saving objects
extension DatabaseSetup {

    func createLocations(using database: Database) {
        for location in locations {
            location.create(on: database)
                 .whenComplete { _ in }
        }
    }

    func createMemberships(using database: Database) {
        for membership in memberships {
            membership.create(on: database)
                .whenComplete { _ in }
        }
    }

    func createUserTypes(using database: Database) {
        for userType in userTypes {
            userType.create(on: database)
                .whenComplete { _ in }
        }
    }

    func createSubscriptionTypes(using database: Database) {
        for subscriptionType in subscriptionTypes {
            subscriptionType.create(on: database)
                .whenComplete { _ in }
        }
    }

    func setUpTimeSlots(using database: Database) {
        let calendar = Calendar.current
        let currentDate = Date()

        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

        var startDateComponents = DateComponents()
        startDateComponents.year = currentComponents.year
        startDateComponents.month = currentComponents.month
        startDateComponents.day = currentComponents.day
        startDateComponents.hour = 11
        startDateComponents.minute = 0

        if let currentHour = calendar.dateComponents([.hour], from: currentDate).hour, currentHour >= 11 {
            startDateComponents.day! += 1
        }

        var startDate = calendar.date(from: startDateComponents)!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!

        var dateComponents = DateComponents()
        dateComponents.hour = 1

        while startDate < endDate {
            if !calendar.isDateInWeekend(startDate) {
                let endTime = calendar.date(byAdding: .hour, value: 1, to: startDate)!
                let timeSlot = Timeslot(startTime: startDate, endTime: endTime)

                timeSlot.create(on: database)
                    .whenComplete { _ in }
            }
            startDate = calendar.date(byAdding: dateComponents, to: startDate)!
        }
    }

    func fillTimeslotLocations(using database: Database) {
        let timeslotIds: EventLoopFuture<[UUID]> = getTimeslotIDs(on: database)
        let locationIds: EventLoopFuture<[UUID]> = getLocationIDs(on: database)

        timeslotIds.and(locationIds).whenSuccess { timeslotIDs, locationIDs in
            for timeslotId in timeslotIDs {
                for locationId in locationIDs {
                    let timeslotLocation = TimeslotLocation(
                        timeslotId: timeslotId,
                        locationId: locationId)
                    timeslotLocation.create(on: database).whenComplete { _ in }
                }
            }
        }
    }

    func createRandomUsers(count: Int, using database: Database) {
        let userTypeIds: EventLoopFuture<[UUID]> = getUserTypesIDs(on: database)

        userTypeIds.whenSuccess { userTypeIds in
            var userCreationFutures: [EventLoopFuture<Void>] = []
            let sampleNames = ["Mia", "Lea", "Dea", "Luka", "Ivan", "Lovre", "Maja", "Sara", "Milan", "Tina", "Lara"]
            let sampleSurnames = ["Lovric", "Saric", "Johnson", "Vekic", "Modric", "Mandzukic", "Olic", "Rakitic", "Perisic", "Vida", "Brozovic"]
            let samplePhoneNumbers = ["0996571382", "0996543382", "0996578393","0996571382","0996571382","0996571382","0996571382","0996571382","0996571382","0996571382","0996571382"]

            do {
                for i in 0..<count {
                    let userTypeId = userTypeIds[i % 2 + 1]

                    let user = try User(
                        name: sampleNames.randomElement() ?? "Unknown",
                        surname: sampleSurnames.randomElement() ?? "Unknown",
                        email: "mojmail@gmail.com",
                        phoneNumber: samplePhoneNumbers.randomElement() ?? "Unknown",
                        userTypeId: userTypeId,
                        dateOfBirth: Date(),
                        password: "12345678"
                    )
                    let userCreationFuture = user.create(on: database)
                    userCreationFutures.append(userCreationFuture)
                }
                let user = try User(
                    name: "Bossman",
                    surname: "Bosic",
                    email: "mojmail@gmail.com",
                    phoneNumber: samplePhoneNumbers.randomElement() ?? "Unknown",
                    userTypeId: userTypeIds[0],
                    dateOfBirth: Date(),
                    password: "12345678"
                )
                let userCreationFuture = user.create(on: database)
                userCreationFutures.append(userCreationFuture)
                self.createRandomReservations(using: database)
                self.createRandomSubscriptions(using: database)
            } catch {
                print("Error creating user: \(error)")
            }
        }
    }

    func createRandomReservations(using database: Database) {
        let userCount = User.query(on: database).count()

        userCount.whenSuccess { count in
            if count > 0 {
                let timeslotLocationIds = TimeslotLocation.query(on: database).all()
                let users = User.query(on: database).all()

                let _ = users.and(timeslotLocationIds).flatMap { users, timeslotLocations in
                    var reservationCreationFutures: [EventLoopFuture<Void>] = []

                    for user in users {
                        if let timeslotLocation = timeslotLocations.randomElement() {
                            let reservation = Reservation(userID: try! user.requireID(), timeslotLocationID: try! timeslotLocation.requireID())
                            reservationCreationFutures.append(reservation.create(on: database))
                        }
                    }

                    return EventLoopFuture.whenAllComplete(reservationCreationFutures, on: database.eventLoop)
                }
            } else {
                print("No users found in the database.")
            }
        }
    }

    func createRandomSubscriptions(using database: Database) {
        let users = User.query(on: database).all()
        let memberships = Membership.query(on: database).all()
        let subscriptionTypes = SubscriptionType.query(on: database).all()

        users.whenSuccess { users in
            memberships.whenSuccess { memberships in
                subscriptionTypes.whenSuccess { types in
                    for user in users {
                        let membership = memberships.randomElement()
                        let subscriptionType = types.randomElement()

                        var validUntil = Date()
                        if let subscriptionTitle = subscriptionType?.title {
                            switch subscriptionTitle {
                            case "weekly":
                                validUntil = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
                            case "monthly":
                                validUntil = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
                            case "yearly":
                                validUntil = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
                            default:
                                validUntil = Date()
                            }
                        }

                        guard let userId = user.id,
                              let memberId = membership?.id,
                              let subscriptionType = subscriptionType?.id else { return }
                        let subscription = Subscription(
                            memberId: userId,
                            membershipId: memberId,
                            validFrom: Date(),
                            validUntil: validUntil,
                            subscriptionTypeId: subscriptionType)
                        subscription.create(on: database).whenComplete { _ in }
                    }
                }
            }
        }
    }

}

// MARK: - Creating objects
extension DatabaseSetup {

    func fillLocations() {
        let sampleAddresses = ["Ilica 10", "Odranska 8", "Heinzlova 47"]
        let sampleDescriptions = ["Beautiful gym near the park", "Cozy in the downtown area", "Modern gym space"]
        let sampleCapacities = [10, 25, 50]
        let samplePhoneNumbers = ["0996571382", "0996543382", "0996578393"]
        let sampleEmails = [
            "infoIlicaGym@gmail.com",
            "infoOdranskaGym@gmail.com",
            "infoHeinzlovaGym@gmail.com"
        ]

        for i in 0..<sampleAddresses.count {
            let location = Location(
                address: sampleAddresses[i],
                description: sampleDescriptions[i],
                capacity: sampleCapacities[i],
                phoneNumber: samplePhoneNumbers[i],
                email: sampleEmails[i],
                opening: 11,
                closing: 19
            )
            locations.append(location)
        }
    }


    func fillMemberships() {
        memberships = [
            Membership(
                title: "Premium",
                description: "Full access to all gym facilities",
                weeklyPrice: 20.0,
                monthlyPrice: 70.0,
                yearlyPrice: 700.0),
            Membership(
                title: "Standard",
                description: "Basic access to gym facilities",
                weeklyPrice: 15.0,
                monthlyPrice: 50.0,
                yearlyPrice: 500.0),
            Membership(
                title: "Student",
                description: "Discounted access for students",
                weeklyPrice: 10.0,
                monthlyPrice: 30.0,
                yearlyPrice: 300.0)
        ]
    }

    func fillSubscriptionTypes() {
        subscriptionTypes = [
            SubscriptionType(title: "weekly"),
            SubscriptionType(title: "monthly"),
            SubscriptionType(title: "yearly")
        ]
    }

    func fillUserTypes() {
        let sampleTitles = ["admin", "employee", "member"]
        let sampleIds: [UUID] = [
            UUID(uuidString: "5A60DA33-BBCD-4F0F-B95B-D445F29D9EC7")!,
            UUID(uuidString: "26519AEA-35B9-49A3-8E56-FCBB370E617D")!,
            UUID(uuidString: "71BEAC26-4426-4620-9F74-DA6DCA89D792")!
        ]
        for (i, title) in sampleTitles.enumerated() {
            let userType = UserType(
                id: sampleIds[i],
                title: title)
            userTypes.append(userType)
        }
    }

    func getTimeslotIDs(on database: Database) -> EventLoopFuture<[UUID]> {
        Timeslot.query(on: database)
            .all()
            .map { timeslots in
                timeslots.map { $0.id! }
            }
    }

    func getLocationIDs(on database: Database) -> EventLoopFuture<[UUID]> {
        Location.query(on: database)
            .all()
            .map { locations in
                locations.map { $0.id! }
            }
    }

    func getUserTypesIDs(on database: Database) -> EventLoopFuture<[UUID]> {
        UserType.query(on: database)
            .all()
            .map { type in
                type.map { $0.id! }
            }
    }
}

// MARK: - Reset methods
extension DatabaseSetup {

    func deleteAllLocations(using database: Database) {
        Location.query(on: database).delete()
            .whenComplete { _ in}
    }

    func deleteAllMemberships(using database: Database) {
        Membership.query(on: database).delete()
            .whenComplete { _ in }
    }

    func deleteAllUserTypes(using database: Database) {
        UserType.query(on: database).delete()
            .whenComplete { _ in }
    }

    func deleteAllSubscriptionTypes(using database: Database) {
        SubscriptionType.query(on: database).delete()
            .whenComplete { _ in }
    }

    func deleteAllTimeSlots(using database: Database) {
        Timeslot.query(on: database).delete()
            .whenComplete { _ in }
    }

    func deleteAllTimeslotLocations(using database: Database) {
        TimeslotLocation.query(on: database)
            .delete()
            .whenComplete { _ in }
    }

    func deleteAllUsers(using database: Database) {
        User.query(on: database)
            .delete()
            .whenComplete { _ in }
    }

    func deleteAllReservations(using database: Database) {
        Reservation.query(on: database)
            .delete()
            .whenComplete { _ in }
    }

    func deleteAllSubscriptions(using database: Database) {
        Subscription.query(on: database)
            .delete()
            .whenComplete { _ in }
    }

}
