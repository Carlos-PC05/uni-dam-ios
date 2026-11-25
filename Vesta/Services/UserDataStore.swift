import Foundation

/// Datos privados de una cuenta, equivalentes a los documentos de Firestore del proyecto Android.
struct UserData: Codable, Equatable, Sendable {
    var initialBalance: InitialBalance?
    var movements: [Movement]

    static let empty = UserData(initialBalance: nil, movements: [])
}

/// Persistencia local en JSON. Cada cuenta tiene su propio archivo y nunca comparte datos.
@MainActor
final class UserDataStore {
    private let directory: URL
    private let fileManager: FileManager

    init(directory: URL, fileManager: FileManager = .default) {
        self.directory = directory
        self.fileManager = fileManager
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    convenience init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.init(directory: base.appendingPathComponent("Vesta/users", isDirectory: true))
    }

    func load(userID: String) throws -> UserData {
        let url = fileURL(for: userID)
        guard fileManager.fileExists(atPath: url.path) else { return .empty }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(UserData.self, from: data)
    }

    func save(_ data: UserData, userID: String) throws {
        let encoded = try JSONEncoder().encode(data)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try encoded.write(to: fileURL(for: userID), options: [.atomic])
    }

    private func fileURL(for userID: String) -> URL {
        directory.appendingPathComponent("\(userID).json")
    }
}
