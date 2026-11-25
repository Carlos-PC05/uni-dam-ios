import Foundation
import Testing
@testable import Vesta

struct FinanceStoreTests {
    @MainActor
    private func makeStore() -> (UserDataStore, URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("VestaTests-\(UUID().uuidString)", isDirectory: true)
        return (UserDataStore(directory: directory), directory)
    }

    @Test @MainActor
    func savesBalanceAndPersistsMovements() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let finance = FinanceStore(userID: "user-1", store: store)
        #expect(finance.loaded)
        #expect(finance.initialBalance == nil)

        let today = CalendarDay.today
        let balanceDay = CalendarDay(year: today.year, month: today.month, day: 1)
        #expect(finance.saveInitialBalance(amount: "100,00", date: balanceDay.formatted))
        #expect(finance.initialBalance?.cents == 10_000)

        #expect(finance.addMovement(amount: "25,50", date: today.formatted, category: .income, note: "Nómina"))
        #expect(finance.addMovement(amount: "10", date: today.formatted, category: .food, note: ""))
        #expect(finance.cashTotalCents == 11_550)
        #expect(finance.selectedFlow.income == 2_550)
        #expect(finance.selectedFlow.expenses == 1_000)
        #expect(finance.selectedFlow.net == 1_550)

        let reloaded = FinanceStore(userID: "user-1", store: store)
        #expect(reloaded.movements.count == 2)
        #expect(reloaded.cashTotalCents == 11_550)
    }

    @Test @MainActor
    func rejectsFutureBalanceAndInvalidMovementDates() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let finance = FinanceStore(userID: "user-2", store: store)
        let today = CalendarDay.today
        let tomorrow = CalendarDay(epochDay: today.epochDay + 1)
        #expect(!finance.saveInitialBalance(amount: "10", date: tomorrow.formatted))
        #expect(finance.dateError != nil)

        let balanceDay = CalendarDay(year: today.year, month: today.month, day: 1)
        #expect(finance.saveInitialBalance(amount: "100", date: balanceDay.formatted))
        let beforeBalance = CalendarDay(epochDay: balanceDay.epochDay - 1)
        #expect(!finance.addMovement(amount: "10", date: beforeBalance.formatted, category: .other, note: ""))
        #expect(finance.dateError != nil)
        #expect(!finance.addMovement(amount: "-5", date: today.formatted, category: .other, note: ""))
        #expect(finance.amountError != nil)
    }

    @Test @MainActor
    func rejectsAmountsWithTooManyDecimalsAndLongNotes() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        let finance = FinanceStore(userID: "user-3", store: store)
        let today = CalendarDay.today
        #expect(finance.saveInitialBalance(amount: "10,999", date: today.formatted) == false)
        #expect(finance.amountError != nil)

        #expect(finance.saveInitialBalance(amount: "10", date: today.formatted))
        let longNote = String(repeating: "a", count: 501)
        #expect(finance.addMovement(amount: "5", date: today.formatted, category: .other, note: longNote) == false)
        #expect(finance.noteError != nil)
    }
}
