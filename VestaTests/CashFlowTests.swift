import Testing
@testable import Vesta

struct CashFlowTests {
    private let january = YearMonth(year: 2024, month: 1)
    private let february = YearMonth(year: 2024, month: 2)

    private var movements: [Movement] {
        [
            Movement(
                id: "1",
                cents: 2_500,
                day: CalendarDay(year: 2024, month: 1, day: 10),
                category: .income,
                note: "Nómina"
            ),
            Movement(
                id: "2",
                cents: 1_200,
                day: CalendarDay(year: 2024, month: 1, day: 11),
                category: .food,
                note: "Compra"
            ),
            Movement(
                id: "3",
                cents: 800,
                day: CalendarDay(year: 2024, month: 2, day: 1),
                category: .transport,
                note: ""
            ),
        ]
    }

    @Test func separatesIncomeAndExpenses() {
        let flow = movements.cashFlow(in: january)
        #expect(flow.income == 2_500)
        #expect(flow.expenses == 1_200)
        #expect(flow.net == 1_300)
    }

    @Test func ignoresOtherMonths() {
        let flow = movements.cashFlow(in: february)
        #expect(flow.income == 0)
        #expect(flow.expenses == 800)
        #expect(flow.net == -800)
    }

    @Test func totalsAllMovementsWhenMonthIsNil() {
        let flow = movements.cashFlow()
        #expect(flow.income == 2_500)
        #expect(flow.expenses == 2_000)
        #expect(flow.net == 500)
    }
}
