/*--------------------------------------------------------------------------------------------------------------------------
    Author:        Felix Nilam
    Company:       Capgemini
    Description:   Helper class to execute business logic on the Global Event trigger
    Inputs:
    Test Class:    GlobalEventTriggerTest 
    ************************************************************************************************
    History
    ************************************************************************************************
    11-Jul-2018     Felix Nilam                   Added logic to set the multi picklist to text representation for audit history
    -----------------------------------------------------------------------------------------------------------------------------*/
public class GlobalEventTriggerHelper {
    /**
     * Method: updateAuditFields
     * Description: set/update the text version of the custom fields for multi picklist.  This is to track the values as field audit history
     *              These audit fields should be set regardless of Record Type
     * @param: List<Global_Event__c>
     * @param: Map<Id, Global_Event__c>
     * @return: void
     */
    public static void updateAuditFields(List<Global_Event__c> lstGlobalEvent, Map<Id, Global_Event__c> oldGlobalEventMap){
        for(Global_Event__c newEvent : lstGlobalEvent){
            Global_Event__c oldEvent = OldGlobalEventMap != Null? oldGlobalEventMap.get(newEvent.Id): Null;
            
            // update the Airport Event Type if it changes
            if(oldEvent == Null || oldEvent.Airport_Event_Type__c != newEvent.Airport_Event_Type__c) {
                newEvent.TECH_Airport_Event_Type__c = newEvent.Airport_Event_Type__c;
            }
            // update the Inflight Event Type if it changes
            if(oldEvent == Null || oldEvent.Inflight_Event_Type__c != newEvent.Inflight_Event_Type__c) {
                newEvent.TECH_Inflight_Event_Type__c = newEvent.Inflight_Event_Type__c;
            }
        }
    }
}