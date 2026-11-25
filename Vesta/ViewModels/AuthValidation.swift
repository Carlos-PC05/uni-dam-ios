import Foundation

enum AuthField: Hashable, Sendable {
    case name
    case email
    case password
    case confirmation
}

/// Validación local previa a la persistencia. La política replica la del ViewModel Android.
enum AuthValidation {
    static func emailError(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return trimmed.range(of: pattern, options: .regularExpression) == nil
            ? "Introduce un correo electrónico válido."
            : nil
    }

    static func nameError(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed.count > 100
            ? "El nombre debe tener entre 1 y 100 caracteres."
            : nil
    }

    static func passwordError(_ password: String) -> String? {
        let hasLetter = password.contains { $0.isLetter }
        let hasDigit = password.contains { $0.isNumber }
        let hasSymbol = password.contains { "-_?#@.".contains($0) }
        guard (12...4096).contains(password.count), hasLetter, hasDigit, hasSymbol else {
            return "Usa entre 12 y 4096 caracteres, con una letra, un número y un símbolo de -_?#@."
        }
        return nil
    }

    static func validateLogin(email: String, password: String) -> [AuthField: String] {
        var errors: [AuthField: String] = [:]
        if let error = emailError(email) { errors[.email] = error }
        if password.isEmpty { errors[.password] = "Introduce tu contraseña." }
        return errors
    }

    static func validateRegistration(
        name: String,
        email: String,
        password: String,
        confirmation: String
    ) -> [AuthField: String] {
        var errors = validateLogin(email: email, password: password)
        if let error = nameError(name) { errors[.name] = error }
        if let error = passwordError(password) { errors[.password] = error }
        if confirmation.isEmpty || confirmation != password {
            errors[.confirmation] = "Las contraseñas deben coincidir exactamente."
        }
        return errors
    }
}
