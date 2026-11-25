import Foundation

/// Conversión y presentación de importes en euros con precisión de céntimos.
enum Money {
    private static let amountPattern = #"^[+-]?[0-9]+([,.][0-9]{1,2})?$"#

    /// Acepta un signo opcional, coma o punto decimal y como máximo dos decimales.
    /// Devuelve `nil` para entradas vacías, con separadores de miles o fuera de `Int64`.
    static func parseCents(_ text: String) -> Int64? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.range(of: amountPattern, options: .regularExpression) != nil else {
            return nil
        }

        var body = trimmed.replacingOccurrences(of: ",", with: ".")
        var sign: Int64 = 1
        if body.hasPrefix("+") {
            body.removeFirst()
        } else if body.hasPrefix("-") {
            sign = -1
            body.removeFirst()
        }

        let pieces = body.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard let whole = Int64(pieces[0]) else { return nil }
        let fraction = pieces.count == 2 ? String(pieces[1]) : ""
        guard fraction.count <= 2 else { return nil }
        let paddedFraction = fraction.padding(toLength: 2, withPad: "0", startingAt: 0)
        guard let cents = Int64(paddedFraction) else { return nil }

        let (scaled, scaleOverflow) = whole.multipliedReportingOverflow(by: 100)
        guard !scaleOverflow else { return nil }
        let (total, addOverflow) = scaled.addingReportingOverflow(cents)
        guard !addOverflow else { return nil }
        let (signed, signOverflow) = total.multipliedReportingOverflow(by: sign)
        guard !signOverflow else { return nil }
        return signed
    }

    /// Formato español sin depender de la configuración regional del dispositivo.
    /// Ejemplo: `123456` se muestra como `1.234,56 €`.
    static func euros(_ cents: Int64) -> String {
        let isNegative = cents < 0
        let absolute = UInt64(cents.magnitude)
        let whole = absolute / 100
        let fraction = absolute % 100

        var reversed = ""
        for (index, character) in String(whole).reversed().enumerated() {
            if index > 0, index % 3 == 0 {
                reversed.append(".")
            }
            reversed.append(character)
        }
        let grouped = String(reversed.reversed())
        return "\(isNegative ? "-" : "")\(grouped),\(String(format: "%02llu", fraction)) €"
    }

    /// Antepone `+` únicamente a los importes positivos, igual que el resumen Android.
    static func signedEuros(_ cents: Int64) -> String {
        (cents > 0 ? "+" : "") + euros(cents)
    }
}
