import Foundation
import Vapor

struct APIController: RouteCollection {

    func boot(routes: Vapor.RoutesBuilder) throws {
        let account: Account = .init()
        let member: Member = .init()
        let employee: Employee = .init()
        let gym: Gym = .init()

        let gymAccount = routes.grouped("gym", "account")

        gymAccount.post("createAccount", use: account.addUser)
        gymAccount.get(":userId", use: account.getUser)
        gymAccount.post("login", use: account.login)

        let gymAdmin = routes.grouped("gym", "admin", "users")

        gymAdmin.get(use: account.getUsers)
        gymAdmin.post(use: account.addUser)
        gymAdmin.get(":userId", use: account.getUser)
        gymAdmin.put(use: account.updateUser)
        gymAdmin.delete(":userId", use: account.deleteUser)

        let gymMemberships = routes.grouped("gym", "memberships")
        gymMemberships.get(use: member.getMemberships)
        gymMemberships.get("types", use: member.getSubscriptionTypes)
        gymMemberships.post(use: member.subscribeToMembership)
        gymMemberships.get("subscriptions",":memberId", use: member.getSubscriptions)

        let gymEmployee = routes.grouped("gym", "employee")
        gymEmployee.get("members", use: employee.getMembers)
        gymEmployee.get("members", "subscriptions", use: employee.getSubscriptions)
        gymEmployee.post("members", "approveSubsctiption", ":subscriptionId", use: employee.approveSubscription)

        let gymLocation = routes.grouped("gym", "locations")
        gymLocation.get(use: gym.getLocations)
        gymLocation.get(":id", use: gym.getLocation)
        gymLocation.get(":id", ":date", use: gym.getTimeslotLocation)

        let gymReservations = routes.grouped("gym", "reservations")
        gymReservations.get(":memberId", use: member.getReservations)
        gymReservations.post(use: member.makeReservation)
        gymReservations.delete(":reservationId", use: member.deleteReservation)
    }
}
