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
        
        
        //let promise = req.eventLoop.newPromise(String.self);
        
        //let secretWrap = promise.futureResult;
        
        let secretWrap: Future<String>
        
        
        if let jwt = try? JWT<AccessPayload>(unverifiedFrom: Data(authToken.utf8)) {
            
            secretWrap = Device.find(jwt.payload.deviceID, on: req).flatMap { device throws -> Future<String> in
                
                guard let device = device else {
                    
                    throw Abort(.forbidden, reason: "Cannot find specified device");
                    
                }
                
                return device.user.get(on: req).flatMap { user throws -> Future<String> in
                    
                    guard let secret = user.secret else {
                        
                        throw Abort(.forbidden, reason: "Cannot find secret key");
                        
                    }
                    
                    return req.eventLoop.newSucceededFuture(result: secret)
                    
                }
                
            }
            
        } else if let jwt = try? JWT<CreationPayload>(unverifiedFrom: Data(authToken.utf8)) {
            
            secretWrap = User.find(jwt.payload.userID, on: req).flatMap { user throws -> Future<String> in
                
                guard let secret = user?.secret else {
                    
                    throw Abort(.forbidden, reason: "Cannot find secret key")
                    
                }
                
                guard user?.role == .creation else {
                    
                    throw Abort(.forbidden, reason: "Unspecified device")
                    
                }
                
                return req.eventLoop.newSucceededFuture(result: secret)
                
            }
            
        } else {
            
            throw Abort(.forbidden, reason: "Invalid Token");
            
        }
        
        
        // verify token validity and return Future<User>
        
        let secretVerificationWrap = secretWrap.flatMap { secret throws -> Future<User>  in
            
            do {
                
                let jwt = try JWT<AccessPayload>(from: authToken, verifiedUsing: JWTSigner.hs512(key: Data(secret.utf8)))
                
                return Device.find(jwt.payload.deviceID, on: req).flatMap({ device throws -> Future<User> in
                    
                    guard let device = device else {
                        
                        throw Abort(.forbidden, reason: "Cannot find specified Device")
                        
                    }
                    
                    return device.user.get(on: req);
                    
                })
            
            } catch is JWTError {
            
                do {
                
                    let jwt = try JWT<CreationPayload>(from: authToken, verifiedUsing: JWTSigner.hs512(key: Data(secret.utf8)))
                    
                    return User.find(jwt.payload.userID, on: req).flatMap({ user throws -> Future<User> in
                        
                        guard let user = user else {
                            
                            throw Abort(.forbidden, reason: "Cannot find specified User")
                            
                        }
                        
                        guard user.role == .creation else {
                            
                            throw Abort(.forbidden, reason: "Unspecified device")
                            
                        }
                        
                        return req.eventLoop.newSucceededFuture(result: user);
                        
                    });
                
                } catch is JWTError {
                
                    throw Abort(.forbidden, reason: "Invalid Token")
                
                }
                
            }
            
        }
        
        
        
        let scopes = scopes.compactMap { $0 };
        
        let scopesVerificationWrap = secretVerificationWrap.flatMap { user throws -> Future<User> in
            
            return try user.can(scopes, on: req).flatMap({ _ -> Future<User> in
                
                return req.eventLoop.newSucceededFuture(result: user);
                
            })
            
        }
        
        
        return scopesVerificationWrap;
        
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




enum Roles: String, Codable {
    
    case guest, creation, addDevice, confirmation, user
    
    
    var capabilities: [Scopes] {
        return [];
    }
    
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        self = Roles(rawValue: label) ?? .guest
    }
    
}
