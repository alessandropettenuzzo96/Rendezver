import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let authController = AuthenticationController();
    router.post("auth", "user", use: authController.create);
    router.delete("auth", "user", use: authController.delete)
    router.post("auth", "device", use: authController.createDevice);
    router.delete("auth", "device", Device.parameter, use: authController.deleteDevice);
    router.post("auth", "code", use: authController.code);
    router.post("auth", "token", use: authController.verify);
    
}
