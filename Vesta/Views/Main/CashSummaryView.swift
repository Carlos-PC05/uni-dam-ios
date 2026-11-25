import SwiftUI

struct CashSummaryView: View {
    @Bindable var finance: FinanceStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Efectivo")
                .font(.title3.bold())
                .foregroundStyle(VestaTheme.ink)

            Text(Money.euros(finance.cashTotalCents ?? 0))
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(VestaTheme.ink)

            MonthSelector(finance: finance)

            VStack(alignment: .leading, spacing: 6) {
                Text("Ingresos: \(Money.euros(finance.selectedFlow.income))")
                Text("Gastos: \(Money.euros(finance.selectedFlow.expenses))")
                Text("Flujo de caja: \(Money.signedEuros(finance.selectedFlow.net))")
            }
            .font(.subheadline)
            .foregroundStyle(VestaTheme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(VestaTheme.mint.opacity(0.45))
        )
    }
}
