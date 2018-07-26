import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    let authController = AuthenticationController();
    router.post("auth", "user", use: authController.create);
    router.post("auth", "device", use: authController.createDevice);
    router.post("auth", "code", use: authController.code);
}
