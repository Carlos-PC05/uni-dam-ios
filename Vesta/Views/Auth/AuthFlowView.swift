import SwiftUI

struct AuthFlowView: View {
    @Environment(AppModel.self) private var model
    @State private var registering = false
    @State private var password = ""
    @State private var confirmation = ""

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Vesta")
                    .font(.headline)
                    .foregroundStyle(VestaTheme.mint)
                Text(registering ? "Crea tu cuenta" : "Bienvenido")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(VestaTheme.cream)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 28)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(registering ? "Empieza a organizar tus finanzas." : "Tus finanzas, en un mismo lugar.")
                        .font(.body)
                        .foregroundStyle(VestaTheme.ink)

                    if registering {
                        VestaAuthField(
                            label: "Nombre completo",
                            text: $model.fullName,
                            error: model.fieldErrors[.name],
                            textContentType: .name,
                            capitalization: .words
                        )
                    }

                    VestaAuthField(
                        label: "Correo electrónico",
                        text: $model.email,
                        error: model.fieldErrors[.email],
                        keyboard: .emailAddress,
                        textContentType: .emailAddress
                    )

                    VestaAuthField(
                        label: "Contraseña",
                        text: $password,
                        error: model.fieldErrors[.password],
                        textContentType: registering ? .newPassword : .password,
                        isSecure: true
                    )

                    if registering {
                        Text("Mínimo 12 caracteres: letras, números y un símbolo de -_?#@.")
                            .font(.footnote)
                            .foregroundStyle(VestaTheme.ink.opacity(0.8))

                        VestaAuthField(
                            label: "Confirmar contraseña",
                            text: $confirmation,
                            error: model.fieldErrors[.confirmation],
                            textContentType: .newPassword,
                            isSecure: true
                        )
                    }

                    if !registering {
                        Button("Recuperar contraseña") {
                            model.sendPasswordReset()
                        }
                        .font(.subheadline)
                        .foregroundStyle(VestaTheme.forest)
                    }

                    if let recoveryMessage = model.recoveryMessage {
                        Text(recoveryMessage)
                            .font(.footnote)
                            .foregroundStyle(VestaTheme.forest)
                    }

                    if let message = model.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(VestaTheme.error)
                    }

                    Button {
                        if registering {
                            model.register(password: password, confirmation: confirmation)
                        } else {
                            model.signIn(password: password)
                        }
                    } label: {
                        Text(registering ? "Crear cuenta" : "Iniciar sesión")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                    }
                    .buttonStyle(VestaPrimaryButtonStyle())

                    Button(registering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate") {
                        model.clearErrors()
                        password = ""
                        confirmation = ""
                        withAnimation(.easeInOut(duration: 0.2)) {
                            registering.toggle()
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(VestaTheme.forest)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .padding(28)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                    .fill(VestaTheme.mint)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(VestaTheme.forest.ignoresSafeArea())
    }
}
