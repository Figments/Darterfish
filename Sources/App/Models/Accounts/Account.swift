import Fluent
import Vapor

final class Account: Model {
    static let schema = "accounts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    @Field(key: "pseudonyms")
    var pseudonyms: [String]
}