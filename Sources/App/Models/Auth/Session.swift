import Fluent
import Vapor
import Argon2Swift

final class Session: Model, Content {
    static let schema = "sessions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "accountId")
    var account: Account

    @Field(key: "deviceOS")
    var deviceOS: String

    @Field(key: "browser")
    var browser: String

    @Field(key: "expires")
    var expires: Date?

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, accountId: Account.IDValue, session: Session.SessionData) {
        self.id = id
        self.$account.id = accountId
        self.deviceOS = session.deviceOS
        self.browser = session.browser
        self.expires = session.expires
    }
}

extension Session {
    struct SessionData: Content {
        var deviceOS: String
        var browser: String
        var expires: Date?

        init(deviceOS: String, browser: String, expires: Date?) {
            self.deviceOS = deviceOS
            self.browser = browser
            self.expires = expires
        }
    }
}