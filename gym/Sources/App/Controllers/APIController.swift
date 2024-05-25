import Foundation
import Vapor

struct APIController: RouteCollection {

    func boot(routes: Vapor.RoutesBuilder) throws {
        let userController: UserController = .init()
        let accountController: AccountController = .init()
        let memberController: MemberController = .init()
        let employeeController: EmployeeController = .init()
        let gymController: GymController = .init()

        let gymAccount = routes.grouped("gym", "account")

        gymAccount.post("createAccount", use: accountController.addUser)
        gymAccount.get(":userId", use: accountController.getUser)
        gymAccount.post("login", use: accountController.login)

        let gymAdmin = routes.grouped("gym", "admin", "users")

        gymAdmin.get(use: userController.users)
        gymAdmin.post(use: userController.addUser)
        gymAdmin.get(":userId", use: userController.getUser)
        gymAdmin.put(use: userController.updateUser)
        gymAdmin.delete(":userId", use: userController.deleteUser)

        let gymMemberships = routes.grouped("gym", "memberships")
        gymMemberships.get(use: memberController.getMemberships)
        gymMemberships.get("types", use: memberController.getSubscriptionTypes)
        gymMemberships.post(use: memberController.subscribeToMembership)
        gymMemberships.get("subscriptions",":memberId", use: memberController.getSubscriptions)

        let gymEmployee = routes.grouped("gym", "employee")
        gymEmployee.get("members", use: employeeController.getMembers)
        gymEmployee.get("members", "subscriptions", use: employeeController.getSubscriptions)
        gymEmployee.post("members", "approveSubsctiption", ":subscriptionId", use: employeeController.approveSubscription)

        let gymLocation = routes.grouped("gym", "locations")
        gymLocation.get(use: gymController.getLocations)
        gymLocation.get(":id", use: gymController.getLocation)
        gymLocation.get(":id", ":date", use: gymController.getTimeslotLocation)

        let gymReservations = routes.grouped("gym", "reservations")

        gymReservations.get(":memberId", use: memberController.getReservations)
        gymReservations.post(use: memberController.makeReservation)
        gymReservations.delete(":reservationId", use: memberController.deleteReservation)
    }
}
