import Fluent
import JWT

struct TokenPayload: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case accountId = "accountId"
        case roles = "roles"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var accountId: UUID?
    var roles: [Roles]

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}