import SwiftUI

struct ProfileView: View {
    let profile: UserProfile
    @Environment(AppModel.self) private var model
    @State private var confirmingSignOut = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Mi perfil")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(VestaTheme.ink)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Nombre completo")
                        .font(.caption.bold())
                        .foregroundStyle(VestaTheme.ink.opacity(0.6))
                    Text(profile.fullName)
                        .font(.title3)
                        .foregroundStyle(VestaTheme.ink)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Correo electrónico")
                        .font(.caption.bold())
                        .foregroundStyle(VestaTheme.ink.opacity(0.6))
                    Text(profile.email)
                        .foregroundStyle(VestaTheme.ink)
                }

                Button(role: .destructive) {
                    confirmingSignOut = true
                } label: {
                    Text("Cerrar sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                }
                .buttonStyle(.bordered)
                .tint(VestaTheme.forest)

                Text("Los datos de esta réplica se guardan localmente en el dispositivo.")
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.ink.opacity(0.65))
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(VestaTheme.cream)
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VestaTheme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .confirmationDialog("¿Cerrar sesión?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                model.signOut()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }
}
