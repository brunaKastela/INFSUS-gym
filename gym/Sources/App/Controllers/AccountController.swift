import Foundation
import Vapor

struct AccountController {

    func createAccount(req: Request) throws -> EventLoopFuture<UserSafeDTO> {
        let member = try req.content.decode(UserDTO.self)

        guard let password = member.password, !password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }

        let user = try User(
            name: member.name,
            surname: member.surname,
            email: member.email,
            phoneNumber: member.phoneNumber,
            userTypeId: member.userTypeId,
            dateOfBirth: member.dateOfBirth,
            password: password
        )

        return user.save(on: req.db).flatMapThrowing {
            let userSafeDTO = UserSafeDTO(
                id: user.id,
                name: user.name,
                surname: user.surname,
                email: user.email,
                phoneNumber: user.phoneNumber,
                dateOfBirth: user.dateOfBirth,
                userTypeId: user.$userType.id,
                userTypeName: user.userType.title
            )
            return userSafeDTO
        }
    }

    func addUser(req: Request) throws -> EventLoopFuture<UserSafeDTO> {
        let userRequest = try req.content.decode(CreateUserRequest.self)

        try ValidationHelper().validateEmailFormat(userRequest.email)
        try ValidationHelper().checkMinimumAge(userRequest.dateOfBirth)

        return ValidationHelper().checkEmailUniqueness(userRequest.email, req: req).flatMap {
            do {
                let user = try User(
                    name: userRequest.name,
                    surname: userRequest.surname,
                    email: userRequest.email,
                    phoneNumber: userRequest.phoneNumber,
                    userTypeId: userRequest.userTypeId,
                    dateOfBirth: userRequest.dateOfBirth,
                    password: userRequest.password
                )

                return user.save(on: req.db)
                    .flatMap {
                        user.$userType.get(on: req.db).map { userType in
                            return UserSafeDTO(
                                id: user.id,
                                name: user.name,
                                surname: user.surname,
                                email: user.email,
                                phoneNumber: user.phoneNumber,
                                dateOfBirth: user.dateOfBirth,
                                userTypeId: userType.id,
                                userTypeName: userType.title
                            )
                        }
                    }
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }

    func getUser(req: Request) throws -> EventLoopFuture<UserSafeDTO> {
        guard let userId = req.parameters.get("userId"), let uuid = UUID(uuidString: userId) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        return User.query(on: req.db)
            .filter(\User.$id, .equal, uuid)
            .with(\.$userType)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { user in
                let userDTO = UserSafeDTO(
                    id: user.id!,
                    name: user.name,
                    surname: user.surname,
                    email: user.email,
                    phoneNumber: user.phoneNumber,
                    dateOfBirth: user.dateOfBirth,
                    userTypeId: user.$userType.id,
                    userTypeName: user.userType.title
                )
                return userDTO
            }
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
