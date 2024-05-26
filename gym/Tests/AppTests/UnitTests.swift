import XCTest
import Vapor
import Fluent
import FluentPostgresDriver

@testable import App

final class UnitTests: XCTestCase {

    var app: Application!
    var userId: UUID!

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
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testValidateEmailFormat() throws {
        let validator = ValidationHelper()
        XCTAssertNoThrow(try validator.validateEmailFormat("test@example.com"))
        XCTAssertThrowsError(try validator.validateEmailFormat("testexample.com")) { error in
            guard let abortError = error as? Abort else {
                XCTFail("Expected Abort error")
                return
            }
            XCTAssertEqual(abortError.status, .badRequest)
            XCTAssertEqual(abortError.reason, "Invalid email format")
        }
    }

    func testCheckMinimumAge() throws {
        let validator = ValidationHelper()
        let eighteenYearsAgo = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        XCTAssertNoThrow(try validator.checkMinimumAge(eighteenYearsAgo))
        let sixteenYearsAgo = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        XCTAssertThrowsError(try validator.checkMinimumAge(sixteenYearsAgo)) { error in
            guard let abortError = error as? Abort else {
                XCTFail("Expected Abort error")
                return
            }
            XCTAssertEqual(abortError.status, .badRequest)
            XCTAssertEqual(abortError.reason, "User must be at least 18 years old")
        }
    }

    func testCheckEmailUniqueness() async throws {
        try setUpWithError()
        try await configure(app)

        let validator = ValidationHelper()
        let req = Request(application: app, on: app.eventLoopGroup.next())

        XCTAssertNoThrow(validator.checkEmailUniqueness("another@example.com", req: req))
        XCTAssertThrowsError(validator.checkEmailUniqueness("admin@gmail.com", req: req))
    }

    func testCheckEmailUniquenessWithCurrentUser() async throws {
        try await configure(app)

        let validator = ValidationHelper()
        let req = Request(application: app, on: app.eventLoopGroup.next())

        XCTAssertNoThrow(validator.checkEmailUniqueness("another@example.com", currentUserId: userId, req: req))
        XCTAssertNoThrow(validator.checkEmailUniqueness("test@example.com", currentUserId: userId, req: req))
    }

    func createUser() throws -> EventLoopFuture<UUID> {
        let date = Date()
        let calendar = Calendar.current
        guard let date20YearsAgo = calendar.date(byAdding: .year, value: -20, to: date) else {
            throw MyError.invalidDate
        }

        do {
            let user = try User(
                name: "Test",
                surname: "Test",
                email: "test@gmail.com",
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
