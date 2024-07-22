public with sharing class LeaveApplicatonTriggerHandlerFactory extends TriggerHandlerFactory {
    
    public override ITriggerHandler createHandler() {
        return new LeaveApplicationTriggerHandler();
    }
}