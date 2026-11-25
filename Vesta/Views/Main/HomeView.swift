import SwiftUI

struct HomeView: View {
    let profile: UserProfile
    @Bindable var finance: FinanceStore

    @State private var amount = ""
    @State private var date = CalendarDay.today.formatted

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hola, \(profile.fullName)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(VestaTheme.ink)

                if let balance = finance.initialBalance {
                    CashSummaryView(finance: finance)
                    Text("Saldo inicial al comienzo del \(balance.day.formatted)")
                        .font(.footnote)
                        .foregroundStyle(VestaTheme.ink.opacity(0.7))
                } else if finance.loaded {
                    initialBalanceForm
                } else if let loadError = finance.loadError {
                    Text(loadError)
                        .font(.footnote)
                        .foregroundStyle(VestaTheme.error)
                    Button("Reintentar") {
                        finance.reload()
                    }
                    .buttonStyle(.bordered)
                } else {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(VestaTheme.forest)
                        Text("Consultando el saldo…")
                    }
                }

                if let saveError = finance.saveError {
                    Text(saveError)
                        .font(.footnote)
                        .foregroundStyle(VestaTheme.error)
                }

                NavigationLink {
                    ProfileView(profile: profile)
                } label: {
                    Text("Ver mi perfil")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.bordered)
                .tint(VestaTheme.forest)
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(VestaTheme.cream)
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VestaTheme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var initialBalanceForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configura tu saldo inicial")
                .font(.title3.bold())
                .foregroundStyle(VestaTheme.ink)

            Text("Indica cuánto efectivo tenías al comienzo del día elegido, antes de registrar operaciones.")
                .font(.subheadline)
                .foregroundStyle(VestaTheme.ink.opacity(0.8))

            VestaFormField(
                label: "Importe (€)",
                text: $amount,
                error: finance.amountError,
                keyboard: .decimalPad,
                footnote: "Admite cero y cantidades negativas."
            )

            VestaFormField(
                label: "Fecha inicial",
                text: $date,
                error: finance.dateError,
                keyboard: .numbersAndPunctuation,
                footnote: "DD/MM/AAAA"
            )

            Button {
                if finance.saveInitialBalance(amount: amount, date: date) {
                    amount = ""
                    date = CalendarDay.today.formatted
                }
            } label: {
                Text("Guardar saldo inicial")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .buttonStyle(VestaPrimaryButtonStyle())
        }
    }
}
