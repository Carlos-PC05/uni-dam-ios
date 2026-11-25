import Foundation

/// Efectivo en euros al comienzo de una fecha, con precisión de céntimos.
struct InitialBalance: Codable, Equatable, Sendable {
    let cents: Int64
    let day: CalendarDay
}
