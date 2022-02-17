import Fluent
import Vapor
import Argon2Swift
import UAParserSwift

final class Session: Model, Content {
    static let schema = "sessions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "accountId")
    var account: Account
    
    @Field(key: "browser")
    var browser: String?
    
    @Field(key: "ipAddr")
    var ipAddr: String?
    
    @Field(key: "os")
    var os: String?

    @Field(key: "expires")
    var expires: Date?

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, accountId: Account.IDValue, info: Session.SessionInfo) {
        self.id = id
        self.$account.id = accountId
        self.browser = info.browser
        self.ipAddr = info.ipAddr
        self.os = info.os
        self.expires = info.expires
    }
}

extension Session {
    struct SessionInfo {
        var browser: String?
        var ipAddr: String?
        var os: String?
        var expires: Date?
        
        init(with browser: String?, from ipAddr: String?, on os: String?, expires: Date? = nil) {
            self.browser = browser
            self.ipAddr = ipAddr
            self.os = os
            self.expires = expires
        }
    }
}
