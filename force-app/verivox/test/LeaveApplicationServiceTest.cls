@isTest
private class LeaveApplicationServiceTest {

    
    @isTest
    static void testGetLeaveApplicationsByEmail(){
        // Create a test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = getDynamicUserNaiveEmail(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'][0].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a test leave application for the user
        Leave_Application__c testLeaveApp = new Leave_Application__c(
            User__c = testUser.Id,
            Start_Date__c = Date.newInstance(System.today().year(), 7, 24),
            End_Date__c = Date.newInstance(System.today().year(), 8, 13),
            Status__c = 'Approved',
            Duration__c = 15
        );
        insert testLeaveApp;

        // Simulate the REST request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leaveapplications';
        req.addParameter('email', 'testuser@example.com');
        req.addParameter('hub.verify_token', 'ABCDDDFFF');
        req.addParameter('hub.challenge', 'test');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        // Call the REST service method
        List<Leave_Application__c> result = LeaveApplicationService.queryLeaveApplications(testUser.Email);

        System.debug(JSON.serializePretty(res));

        // Verify the response
        System.assertEquals(200, res.statusCode);
 
    }
    
    @isTest
    static void testGetLeaveApplicationsByEmailMissingEmail() {
        // Simulate the REST request and response
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/leaveapplications';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        System.debug(JSON.serializePretty(RestContext.response.statusCode));

        // Call the REST service method
        List<Leave_Application__c> result = LeaveApplicationService.getLeaveApplicationsByEmail();

        // Verify the response
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Missing email parameter', RestContext.response.responseBody.toString());
    }

    @isTest
    static void testGetLeaveApplicationsByEmailUserNotFound() {
        // Simulate the REST request and response
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/leaveapplications';
        req.addParameter('email', 'nonexistent@example.com');
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the REST service method
        List<Leave_Application__c> result = LeaveApplicationService.getLeaveApplicationsByEmail();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(0, result.size());
    }

    static String getDynamicUserNaiveEmail() {
        return 'testuser' + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@example.com';
    }
}
