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
