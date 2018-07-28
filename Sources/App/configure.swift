import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    let dbConfig: PostgreSQLDatabaseConfig;
    
    if let dbUrl = ProcessInfo.processInfo.environment["DATABASE_URL"] {
        
        dbConfig = PostgreSQLDatabaseConfig(url: dbUrl)!;
        
    } else {
        
        dbConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "rendezver", database: "rendezvous");
        
    }
    
    // Configure a MySQL database
    let psql = PostgreSQLDatabase(config: dbConfig);
    
    
    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    //databases.add(database: mysql, as: .mysql)
    databases.add(database: psql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    //migrations.add(migration: CreateUserTable.self, database: .mysql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Device.self, database: .psql)
    services.register(migrations)
    
}
