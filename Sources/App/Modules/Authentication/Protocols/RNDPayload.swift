
import Vapor
import JWT

protocol RNDPayload: JWTPayload {
    
    var exp: ExpirationClaim { get set }
    var iss: IssuerClaim { get set }
    var iat: IssuedAtClaim { get set }
    
}

struct CreationPayload: RNDPayload {
    
    var exp: ExpirationClaim
    
    var iss: IssuerClaim
    
    var iat: IssuedAtClaim
    
    var uid: ID
    
    
    func verify() throws {
        try self.exp.verify()
        guard self.uid > 0 else {
            throw JWTError(identifier: "uid", reason: "Invalid User")
        }
    }
    
    init(_ userID: ID) {
        self.exp = ExpirationClaim(value: Date(timeIntervalSinceNow: 172800));
        self.iss = IssuerClaim(value: "RND-SS");
        self.iat = IssuedAtClaim(value: Date());
        self.uid = userID;
    }
    
}

struct AccessPayload: RNDPayload {
    
    var exp: ExpirationClaim
    
    var iss: IssuerClaim
    
    var iat: IssuedAtClaim
    
    var did: ID
    
    
    func verify() throws {
        try self.exp.verify()
        guard self.did > 0 else {
            throw JWTError(identifier: "did", reason: "Invalid Device")
        }
    }
    
    
    init(_ deviceID: ID) {
        self.exp = ExpirationClaim(value: Date(timeIntervalSinceNow: 172800));
        self.iss = IssuerClaim(value: "RND-SS");
        self.iat = IssuedAtClaim(value: Date());
        self.did = deviceID;
    }
    
    
}
