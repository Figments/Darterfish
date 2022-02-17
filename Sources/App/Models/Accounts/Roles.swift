import Vapor

enum Roles: String, Codable, Content {
    static let allRoles: [Roles] = [
        .admin,
        .moderator,
        .workApprover,
        .chatModerator,
        .maintainer,
        .contributor,
        .vip,
        .supporter,
        .user
    ]
    case admin = "Admin"
    case moderator = "Moderator"
    case workApprover = "Work Approver"
    case chatModerator = "Chat Moderator"
    case maintainer = "Maintainer"
    case contributor = "Contributor"
    case vip = "VIP"
    case supporter = "Supporter"
    case user = "User"
}