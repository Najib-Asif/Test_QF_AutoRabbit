public with sharing class QCC_EventFlightDetailsUpdateQueuable implements Queueable , Database.AllowsCallouts{
    private List<Id> listIds;
    
    public QCC_EventFlightDetailsUpdateQueuable (List<Id> recordIds) {
        this.listIds = recordIds ;
    }
    
    public void execute(QueueableContext context) {
        String result = QCC_EventFlightInfoUpdateHelper.updateforEvent(listIds);  
    }
}