import Foundation

enum MovementCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case income = "INCOME"
    case leisure = "LEISURE"
    case housing = "HOUSING"
    case food = "FOOD"
    case transport = "TRANSPORT"
    case health = "HEALTH"
    case other = "OTHER"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .income: "Ingreso"
        case .leisure: "Ocio"
        case .housing: "Vivienda"
        case .food: "Comida"
        case .transport: "Transporte"
        case .health: "Salud"
        case .other: "Otros"
        }
    }
}

struct Movement: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let cents: Int64
    let day: CalendarDay
    let category: MovementCategory
    let note: String
}

struct CashFlow: Equatable, Sendable {
    var income: Int64
    var expenses: Int64
    var net: Int64 { income - expenses }
}

extension Array where Element == Movement {
    /// Suma los ingresos y los gastos del mes indicado, o de todo el historial si se omite.
    func cashFlow(in month: YearMonth? = nil) -> CashFlow {
        var income: Int64 = 0
        var expenses: Int64 = 0
        for movement in self {
            if let month, movement.day.yearMonth != month { continue }
            if movement.category == .income {
                income += movement.cents
            } else {
                expenses += movement.cents
            }
        }
        return CashFlow(income: income, expenses: expenses)
    }
}
