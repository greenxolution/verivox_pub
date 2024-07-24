public with sharing class DurationCalculator {
    private Date startDate;
    private Date endDate;
    private Map<Date, String> holidays;

    // Constructor with injected holidays
    public DurationCalculator(Map<Date, String> holidays) {
        this.holidays = holidays;
    }

    // Default constructor that loads holidays from metadata
    public DurationCalculator() {
        this(getAllGermanHolidays());
    }
    
    public Integer calculateWorkingDays(Date startDate, Date endDate) {
        Integer workingDays = 0;
        Date currentDate = startDate;
        
        while (currentDate <= endDate) {
            if (!isWeekend(currentDate) && !isHoliday(currentDate)) {
                workingDays++;
            }
            currentDate = currentDate.addDays(1);
        }
        
        return workingDays;
    }
    
    private Boolean isWeekend(Date targetDate) {
        Datetime targetDateTime = Datetime.newInstance(targetDate.year(), targetDate.month(), targetDate.day());
        String expectedDayOfWeekend = targetDateTime.format('EEE');

        return expectedDayOfWeekend == 'Sat' || expectedDayOfWeekend == 'Sun';
    }
    
    private Boolean isHoliday(Date targetDate) {
        return holidays.containsKey(targetDate);
    }

    // Return all German Holidays for the given year
    // Return a Map<Date, Name>
    static public Map<Date, String> getAllGermanHolidays() {
        List<German_Holiday__mdt> germanHolidays = [SELECT Id, Holiday_Date__c, Label FROM German_Holiday__mdt];

        Map<Date, String> germanHolidaysMap = new Map<Date, String>();
        for (German_Holiday__mdt germanHoliday : germanHolidays) {
            germanHolidaysMap.put(germanHoliday.Holiday_Date__c, germanHoliday.Label);
        }

        return germanHolidaysMap;
    }
    
    private Boolean isBusinessDay(Date targetDate) {
        return !isWeekend(targetDate) && !isHoliday(targetDate);
    }
}
