import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: "localhost",
        port: 5432,
        username: "postgres",
        password: "postgres",
        database: "gymdb",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUserType())
    app.migrations.add(CreateSubscriptionType())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateMembership())
    app.migrations.add(CreateSubscription())
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateTimeslot())
    app.migrations.add(CreateTimeslotLocation())
    app.migrations.add(CreateReservation())

    app.views.use(.leaf)

    try await app.autoRevert()
    try await app.autoMigrate()

    DatabaseSetup().setUpDatabase(using: app.db)

    try routes(app)
}
