public class QCC_DeletePassengerForEvents implements Queueable {
    //Variables 
    public final Event__c objEvent;
    public final Integer count;
    public static final String preflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Pre');
    public static final String postflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Post');
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        QCC_DeletePassengerForEvents 
    Description:        Constructor 
    Parameter:          Event object 
    --------------------------------------------------------------------------------------*/ 
    public QCC_DeletePassengerForEvents(Event__c objEvent, Integer count){
        this.objEvent = objEvent;
        this.count= count;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        execute
    Description:        Queueable  execution  
    Parameter:         
    --------------------------------------------------------------------------------------*/ 
    public void execute(QueueableContext context){
        String  flightStatus;
        //getting the flight status
        if(String.isNotBlank(objEvent.Flight_Status__c )){
            for(String pre: preflightStatus.split(',')){
                if(pre.trim() == objEvent.Flight_Status__c){
                    flightStatus = 'PreFlight';
                    break;
                }
            }
            for(String post: postflightStatus.split(',')){
                if(post.trim() == objEvent.Flight_Status__c){
                    flightStatus = 'PostFlight';
                    break;
                }
            }
        }
        Id eventID = objEvent.Id; 
        List<Affected_Passenger__c> lstDelPassenger = new List<Affected_Passenger__c>();
        List<Affected_Passenger__c> lstPassenger = new List<Affected_Passenger__c>();
        String RecId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'QCC Offload Passenger');
        //Delete passenger in case if this passenger is not list in the latest response 
        for(Affected_Passenger__c objDelPassenger: [Select Id, PassengerId__c, Passenger__c, TECH_PostFlight__c, RecordTypeId,
                                                    TECH_PreFlight__c, Counter__c  from Affected_Passenger__c 
                                                    where Event__c =: eventID and Counter__c <=: count and RecordTypeId !=: recId ])
        {
            //Delete if post Flight is true and flight status is in post flight annd pre flight is false
            if(objDelPassenger.TECH_PostFlight__c == true && objDelPassenger.TECH_PreFlight__c != true && flightStatus ==  'PostFlight' ){
                lstDelPassenger.add(objDelPassenger);
            }
            //Delete if pre Flight is true and flight status is in pre flight and post flight is false
            else if(objDelPassenger.TECH_PostFlight__c != true && objDelPassenger.TECH_PreFlight__c == true && flightStatus == 'PreFlight'){
                lstDelPassenger.add(objDelPassenger);
            }else{
                objDelPassenger.Counter__c = objDelPassenger.Counter__c+1;
                lstPassenger.add(objDelPassenger);
            }
        }
        //Delete Passenger 
        delete lstDelPassenger;
        update lstPassenger;
    }
    
}