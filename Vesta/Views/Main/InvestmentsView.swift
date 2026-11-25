import SwiftUI

struct InvestmentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Inversiones")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(VestaTheme.ink)
                Text("Pendiente de implementación. Esta sección se incorporará en su ticket correspondiente.")
                    .foregroundStyle(VestaTheme.ink.opacity(0.8))
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(VestaTheme.cream)
        .navigationTitle("Inversiones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VestaTheme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
