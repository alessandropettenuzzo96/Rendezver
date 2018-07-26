import Vapor

final class AuthenticationController {
    
    /// Returns a list of all `Todo`s.
    
    func index(_ req: Request) throws -> Future<[User]> {
        
        return User.query(on: req).all()
        
    }
    
    
    
    /// User management routes
    
    func create(_ req: Request) throws -> Future<CreationToken> {
        
        return try req.content.decode(User.self).flatMap { user throws -> Future<CreationToken> in
            
            return user.save(on: req).flatMap({ savedUser throws -> Future<CreationToken> in
                
                return req.eventLoop.newSucceededFuture(result: try CreationToken(with: savedUser, on: req))
                
            });
            
        }
        
    }
    
    
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(User.self).flatMap { user throws -> Future<HTTPStatus> in
            
            return try Authentication.authenticate(req, for: .deleteItem(user)).flatMap({ (_) -> Future<HTTPStatus> in
                
                return user.delete(on: req).transform(to: .ok);
                
            })
            
        }
        
    }
    
    
    
    func update(_ req: Request) throws -> Future<User> {
        
        return try req.parameters.next(User.self).flatMap({ user throws -> Future<User> in
            
            return try Authentication.authenticate(req, for: .updateItem(user)).flatMap({ (_) -> Future<User> in
                
                return user.update(on: req);
                
            })
            
        })
        
    }
    
    
    /// Device management routes
    
    func createDevice(_ req: Request) throws -> Future<Device> {
        
        return try Authentication.authenticate(req, for: .create(Device.self)).flatMap { user throws -> Future<Device> in
            
            return try req.content.decode(Device.self).flatMap({ device -> Future<Device> in
                
                device.userID = user.id!;
                
                return device.save(on: req);
                
            })
            
        }
        
    }
    
    
    
    func updateDevice(_ req: Request) throws -> Future<Device> {
        
        return try req.content.decode(Device.self).flatMap({ device -> Future<Device> in
            
            return try Authentication.authenticate(req, for: .updateItem(device)).flatMap { _ throws -> Future<Device> in
                
                return device.update(on: req);
                
            }
            
        })
        
    }
    
    
    func deleteDevice(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(Device.self).flatMap({ device throws -> Future<HTTPStatus> in
            
            return try Authentication.authenticate(req, for: .deleteItem(device)).flatMap { _ throws -> Future<HTTPStatus> in
                
                return device.delete(on: req).transform(to: .ok);
                
            }
            
        })
        
    }
    
    
    
    // Access token management routes
    
    func code(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(CodeRequest.self).flatMap { codeRequest throws -> Future<HTTPStatus> in
            
            return Device.find(Int(codeRequest.deviceID), on: req).flatMap { device throws -> Future<HTTPStatus> in
                
                guard let device = device else {
                    throw Abort(.badRequest, reason: "Invalid device")
                }
                
                return try Authentication.authenticate(req, for: .executeAction(CodeRequest.for(device))).flatMap { user throws -> Future<HTTPStatus> in
                    
                    let code = Code(device: device);
                    
                    return try code.send(to: user, on: req);
                    
                }
                
            }
            
        }
        
    }
    
}

