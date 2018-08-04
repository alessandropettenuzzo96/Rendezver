//
//  Code.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 25/07/18.
//

import Vapor
import Foundation

class Code {
    
    let device: Device
    private let code: String;
    
    init(device: Device, count: UInt8 = 6) {
        
        self.device = device
        
        self.code = Code.random(length: count)
        
    }
    
    private func save(on req: Request) -> Future<Void> {
        
        self.device.code = self.code;
        
        self.device.codeIssuedAt = Date();
        
        return self.device.update(on: req).transform(to: Void());
        
    }
    
    func send(to user: User, on req: Request) throws -> Future<HTTPStatus> {
        
        return self.save(on: req).flatMap { _ throws -> Future<HTTPStatus> in
            
            return try SMSSender(to: user.phone, with: "Hola, questo è il tuo codice "+self.code+" :)").send(on: req);
            
        }
        
    }
    
    
    private static func random(length: UInt8) -> String {
        
        let letters : String = "0123456789"
        let len = letters.count
        
        var randomString = ""
        
        for _ in 0 ..< length {
            var rand = Code.randomInt(min: 0, max: Int(len))
            if rand >= letters.count {
                rand = letters.count - 1;
            }
            let nextChar: Character = letters[rand]
            randomString += String(nextChar)
            //randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    public static func randomInt(min: Int, max:Int) -> Int {
        #if os(Linux)
        return Glibc.random() % max
        #else
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        #endif
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

final class CodeVerifier: Content {
    
    let code: String;
    let deviceID: Int;
    
    private var device: Device?;
    
    func device(on req: Request) throws -> Future<Device> {
        
        if let device = self.device {
            
            return req.eventLoop.newSucceededFuture(result: device);
            
        }
        
        return Device.find(self.deviceID, on: req).flatMap { device -> Future<Device> in
            
            guard let device = device else {
                
                throw Abort(.forbidden, reason: "Cannot find specified device");
                
            }
            
            self.device = device;
            
            return req.eventLoop.newSucceededFuture(result: device);
            
        }
        
    }
    
    func verify(on req: Request) throws -> Future<HTTPStatus> {
        
        return try self.device(on: req).flatMap { device throws -> Future<HTTPStatus> in
            
            guard device.code == self.code else {
                
                throw Abort(.forbidden, reason: "Invalid code")
                
            }
            
            guard let codeIssuedAt = device.codeIssuedAt else {
                
                throw Abort(.forbidden, reason: "Code expired")
                
            }
            
            guard codeIssuedAt.addingTimeInterval(600).compare(Date()) == ComparisonResult.orderedDescending else {
                
                throw Abort(.forbidden, reason: "Code expired")
                
            }
            
            device.verified = true;
            device.code = nil;
            device.codeIssuedAt = nil
            
            return device.update(on: req).transform(to: .ok);
            
        }
    
    }
    
    static func `for`(_ device: Device) -> Executable {
        
        return Action.verifyCode(device);
        
    }
    
    private enum Action: Executable {
        case verifyCode(Device)
    }
    
}
