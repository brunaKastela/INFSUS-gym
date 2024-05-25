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

        gymAccount.post("createAccount", use: accountController.createAccount)
        gymAccount.get(":memberId", use: accountController.account)

        let gymAdmin = routes.grouped("gym", "admin", "users")

        gymAdmin.get(use: userController.users)
        gymAdmin.post(use: userController.addUser)
        gymAdmin.get(":userId", use: userController.getUser)
        gymAdmin.put(use: userController.updateUser)
        gymAdmin.delete(":userId", use: userController.deleteUser)

        let gymMember = routes.grouped("gym", "member")
        let gymMemberships = routes.grouped("gym", "member", "memberships")
        gymMemberships.get(use: memberController.getMemberships)
        gymMemberships.get("types", use: memberController.getSubscriptionTypes)
        gymMemberships.post(use: memberController.subscribeToMembership)
        gymMember.get("subscriptions",":memberId", use: memberController.getSubscriptions)

        let gymEmployee = routes.grouped("gym", "employee")
        gymEmployee.get("members", use: employeeController.getMembers)
        gymEmployee.post("members", "approveSubsctiption", ":subscriptionId", use: employeeController.approveSubscription)

        let gymLocation = routes.grouped("gym", "locations")
        gymLocation.get(use: gymController.getLocations)
        gymLocation.get(":id", use: gymController.getLocation)
        gymLocation.get(":id", ":date", use: gymController.getTimeslotLocation)
        gymLocation.get("reservations", ":userId", use: memberController.getReservations)
        gymLocation.post("reservation", use: memberController.makeReservation)
        gymLocation.delete("reservation", ":reservationId", use: memberController.deleteReservation)
    }
}
