public class ERPIntegrationService {
    
    @future(callout=true)
    public static void updateVacationBalance(Set<Id> userIds) {

        // Get user records
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Email, Leftover_Vacation__c 
                                                    FROM User WHERE Id IN :userIds]);
        // Create JSON payload for all users
        List<Map<String, Object>> userPayloads = new List<Map<String, Object>>();
        for (User user : usersMap.values()) {
            Map<String, Object> userPayload = new Map<String, Object>();
            userPayload.put('email', user.Email);
            userPayload.put('leftoverVacationDays', usersMap.get(user.Id).Leftover_Vacation__c);
            userPayloads.add(userPayload);
        }
        
        // Callout to ERP system to update vacation balance for all users
            HttpRequest req = new HttpRequest();
            req.setEndpoint(getLeavePolicyConfigs().ERPIntegrationServiceURL__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(userPayloads));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() != 200) {
                System.debug('Failed to update ERP system: ' + res.getBody());
            }

        }

        @TestVisible
        private static Leave_Policy_Config__mdt getLeavePolicyConfigs() {
            return [SELECT Id, MaximumLeaveDurationinDays__c, TotalVacationDaysPerYear__c, ERPIntegrationServiceURL__c 
                    FROM Leave_Policy_Config__mdt LIMIT 1];
        }
    }