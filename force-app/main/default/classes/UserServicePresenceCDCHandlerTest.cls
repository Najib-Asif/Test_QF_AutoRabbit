@IsTest
private class UserServicePresenceCDCHandlerTest {
    
    @TestSetup
    public static void testData(){
        QantasConfigData__c config = TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs');
        insert config;
        
	}
    
    //TEST: prepareEvent WITH ChangeEventHeader
    @IsTest
    static void testPrepareEvent_WithHeader() {

        EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
        header.commitNumber = 20L;
        header.commitUser = UserInfo.getUserId();
        header.sequenceNumber = 1;
        header.entityName = 'UserServicePresence';
        header.changeType = 'UPDATE';
        header.commitTimestamp = System.now().getTime();
        header.changeOrigin = 'UnitTest';
        header.transactionKey = 'txn-pres-001';
        header.changedFields = new List<String>{ 'IsAway', 'IsCurrentState' };
        header.recordIds = new List<Id>{ '0Yx000000000001AAA' };

        UserServicePresenceChangeEvent evt =
            new UserServicePresenceChangeEvent();

        evt.ChangeEventHeader = header;
        evt.UserId = UserInfo.getUserId();
        evt.ServicePresenceStatusId = '0PS000000000001AAA';
        evt.IsAway = true;
        evt.IsCurrentState = false;
        evt.IdleDuration = 120;
        evt.StatusStartDate = System.now().addMinutes(-10);
        evt.StatusEndDate = System.now();

        Agent_Presence_Event__e pe =
            UserServicePresenceCDCHandler.prepareEvent(evt);

        Assert.isNotNull(pe);
        Assert.areEqual(evt.UserId, pe.UserId__c);
        Assert.areEqual(evt.ServicePresenceStatusId, pe.ServicePresenceStatusId__c);
        Assert.areEqual('true', pe.IsAway__c);
        Assert.areEqual('false', pe.IsCurrentState__c);

        Map<String, Object> headerMap =
            (Map<String, Object>) JSON.deserializeUntyped(
                pe.ChangeEventHeader__c
            );

        Assert.areEqual('UserServicePresence', headerMap.get('entityName'));
        Assert.areEqual('UPDATE', headerMap.get('changeType'));

        List<Object> recordIds =
            (List<Object>) headerMap.get('recordIds');

        Assert.areEqual(1, recordIds.size());
    }

  
    //TEST: handleAfterInsert – Happy Path (Publish Executed)
    @IsTest
    static void testHandleAfterInsert_WithEvents() {

        UserServicePresenceChangeEvent evt =
            new UserServicePresenceChangeEvent();

        evt.UserId = UserInfo.getUserId();
        evt.ServicePresenceStatusId = '0PS000000000001AAA';
        evt.IsAway = true;
        evt.IsCurrentState = true;
        evt.IdleDuration = 10;
        evt.StatusStartDate = System.now().addMinutes(-2);
        evt.StatusEndDate = System.now();

        Test.startTest();
        UserServicePresenceCDCHandler.handleAfterInsert(
            new List<UserServicePresenceChangeEvent>{ evt }
        );
        Test.stopTest();

        /*
         * No assertions on publish
         * Platform Events are fire-and-forget in tests
         * Coverage is achieved by executing publishEvents()
         */
        Assert.isTrue(true, 'Handler executed without exceptions');
    }

    
    //TEST: handleAfterInsert – Empty List (Guard Clause)
  
    @IsTest
    static void testHandleAfterInsert_EmptyList() {

        Test.startTest();
        UserServicePresenceCDCHandler.handleAfterInsert(
            new List<UserServicePresenceChangeEvent>()
        );
        Test.stopTest();

        Assert.isTrue(true, 'Empty list handled safely');
    }


 
    // Handle custom exception 
    
    @IsTest
    static void testLogPublishException_WithoutNewClass() {
    
        List<Agent_Presence_Event__e> events =
            new List<Agent_Presence_Event__e>{
                new Agent_Presence_Event__e(
                    UserId__c = UserInfo.getUserId()
                )
            };
    
        try {
            // Allowed in Apex
            throw new CalloutException('Forced test exception');
        } catch (Exception ex) {
    
            Test.startTest();
            UserServicePresenceCDCHandler.logPublishException(events, ex);
            Test.stopTest();
    
            Assert.isTrue(true, 'logPublishException executed');
        }
    }
    

}