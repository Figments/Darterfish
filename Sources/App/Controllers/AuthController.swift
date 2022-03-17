import Fluent
import Vapor
import Argon2Swift
import UAParserSwift

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
        auth.get("refresh-token", use: refreshToken)
        auth.get("logout", use: logout)
    }

    private func register(req: Request) async throws -> Response {
        let registerForm = try req.content.decode(Account.RegisterForm.self)
        let newAccount = Account.init(formData: registerForm)
        try await newAccount.save(on: req.db)
        return try await processLogin(for: newAccount, via: req, session: true)
    }

    private func login(req: Request) async throws -> Response {
        let loginForm = try req.content.decode(Account.LoginForm.self)
        guard let existingAccount = try await Account.query(on: req.db).filter(\.$email == loginForm.email).first() else {
            throw Abort(.notFound)
        }

        if try! Argon2Swift.verifyHashString(password: loginForm.password, hash: existingAccount.password, type: Argon2Type.id) {
            return try await processLogin(for: existingAccount, via: req, session: loginForm.rememberMe)
        } else {
            throw Abort(.unauthorized)
        }
    }

    private func logout(req: Request) async throws -> String {
        "You hit the logout route!"
    }

    private func refreshToken(req: Request) async throws -> Response {
        guard let refreshToken = req.cookies["refreshToken"]?.string else {
            throw Abort(.unauthorized, reason: "There's no refresh token here!")
        }

        guard let associatedSession =
            try await Session
                .query(on: req.db)
                .with(\.$account)
                .filter(\.$id == UUID(refreshToken).unsafelyUnwrapped)
                .first()
            else {
                throw Abort(.unauthorized, reason: "No valid session associated with this token.")
            }

        return try await refreshAuthToken(session: associatedSession, on: req)
    }

    private func processLogin(for account: Account, via req: Request, session rememberMe: Bool) async throws -> Response {
        let userAgent = UAParser(agent: req.headers.first(name: .userAgent).unsafelyUnwrapped)
        let sessionInfo = Session.SessionInfo(
            with: userAgent.browser?.name,
            from: req.remoteAddress?.ipAddress,
            on: userAgent.os?.name
        )
        let newSession = Session.init(accountId: account.id.unsafelyUnwrapped, info: sessionInfo)
        try await newSession.save(on: req.db)

        let token = try req.jwt.sign(
            TokenPayload.init(
                subject: "vapor",
                expiration: .init(value: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now),
                accountId: account.id,
                roles: account.roles
            )
        )

        let response = try await AccountPackage(FrontendAccount(account), token).encodeResponse(for: req)
        if rememberMe == true {
            response.cookies["refreshToken"] = HTTPCookies.Value(
                string: newSession.id?.uuidString ?? "aToken",
                expires: .distantFuture,
                isSecure: false,
                isHTTPOnly: true,
                sameSite: .lax
            )
            return response
        } else {
            return response
        }
    }

    private func refreshAuthToken(session: Session, on request: Request) async throws -> Response {
        let newToken = try request.jwt.sign(
            TokenPayload.init(
                subject: "vapor",
                expiration: .init(value: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now),
                accountId: session.account.id,
                roles: session.account.roles
            )
        )

        return try await RefreshPackage.init(newToken: newToken).encodeResponse(for: request)
    }
}
