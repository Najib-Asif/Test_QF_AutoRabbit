/*-----------------------------------------------------------------------------------------
    Author: Nga Do
	Company: Capgemini
	Description: 
	Inputs: 
	Test Class: QCC_EventSubmitRecoveriesControllerTest
	***************************************************************************************
	History:
	***************************************************************************************
	08-May-2018
 ------------------------------------------------------------------------------------------*/
public class QCC_EventSubmitRecoveriesController {
    private static string submittedEventId;

    /*--------------------------------------------------------------------------------------       
    Method Name:        createRecoveries
    Description:        submit recovery for specific event
    Parameter:          set Id of Event
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String createRecoveries(String eventId){
        
        submittedEventId = eventId;
        try{
            // get event need to update
            Event__c eventOject = [SELECT Id, RecoveryIsCreated__c FROM Event__c WHERE  Id =: eventId];
            // if the QCC Lead or OM submit recoveries once the recoveries are created show Error Message;
            if(eventOject.RecoveryIsCreated__c == true){
                return CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Error Message');
            }
            String strSQL = 'SELECT ' 
                            +    'count() '
                            +'FROM '
                            +    'Affected_Passenger__c '
                            +'WHERE '
                            +    'RecoveryIsCreated__c = FALSE ' 
                            +'AND Affected__c = TRUE '
                            +'AND TECH_OfferedQantasPoints__c > 0 '
                            +'AND Event__c =: submittedEventId LIMIT 50000';
                            
            Integer numberAffectedPassengers = Database.countQuery(strSQL); 
            if(numberAffectedPassengers == 0){
                return CustomSettingsUtilities.getConfigDataMap('Recovery Submitted No Passenger Msg');
            }
            // call batcheable to creating cases and recoveries
            Database.executeBatch(new QCC_EventSubmitRecoveriesBatchable(eventId), 50);

            return CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Initializing'); 
            
        }catch(Exception ex){
            
            return 'Error: '+ CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Fail Message');
            
        }
        
    }
   
}