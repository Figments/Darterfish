import Fluent
import FluentMongoDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Setting up database connection pool
    try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    // Setting up JWT signing
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "aSecret"))

    // Adding migrations
    app.migrations.add(CreateAccount())
    app.migrations.add(CreateSession())
    app.migrations.add(CreatePseudonym())
    app.migrations.add(CreateUserContent())

    // register routes
    try routes(app)
}
