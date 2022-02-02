import Fluent
import Vapor
import Argon2Swift

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> FrontendAccount {
        let registerForm = try req.content.decode(Account.RegisterForm.self)
        let newAccount = Account.init(formData: registerForm)
        try await newAccount.save(on: req.db)
        return FrontendAccount.init(account: newAccount)
    }

    func login(req: Request) async throws -> FrontendAccount {
        let loginForm = try req.content.decode(Account.LoginForm.self)
        guard let existingAccount = try await Account.query(on: req.db).filter(\.$email == loginForm.email).first() else {
            throw Abort(.notFound)
        }

        let isCorrect = try! Argon2Swift.verifyHashString(password: loginForm.password, hash: existingAccount.password, type: Argon2Type.id)
        if isCorrect {
            return FrontendAccount.init(account: existingAccount)
        } else {
            throw Abort(.unauthorized)
        }
    }
}