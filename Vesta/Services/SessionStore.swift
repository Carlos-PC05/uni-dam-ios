import Foundation

/// Conserva el identificador de la cuenta que mantiene la sesión entre aperturas.
@MainActor
final class SessionStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "vesta.currentUserID") {
        self.defaults = defaults
        self.key = key
    }

    var currentUserID: String? {
        get { defaults.string(forKey: key) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    func clear() {
        currentUserID = nil
    }
}
