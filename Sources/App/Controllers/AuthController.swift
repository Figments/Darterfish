import Fluent
import Vapor
import Argon2Swift
import UAParserSwift

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> AccountPackage {
        let registerForm = try req.content.decode(Account.RegisterForm.self)
        let newAccount = Account.init(formData: registerForm)
        try await newAccount.save(on: req.db)
        return try await createLoginPackage(account: newAccount, req: req)
    }

    func login(req: Request) async throws -> AccountPackage {
        let loginForm = try req.content.decode(Account.LoginForm.self)
        guard let existingAccount = try await Account.query(on: req.db).filter(\.$email == loginForm.email).first() else {
            throw Abort(.notFound)
        }

        let isCorrect = try! Argon2Swift.verifyHashString(password: loginForm.password, hash: existingAccount.password, type: Argon2Type.id)
        if isCorrect {
            return try await createLoginPackage(account: existingAccount, req: req)
        } else {
            throw Abort(.unauthorized)
        }
    }

    func logout(req: Request) async throws {
        
    }

    func createLoginPackage(account: Account, req: Request) async throws -> AccountPackage {
        let userAgent = UAParser(agent: req.headers.first(name: .userAgent).unsafelyUnwrapped)
        let sessionInfo = Session.SessionInfo(
                with: userAgent.browser?.name,
                from: req.remoteAddress?.ipAddress,
                on: userAgent.os?.name
        )
        let session = Session.init(accountId: account.id.unsafelyUnwrapped, info: sessionInfo)
        try await session.save(on: req.db)
        return AccountPackage.init(FrontendAccount.init(account), session.id)
    }
}
