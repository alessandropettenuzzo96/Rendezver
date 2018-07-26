import FluentMySQL
import Vapor
import Telesign

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "rendezver", password: "7h{A+6hQJCSp/&YvhARx_BTd.y(H]um4", database: "rendezvous"));
    
    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    //migrations.add(migration: CreateUserTable.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Device.self, database: .mysql)
    services.register(migrations)

    // Configuring Telesign sms gateway
    services.register(TelesignConfig(apiKey: "M/pCfuL3v4BWsbgPryE/76tBz1zJ3pL7lQTdhWWOXGDnWxPl2JVMh5oHOYpKKEy8MgxSPYdoXLzaFVB7FUIMzA==M/pCfuL3v4BWsbgPryE/76tBz1zJ3pL7lQTdhWWOXGDnWxPl2JVMh5oHOYpKKEy8MgxSPYdoXLzaFVB7FUIMzA==", customerId: "0574CBFC-10E3-4A0F-A7E8-1350E0BEE5CC"))
    try services.register(TelesignProvider())
    
}
