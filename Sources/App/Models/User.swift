import FluentMySQL
import Vapor

typealias ID = Int;


final class User: MySQLModel, Resource {

    var id: ID?
    
    var phone: String
    var username: String
    var email: String
    var role: Role
    
    var secret: String?
    
    var devices: Children<User, Device> {
        return children(\.userID);
    }

    init( id: Int? = nil, username: String, phone: String, email: String, role: Role ) {
        self.id = id
        self.username = username;
        self.phone = phone;
        self.email = email;
        self.role = role;
    }
    
    
    
    func can(_ scopes: Scopes..., on req: Request) -> Future<Void> {
        
        let p = req.eventLoop.newPromise(Void.self);
        
        let capabilities = self.role.capabilities;
        
        for scope in scopes {
            
            switch scope {
                
            case .create( let entity ):
                
                break;
                
                
            case .delete( let entity ):
                
                break;
                
            
            case .deleteItem( let element ):
                
                break;
                
                
            case .update( let entity ):
                
                break;
                
                
            case .updateItem( let element ):
                
                break;
                
                
            case .list( let entity ):
                
                break;
                
                
            case .listItems( let elements ):
                
                break;
                
                
            case .read( let entity ):
                
                break;
                
                
            case .readItem( let element ):
                
                break;
                
                
            case .execute( let entity ):
                
                break;
                
                
            case .executeAction( let action ):
                
                break;
            }
            
        }
        
        return p.futureResult;
        
    }
}


extension User: Migration { }

extension User: Content { }

extension User: Parameter { }
