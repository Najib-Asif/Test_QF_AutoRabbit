public with sharing class TriggerHelper {
    // This defines the types of trigger actions we support
    public enum Action {BEFOREINSERT, BEFOREUPDATE, BEFOREDELETE, AFTERINSERT, AFTERUPDATE, AFTERDELETE, AFTERUNDELETE}
    
    // Dispatch classes implement this interface
    public interface Processor {
        void processTrigger(List<sObject> newRecs, List<sObject> oldRecs, Action act);
    }
    
    // Default constructor
    public TriggerHelper() {
    }
}