import Foundation

/// Fecha de calendario sin hora ni zona horaria, guardada como días desde el 1 de enero de 1970.
/// Reproduce el campo `dia` de Firestore de la aplicación Android.
struct CalendarDay: Hashable, Comparable, Codable, Sendable {
    let epochDay: Int

    init(epochDay: Int) {
        self.epochDay = epochDay
    }

    init(localDate date: Date = Date(), calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(
            year: components.year ?? 1970,
            month: components.month ?? 1,
            day: components.day ?? 1
        )
    }

    init(year: Int, month: Int, day: Int) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day)
        let date = calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
        self.epochDay = Int((date.timeIntervalSince1970 / 86_400).rounded(.down))
    }

    static var today: CalendarDay {
        CalendarDay(localDate: Date())
    }

    var date: Date {
        Date(timeIntervalSince1970: Double(epochDay) * 86_400)
    }

    var year: Int { components.year ?? 1970 }
    var month: Int { components.month ?? 1 }
    var day: Int { components.day ?? 1 }
    var yearMonth: YearMonth { YearMonth(year: year, month: month) }

    /// Formato `DD/MM/AAAA`, el mismo que espera la interfaz.
    var formatted: String {
        String(format: "%02d/%02d/%04d", day, month, year)
    }

    /// Acepta exclusivamente `DD/MM/AAAA` y rechaza fechas inexistentes como el 30 de febrero.
    static func parse(_ text: String) -> CalendarDay? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.range(of: #"^[0-9]{2}/[0-9]{2}/[0-9]{4}$"#, options: .regularExpression) != nil else {
            return nil
        }
        let parts = trimmed.split(separator: "/").compactMap { Int($0) }
        guard parts.count == 3, (1...9999).contains(parts[2]) else { return nil }

        let candidate = CalendarDay(year: parts[2], month: parts[1], day: parts[0])
        guard candidate.year == parts[2], candidate.month == parts[1], candidate.day == parts[0] else {
            return nil
        }
        return candidate
    }

    private var components: DateComponents {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.dateComponents([.year, .month, .day], from: date)
    }

    static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        lhs.epochDay < rhs.epochDay
    }
}

/// Mes natural usado por el selector y los resúmenes de flujo de caja.
struct YearMonth: Hashable, Comparable, Codable, Sendable {
    let year: Int
    let month: Int

    init(year: Int, month: Int) {
        var normalizedYear = year
        var normalizedMonth = month
        while normalizedMonth < 1 {
            normalizedMonth += 12
            normalizedYear -= 1
        }
        while normalizedMonth > 12 {
            normalizedMonth -= 12
            normalizedYear += 1
        }
        self.year = normalizedYear
        self.month = normalizedMonth
    }

    init(day: CalendarDay) {
        self.init(year: day.year, month: day.month)
    }

    static var current: YearMonth {
        YearMonth(day: .today)
    }

    var startDay: CalendarDay {
        CalendarDay(year: year, month: month, day: 1)
    }

    func adding(months: Int) -> YearMonth {
        let totalMonths = year * 12 + (month - 1) + months
        return YearMonth(year: totalMonths / 12, month: totalMonths % 12 + 1)
    }

    /// Nombre del mes en español, por ejemplo `enero 2024`.
    var displayName: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return "\(month)/\(year)"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        lhs.year == rhs.year ? lhs.month < rhs.month : lhs.year < rhs.year
    }
}
