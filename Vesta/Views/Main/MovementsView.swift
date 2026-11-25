import SwiftUI

struct MovementsView: View {
    @Bindable var finance: FinanceStore
    @State private var showingForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Movimientos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(VestaTheme.ink)

                if finance.loaded {
                    if finance.initialBalance != nil {
                        Button {
                            showingForm = true
                        } label: {
                            Text("Registrar movimiento")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50)
                        }
                        .buttonStyle(VestaPrimaryButtonStyle())

                        MonthSelector(finance: finance)

                        let visible = finance.visibleMovements
                        if visible.isEmpty {
                            Text("No hay movimientos en este mes.")
                                .font(.subheadline)
                                .foregroundStyle(VestaTheme.ink.opacity(0.7))
                                .padding(.vertical, 8)
                        } else {
                            ForEach(visible) { movement in
                                MovementRow(movement: movement)
                            }
                        }
                    } else {
                        Text("Configura el saldo inicial en Inicio para registrar movimientos.")
                            .font(.subheadline)
                            .foregroundStyle(VestaTheme.ink.opacity(0.8))
                    }
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
                        Text("Consultando movimientos…")
                    }
                }

                if let saveError = finance.saveError {
                    Text(saveError)
                        .font(.footnote)
                        .foregroundStyle(VestaTheme.error)
                }
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(VestaTheme.cream)
        .navigationTitle("Movimientos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VestaTheme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingForm = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(finance.initialBalance == nil)
                .accessibilityLabel("Registrar movimiento")
            }
        }
        .sheet(isPresented: $showingForm) {
            NavigationStack {
                MovementFormView(finance: finance)
            }
        }
    }
}

private struct MovementRow: View {
    let movement: Movement

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(movement.day.formatted) · \(movement.category.label)")
                    .font(.subheadline)
                    .foregroundStyle(VestaTheme.ink)
                Spacer()
                Text((movement.category == .income ? "+" : "−") + Money.euros(movement.cents))
                    .font(.subheadline.bold())
                    .foregroundStyle(movement.category == .income ? VestaTheme.forest : VestaTheme.ink)
            }
            if !movement.note.isEmpty {
                Text(movement.note)
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.ink.opacity(0.7))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(VestaTheme.forest.opacity(0.12), lineWidth: 1)
        )
    }
}
