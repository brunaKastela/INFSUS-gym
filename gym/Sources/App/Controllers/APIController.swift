import Foundation
import Vapor

struct APIController: RouteCollection {

    func boot(routes: Vapor.RoutesBuilder) throws {
        let gymAdmin = routes.grouped("gym", "admin")

        gymAdmin.get("members", use: members)
        gymAdmin.post("members", use: addMember)
        gymAdmin.get("members", ":memberId", use: member)
        gymAdmin.put("members", use: updateMember)
        gymAdmin.delete("members", ":memberId", use: deleteMember)
    }
}

extension APIController {

    func members(req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }

    func addMember(req: Request) throws -> EventLoopFuture<User> {
        let member = try req.content.decode(User.self)

        return member.create(on: req.db).map { member }
    }

    func member(req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateMember(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let member = try req.content.decode(User.self)

        return User
            .find(member.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                return $0.update(on: req.db).transform(to: .ok)
            }
    }

    func deleteMember(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .find(req.parameters.get("memberId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }.transform(to: .ok)
    }
}
