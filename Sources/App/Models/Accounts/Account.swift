import Vapor
import Fluent
import Argon2Swift

final class Account: Model, Content {
    static let schema = "accounts"

    @ID(custom: "_id")
    var id: String?

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    @Field(key: "pseudonyms")
    var pseudonyms: [String]

    @Field(key: "roles")
    var roles: [Roles]

    @Field(key: "termsAgree")
    var termsAgree: Bool

    @Field(key: "emailConfirmed")
    var emailConfirmed: Bool

    @Children(for: \.$account)
    var sessions: [Session]

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: String? = nil, formData: Account.RegisterForm) {
        let hashedPassword = try! Argon2Swift.hashPasswordString(password: formData.password, salt: Salt.newSalt(), type: Argon2Type.id)

        self.id = id
        email = formData.email
        password = hashedPassword.encodedString()
        pseudonyms = []
        roles = [.user]
        termsAgree = formData.termsAgree
        emailConfirmed = false
    }
}

extension Account {
    struct RegisterForm: Content {
        var email: String
        var password: String
        var termsAgree: Bool
        var inviteCode: String
    }

    struct LoginForm: Content {
        var email: String
        var password: String
        var rememberMe: Bool
    }

    struct ChangeEmail: Content {
        var email: String
        var password: String
    }

    struct ChangePassword: Content {
        var newPassword: String
        var oldPassword: String
    }
}

extension Account.RegisterForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .alphanumeric)
        validations.add("password", as: String.self, is: .count(8...))
        validations.add("inviteCode", as: String.self, is: !.empty)
    }
}

extension Account.LoginForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: !.empty)
    }
}
