import Vapor
import Fluent

struct AccountPackage: Content {
    var account: FrontendAccount
    var accessToken: UUID?

    init(_ account: FrontendAccount, _ token: UUID?) {
        self.account = account
        self.accessToken = token
    }
}