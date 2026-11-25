import SwiftUI

struct CompleteProfileView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Vesta")
                    .font(.headline)
                    .foregroundStyle(VestaTheme.mint)
                Text("Completa tu perfil")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(VestaTheme.cream)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 28)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tu cuenta ya existe. Confirma tu nombre para terminar el registro.")
                        .foregroundStyle(VestaTheme.ink)

                    VestaAuthField(
                        label: "Nombre completo",
                        text: $model.fullName,
                        error: model.fieldErrors[.name],
                        textContentType: .name,
                        capitalization: .words
                    )

                    if let message = model.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(VestaTheme.error)
                    }

                    Button {
                        model.completeProfile()
                    } label: {
                        Text("Guardar perfil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                    }
                    .buttonStyle(VestaPrimaryButtonStyle())

                    Button("Volver al acceso") {
                        model.signOut()
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
