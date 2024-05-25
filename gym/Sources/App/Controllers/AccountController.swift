import Foundation
import Vapor

struct AccountController {

    func createAccount(req: Request) throws -> EventLoopFuture<User> {
        let member = try req.content.decode(UserDTO.self)

        guard let password = member.password else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }

        let user = try? User(
            name: member.name,
            surname: member.surname,
            email: member.email,
            phoneNumber: member.phoneNumber,
            userTypeId: member.userTypeId,
            dateOfBirth: member.dateOfBirth,
            password: password
        )

        guard let user = user else { throw Abort(.badRequest, reason: "Internal error") }
        return user.create(on: req.db).map { user }
    }

    func account(req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
