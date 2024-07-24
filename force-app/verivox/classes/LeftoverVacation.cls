//It should be possible to track the Status (Draft, In Progress, Approved, Not Approved)
public with sharing class LeftoverVacation {

    // Calculate the total vacation days 
    public static Integer calculateVacationDays(User user) {
        Integer vacationDays = 0;

        Id userId = 'yourUserIdHere'; // replace with the actual user ID
        AggregateResult[] results = [SELECT SUM(Duration__c) totalDuration 
                                     FROM Leave_Application__c 
                                     WHERE Status__c = 'Approved' 
                                     AND User__c = :userId];
        
        if (!results.isEmpty()) {
            vacationDays = ((Decimal)results[0].get('totalDuration')).intValue();
        } else {
            System.debug('No approved leave applications found for this user.');
        }

        return vacationDays;
    }

    // Calculate the leftover vacation days

    public static Integer calculateLeftoverVacationDays(User user) {
        Integer vacationDays = LeftoverVacation.calculateVacationDays(user);
        Integer leftoverVacationDays = LeftoverVacation.getAllowedVacationDays() - vacationDays;

        if (leftoverVacationDays < 0) {
            leftoverVacationDays = 0;
        }

        return leftoverVacationDays;
    }

    // Get allowed vacation days
    public static Integer getAllowedVacationDays() {

        return [SELECT TotalVacationDaysPerYear__c 
        FROM Leave_Policy_Config__mdt LIMIT 1].TotalVacationDaysPerYear__c.intValue();
    }


}