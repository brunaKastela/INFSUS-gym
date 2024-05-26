import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {

//    DEPLOY
    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
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
    }

//    TEST
//
//    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
//        hostname: "localhost",
//        port: 5432,
//        username: "postgres",
//        password: "postgres",
//        database: "gymdb",
//        tls: .prefer(try .init(configuration: .clientDefault)))
//    ), as: .psql)
//
//    app.migrations.add(CreateUserType())
//    app.migrations.add(CreateSubscriptionType())
//    app.migrations.add(CreateUser())
//    app.migrations.add(CreateMembership())
//    app.migrations.add(CreateSubscription())
//    app.migrations.add(CreateLocation())
//    app.migrations.add(CreateTimeslot())
//    app.migrations.add(CreateTimeslotLocation())
//    app.migrations.add(CreateReservation())
//
//    app.views.use(.leaf)
//
//    try await app.autoRevert()
//    try await app.autoMigrate()
//
//    DatabaseSetup().setUpDatabase(using: app.db)

//    ======
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    try routes(app)
}
