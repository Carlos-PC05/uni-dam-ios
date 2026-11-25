import Foundation
import Observation

enum AccessStatus: Equatable {
    case checking
    case signedOut
    case incomplete
    case ready
}

/// Raíz de la sesión: decide entre acceso, perfil incompleto y navegación privada.
@MainActor
@Observable
final class AppModel {
    private(set) var access: AccessStatus = .checking
    private(set) var profile: UserProfile?
    private(set) var finance: FinanceStore?
    private(set) var message: String?
    private(set) var recoveryMessage: String?
    private(set) var fieldErrors: [AuthField: String] = [:]

    var fullName = ""
    var email = ""

    private let accounts: AccountStore
    private let session: SessionStore
    private let dataStore: UserDataStore
    private var currentAccount: StoredAccount?

    init(accounts: AccountStore? = nil, session: SessionStore? = nil, dataStore: UserDataStore? = nil) {
        self.accounts = accounts ?? AccountStore()
        self.session = session ?? SessionStore()
        self.dataStore = dataStore ?? UserDataStore()
        restoreSession()
        #if DEBUG
        seedDemoDataIfRequested()
        #endif
    }

    func restoreSession() {
        guard let userID = session.currentUserID, let account = accounts.account(id: userID) else {
            session.clear()
            profile = nil
            finance = nil
            currentAccount = nil
            access = .signedOut
            return
        }
        currentAccount = account
        fullName = account.fullName
        email = account.email
        if account.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            access = .incomplete
            profile = nil
            finance = nil
            return
        }
        open(account: account)
    }

    func updateName(_ value: String) {
        fullName = value
        fieldErrors[.name] = nil
    }

    func updateEmail(_ value: String) {
        email = value
        fieldErrors[.email] = nil
        recoveryMessage = nil
    }

    func clearErrors() {
        fieldErrors = [:]
        message = nil
        recoveryMessage = nil
    }

    func register(password: String, confirmation: String) {
        clearErrors()
        let errors = AuthValidation.validateRegistration(
            name: fullName,
            email: email,
            password: password,
            confirmation: confirmation
        )
        guard errors.isEmpty else {
            fieldErrors = errors
            return
        }
        do {
            let account = try accounts.create(fullName: fullName, email: email, password: password)
            currentAccount = account
            session.currentUserID = account.id
            open(account: account)
        } catch AccountStoreError.duplicateEmail {
            fieldErrors[.email] = "Ese correo ya está registrado. Inicia sesión con tu cuenta."
        } catch {
            message = "No se ha podido crear la cuenta. Reintenta."
        }
    }

    func signIn(password: String) {
        clearErrors()
        let errors = AuthValidation.validateLogin(email: email, password: password)
        guard errors.isEmpty else {
            fieldErrors = errors
            return
        }
        guard let account = accounts.authenticate(email: email, password: password) else {
            message = "No se ha podido autenticar la cuenta. Comprueba el correo y la contraseña."
            return
        }
        currentAccount = account
        session.currentUserID = account.id
        open(account: account)
    }

    /// La réplica no envía correos reales; mantiene la misma respuesta genérica
    /// que la aplicación Android para no revelar si una cuenta existe.
    func sendPasswordReset() {
        clearErrors()
        if let error = AuthValidation.emailError(email) {
            fieldErrors[.email] = error
            return
        }
        recoveryMessage = "Si hay una cuenta con ese correo, recibirás un enlace para restablecer la contraseña."
    }

    func completeProfile() {
        clearErrors()
        guard let account = currentAccount else {
            access = .signedOut
            return
        }
        if let error = AuthValidation.nameError(fullName) {
            fieldErrors[.name] = error
            return
        }
        do {
            let updated = try accounts.updateName(id: account.id, fullName: fullName)
            currentAccount = updated
            open(account: updated)
        } catch {
            message = "No se ha podido guardar el perfil. Reintenta."
        }
    }

    func signOut() {
        session.clear()
        currentAccount = nil
        profile = nil
        finance = nil
        fullName = ""
        email = ""
        clearErrors()
        access = .signedOut
    }

    private func open(account: StoredAccount) {
        profile = UserProfile(id: account.id, fullName: account.fullName, email: account.email)
        finance = FinanceStore(userID: account.id, store: dataStore)
        message = nil
        recoveryMessage = nil
        fieldErrors = [:]
        access = .ready
    }

    #if DEBUG
    /// Permite generar capturas y demos reproducibles sin introducir datos a mano.
    /// Solo se activa con `VESTA_DEMO=1` en compilaciones Debug.
    private func seedDemoDataIfRequested() {
        guard ProcessInfo.processInfo.environment["VESTA_DEMO"] == "1" else { return }

        let demoEmail = "carlos@example.com"
        let account: StoredAccount
        if let existing = accounts.account(withEmail: demoEmail) {
            account = existing
        } else if let created = try? accounts.create(
            fullName: "Carlos Parra",
            email: demoEmail,
            password: "VestaSegura#2024"
        ) {
            account = created
        } else {
            return
        }

        if let stored = try? dataStore.load(userID: account.id), stored.initialBalance == nil {
            let today = CalendarDay.today
            let start = CalendarDay(year: today.year, month: today.month, day: 1)
            let second = CalendarDay(epochDay: min(start.epochDay + 6, today.epochDay))
            let third = CalendarDay(epochDay: min(start.epochDay + 12, today.epochDay))
            let data = UserData(
                initialBalance: InitialBalance(cents: 84_000, day: start),
                movements: [
                    Movement(id: "demo-nomina", cents: 235_000, day: start, category: .income, note: "Nómina"),
                    Movement(id: "demo-alquiler", cents: 72_000, day: second, category: .housing, note: "Alquiler"),
                    Movement(id: "demo-compra", cents: 6_450, day: third, category: .food, note: "Compra semanal"),
                    Movement(id: "demo-transporte", cents: 2_100, day: third, category: .transport, note: "Abono transporte"),
                ]
            )
            try? dataStore.save(data, userID: account.id)
        }

        session.currentUserID = account.id
        currentAccount = account
        open(account: account)
    }
    #endif
}
