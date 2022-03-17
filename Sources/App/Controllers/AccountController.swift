import Fluent
import Vapor
import Argon2Swift

struct AccountController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let account = routes.grouped("accounts")
        account.grouped(RolesMiddleware(needs: [.user])).post("add-pseudonym", use: addPseudonym)
        account.grouped(RolesMiddleware(needs: [.user])).patch("change-email", use: changeEmail)
        account.grouped(RolesMiddleware(needs: [.user])).patch("change-password", use: changePassword)
        account.grouped(IdentityMiddleware(needs: [.user])).patch("change-user-tag", use: changeUserTag)
        account.grouped(IdentityMiddleware(needs: [.user])).patch("change-screen-name", use: changeScreenName)
        account.grouped(IdentityMiddleware(needs: [.user])).patch("change-tagline", use: changeTagline)
    }

    private func addPseudonym(req: Request) async throws -> Pseudonym {
        // Grab the account making this request from the request object. If not found,
        // throw an error.
        let account = try retrieveAccount(from: req)

        // Check to see if an account has already reached the limit on pseudonyms. If yes,
        // throw an error.
        if account.pseudonyms.count == 3 {
            throw Abort(.badRequest, reason: "You've already reached the pseudonym limit!")
        }

        // Otherwise, grab the Pseudonym Form data from request content.
        let pseudForm = try req.content.decode(Pseudonym.PseudonymForm.self)

        // And begin a transaction to create a new Pseudonym, then save its ID to the
        // account. When complete, return the newly-created Pseudonym
        return try await req.db.transaction { database -> Pseudonym in
            let pseudId = UUID()
            let newPseud = Pseudonym(
                id: pseudId,
                for: account.id.unsafelyUnwrapped,
                with: pseudForm,
                roles: account.roles
            )
            try await newPseud.save(on: database)

            account.pseudonyms.append(pseudId.uuidString)
            try await account.save(on: database)

            return newPseud
        }
    }

    private func changeEmail(req: Request) async throws -> HTTPResponseStatus {
        let account = try retrieveAccount(from: req)

        let emailForm = try req.content.decode(Account.ChangeEmail.self)

        if try! Argon2Swift.verifyHashString(password: emailForm.password, hash: account.password, type: .id) {
            account.email = emailForm.email
            try await account.save(on: req.db)
            return .ok
        } else {
            throw Abort(.unauthorized, reason: "You don't have permission to do that.")
        }
    }

    private func changePassword(req: Request) async throws -> HTTPResponseStatus {
        let account = try retrieveAccount(from: req)

        let pwForm = try req.content.decode(Account.ChangePassword.self)

        if try! Argon2Swift.verifyHashString(password: pwForm.oldPassword, hash: account.password, type: .id) {
            let newHash = try! Argon2Swift.hashPasswordString(password: pwForm.newPassword, salt: Salt.newSalt(), type: .id)
            account.password = newHash.encodedString()
            try await account.save(on: req.db)
            return .ok
        } else {
            throw Abort(.unauthorized, reason: "You don't have permission to do that.")
        }
    }

    private func changeUserTag(req: Request) async throws -> Pseudonym {
        let pseudonym = try retrievePseudonym(from: req)

        let tagForm = try req.content.decode(Pseudonym.ChangeUserTag.self)

        pseudonym.userTag = tagForm.newUserTag
        try await pseudonym.save(on: req.db)

        return pseudonym
    }

    private func changeScreenName(req: Request) async throws -> Pseudonym {
        let pseudonym = try retrievePseudonym(from: req)

        let nameForm = try req.content.decode(Pseudonym.ChangeScreenName.self)

        pseudonym.screenName = nameForm.newScreenName
        try await pseudonym.save(on: req.db)

        return pseudonym
    }

    private func changeTagline(req: Request) async throws -> Pseudonym {
        let pseudonym = try retrievePseudonym(from: req)

        let taglineForm = try req.content.decode(Pseudonym.ChangeTagline.self)

        pseudonym.screenName = taglineForm.newTagline
        try await pseudonym.save(on: req.db)

        return pseudonym
    }

    private func retrieveAccount(from request: Request) throws -> Account {
        guard let account = request.userInfo?.user else {
            throw Abort(.unauthorized)
        }

        return account
    }

    private func retrievePseudonym(from request: Request) throws -> Pseudonym {
        guard let pseudonym = request.userInfo?.pseudonym else {
            throw Abort(.unauthorized)
        }

        return pseudonym
    }
}