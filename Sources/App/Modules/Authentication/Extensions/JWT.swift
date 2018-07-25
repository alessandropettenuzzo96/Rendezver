//
//  JWT.swift
//  App
//
//  Created by C1rcul4r on 25/07/18.
//

import JWT
import Vapor

extension JWT {
    
    mutating func signed(with user: User) throws -> String {
        guard let secret = user.secret, let secretData = secret.data(using: .utf8, allowLossyConversion: false) else {
            throw Abort(.internalServerError, reason: "Cannot read secret for user")
        }
        return String.init(data: try self.sign(using: JWTSigner.hs512(key: secretData)), encoding: .utf8)!; 
    }
    
}
