import Fluent
import Vapor

final class Pseudonym: Model, Codable {
    static let schema = "pseudonyms"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userTag")
    var userTag: String

    @Field(key: "screenName")
    var screenName: String

    @Field(key: "profile")
    var profile: ProfileInfo

    @Field(key: "stats")
    var stats: ProfileStats

    @Field(key: "presence")
    var presence: Presence

    @Field(key: "roles")
    var roles: [Roles]

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }
}