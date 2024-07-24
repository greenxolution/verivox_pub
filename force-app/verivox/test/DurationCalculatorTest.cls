@isTest
public class DurationCalculatorTest {
    
    @isTest
    static void testCalculateWorkingDays_Basic() {
        Date startDate = Date.newInstance(2023, 7, 17); // Monday
        Date endDate = Date.newInstance(2023, 7, 21); // Friday
        Map<Date, String> holidays = new Map<Date, String>();
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(5, workingDays, 'There should be 5 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_IncludingWeekends() {
        Date startDate = Date.newInstance(2023, 7, 14); // Friday
        Date endDate = Date.newInstance(2023, 7, 20); // Thursday
        Map<Date, String> holidays = new Map<Date, String>();
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(5, workingDays, 'There should be 5 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_IncludingHolidays() {
        Date startDate = Date.newInstance(2023, 12, 22); // Friday
        Date endDate = Date.newInstance(2023, 12, 26); // Tuesday
        Map<Date, String> holidays = new Map<Date, String>{
            Date.newInstance(2023, 12, 25) => 'Christmas Day'
        };
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(2, workingDays, 'There should be 2 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_IncludingWeekendsAndHolidays() {
        Date startDate = Date.newInstance(2023, 12, 22); // Friday
        Date endDate = Date.newInstance(2023, 12, 27); // Wednesday
        Map<Date, String> holidays = new Map<Date, String>{
            Date.newInstance(2023, 12, 25) => 'Christmas Day'
        };
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(3, workingDays, 'There should be 3 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_SameStartEndDate_WorkingDay() {
        Date targetDate = Date.newInstance(2023, 7, 17); // Monday
        Map<Date, String> holidays = new Map<Date, String>();
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(targetDate, targetDate);
        System.assertEquals(1, workingDays, 'There should be 1 working day.');
    }

    @isTest
    static void testCalculateWorkingDays_SameStartEndDate_Weekend() {
        Date targetDate = Date.newInstance(2023, 7, 16); // Sunday
        Map<Date, String> holidays = new Map<Date, String>();
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(targetDate, targetDate);
        System.assertEquals(0, workingDays, 'There should be 0 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_SameStartEndDate_Holiday() {
        Date targetDate = Date.newInstance(2023, 12, 25); // Christmas Day
        Map<Date, String> holidays = new Map<Date, String>{
            Date.newInstance(2023, 12, 25) => 'Christmas Day'
        };
        
        DurationCalculator calculator = new DurationCalculator( holidays);
        Integer workingDays = calculator.calculateWorkingDays(targetDate, targetDate);
        System.assertEquals(0, workingDays, 'There should be 0 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_SpanMultipleMonths() {
        Date startDate = Date.newInstance(2023, 7, 31); // Monday
        Date endDate = Date.newInstance(2023, 8, 4); // Friday
        Map<Date, String> holidays = new Map<Date, String>();
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(5, workingDays, 'There should be 5 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_AllWeekendsAndHolidays() {
        Date startDate = Date.newInstance(2023, 12, 23); // Saturday
        Date endDate = Date.newInstance(2023, 12, 25); // Monday
        Map<Date, String> holidays = new Map<Date, String>{
            Date.newInstance(2023, 12, 25) => 'Christmas Day'
        };
        
        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(0, workingDays, 'There should be 0 working days.');
    }

    @isTest
    static void testCalculateWorkingDays_EmptyHolidayList() {
        Date startDate = Date.newInstance(2023, 7, 17); // Monday
        Date endDate = Date.newInstance(2023, 7, 21); // Friday
        Map<Date, String> holidays = new Map<Date, String>();

        DurationCalculator calculator = new DurationCalculator(holidays);
        Integer workingDays = calculator.calculateWorkingDays(startDate, endDate);
        System.assertEquals(5, workingDays, 'There should be 5 working days without any holidays.');
    }
}
