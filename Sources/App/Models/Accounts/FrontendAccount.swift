import Fluent
import Vapor

struct FrontendAccount: Content {
    var id: String?
    var pseudonyms: [String]
    var roles: [Roles]
    var termsAgree: Bool
    var emailConfirmed: Bool
    var createdAt: Date?
    var updatedAt: Date?

    init(_ account: Account) {
        self.id = account.id
        self.pseudonyms = account.pseudonyms
        self.roles = account.roles
        self.termsAgree = account.termsAgree
        self.emailConfirmed = account.emailConfirmed
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
}