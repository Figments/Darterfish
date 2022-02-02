import Fluent

struct CreateAccount: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("accounts")
                .id()
                .field("email", .string, .required)
                .field("password", .string, .required)
                .field("pseudonyms", .array(of: .string))
                .field("roles", .array(of: .string))
                .field("termsAgree", .bool)
                .field("emailConfirmed", .bool)
                .field("createdAt", .datetime)
                .field("updatedAt", .datetime)
                .unique(on: "email")
                .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("accounts").delete()
    }
}