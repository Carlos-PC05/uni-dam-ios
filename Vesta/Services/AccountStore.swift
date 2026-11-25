import CryptoKit
import Foundation

struct StoredAccount: Codable, Equatable, Sendable {
    let id: String
    var fullName: String
    let email: String
    let salt: String
    let passwordHash: String
}

enum AccountStoreError: Error, Equatable {
    case duplicateEmail
    case invalidAccount
    case persistence
}

/// Cuentas locales de la réplica. La contraseña se guarda como SHA-256 con sal,
/// nunca en claro; no sustituye a un proveedor de autenticación real.
@MainActor
final class AccountStore {
    private(set) var accounts: [StoredAccount] = []
    private let fileURL: URL
    private let fileManager: FileManager

    init(directory: URL, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.fileURL = directory.appendingPathComponent("accounts.json")
        load()
    }

    convenience init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = base.appendingPathComponent("Vesta", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.init(directory: directory)
    }

    func account(withEmail email: String) -> StoredAccount? {
        let normalized = Self.normalize(email)
        return accounts.first { Self.normalize($0.email) == normalized }
    }

    func account(id: String) -> StoredAccount? {
        accounts.first { $0.id == id }
    }

    @discardableResult
    func create(fullName: String, email: String, password: String) throws -> StoredAccount {
        let normalizedEmail = Self.normalize(email)
        guard account(withEmail: normalizedEmail) == nil else {
            throw AccountStoreError.duplicateEmail
        }
        let salt = UUID().uuidString
        let account = StoredAccount(
            id: UUID().uuidString,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: normalizedEmail,
            salt: salt,
            passwordHash: Self.hash(password: password, salt: salt)
        )
        var updated = accounts
        updated.append(account)
        try persist(updated)
        accounts = updated
        return account
    }

    func authenticate(email: String, password: String) -> StoredAccount? {
        guard let account = account(withEmail: email) else { return nil }
        return account.passwordHash == Self.hash(password: password, salt: account.salt) ? account : nil
    }

    @discardableResult
    func updateName(id: String, fullName: String) throws -> StoredAccount {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else {
            throw AccountStoreError.invalidAccount
        }
        var updated = accounts
        updated[index].fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        try persist(updated)
        accounts = updated
        return updated[index]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        accounts = (try? JSONDecoder().decode([StoredAccount].self, from: data)) ?? []
    }

    private func persist(_ accounts: [StoredAccount]) throws {
        do {
            let data = try JSONEncoder().encode(accounts)
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw AccountStoreError.persistence
        }
    }

    private static func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func hash(password: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
