import Vapor

struct RolesMiddleware: AsyncMiddleware {
    var requiredRoles: [Roles]

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.jwt.verify(as: TokenPayload.self)


        return try await next.respond(to: request)
    }

    init(needs requiredRoles: [Roles]) {
        self.requiredRoles = requiredRoles
    }
}