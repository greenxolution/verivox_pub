public with sharing class LeaveApplicationController {
    @AuraEnabled
    public static void saveLeaveApplication(Date startDate, Date endDate, String leaveType, Id userId) {
        Leave_Application__c leaveApplication = new Leave_Application__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Type__c = leaveType,
            Status__c = 'Draft', // or the appropriate default status
            userId = userId
        );
        insert leaveApplication;
    }

    @AuraEnabled
    public static Decimal getVacationBalance() {
        User currentUser = [SELECT Id, Leftover_Vacation__c FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser.Leftover_Vacation__c;
    }

    @AuraEnabled(cacheable=true)
    public static List<Leave_Application__c> getLeaveApplications() {
        return [SELECT Id, Start_Date__c, End_Date__c, Status__c, Duration__c, Type__c
                FROM Leave_Application__c];
    }
}
