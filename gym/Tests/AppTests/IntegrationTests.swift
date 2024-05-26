import XCTVapor
@testable import App
import FluentPostgresDriver

enum MyError: Error {
    case invalidDate
    case userInitializationFailed
}

final class IntegrationTests: XCTestCase {
    var app: Application!
    var userId: UUID!
    var membershipId: UUID!
    var subscriptionTypeId: UUID!

    override func setUpWithError() throws {
        app = Application(.testing)

        let databaseConfig = SQLPostgresConfiguration(
            hostname: "localhost",
            port: 5432,
            username: "postgres",
            password: "postgres",
            database: "gymdb",
            tls: .prefer(try .init(configuration: .clientDefault)))
        app.databases.use(.postgres(configuration: databaseConfig), as: .psql)

        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        userId = try createUser().wait()
        membershipId = UUID(uuidString: "AC55BCFF-87B5-425D-A3C0-61E608371BBA")
        subscriptionTypeId = UUID(uuidString: "290CA7F4-F57E-43AA-A1FA-5698A54E36A1")
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testSubscribeUnknownUserToMembership() async throws {
        try await configure(app)

        let subscriptionDTO = SubscriptionDTO(userId: UUID(), membershipId: UUID(), subscriptionTypeId: UUID())
        try app.test(.POST, "/gym/memberships", beforeRequest: { req in
            try req.content.encode(subscriptionDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func createUser() throws -> EventLoopFuture<UUID> {
        let date = Date()
        let calendar = Calendar.current
        guard let date20YearsAgo = calendar.date(byAdding: .year, value: -20, to: date) else {
            throw MyError.invalidDate
        }

        do {
            let user = try User(
                name: "Iva",
                surname: "Dukic",
                email: "iva@gmail.com",
                phoneNumber: "09876627891",
                userTypeId: UUID(uuidString: "5a60da33-bbcd-4f0f-b95b-d445f29d9ec7")!,
                dateOfBirth: date20YearsAgo,
                password: "12345678"
            )
            return user.save(on: app.db).map { user.id! }
        } catch {
            throw MyError.userInitializationFailed
        }
    }
}
