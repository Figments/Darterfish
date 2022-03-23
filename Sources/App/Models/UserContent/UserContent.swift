import Vapor
import Fluent

final class UserContent: Model, Content {
    static let schema = "content"

    @ID(key: .id)
    var id: UUID?


}
