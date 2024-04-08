import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

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
    app.migrations.add(CreateReservation())
    app.migrations.add(CreateTimeslotLocationCapacity())

    app.views.use(.leaf)

    try routes(app)
}
