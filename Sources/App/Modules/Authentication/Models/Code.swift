//
//  Code.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 25/07/18.
//

import Vapor
import Foundation
import Telesign

class Code {
    
    let device: Device
    private let code: String;
    
    init(device: Device, count: UInt8 = 6) {
        
        self.device = device
        
        self.code = Code.random(length: count)
        
    }
    
    private func save(on req: Request) -> Future<Void> {
        self.device.code = self.code;
        return self.device.update(on: req).transform(to: Void());
    }
    
    func send(to user: User, on req: Request) throws -> Future<HTTPStatus> {
        return self.save(on: req).flatMap { _ throws -> Future<HTTPStatus> in
            return try req.make(TelesignClient.self).messaging.send(message: "Your device verification code is: "+self.code+".", to: user.phone, messageType: MessageType.ARN).transform(to: .ok);
        }
    }
    
    
    private static func random(length: UInt8) -> String {
        
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    enum Execute: Executable {
        case request(device: Device)
    }
    
}


struct CodeRequest: Content {
    let deviceID: UInt64;
    
    static func `for`(_ device: Device) -> Executable {
        
        return Action.requestCode(device);
        
    }
    
    private enum Action: Executable {
        case requestCode(Device)
    }
    
}
