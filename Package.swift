// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Rendezver",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        // JWT
        .package(url:"https://github.com/vapor/jwt.git", from: "3.0.0-rc.2"),
        
        // SMS GATEWAY : TELESIGN
        .package(url: "https://github.com/vapor-community/telesign-provider.git", from: "2.0.2")
        
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Telesign", "JWT", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

