//
//  AccountController.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 29/07/18.
//

import Vapor

final class RelationController {
    
    func relate(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(RelationRequest.self).flatMap { relationRequest throws -> Future<HTTPStatus> in
            
            return try relationRequest.user(on: req).flatMap { subject throws -> Future<HTTPStatus> in
                
                return try Authentication.authenticate(req, for: .executeAction(RelationRequest.with(subject))).flatMap { user throws -> Future<HTTPStatus> in
                    
                    return try relationRequest.relate(with: user, on: req).transform(to: .ok);
                    
                }
                
            }
            
        }
        
    }
    
}
