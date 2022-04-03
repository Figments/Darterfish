import Fluent
import Vapor
import Argon2Swift
import UAParserSwift

final class Session: Model, Content {
    static let schema = "sessions"

    @ID(custom: "_id")
    var id: String?

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

    init(id: String? = nil, accountId: Account.IDValue, info: Session.SessionInfo) {
        self.id = id
        self.$account.id = accountId
        browser = info.browser
        ipAddr = info.ipAddr
        os = info.os
        expires = info.expires
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
