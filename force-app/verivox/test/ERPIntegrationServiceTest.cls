@isTest
private class ERPIntegrationServiceTest {
    
    @isTest
    static void testUpdateVacationBalance() {
        // Create a test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'][0].Id,
            LanguageLocaleKey = 'en_US',
            Leftover_Vacation__c = 10
        );
        insert testUser;

        // Create a set of user IDs
        Set<Id> userIds = new Set<Id>{ testUser.Id };

        // Set up the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ERPIntegrationServiceMock());

        // Call the future method
        Test.startTest();
        ERPIntegrationService.updateVacationBalance(userIds);
        Test.stopTest();

        // Verify that the HTTP callout was made and check the payload
        List<MockHttpRequest> requests = requests;
        System.assertEquals(1, requests.size(), 'One HTTP request should have been made.');

        // Verify the request payload
        String requestBody = requests[0].getBody();
        System.debug(JSON.serializePretty(requestBody));
        List<Playload> payload = (List<Playload>) JSON.deserialize(requestBody, List<Playload>.class);
        System.assertEquals(1, payload.size(), 'The payload should contain one user.');

        Playload userPayload = payload[0];
        System.assertEquals('testuser@example.com', userPayload.getEmail());
        System.assertEquals(10, userPayload.getLeftoverVacationDays());
    }

    public static List<MockHttpRequest> requests = new List<MockHttpRequest>();
    
    public class ERPIntegrationServiceMock implements HttpCalloutMock {

        

        public HTTPResponse respond(HTTPRequest req) {
            // Store the request for verification
            requests.add(new MockHttpRequest(req));

            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class Playload {
        public String email;
        public Decimal leftoverVacationDays;
    
        public String getEmail() {
            return email;
        }
    
        public Decimal getLeftoverVacationDays() {
            return leftoverVacationDays;
        }
    }

    private class MockHttpRequest {
        private HttpRequest req;

        public MockHttpRequest(HttpRequest req) {
            this.req = req;
        }

        public String getBody() {
            return req.getBody();
        }
    }
}
