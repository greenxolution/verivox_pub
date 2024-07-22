/**
 * 
 * @author araujo.guntin@gmail.com
 * @since 
 */
public interface ITriggerHandler {

    void handle(TriggerOperation operation, List<SObject> newRecords, List<SObject> oldRecords);
}