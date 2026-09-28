public class QCC_ClosePendingRecoveryCaseQueuable implements Queueable {
    private Map<String, List<Id>> mapOfRStatusNCase;
    private Set<Id> noGoodWillCases;

    public QCC_ClosePendingRecoveryCaseQueuable(Map<String, List<Id>> mapOfRStatusNCase, Set<Id> noGoodWillCases) {
        this.mapOfRStatusNCase = mapOfRStatusNCase;
        this.noGoodWillCases = noGoodWillCases;
    }

    public void execute(QueueableContext context) {
        System.debug('Inside QCC_ClosePendingRecoveryCaseQueuable execute');
        
        CaseStatusUpdateHandler.updateCase(mapOfRStatusNCase, noGoodWillCases);
        
    }
}