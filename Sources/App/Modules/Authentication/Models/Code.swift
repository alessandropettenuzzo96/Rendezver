//
//  Code.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 25/07/18.
//

import Vapor
import Foundation

class CodeRequest: Executable, Content {
    
    let deviceID: ID
    
    init(deviceID: ID) {
        
        self.deviceID = deviceID
        
    }
    
    
    func generate(_ count: Int = 6) -> Future<HTTPStatus> {
        
        let code = Int.random(in: 100000...999999);
        
    }
    
    func save() -> Future<HTTPStatus> {
        
    }
    
    func send() -> Future<HTTPStatus> {
        
    }
    
}
