import Foundation

/// Perfil visible de la sesión. Nunca contiene contraseñas ni hashes.
struct UserProfile: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let fullName: String
    let email: String
}
