import Vapor
import Fluent

final class UserContent: Model, Content {
    static let schema = "content"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "author")
    var author: Pseudonym

    @Field(key: "title")
    var title: String

    @Field(key: "desc")
    var desc: String

    @Field(key: "body")
    var body: String

    @Field(key: "sections")
    var sections: [String]?

    @Field(key: "meta")
    var meta: Meta

    @Field(key: "stats")
    var stats: Stats

    @Field(key: "audit")
    var audit: Audit

    @Field(key: "kind")
    var kind: Kind

    @Field(key: "tags")
    var tags: [String]?

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, for pseudId: Pseudonym.IDValue, formData: UserContentForm) {
        self.id = id
        self.$author.id = pseudId
        title = formData.title
        desc = formData.desc
        body = formData.body
        sections = nil
        meta = .init(with: formData)
        stats = .init()
        audit = .init()
        kind = formData.kind
        tags = nil
    }
}

extension UserContent {
    struct Stats: Codable {
        var likes: Int
        var dislikes: Int
        var views: Int
        var comments: Int

        init() {
            likes = 0
            dislikes = 0
            views = 0
            comments = 0
        }
    }

    struct Meta: Codable {
        var rating: Rating
        var warnings: [String]?
        var banner: String?
        var category: Category?
        var genres: [Genres]?
        var form: Forms?
        var status: Status?
        var coverArt: String?

        init(with formInfo: UserContentForm) {
            rating = formInfo.rating
            warnings = nil
            banner = nil
            category = formInfo.category
            genres = formInfo.genres
            form = formInfo.form
            status = formInfo.status
            coverArt = nil
        }
    }

    struct Audit: Codable {
        var published: PublishStatus
        var publishedOn: Date?
        var hasComments: Bool
        var releaseOn: Date?
        var isNewsPost: Bool
        var isFeatured: Bool

        init() {
            published = .unpublished
            publishedOn = nil
            hasComments = true
            releaseOn = nil
            isNewsPost = false
            isFeatured = false
        }
    }

    struct UserContentForm: Content {
        var title: String
        var desc: String
        var body: String
        var category: Category?
        var genres: [Genres]?
        var form: Forms?
        var tags: [String]?
        var rating: Rating
        var status: Status?
        var kind: Kind
    }

    enum Kind: String, Codable {
        case prose = "ProseContent"
        case poetry = "PoetryContent"
        case blog = "BlogContent"
    }

    enum Rating: String, Codable {
        case everyone = "Everyone"
        case teen = "Teen"
        case mature = "Mature"
        case explicit = "Explicit"
    }

    enum Category: String, Codable {
        case original = "Original"
        case fanwork = "Fanwork"
    }

    enum Genres: String, Codable {
        case actionAdventure = "Action/Adventure"
        case drama = "Drama"
        case sliceOfLife = "Slice of Life"
        case comedy = "Comedy"
        case romance = "Romance"
        case scienceFiction = "Science Fiction"
        case speculativeFiction = "Speculative Fiction"
        case fantasy = "Fantasy"
        case horror = "Horror"
        case thriller = "Thriller"
        case mystery = "Mystery"
        case erotica = "Erotica"
        case tragedy = "Tragedy"
    }

    enum Forms: String, Codable {
        case limerick = "Limerick"
        case haiku = "Haiku"
        case sonnet = "Sonnet"
        case ballad = "Ballad"
        case ode = "Ode"
        case freeVerse = "Free Verse"
        case fixedVerse = "Fixed Verse"
    }

    enum Status: String, Codable {
        case incomplete = "Incomplete"
        case complete = "Complete"
        case hiatus = "Hiatus"
        case cancelled = "Cancelled"
    }

    enum PublishStatus: String, Codable {
        case published = "Published"
        case unpublished = "Unpublished"
        case pending = "Pending"
        case rejected = "Rejected"
        case approvedUnpublished = "ApprovedUnpublished"
    }
}
