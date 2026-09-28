public class QCC_MultiSectorFlightUpdateQueuable implements Queueable , Database.AllowsCallouts{
    private List<Id> listIds;
    
    public QCC_MultiSectorFlightUpdateQueuable (List<Id> recordIds) {
        this.listIds = recordIds ;
    }
    
    public void execute(QueueableContext context) {
        String result = QCC_EventFlightInfoUpdateHelper.updateMultiSectorFlightInfoforEvent(listIds);  
    }
}