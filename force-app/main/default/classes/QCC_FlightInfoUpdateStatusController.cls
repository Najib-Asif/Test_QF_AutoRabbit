public class QCC_FlightInfoUpdateStatusController {
    /*--------------------------------------------------------------------------------------       
    Method Name:        getStatus
    Description:        get EventFlight_Info_Update_Status__c
    Parameter:          List of Recoveries,Map<Id,Recovery>
    --------------------------------------------------------------------------------------*/  

	@AuraEnabled
    public static String getStatus(String eventId){
        List<Event__c> events = [Select id, Flight_Info_Update_Status__c
                            FROM Event__c 
                            WHERE Id = :eventId];
        if(events.size() > 0){
            return events[0].Flight_Info_Update_Status__c;
        }else{
            return '';
        }
    }
}