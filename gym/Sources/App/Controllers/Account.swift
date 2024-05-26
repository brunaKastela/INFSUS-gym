import Foundation
import Vapor

struct Account {

    func getUsers(req: Request) throws -> EventLoopFuture<[UserSafeDTO]> {
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

    func updateUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let updateUserDTO = try req.content.decode(UserDTO.self)

        return User.find(updateUserDTO.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { existingUser in
                var validationFutures: [EventLoopFuture<Void>] = []

                if let email = updateUserDTO.email {
                    do {
                        try ValidationHelper().validateEmailFormat(email)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                    validationFutures.append(ValidationHelper().checkEmailUniqueness(email, currentUserId: existingUser.id!, req: req))
                }

                if let dateOfBirth = updateUserDTO.dateOfBirth {
                    do {
                        try ValidationHelper().checkMinimumAge(dateOfBirth)
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
