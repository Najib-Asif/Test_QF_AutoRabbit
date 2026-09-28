public class QCC_InvokeEmailBatchFromFlow {
    @InvocableMethod(label='Send Recovery Emails In Batch')
    public static void runBatch(List<EmailRequests> emailRequests) {
        Database.executeBatch(new QCC_SendRecoveryEmailBatch(emailRequests), 10); // 1 = 1 dummy user record per scope
    }
}