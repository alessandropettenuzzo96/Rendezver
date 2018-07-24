
import Vapor
import JWT

protocol RNDPayload: JWTPayload {
    
    var exp: ExpirationClaim { get set }
    var iss: IssuerClaim { get set }
    var nbf: NotBeforeClaim { get set }
    var aud: AudienceClaim { get set }
    var sub: SubjectClaim { get set }
    var iat: IssuedAtClaim { get set }
    
}

struct CreationPayload: RNDPayload {
    
    var exp: ExpirationClaim
    
    var iss: IssuerClaim
    
    var nbf: NotBeforeClaim
    
    var aud: AudienceClaim
    
    var sub: SubjectClaim
    
    var iat: IssuedAtClaim
    
    
    var userID: ID
    
    
    func verify() throws {
        try self.exp.verify()
        try self.nbf.verify()
        guard self.userID > 0 else {
            throw JWTError(identifier: "exp", reason: "Invalid User")
        }
    }
    
}

struct AccessPayload: RNDPayload {
    
    var exp: ExpirationClaim
    
    var iss: IssuerClaim
    
    var nbf: NotBeforeClaim
    
    var aud: AudienceClaim
    
    var sub: SubjectClaim
    
    var iat: IssuedAtClaim
    
    
    var deviceID: ID
    
    
    func verify() throws {
        try self.exp.verify()
        try self.nbf.verify()
        guard self.deviceID > 0 else {
            throw JWTError(identifier: "exp", reason: "Invalid Device")
        }
    }
    
    
}
