trigger LeaveApplicationTrigger on Leave_Application__c (before insert, after insert, before update, after update, before delete, after delete) {

    TriggerHandlerFactory factory = new AccountTriggerHandlerFactory();
    ITriggerHandler handler = factory.createHandler();
    TriggerOperation operation;
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            operation = TriggerOperation.BEFORE_INSERT;
        } else if (Trigger.isUpdate) {
            operation = TriggerOperation.BEFORE_UPDATE;
        } else if (Trigger.isDelete) {
            operation = TriggerOperation.BEFORE_DELETE;
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            operation = TriggerOperation.AFTER_INSERT;
        } else if (Trigger.isUpdate) {
            operation = TriggerOperation.AFTER_UPDATE;
        } else if (Trigger.isDelete) {
            operation = TriggerOperation.AFTER_DELETE;
        }
    } else {
        // Handle cases where no operation matches
        return;
    }

    handler.handle(operation, Trigger.new, Trigger.old);
}