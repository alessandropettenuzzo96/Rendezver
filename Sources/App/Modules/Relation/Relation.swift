//
//  Relation.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 30/07/18.
//

import Vapor
import FluentPostgreSQL

final class Relation: PostgreSQLModel {
    
    var id: ID?
    
    
    
    
}

final class RelationRequest: Content {
    
    let phone: String;
    
    func user(on req: Request) throws -> Future<User> {
        
        return User.query(on: req).filter(\.phone, .equal, self.phone).first().flatMap { user -> Future<User> in
            
            guard let user = user else {
                
                throw Abort(.badRequest, reason: "Cannot find user with specified number");
                
            }
            
            return req.eventLoop.newSucceededFuture(result: user);
        
        }
        
    }
    
    func relate(with user: User, on req: Request) throws -> Future<[Relation]> {
        
        throw Abort(.notImplemented);
        
    }
    
    static func with(_ user: User) -> Executable {
        
        return Action.relateWith(user);
        
    }
    
    private enum Action: Executable {
        
        case relateWith(User);
        
    }
}
