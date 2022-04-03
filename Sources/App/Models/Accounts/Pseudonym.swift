import Fluent
import Vapor

final class Pseudonym: Model, Content {
    static let schema = "pseudonyms"

    @ID(custom: "_id")
    var id: String?

    @Parent(key: "accountId")
    var account: Account

    @Field(key: "userTag")
    var userTag: String

    @Field(key: "screenName")
    var screenName: String

    @Field(key: "profile")
    var profile: ProfileInfo

    @Field(key: "stats")
    var stats: ProfileStats

    @Field(key: "roles")
    var roles: [Roles]

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: String? = nil, for accountId: Account.IDValue, with formData: Pseudonym.PseudonymForm, roles: [Roles]) {
        self.id = id
        self.$account.id = accountId
        userTag = formData.userTag
        screenName = formData.screenName
        profile = .init()
        stats = .init()
        self.roles = roles
    }
}

extension Pseudonym {
    struct ProfileStats: Codable {
        var works: Int
        var blogs: Int
        var followers: Int
        var following: Int

        init() {
            works = 0
            blogs = 0
            followers = 0
            following = 0
        }
    }

    struct ProfileInfo: Codable {
        var avatar: String
        var bio: String?
        var tagline: String?
        var coverPic: String?
        var pronouns: [Pronouns]?
        var presence: Presence

        init() {
            avatar = "https://images.offprint.net/avatars/avatar.png"
            bio = nil
            tagline = nil
            coverPic = nil
            pronouns = nil
            presence = .offline
        }
    }

    struct PseudonymForm: Content {
        var userTag: String
        var screenName: String
    }

    struct ChangeScreenName: Content {
        var newScreenName: String
    }

    struct ChangeUserTag: Content {
        var newUserTag: String
    }

    struct ChangeTagline: Content {
        var newTagline: String
    }

    enum Presence: String, Codable {
        case online = "Online"
        case offline = "Offline"
        case away = "Away"
        case doNotDisturb = "Do Not Disturb"
    }

    enum Pronouns: String, Codable {
        case sheHer = "She/Her"
        case heHim = "He/Him"
        case theyThem = "They/Them"
        case zeZir = "Ze/Zir"
        case anyAll = "Any/All"
    }
}