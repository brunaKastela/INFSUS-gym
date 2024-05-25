import Foundation
import Vapor

struct ValidationHelper {

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
