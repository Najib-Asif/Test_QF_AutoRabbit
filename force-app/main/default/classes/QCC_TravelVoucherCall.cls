public without sharing class QCC_TravelVoucherCall implements Queueable, Database.AllowsCallouts {        
    public List<Id> recordIds;  
    
    public QCC_TravelVoucherCall(List<Id> recordIds) {
        this.recordIds= recordIds;
    }
    
    public void execute(QueueableContext context) {
        list<Note> notelist = new list<Note>();
        boolean iseception = false;
        string responsebody = '';
        try{
            string bodyJson = QCC_TravelVoucherCallHelper.createRecoveryJson(this.recordIds, Date.Today());
            if(bodyJson == null){
                return ;
            }
            notelist.add(QCC_TravelVoucherCallHelper.createNoteForRecord(this.recordIds[0],'request',bodyJson));
            
            HttpResponse response = QCC_RecoveryIntegrationUtility.actualHttpCall('callout:QCC_Recovery_DGCT_NC',bodyJson);
            if (response.getStatusCode() == 200) {
                responsebody = response.getBody();                 
            } else {
                responsebody = response.getStatusCode() + response.getBody();
                iseception = true;
            }
        }catch(exception e){
            iseception = true;
            responsebody = e.getMessage();
        }
        notelist.add(QCC_TravelVoucherCallHelper.createNoteForRecord(this.recordIds[0],'response',responsebody));
        try {
            QCC_TravelVoucherCallHelper.updateRecoveries(this.recordIds,responsebody,iseception,responsebody);
        
         
            insert notelist;
            
        } catch (DmlException e) {
            System.debug('An error occurred while creating the note: ' + e.getMessage());
        }
                        
    }
    
    
    
}