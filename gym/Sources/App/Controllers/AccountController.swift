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

    func login(req: Request) throws -> EventLoopFuture<UserSafeDTO> {
        let loginDTO = try req.content.decode(LoginDTO.self)

        return User.query(on: req.db)
            .with(\.$userType)
            .filter(\User.$email, .equal, loginDTO.email)
            .first()
            .unwrap(or: Abort(.notFound, reason: "User not found"))
            .flatMapThrowing { user in
                guard let hashedPassword = user.passwordHash else {
                    throw Abort(.internalServerError, reason: "User password is not hashed")
                }
                do {
                    let isValidPassword = try Bcrypt.verify(loginDTO.password, created: hashedPassword)
                    guard isValidPassword else {
                        throw Abort(.unauthorized, reason: "Invalid password")
                    }
                    return UserSafeDTO(
                        id: user.id,
                        name: user.name,
                        surname: user.surname,
                        email: user.email,
                        phoneNumber: user.phoneNumber,
                        dateOfBirth: user.dateOfBirth,
                        userTypeId: user.$userType.id,
                        userTypeName: user.userType.title
                    )
                } catch {
                    throw Abort(.unauthorized, reason: "Invalid password")
                }
            }
    }
}
