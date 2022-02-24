import Vapor

enum Roles: String, Codable, Content {
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