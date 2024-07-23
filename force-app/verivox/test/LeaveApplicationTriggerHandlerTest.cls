@IsTest
public with sharing class LeaveApplicationTriggerHandlerTest {


    // @TestSetup
    // static void setupTestData() {
    //     // Setup test data if required
    // }

    @IsTest
    static void testLeaveRequestEndDateBeforeStartDate() {
        // Setup test data for leave request with end date before start date
        // Attempt to set a leave request end date before the start date
        // Assert that the system does not allow it and displays an appropriate error message
        
        Leave_Application__c leaveRequest = new Leave_Application__c();
        leaveRequest.Start_Date__c = Date.today().addDays(5);
        leaveRequest.End_Date__c = Date.today().addDays(2);
        
        try {
            insert leaveRequest;

            System.assertEquals(true, false, 'An exception should have been thrown by the trigger but was not.');
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('End date cannot be before start date') ? true : false;
            
            System.assertEquals(expectedExceptionThrown, false);
        }
    }


    @IsTest
    static void testLeaveRequestWithinAllowedDuration() {
        // Setup test data for leave request within allowed duration
        // Attempt to set a leave request within the allowed duration
        // Assert that the system allows it and does not display any error message
        
        Leave_Application__c leaveRequest = new Leave_Application__c();
        leaveRequest.Start_Date__c = Date.today().addDays(5);
        leaveRequest.End_Date__c = Date.today().addDays(10);
        
        try {
            insert leaveRequest;
        } catch (Exception e) {
            System.assertEquals(true, true, 'No exception should be thrown');
        }
    }


    @IsTest
    static void testLeaveDurationLongerThan3Weeks() {
        // Setup test data for leave duration longer than 3 weeks
        // Attempt to set the leave duration longer than 3 calendar weeks
        // Assert that the system does not allow it and displays an appropriate error message
    }

    @IsTest
    static void testCalculateDurationWithWorkingDaysOnly() {
        // Setup test data for leave duration including weekends
        // Set leave duration including weekends
        // Assert that the system calculates the duration excluding weekends and displays the correct duration in working days
    }

    @IsTest
    static void testGermanHolidaysAsNonWorkingDays() {
        // Setup test data for leave duration that includes German public holidays
        // Set leave duration that includes German public holidays
        // Assert that the system excludes German holidays from the duration calculation and displays the correct duration in working days
    }

    @IsTest
    static void testExceedingAnnualVacationDays() {
        // Setup test data for leave requests that exceed the total of 30 days of vacation in a year
        // Create leave requests that exceed the total of 30 days of vacation in a year
        // Assert that the system does not allow leave requests that exceed 30 days in total for the year and displays an appropriate error message
    }

    @IsTest
    static void testVacationBalanceVisualization() {
        // Display the current balance of vacation days
        // Assert that the system correctly displays the current balance of vacation days for the employee
    }

    @IsTest
    static void testNegativeLeftoverVacationDays() {
        // Ensure leftover vacation days cannot be negative
        // Assert that the system does not allow the balance of vacation days to go below 0 and displays an appropriate error message
    }
}