import SwiftUI

struct MonthSelector: View {
    @Bindable var finance: FinanceStore

    var body: some View {
        HStack {
            Button {
                finance.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.bold())
                    .frame(width: 40, height: 36)
            }
            .disabled(!finance.canGoPrevious)
            .accessibilityLabel("Mes anterior")

            Spacer()

            Text(finance.selectedMonth.displayName.capitalized)
                .font(.subheadline.bold())
                .foregroundStyle(VestaTheme.ink)

            Spacer()

            Button {
                finance.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .frame(width: 40, height: 36)
            }
            .disabled(!finance.canGoNext)
            .accessibilityLabel("Mes siguiente")
        }
        .buttonStyle(.plain)
        .foregroundStyle(VestaTheme.forest)
    }
}
