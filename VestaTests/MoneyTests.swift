import Testing
@testable import Vesta

struct MoneyTests {
    @Test func parsesAmountsWithCommaAndDot() {
        #expect(Money.parseCents("12,34") == 1_234)
        #expect(Money.parseCents("12.34") == 1_234)
        #expect(Money.parseCents("0") == 0)
        #expect(Money.parseCents("+7") == 700)
        #expect(Money.parseCents("-12,50") == -1_250)
        #expect(Money.parseCents(" 1,5 ") == 150)
    }

    @Test func rejectsInvalidAmounts() {
        #expect(Money.parseCents("") == nil)
        #expect(Money.parseCents("12,345") == nil)
        #expect(Money.parseCents("1.234,56") == nil)
        #expect(Money.parseCents("doce") == nil)
        #expect(Money.parseCents("1,") == nil)
        #expect(Money.parseCents("92233720368547758,08") == nil)
    }

    @Test func formatsEurosWithSpanishSeparators() {
        #expect(Money.euros(1_234) == "12,34 €")
        #expect(Money.euros(123_456) == "1.234,56 €")
        #expect(Money.euros(-1_250) == "-12,50 €")
        #expect(Money.signedEuros(1_234) == "+12,34 €")
        #expect(Money.signedEuros(0) == "0,00 €")
    }
}
