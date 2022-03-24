import Fluent

struct CreateUserContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("content")
            .id()
            .foreignKey("author", references: "pseudonyms", "id")
            .field("title", .string, .required)
            .field("desc", .string, .required)
            .field("body", .string, .required)
            .field("sections", .array(of: .string))
            .field("meta", .dictionary, .required)
            .field("stats", .dictionary, .required)
            .field("audit", .dictionary, .required)
            .field("kind", .string, .required)
            .field("tags", .array(of: .string))
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("content").delete()
    }
}