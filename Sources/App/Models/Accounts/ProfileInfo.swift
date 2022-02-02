struct Profile: Codable {
    var avatar: String
    var bio: String
    var tagline: String
    var coverPic: String
    var pronouns: [Pronouns]
}