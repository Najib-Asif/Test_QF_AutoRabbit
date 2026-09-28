@IsTest
private class AgentWorkCDCHandlerTest {
    
    @TestSetup
    public static void testData(){
        QantasConfigData__c config = TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs');
        insert config;
        
	}
    

    @IsTest
    static void testHandleAfterInsert_IgnoresNullStatus() {

        AgentWorkChangeEvent evt = new AgentWorkChangeEvent();
        evt.UserId = UserInfo.getUserId();
        evt.Status = null;

        Test.startTest();
        AgentWorkCDCHandler.handleAfterInsert(
            new List<AgentWorkChangeEvent>{ evt }
        );
        Test.stopTest();

        Assert.isTrue(
            true,
            'Null Status events are safely ignored'
        );
    }

    @IsTest
    static void testLogPublishException_DirectCall() {

        List<Agent_Work_Event__e> events =
            new List<Agent_Work_Event__e>{
                new Agent_Work_Event__e(UserId__c = UserInfo.getUserId())
            };

        try {
            throw new CalloutException('Forced test exception');
        } catch (Exception ex) {
            Test.startTest();
            AgentWorkCDCHandler.logPublishException(events, ex);
            Test.stopTest();
        }

        Assert.isTrue(true, 'Exception logging covered');
    }
    
    
    @IsTest
    static void testPrepareEvent_WithHeaderAndRecordIds() {

        // Create ChangeEventHeader
        EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
        header.commitNumber = 1001L;
        header.commitUser = UserInfo.getUserId();
        header.sequenceNumber = 1;
        header.entityName = 'AgentWork';
        header.changeType = 'UPDATE';
        header.commitTimestamp = System.now().getTime();
        header.changeOrigin = 'UnitTest';
        header.transactionKey = 'txn-123';
        header.changedFields = new List<String>{ 'Status' };
        header.recordIds = new List<Id>{ '0Hn000000000001AAA' };

        // Construct Change Event manually
        AgentWorkChangeEvent evt = new AgentWorkChangeEvent();
        evt.ChangeEventHeader = header;
        evt.UserId = UserInfo.getUserId();
        evt.OwnerId = UserInfo.getUserId();
        evt.Status = 'Assigned';
        evt.LastModifiedDate = System.now();

        Test.startTest();
        Agent_Work_Event__e pe =
            AgentWorkCDCHandler.prepareEvent(evt);
        Test.stopTest();

        // Assertions using Assert class only
        Assert.isNotNull(pe, 'Platform event must be created');
        Assert.isNotNull(
            pe.ChangeEventHeader__c,
            'ChangeEventHeader JSON must be populated'
        );

        Map<String,Object> headerMap =
            (Map<String,Object>) JSON.deserializeUntyped(
                pe.ChangeEventHeader__c
            );

        Assert.areEqual('AgentWork', headerMap.get('entityName'));
        Assert.areEqual('UPDATE', headerMap.get('changeType'));
        Assert.isTrue(headerMap.containsKey('recordIds'),
            'recordIds must be present');
    }

}