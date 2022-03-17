import Vapor

struct UserInfo {
    var user: Account
    var pseudonym: Pseudonym?
}

struct UserInfoKey: StorageKey {
    typealias Value = UserInfo
}

extension Request {
    var userInfo: UserInfo? {
        get {
            self.storage[UserInfoKey.self]
        }
        set {
            self.storage[UserInfoKey.self] = newValue
        }
    }
}
