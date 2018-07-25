import FluentMySQL
import Vapor
import Crypto

typealias ID = Int;


final class User: MySQLModel, Resource, Authenticable {

    var id: ID?
    
    var phone: String
    var username: String
    var email: String
    var role: Roles!
    
    var secret: String?
    
    var devices: Children<User, Device> {
        return children(\.userID!);
    }

    init( id: Int? = nil, username: String, phone: String, email: String ) {
        self.id = id
        self.username = username;
        self.phone = phone;
        self.email = email;
    }
    
    
    func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<User> {
        self.role = .creation;
        self.secret = try CryptoRandom().generateData(count: 64).base64URLEncodedString();
        return conn.eventLoop.newSucceededFuture(result: self);
    }
    
    
    func can(_ scopes: Scopes..., on req: Request ) throws -> Future<Void> {
        return try self.can(scopes, on: req);
    }
    
    
    func can(_ scopes: [Scopes], on req: Request) throws -> Future<Void> {
        
        let p = req.eventLoop.newPromise(Void.self);
        
        let capabilities = self.role.capabilities;
        
        
        // TODO: This is a Mock
        p.succeed(result: Void());
        
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
