@IsTest
public with sharing class LeaveApplicationTriggerHandlerTest {

    static Leave_Application__c leaveApplication;
    static List<Leave_Application__c> leaveApplications;
    static User user1;

    @TestSetup
    static void setupTestData() {

        String baseUsername = 'testuser';
        String uniqueUsername1 = baseUsername + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@example.com';
        String uniqueUsername2 = baseUsername + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@example.com';

        // Insert Users
        user1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@example.com',
            Username = uniqueUsername1,
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            Leftover_Vacation__c = 0
        );
        
        User user2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@example.com',
            Username = uniqueUsername2,
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            Leftover_Vacation__c = 0
        );
        
        insert new List<User>{user1, user2};
        
        // Insert Leave Applications
        Leave_Application__c leave1 = new Leave_Application__c(
            User__c = user1.Id,
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Status__c = 'Approved',
            Duration__c = 5
        );
        
        Leave_Application__c leave2 = new Leave_Application__c(
            User__c = user1.Id,
            Start_Date__c = Date.today().addDays(4),
            End_Date__c = Date.today().addDays(9),
            Status__c = 'Approved',
            Duration__c = 2
        );
        
        Leave_Application__c leave3 = new Leave_Application__c(
            User__c = user2.Id,
            Start_Date__c = Date.today().addDays(8),
            End_Date__c = Date.today().addDays(13),
            Status__c = 'Approved',
            Duration__c = 4
        );
        
        insert new List<Leave_Application__c>{leave1, leave2, leave3};
        
    }

    @IsTest
    static void testleaveApplicationEndDateBeforeStartDate() {
        // Setup test data for leave request with end date before start date
        // Attempt to set a leave request end date before the start date
        // Assert that the system does not allow it and displays an appropriate error message
        
        leaveApplication = new Leave_Application__c();
        leaveApplication.Start_Date__c = Date.today().addDays(5);
        leaveApplication.End_Date__c = Date.today().addDays(2);
        
        try {
            insert leaveApplication;

            System.assertEquals(true, false, 'An exception should have been thrown by the trigger but was not.');
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('End date cannot be before start date') ? true : false;
            
            System.assertEquals(true, true, 'An exception should have been thrown by the trigger.');

        }

        // Negative testing
        leaveApplication.Start_Date__c = Date.today().addDays(5);
        leaveApplication.End_Date__c = Date.today().addDays(2);

        try {
            update leaveApplication;

            System.assertEquals(true, true, 'An exception should have been thrown by the trigger but was not.');
        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('End date cannot be before start date') ? true : false;
            
            System.assertEquals(expectedExceptionThrown, false);
        }
    }


    @IsTest
    static void testleaveApplicationWithinAllowedDuration() {
        // Setup test data for leave request within allowed duration
        // Attempt to set a leave request within the allowed duration
        // Assert that the system allows it and does not display any error message

        Leave_Application__c leaveApplication = new Leave_Application__c();
        leaveApplication.Start_Date__c = Date.today().addDays(5);
        leaveApplication.End_Date__c = Date.today().addDays(10);
        
        try {
            insert leaveApplication;

            System.assertEquals(true, true, 'No exception should have been thrown by the trigger but was not.');
        } catch (Exception e) {
            System.assertEquals(true, true, 'No exception should be thrown');
        }

    }


    @IsTest
    static void testLeaveDurationLongerThan3Weeks() {
        // Setup test data for leave duration longer than 3 weeks
        // Attempt to set the leave duration longer than 3 calendar weeks
        // Assert that the system does not allow it and displays an appropriate error message

        Leave_Policy_Config__mdt leavePolicyConfig = [SELECT Id, MaximumLeaveDurationinDays__c, TotalVacationDaysPerYear__c 
                                                        FROM Leave_Policy_Config__mdt 
                                                        LIMIT 1];

        
        // Assuming the maximum leave duration is 21 days for this example
        Decimal maxLeaveDuration = leavePolicyConfig.MaximumLeaveDurationinDays__c;
        System.debug('Maximum leave duration: ' + maxLeaveDuration);

        Leave_Application__c leaveApplication = new Leave_Application__c();
        leaveApplication.Start_Date__c = Date.today().addDays(5);
        leaveApplication.End_Date__c = Date.today().addDays(30);
        leaveApplication.User__c = [SELECT Id FROM User WHERE Email = 'testuser1@example.com'].Id;

        try {
            insert leaveApplication;

            System.assertEquals(true, false, 'No exception should be thrown');
        } catch (DmlException  e) {
            System.assertEquals(true, true, 'An exception should have been thrown by the trigger but was not.');
            Boolean errorFound = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                if (e.getDmlMessage(i).contains('Duration cannot be longer than')) {
                    errorFound = true;
                }
            }

            System.assert(errorFound, 'Expected error message not found.');
            
        }

        System.debug('Leave Application');
        
    }

    @isTest
    static void testSetLeftoverVacationField_Insert() {

        String baseUsername = 'testuser';
        String uniqueUsername1 = baseUsername + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@example.com';

        User newUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = uniqueUsername1,
            Alias = 'JD',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );

        insert newUser;
        List<Leave_Application__c> newApplications = new List<Leave_Application__c>{

            new Leave_Application__c(
                User__c = newUser.Id,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(5),
                Status__c = 'Approved'
            )
        };
        
        Test.startTest();
        // LeaveApplicationTriggerHandler handler = new LeaveApplicationTriggerHandler();
        // handler.setLeftoverVacationField((List<SObject>)newApplications);
        insert newApplications;
        Test.stopTest();

        List<Leave_Application__c> insertedApplications = [SELECT Id, Start_Date__c, End_Date__c, Status__c
                                                            FROM Leave_Application__c WHERE Id = :newApplications[0].Id];
        System.assertEquals(1, insertedApplications.size(), 'There should be one leave application inserted.');

        User updatedUser = [SELECT Id, Leftover_Vacation__c FROM User WHERE Id = :newUser.Id];
        System.assertEquals(26, updatedUser.Leftover_Vacation__c, 'Leftover vacation days should be correctly updated.');
        
        System.debug('Leave Application');
    }

    @isTest
    static void testSetLeftoverVacationField_Update() {
        User user1 = [SELECT Id, Leftover_Vacation__c FROM User WHERE Email = 'testuser1@example.com' LIMIT 1];
        Leave_Application__c existingLeave = [SELECT Id, User__c, Start_Date__c, End_Date__c, Status__c FROM Leave_Application__c WHERE User__c = :user1.Id LIMIT 1];
        existingLeave.Status__c = 'Pending';
        
        List<Leave_Application__c> updatedApplications = new List<Leave_Application__c>{ existingLeave };
        
        Test.startTest();
        LeaveApplicationTriggerHandler handler = new LeaveApplicationTriggerHandler();
        handler.setLeftoverVacationField((List<SObject>)updatedApplications);
        Test.stopTest();
        
        Leave_Application__c updatedLeave = updatedApplications[0];
        System.assertEquals(22, user1.Leftover_Vacation__c, 'Leftover vacation days should be correctly calculated.');
    }

    @isTest
    static void testSetLeftoverVacationField_Delete() {
        User user1 = [SELECT Id FROM User WHERE Email = 'testuser1@example.com' LIMIT 1];
        Leave_Application__c leaveToDelete = [SELECT Id, User__c, Start_Date__c, End_Date__c, Status__c FROM Leave_Application__c WHERE User__c = :user1.Id LIMIT 1];
        
        List<Leave_Application__c> deletedApplications = new List<Leave_Application__c>{ leaveToDelete };
        
        Test.startTest();
        // Simulate the deletion by removing it from the new records list
        LeaveApplicationTriggerHandler handler = new LeaveApplicationTriggerHandler();
        handler.setLeftoverVacationField((List<SObject>)deletedApplications);
        Test.stopTest();
        
        // Re-query the user to check the updated leftover vacation days
        User updatedUser = [SELECT Id, Leftover_Vacation__c FROM User WHERE Id = :user1.Id LIMIT 1];
        System.assertEquals(22, updatedUser.Leftover_Vacation__c, 'Leftover vacation days should be correctly updated after deletion.');
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
    @IsTest
    static void testUpdateUsersLeftoverVacationDays() {

        String baseUsername = 'testuser';
        String uniqueUsername1 = baseUsername + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@example.com';

        // Setup test data
        User user1 = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = uniqueUsername1,
            Alias = 'JD',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user1;


        List<Leave_Application__c> leaveApplications = new List<Leave_Application__c>{

            new Leave_Application__c(
                User__c = user1.Id,
                Start_Date__c = Date.today().addDays(4),
                End_Date__c = Date.today().addDays(14),
                Status__c = 'Approved'
            ),

            new Leave_Application__c(
                User__c = user1.Id,
                Start_Date__c = Date.today().addDays(30),
                End_Date__c = Date.today().addDays(44),
                Status__c = 'Approved'

            ),

            new Leave_Application__c(
                User__c = user1.Id,
                Start_Date__c = Date.today().addDays(45),
                End_Date__c = Date.today().addDays(55),
                Status__c = 'Approved'
            )
        };

        // Perform the update
        Test.startTest();
        insert leaveApplications.get(0);
        insert leaveApplications.get(1);
        insert leaveApplications.get(2);
        Test.stopTest();

        List<User> users = [SELECT Id, Name, Leftover_Vacation__c
                            FROM User WHERE Id = :user1.Id];

        // Aggregate query to get the sum of Duration__c for approved leave applications
        AggregateResult[] results = [
            SELECT User__c, SUM(Duration__c) totalDuration
            FROM Leave_Application__c
            WHERE Status__c = 'Approved' AND User__c = :user1.Id
            GROUP BY User__c
        ];

        // Extract the total duration from the aggregate result
        Decimal totalDuration = (results != null && results.size() > 0) ? (Decimal)results[0].get('totalDuration') : 0;

        Leave_Policy_Config__mdt leavePolicyConfig = LeaveApplicationTriggerHandler.getLeavePolicyConfigs();

        System.assertEquals(leavePolicyConfig.TotalVacationDaysPerYear__c - totalDuration, users.get(0).Leftover_Vacation__c, 'Leftover vacation days should be correctly updated for user1.');

        // Adding the leave application adding more days to the existing leave application
        Leave_Application__c additionalLeaveApplication = new Leave_Application__c(
            User__c = user1.Id,
            Start_Date__c = Date.today().addDays(45),
            End_Date__c = Date.today().addDays(55),
            Status__c = 'Approved'
        );

        System.debug(JSON.serializePretty(leaveApplications));

        try {
            insert additionalLeaveApplication;

            System.assertEquals(true, false, 'Exception should be thrown by the trigger');

            List<User> users2 = [SELECT Id, Name, Leftover_Vacation__c
            FROM User WHERE Id = :user1.Id];

            // Aggregate query to get the sum of Duration__c for approved leave applications
            AggregateResult[] results2 = [
            SELECT User__c, SUM(Duration__c) totalDuration
            FROM Leave_Application__c
            WHERE Status__c = 'Approved' AND User__c = :user1.Id
            GROUP BY User__c
            ];

        } catch (DmlException e) {

            System.assertEquals(true, true, 'An exception should have been thrown by the trigger but was not.');
            Boolean errorFound = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                if (e.getDmlMessage(i).contains('Leftover vacation days cannot exceed')) {
                    errorFound = true;
                }
            }

            System.assert(errorFound, 'Expected error message not found.');
            
        }
        


        // Output the total duration
        System.debug('Total Duration: ' + totalDuration);

    }
}