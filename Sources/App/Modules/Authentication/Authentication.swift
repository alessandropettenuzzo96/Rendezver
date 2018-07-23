//
//  Authentication.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 19/07/18.
//

import Vapor
import JWT


class Authentication {
    
    
    
    func authenticate(_ req: Request, for scopes: Scopes?...) throws -> Future<User>{
        
        
        guard let authHeader = req.http.headers.firstValue(name: HTTPHeaderName("Authorization") ) else {
            
            throw Abort(.forbidden, reason: "Missing Authorization header");
            
        }
        
        
        let authHeaderParts = authHeader.split(separator: " ");
        
        guard authHeaderParts.count == 2 else {
            
            throw Abort(.forbidden, reason: "Malformed Authorization header");
            
        }
        
        
        
        guard let authToken = authHeaderParts.last?.string(), let authType = AuthenticationType.from(unwrapped: authHeaderParts.first?.string()) else {
            
            throw Abort(.forbidden, reason: "Malformed Authorization header");
            
        }
        
        
        
        guard authType == .Bearer else {
            
            throw Abort(.forbidden, reason: "Invalid Authentication method");
            
        }
        
        
        
        guard let jwtWrap = try? JWT.decode(authToken) else {
            
            throw Abort(.forbidden, reason: "Invalid Token");
            
        }
        
        
        
        guard let jwt = jwtWrap else {
            
            throw Abort(.forbidden, reason: "Invalid Token");
            
        }
        
        
        
        
        
        let promise = req.eventLoop.newPromise(String.self);
        
        
        
        let secretWrap = promise.futureResult;
        
        
        
        if let deviceID = jwt.claims.asDictionary["device_id"] as? ID {
            
            
            
            Device.find(deviceID, on: req).do { device in
                
                guard let device = device else {
                    
                    return promise.fail(error: Abort(.forbidden, reason: "Cannot find specified device"));
                    
                }
                
                device.user.get(on: req).do { u in
                    
                    guard let secret = u.secret else {
                        
                        return promise.fail(error: Abort(.forbidden, reason: "Cannot find secret key"));
                        
                    }
                    
                    return promise.succeed(result: secret);
                    
                }
                
            }
            
            
            
        } else if let userID = jwt.claims.asDictionary["user_id"] as? ID {
            
            
            
            User.find(userID, on: req).do { u in
                
                guard let secret = u?.secret else {
                    
                    return promise.fail(error: Abort(.forbidden, reason: "Cannot find secret key"));
                    
                }
                
                return promise.succeed(result: secret);
                
            }
            
            
            
        } else {
            
            throw Abort(.forbidden, reason: "Invalid Token");
            
        }
        
        
        // verify scopes and token validity
        
        secretWrap.do { secret in
            JWT.verify(authToken, using: )
        }
        
        
        
        let scopes = scopes.compactMap { $0 };
        
        
        
        let p = req.eventLoop.newPromise(User.self);
        
        return p.futureResult;
        
    }
    
    
    
}





enum AuthenticationType: String {
    
    
    
    case Basic = "Basic"
    
    case Bearer = "Bearer"
    
    
    
    static func from(unwrapped rawValue: String?) -> AuthenticationType? {
        
        guard let raw = rawValue else {
            
            return nil;
            
        }
        
        
        
        return AuthenticationType(rawValue: raw);
        
    }
    
    
    
}

enum Scopes {
    
    case create(Creatable.Type)
    
    case list(Listable.Type)
    
    case listItems([Listable])
    
    case delete(Deletable.Type)
    
    case deleteItem(Deletable)
    
    case update(Editable.Type)
    
    case updateItem(Editable)
    
    case read(Readable.Type)
    
    case readItem(Readable)
    
    case execute(Executable.Type)
    
    case executeAction(Executable)
    
}



protocol Resource: Creatable, Deletable, Editable, Readable, Listable, Executable {}



protocol Creatable {}

protocol Deletable {}

protocol Editable {}

protocol Readable {}

protocol Listable {}

protocol Executable {}





struct Role: Codable {
    
    private static let capabilities: [Roles: [Scopes]] = [:];
    
    let role: Roles;
    
    var capabilities: [Scopes]? {
        return Role.capabilities[self.role];
    }
    
    
    
    init(_ role: Roles) {
        
        self.role = role;
        
    }
    
}



enum Roles: String, Codable {
    
    case creation
    
    case addDevice
    
    case confirmation
    
    case user
    
}
