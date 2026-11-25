import Testing
@testable import Vesta

struct CalendarDayTests {
    @Test func parsesAndFormatsDates() {
        let day = CalendarDay.parse("01/01/2024")
        #expect(day != nil)
        #expect(day?.formatted == "01/01/2024")
        #expect(day?.yearMonth == YearMonth(year: 2024, month: 1))
    }

    @Test func rejectsImpossibleDates() {
        #expect(CalendarDay.parse("29/02/2023") == nil)
        #expect(CalendarDay.parse("30/02/2024") == nil)
        #expect(CalendarDay.parse("31/04/2024") == nil)
        #expect(CalendarDay.parse("1/1/2024") == nil)
        #expect(CalendarDay.parse("01-01-2024") == nil)
    }

    @Test func advancesAcrossYearBoundary() {
        let december = YearMonth(year: 2024, month: 12)
        #expect(december.adding(months: 1) == YearMonth(year: 2025, month: 1))
        #expect(december.adding(months: -1) == YearMonth(year: 2024, month: 11))
    }

    @Test func ordersDates() {
        let first = CalendarDay(year: 2024, month: 1, day: 1)
        let second = CalendarDay(year: 2024, month: 1, day: 2)
        #expect(first < second)
        #expect(!(first.yearMonth < second.yearMonth))
    }
}
