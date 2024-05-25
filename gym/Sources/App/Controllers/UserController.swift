import Foundation
import Vapor

struct UserController {

    func users(req: Request) throws -> EventLoopFuture<[UserSafeDTO]> {
        User.query(on: req.db)
            .with(\.$userType)
            .all()
            .map { users in
                users.map { user in
                    UserSafeDTO(
                        id: user.id!,
                        name: user.name,
                        surname: user.surname,
                        email: user.email,
                        phoneNumber: user.phoneNumber,
                        dateOfBirth: user.dateOfBirth,
                        userTypeId: user.$userType.id,
                        userTypeName: user.userType.title
                    )
                }
            }
    }

    func addUser(req: Request) throws -> EventLoopFuture<UserSafeDTO> {
        let userRequest = try req.content.decode(CreateUserRequest.self)

        try validateEmailFormat(userRequest.email)
        try checkMinimumAge(userRequest.dateOfBirth)

        return checkEmailUniqueness(userRequest.email, req: req).flatMap {
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

    func updateUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let updateUserDTO = try req.content.decode(UserDTO.self)

        return User.find(updateUserDTO.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { existingUser in
                var validationFutures: [EventLoopFuture<Void>] = []

                if let email = updateUserDTO.email {
                    do {
                        try validateEmailFormat(email)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                    validationFutures.append(checkEmailUniqueness(email, currentUserId: existingUser.id!, req: req))
                }

                if let dateOfBirth = updateUserDTO.dateOfBirth {
                    do {
                        try checkMinimumAge(dateOfBirth)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                }

                return EventLoopFuture.andAllSucceed(validationFutures, on: req.eventLoop).flatMap {
                    if let name = updateUserDTO.name {
                        existingUser.name = name
                    }
                    if let surname = updateUserDTO.surname {
                        existingUser.surname = surname
                    }
                    if let email = updateUserDTO.email {
                        existingUser.email = email
                    }
                    if let phoneNumber = updateUserDTO.phoneNumber {
                        existingUser.phoneNumber = phoneNumber
                    }
                    if let dateOfBirth = updateUserDTO.dateOfBirth {
                        existingUser.dateOfBirth = dateOfBirth
                    }
                    if let userTypeId = updateUserDTO.userTypeId {
                        existingUser.$userType.id = userTypeId
                    }
                    if let password = updateUserDTO.password {
                        do {
                            existingUser.passwordHash = try Bcrypt.hash(password)
                        } catch {
                            return req.eventLoop.makeFailedFuture(User.InitError.passwordHashingFailed)
                        }
                    }

                    return existingUser.update(on: req.db).transform(to: .ok)
                }
            }
    }

    func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }.transform(to: .ok)
    }
}


extension UserController {

    func validateEmailFormat(_ email: String) throws {
        guard email.contains("@") else {
            throw Abort(.badRequest, reason: "Invalid email format")
        }
    }

    func checkMinimumAge(_ dateOfBirth: Date, minimumAge: Int = 18) throws {
        let calendar = Calendar.current
        let now = Date()
        guard let age = calendar.dateComponents([.year], from: dateOfBirth, to: now).year, age >= minimumAge else {
            throw Abort(.badRequest, reason: "User must be at least \(minimumAge) years old")
        }
    }

    func checkEmailUniqueness(_ email: String, req: Request) -> EventLoopFuture<Void> {
        return User.query(on: req.db)
            .filter(\User.$email, .equal, email)
            .first()
            .flatMapThrowing { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "Email is already in use")
                }
            }
    }

    func checkEmailUniqueness(_ email: String, currentUserId: UUID, req: Request) -> EventLoopFuture<Void> {
        return User.query(on: req.db)
            .filter(\User.$email, .equal, email)
            .first()
            .flatMapThrowing { existingUser in
                if let existingUser = existingUser, existingUser.id != currentUserId {
                    throw Abort(.badRequest, reason: "Email is already in use")
                }
            }
    }
}
