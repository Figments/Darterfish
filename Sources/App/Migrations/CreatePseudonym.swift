import Fluent

struct CreatePseudonym: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("pseudonyms")
                .id()
                .foreignKey("accountId", references: "accounts", "id")
                .field("userTag", .string, .required)
                .field("screenName", .string, .required)
                .field("profile", .dictionary, .required)
                .field("stats", .dictionary, .required)
                .field("presence", .string)
                .field("roles", .array(of: .string))
                .field("createdAt", .datetime)
                .field("updatedAt", .datetime)
                .unique(on: "userTag")
                .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("pseudonyms").delete()
    }
}