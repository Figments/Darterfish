import Vapor
import Fluent

struct AccountPackage: Content {
    var account: FrontendAccount
    var token: String

    init(_ account: FrontendAccount, _ token: String) {
        self.account = account
        self.token = token
    }
}