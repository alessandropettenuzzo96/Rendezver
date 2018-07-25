//
//  Token.swift
//  App
//
//  Created by C1rcul4r on 25/07/18.
//

import Vapor

final class CreationToken : Content {
    
    let user: User;
    let token: Token
    
    init(with user: User, on req: Request) throws {
        self.user = user;
        var t = try Authentication.token(for: self.user, on: req);
        self.token = Token(type: "Bearer", token: try t.signed(with: user))
    }
    
}

final class AccessToken: Content {
    
    let device: Device;
    let token: Token
    
    init(with device: Device, and user: User, on req: Request) throws {
        self.device = device;
        var t = try Authentication.token(for: self.device, on: req)
        self.token = Token(type: "Bearer", token: try t.signed(with: user))
    }
    
}

final class Token: Content {
    
    let type: String
    let token: String
    
    init(type: String, token: String) {
        self.type = type;
        self.token = token;
    }
    
}
