import Vapor

enum Pronouns: String, Codable, Content {
    case sheHer = "She/Her"
    case heHim = "He/Him"
    case theyThem = "They/Them"
    case zeZir = "Ze/Zir"
    case anyAll = "Any/All"
}