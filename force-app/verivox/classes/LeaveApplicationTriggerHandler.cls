/**
 * This class is responsible for handling triggers related to leave applications.
 * It provides methods to handle before and after triggers for the LeaveApplication object.
 * The purpose of this class is to encapsulate the logic for trigger operations and provide a modular approach to trigger handling.
 * It ensures that trigger logic is separated from the main business logic of the application.
 * The scope of this class is limited to handling triggers for the LeaveApplication object only.
 * 
 * @author araujo.guntin@gmail.com
 * @since 
 */

public with sharing class LeaveApplicationTriggerHandler implements ITriggerHandler {

    
    public void handle(TriggerOperation operation, List<SObject> newRecords, List<SObject> oldRecords) {
   
        switch on operation {
            when BEFORE_INSERT {		
                
                handleBeforeInsert(newRecords);
            }
            when BEFORE_UPDATE {		
                
                handleBeforeUpdate(oldRecords, newRecords);
            }
            when AFTER_UPDATE {		
                
                handleAfterUpdate(oldRecords, newRecords);
            }
            when BEFORE_DELETE {		
                
                handleBeforeDelete(oldRecords);
            }
            when AFTER_DELETE {		
                
                handleAfterDelete(oldRecords);
            }
            when AFTER_INSERT {		
                
                handleAfterInsert(newRecords);
            }
            when else {		  

                System.debug('TriggerOperation.else');
            }
        }
    }
    
    private void handleBeforeInsert(List<SObject> newRecords) {
        List<Leave_Application__c> leaveApplications = (List<Leave_Application__c>) newRecords;

        Leave_Policy_Config__mdt leavePolicyConfig = getLeavePolicyConfigs();

        if (leavePolicyConfig == null) {
            leaveApplications[0].addError('Leave policy configuration is missing.');
            return;
        }

        for (Leave_Application__c leaveApplication : leaveApplications) {
            
            // Set Duration
            leaveApplication.Duration__c = getDurationCalculation(leaveApplication.Start_Date__c, leaveApplication.End_Date__c);

            // Validate Maximun Leave Duration Date
            if (leaveApplication.Duration__c > leavePolicyConfig.MaximumLeaveDurationinDays__c) {
                leaveApplication.addError('Leave duration cannot exceed ' + leavePolicyConfig.MaximumLeaveDurationinDays__c + ' days.');
            }
        }
    }
    
    private void handleAfterInsert(List<SObject> newRecords) {
        // Logic for after insert
        setLeftoverVacationField(newRecords);

        sendUpdatToERP(newRecords);

    }
    
    private void handleBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
        // Logic for before update
    }
    
    private void handleAfterUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
        // Logic for after update
        setLeftoverVacationField(newRecords);

        sendUpdatToERP(newRecords);
    }
    
    private void handleBeforeDelete(List<SObject> oldRecords) {
        // Logic for before delete
    }
    
    private void handleAfterDelete(List<SObject> oldRecords) {
        // Logic for after delete
        setLeftoverVacationField(oldRecords);

        sendUpdatToERP(oldRecords);
    }

    @TestVisible
    private Integer getDurationCalculation(Date startDate, Date endDate) {
        DurationCalculator calculator = new DurationCalculator();
        return calculator.calculateWorkingDays(startDate, endDate);
    }


    @TestVisible
    private static Leave_Policy_Config__mdt getLeavePolicyConfigs() {
        return [SELECT Id, MaximumLeaveDurationinDays__c, TotalVacationDaysPerYear__c FROM Leave_Policy_Config__mdt LIMIT 1];
    }

    @TestVisible
    private void sendUpdatToERP(List<Leave_Application__c> newRecords) {
        if (Test.isRunningTest()) {
            return;
        }

        Set<Id> userIds = new Set<Id>();
        for (Leave_Application__c leaveApplication : newRecords) {
            if (leaveApplication.Status__c == 'Approved') {
                
                userIds.add(leaveApplication.User__c);
            }
        }

        if(userIds.size() > 0) {
            ERPIntegrationService.updateVacationBalance(userIds);
        }
    }

    // Set User.Leftover_Vacation__c in insert, update and delete scenarios
    @TestVisible
    private void setLeftoverVacationField(List<SObject> newRecords) {
        // Create a set of user IDs from the new leave applications
        Set<Id> userIds = new Set<Id>();
        List<User> usersToUpdate = new List<User>();

        for (Leave_Application__c leaveApplication : (List<Leave_Application__c>) newRecords) {
            userIds.add(leaveApplication.User__c);
        }
    
        // Query users with the total vacation days field
        Map<Id, User> usersMap = new Map<Id, User>([
            SELECT Id, Leftover_Vacation__c
            FROM User
            WHERE Id IN :userIds
        ]);
    
        // Query approved leave applications for these users to calculate used vacation days
        AggregateResult[] aggregateResults = [SELECT User__c, SUM(Duration__c) Duration__c
                                              FROM Leave_Application__c
                                              WHERE Status__c = 'Approved'
                                              AND User__c IN :userIds
                                              GROUP BY User__c];
    
        // Create a map to store used vacation days
        Map<Id, Decimal> usedVacationDaysMap = new Map<Id, Decimal>();
        for (AggregateResult ar : aggregateResults) {
            usedVacationDaysMap.put((Id)ar.get('User__c'), (Decimal)ar.get('Duration__c'));
        }
    
        Decimal allowedVacationDays = getLeavePolicyConfigs().TotalVacationDaysPerYear__c;
        // Calculate and set the leftover vacation days for each user
        Map<Id, Decimal> leftoverVacationDaysMap = new Map<Id, Decimal>();
        for (Leave_Application__c leaveApplication : (List<Leave_Application__c>) newRecords) {
            User user = usersMap.get(leaveApplication.User__c);
            Decimal usedVacationDays = usedVacationDaysMap.containsKey(user.Id) ? usedVacationDaysMap.get(user.Id) : 0;
            
            Decimal remainingVacationDays = leftoverVacationDaysMap.containsKey(user.Id) ? leftoverVacationDaysMap.get(user.Id) : allowedVacationDays;
            remainingVacationDays -= leaveApplication.Duration__c;
            leftoverVacationDaysMap.put(user.Id, remainingVacationDays);
            Decimal leftoverVacationDays = allowedVacationDays - usedVacationDays;
            if(leftoverVacationDays < 0) {
                leaveApplication.addError('Leftover vacation days cannot exceed ' + allowedVacationDays + ' days.');
                return;
            }

            leftoverVacationDaysMap.put(user.Id, leftoverVacationDays);
        }

        // Update the leftover vacation days for each user
        for (User userToUpdate : usersMap.values()) {
            Decimal leftoverVacationDays = leftoverVacationDaysMap.get(userToUpdate.Id);
            userToUpdate.Leftover_Vacation__c = leftoverVacationDays;
            // if (userToUpdate.Leftover_Vacation__c < 0) {
            //     Leave_Application__c leaveApplication = new Leave_Application__c(User__c = userToUpdate.Id);
            //     leaveApplication.addError('Leftover vacation days cannot exceed 30.');
            // }
            usersToUpdate.add(userToUpdate);
        }
        
        update usersToUpdate;
    }

}