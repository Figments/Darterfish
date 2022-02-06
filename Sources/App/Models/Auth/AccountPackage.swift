import Vapor

struct AccountPackage: Content {
    var account: FrontendAccount
    var accessToken: String
}