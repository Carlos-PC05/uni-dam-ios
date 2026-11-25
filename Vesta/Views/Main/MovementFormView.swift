import SwiftUI

struct MovementFormView: View {
    @Bindable var finance: FinanceStore
    @Environment(\.dismiss) private var dismiss

    @State private var amount = ""
    @State private var date = CalendarDay.today.formatted
    @State private var category: MovementCategory = .income
    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Registrar movimiento")
                    .font(.title3.bold())
                    .foregroundStyle(VestaTheme.ink)

                VestaFormField(
                    label: "Importe (€)",
                    text: $amount,
                    error: finance.amountError,
                    keyboard: .decimalPad,
                    footnote: "Introduce un importe positivo con hasta dos decimales."
                )

                VestaFormField(
                    label: "Fecha (DD/MM/AAAA)",
                    text: $date,
                    error: finance.dateError,
                    keyboard: .numbersAndPunctuation,
                    footnote: "Debe estar entre el saldo inicial y hoy."
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Categoría")
                        .font(.subheadline.bold())
                        .foregroundStyle(VestaTheme.ink)

                    Picker("Categoría", selection: $category) {
                        ForEach(MovementCategory.allCases) { category in
                            Text(category.label).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(VestaTheme.forest)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(VestaTheme.forest.opacity(0.25), lineWidth: 1)
                    )
                }

                VestaFormField(
                    label: "Nota (opcional)",
                    text: $note,
                    error: finance.noteError,
                    footnote: "Hasta 500 caracteres.",
                    axis: .vertical,
                    lineLimit: 3...5
                )

                if let saveError = finance.saveError {
                    Text(saveError)
                        .font(.footnote)
                        .foregroundStyle(VestaTheme.error)
                }

                Button {
                    if finance.addMovement(amount: amount, date: date, category: category, note: note) {
                        dismiss()
                    }
                } label: {
                    Text("Guardar movimiento")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                }
                .buttonStyle(VestaPrimaryButtonStyle())
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(VestaTheme.cream)
        .navigationTitle("Nuevo movimiento")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VestaTheme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
        .onAppear {
            finance.clearErrors()
        }
    }
}
