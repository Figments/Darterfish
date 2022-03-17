import Vapor
import Fluent

struct RolesMiddleware: AsyncMiddleware {
    var requiredRoles: Set<Roles>

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.jwt.verify(as: TokenPayload.self)
        let failReason = "You're not allowed to access this function."

        // Try to find an account tied to the incoming token. If none is found, throw an error
        guard let account = try await Account.find(payload.accountId, on: request.db) else {
            throw Abort(.unauthorized, reason: failReason)
        }

        // Check to see if there are any of the required roles among the account's roles.
        // Performs an ad-hoc conversion from the account's Roles array to a Swift Set
        // to allow use of the intersection function.
        let intersection = requiredRoles.intersection(Set(account.roles))

        // If there's nothing in common, throw an error
        if intersection.count == 0 {
            throw Abort(.unauthorized, reason: failReason)
        }

        request.userInfo = .init(user: account)

        // Otherwise, go to the next middleware
        return try await next.respond(to: request)
    }

    init(needs requiredRoles: [Roles]) {
        self.requiredRoles = Set(requiredRoles)
    }
}