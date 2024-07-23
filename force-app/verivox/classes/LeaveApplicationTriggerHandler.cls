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
            when else {		  

                System.debug('TriggerOperation.else');
            }
        }
    }
    
    private void handleBeforeInsert(List<SObject> newRecords) {
        // Logic for before insert
    }
    
    private void handleAfterInsert(List<SObject> newRecords) {
        // Logic for after insert
    }
    
    private void handleBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
        // Logic for before update
    }
    
    private void handleAfterUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
        // Logic for after update
    }
    
    private void handleBeforeDelete(List<SObject> oldRecords) {
        // Logic for before delete
    }
    
    private void handleAfterDelete(List<SObject> oldRecords) {
        // Logic for after delete
    }
}