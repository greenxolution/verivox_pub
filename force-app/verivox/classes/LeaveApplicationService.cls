@RestResource(urlMapping='/leaveapplications/*')
global with sharing class LeaveApplicationService {
    
    @HttpGet
    global static List<Leave_Application__c> getLeaveApplicationsByEmail() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Get the email parameter from the request
        String email = RestContext.request.params.get('email');

        // Check if the email parameter is provided
        if (email == null) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Missing email parameter');
            return null;
        }
        
        return queryLeaveApplications(email);
    }
    
    @TestVisible
    private static List<Leave_Application__c> queryLeaveApplications(String email) {
        // Get the current financial year
        Date startOfYear = Date.newInstance(System.today().year(), 1, 1);
        Date endOfYear = Date.newInstance(System.today().year(), 12, 31);

        // Query the user based on email
        List<User> users = [SELECT Id FROM User WHERE Email =: email];
        
        if (users.size() == 0) {
            return new List<Leave_Application__c>(); // Return empty list if user not found
        }

        user user = users[0];
        
        // Query leave applications for the user in the current financial year
        List<Leave_Application__c> leaveApplications = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Duration__c
                                                        FROM Leave_Application__c
                                                        WHERE User__c = :user.Id
                                                        AND Start_Date__c >= :startOfYear
                                                        AND End_Date__c <= :endOfYear];
        
        return leaveApplications;
    }
}
