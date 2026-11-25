import Foundation
import Observation

/// Estado del saldo y de los movimientos de la cuenta activa.
/// Las operaciones son locales e inmediatas; la interfaz mantiene los mismos
/// estados de error y validación que la versión Android.
@MainActor
@Observable
final class FinanceStore {
    let userID: String
    private let store: UserDataStore

    private(set) var initialBalance: InitialBalance?
    private(set) var movements: [Movement] = []
    private(set) var loaded = false
    var selectedMonth: YearMonth = .current

    var loadError: String?
    var saveError: String?
    var amountError: String?
    var dateError: String?
    var noteError: String?

    init(userID: String, store: UserDataStore) {
        self.userID = userID
        self.store = store
        reload()
    }

    var cashTotalCents: Int64? {
        guard let initialBalance else { return nil }
        return initialBalance.cents + movements.cashFlow().net
    }

    var visibleMovements: [Movement] {
        movements
            .filter { $0.day.yearMonth == selectedMonth }
            .sorted { $0.day > $1.day }
    }

    var selectedFlow: CashFlow {
        movements.cashFlow(in: selectedMonth)
    }

    var canGoPrevious: Bool {
        guard let initialBalance else { return false }
        return selectedMonth > initialBalance.day.yearMonth
    }

    var canGoNext: Bool {
        selectedMonth < .current
    }

    func reload() {
        do {
            let data = try store.load(userID: userID)
            initialBalance = data.initialBalance
            movements = data.movements
            loaded = true
            loadError = nil
            if let balance = data.initialBalance, selectedMonth < balance.day.yearMonth {
                selectedMonth = balance.day.yearMonth
            }
        } catch {
            loaded = false
            loadError = "No se han podido consultar los movimientos."
        }
    }

    func previousMonth() {
        guard canGoPrevious else { return }
        selectedMonth = selectedMonth.adding(months: -1)
    }

    func nextMonth() {
        guard canGoNext else { return }
        selectedMonth = selectedMonth.adding(months: 1)
    }

    /// Devuelve `true` solo cuando el saldo queda persistido. Mantiene el formulario si falla.
    @discardableResult
    func saveInitialBalance(amount: String, date: String) -> Bool {
        guard initialBalance == nil else { return true }
        clearErrors()

        let cents = Money.parseCents(amount)
        let day = CalendarDay.parse(date)
        if cents == nil {
            amountError = "Introduce un importe válido con hasta dos decimales."
        }
        if day == nil || (day.map { $0 > CalendarDay.today } ?? true) {
            dateError = "Introduce una fecha válida que no sea posterior a hoy."
        }
        guard let cents, let day, day <= .today else { return false }

        let balance = InitialBalance(cents: cents, day: day)
        let updated = UserData(initialBalance: balance, movements: movements)
        do {
            try store.save(updated, userID: userID)
        } catch {
            saveError = "No se ha podido confirmar el saldo. Puedes reintentar el guardado."
            return false
        }
        initialBalance = balance
        selectedMonth = day.yearMonth
        loaded = true
        return true
    }

    /// Valida y persiste un movimiento positivo entre la fecha del saldo y hoy.
    @discardableResult
    func addMovement(amount: String, date: String, category: MovementCategory, note: String) -> Bool {
        guard let initialBalance else {
            saveError = "Configura el saldo inicial en Inicio para registrar movimientos."
            return false
        }
        clearErrors()

        let cents = Money.parseCents(amount)
        let day = CalendarDay.parse(date)
        if cents == nil || (cents ?? 0) <= 0 {
            amountError = "Introduce un importe positivo con hasta dos decimales."
        }
        if day == nil || (day.map { $0 < initialBalance.day || $0 > CalendarDay.today } ?? true) {
            dateError = "Introduce una fecha entre el saldo inicial y hoy."
        }
        if note.count > 500 {
            noteError = "La nota admite hasta 500 caracteres."
        }
        guard let cents, cents > 0,
              let day, day >= initialBalance.day, day <= .today,
              note.count <= 500 else {
            return false
        }

        let movement = Movement(
            id: UUID().uuidString,
            cents: cents,
            day: day,
            category: category,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        var updated = UserData(initialBalance: initialBalance, movements: movements)
        updated.movements.append(movement)
        do {
            try store.save(updated, userID: userID)
        } catch {
            saveError = "No se ha podido confirmar el movimiento. Puedes reintentar."
            return false
        }
        movements = updated.movements
        selectedMonth = day.yearMonth
        return true
    }

    func clearErrors() {
        saveError = nil
        amountError = nil
        dateError = nil
        noteError = nil
    }
}
