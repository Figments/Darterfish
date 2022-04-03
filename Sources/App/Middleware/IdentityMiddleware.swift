import Vapor
import Fluent
import JWT

struct IdentityMiddleware: AsyncMiddleware {
    var requiredRoles: Set<Roles>

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.jwt.verify(as: TokenPayload.self)
        let unauthReason = "You're not allowed to access this function."

        // Check to see if a query parameter with the `pseudID` is provided, otherwise
        // throw an error
        guard let pseudId: String = request.query["pseudId"] else {
            throw Abort(.badRequest, reason: "You must include the pseudonym ID in your request.")
        }

        // Try to find an account tied to the incoming token. If none is found, throw an error
        guard let account = try await Account.find(payload.accountId, on: request.db) else {
            throw Abort(.unauthorized, reason: unauthReason)
        }

        // Determine if the account contains the provided `pseudID`. If it does, move on.
        // If not, throw an error.
        if !account.pseudonyms.contains(pseudId) {
            throw Abort(.unauthorized, reason: unauthReason)
        }

        // Grab the related pseudonym from the provided ID
        guard let pseudonym = try await Pseudonym.find(pseudId, on: request.db) else {
            throw Abort(.notFound, reason: "No such pseudonym exists. Check to make sure the ID provided is correct.")
        }

        // Check to see if there are any of the required roles among the account's roles.
        // Performs an ad-hoc conversion from the account's Roles array to a Swift Set
        // to allow use of the intersection function.
        let intersection = requiredRoles.intersection(Set(account.roles))

        // If there's nothing in common, throw an error
        if intersection.count == 0 {
            throw Abort(.unauthorized, reason: unauthReason)
        }

        // Otherwise, attach the user's account to the Request object
        request.userInfo = .init(user: account, pseudonym: pseudonym)

        return try await next.respond(to: request)
    }

    init(needs requiredRoles: [Roles]) {
        self.requiredRoles = Set(requiredRoles)
    }
}