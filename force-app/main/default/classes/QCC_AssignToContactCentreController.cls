public class QCC_AssignToContactCentreController {
	//do the Assign Event to Customer Care Queue
    @AuraEnabled
    public static String doAssignToContactCenter(String eventId){
        String output = '';
        try{
             //search for the Event
            Event__c ev = [Select id, name,  OwnerId,Status__c from Event__c where id=:eventId limit 1];
            //search for the Queue
            List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='CCC_CIOC_Queue'];

            //Do Assignment
            if(listQueue.size() > 0){
                if(ev.OwnerId != listQueue[0].id || ev.Status__c != 'Assigned'){
                    if(ev.Status__c== 'Closed'){
                        output= 'Error: ' + 'Event is already closed. Please reload the page';
                    }else{
                        ev.OwnerId = listQueue[0].id;
                        //Change Status to 'Assigned'
                        ev.Status__c = 'Assigned';
                        Database.DmlOptions options = new Database.DmlOptions();
                        options.emailHeader.triggerUserEmail = true;
                        Database.update(ev, options);
                        //update ev;
                        output = ev.Name;
                    }
                }else{
                    output= 'Error: ' + 'Event is already assigned.';
                }   
            }
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output= 'Error: ' + ' Some error occurred!';
        }
       
        
        return output;
    }
}