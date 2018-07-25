//
//  Device.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 19/07/18.
//

import Vapor
import FluentMySQL

final class Device: MySQLModel, Resource, Authenticable {
    
    var id: ID?
    
    var userID: ID!
    var name: String
    var type: DeviceType
    var location: Coordinate?
    
    var user: Parent<Device, User> {
        return parent(\.userID!)
    }
    
    init(id: ID? = nil, userID: ID, name: String, type: DeviceType, location: Coordinate? ) {
        self.id = id;
        self.userID = userID;
        self.name = name;
        self.type = type;
        self.location = location;
    }
    
}


extension Device: Migration { }

extension Device: Content { }

extension Device: Parameter { }

enum DeviceType: Int, Codable {
    case mobile
    case desktop
}
