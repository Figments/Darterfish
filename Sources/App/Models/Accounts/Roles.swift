enum Roles: String, Codable {
    case Admin = "Admin"
    case Moderator = "Moderator"
    case WorkApprover = "Work Approver"
    case ChatModerator = "Chat Moderator"
    case Maintainer = "Maintainer"
    case Contributor = "Contributor"
    case VIP = "VIP"
    case Supporter = "Supporter"
    case User = "User"
}