import Foundation
import Testing
@testable import Vesta

struct AccountStoreTests {
    @MainActor
    private func makeStore() -> (AccountStore, URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("VestaAccounts-\(UUID().uuidString)", isDirectory: true)
        return (AccountStore(directory: directory), directory)
    }

    @Test @MainActor
    func createsAndAuthenticatesAnAccount() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let account = try store.create(
            fullName: "  Carlos Parra  ",
            email: " Carlos@Example.com ",
            password: "VestaSegura#2024"
        )
        #expect(account.fullName == "Carlos Parra")
        #expect(account.email == "carlos@example.com")
        #expect(account.passwordHash != "VestaSegura#2024")

        #expect(store.authenticate(email: "carlos@example.com", password: "VestaSegura#2024") != nil)
        #expect(store.authenticate(email: "carlos@example.com", password: "incorrecta") == nil)
    }

    @Test @MainActor
    func rejectsDuplicateEmailIgnoringCase() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        _ = try store.create(fullName: "Carlos", email: "carlos@example.com", password: "VestaSegura#2024")
        #expect(throws: AccountStoreError.duplicateEmail) {
            try store.create(fullName: "Otra", email: "CARLOS@example.com", password: "OtraClave#2024")
        }
    }

    @Test @MainActor
    func persistsAccountsAndUpdatesName() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let account = try store.create(fullName: "Carlos", email: "carlos@example.com", password: "VestaSegura#2024")
        let updated = try store.updateName(id: account.id, fullName: "Carlos Parra")
        #expect(updated.fullName == "Carlos Parra")

        let reloaded = AccountStore(directory: directory)
        #expect(reloaded.account(id: account.id)?.fullName == "Carlos Parra")
    }
}
