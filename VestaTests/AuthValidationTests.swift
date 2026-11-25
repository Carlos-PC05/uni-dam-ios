import Testing
@testable import Vesta

struct AuthValidationTests {
    @Test func acceptsValidRegistration() {
        let errors = AuthValidation.validateRegistration(
            name: "Carlos Parra",
            email: "carlos@example.com",
            password: "VestaSegura#2024",
            confirmation: "VestaSegura#2024"
        )
        #expect(errors.isEmpty)
    }

    @Test func rejectsInvalidEmailAndEmptyPassword() {
        let errors = AuthValidation.validateLogin(email: "sin-arroba", password: "")
        #expect(errors[.email] != nil)
        #expect(errors[.password] != nil)
    }

    @Test func loginDoesNotReapplyTheRegistrationPolicy() {
        // Una cuenta creada con otra política anterior debe poder iniciar sesión.
        #expect(AuthValidation.validateLogin(email: "carlos@example.com", password: "corta").isEmpty)
    }

    @Test func enforcesPasswordPolicy() {
        #expect(AuthValidation.passwordError("VestaSegura#2024") == nil)
        #expect(AuthValidation.passwordError("sinNumero#largo") != nil)
        #expect(AuthValidation.passwordError("SinSimbolo2024") != nil)
        #expect(AuthValidation.passwordError("Corta#1") != nil)
        #expect(AuthValidation.passwordError("Vesta Segura 2024") != nil)
    }

    @Test func requiresMatchingConfirmation() {
        let errors = AuthValidation.validateRegistration(
            name: "Carlos",
            email: "carlos@example.com",
            password: "VestaSegura#2024",
            confirmation: "OtraClave#2024"
        )
        #expect(errors[.confirmation] != nil)
    }

    @Test func validatesNameLength() {
        #expect(AuthValidation.nameError("   ") != nil)
        #expect(AuthValidation.nameError(String(repeating: "a", count: 101)) != nil)
        #expect(AuthValidation.nameError("Carlos") == nil)
    }
}
