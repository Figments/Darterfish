import Fluent

struct CreateSession: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("sessions")
                .id()
                .foreignKey("accountId", references: "accounts", "id")
                .field("browser", .string)
                .field("ipAddr", .string)
                .field("os", .string)
                .field("expires", .datetime)
                .field("createdAt", .datetime)
                .field("updatedAt", .datetime)
                .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("sessions").delete()
    }
}
