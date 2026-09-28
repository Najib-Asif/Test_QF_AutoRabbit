/********
* Created By : Van Cabezas | ACN | Developer 
* Purpose : Test Class for QantasExtension
* REST API : No Rest API Needed

Modified Date   : 27/01/23 (DD/MM/YYYY)
Modified By     : Van Cabezas
JIRA            : ADT-25, ADT-207
Version         : 1.2 -Initial Development | van
*/
@isTest
private class QCC_PurecloudExtensionTest {
        /***************************
             *  Purpose             : Create test record for case
             *  Parameters          : 
             *  Returns             : 
             * 
             *  Throws
             *  Expectations        :
    */
    @testSetup
    static void createCaseData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        update statToUpdate;
        Trigger_Status__c ts1 = new Trigger_Status__c(); 
        ts1.Name = 'QCC_SetNonFFContactOnCase'; 
        ts1.Active__c = false; insert ts1;
        
        Trigger_Status__c ts2 = new Trigger_Status__c(); 
        ts2.Name = 'CCCVoice_CaseTrigger_Switch'; 
        ts2.Active__c = false; 
        insert ts2;
        
    }
    /***************************
             *  Purpose             : Test for onSaveLog Inbound call
             *  Parameters          : 
             *  Returns             : 
             * 
             *  Throws
             *  Expectations        :
    */
    @isTest
    static void testOnSaveLogInbound(){
       try
       {
           Task newTask = new Task();
        insert newTask; 
        String testData = '{"interaction":{"isDisconnected":true,"direction":"Inbound","isMessage":false,"isInternal":true,"phone":""},"callLog":{"calldurationinseconds":16,"id":"'+newTask.id+'"}}';
        
        QCC_PurecloudExtension var = new QCC_PurecloudExtension();
        Test.startTest();
        String Result = var.onSaveLog(testData);
        Test.stopTest();
        
        //Task TaskCreated = [Select QCC_Caller_Verified__c From Task where Id =: newTask.id];
        //System.assertEquals('No', TaskCreated.QCC_Caller_Verified__c);
        System.assertEquals(newTask.id, Result);
       }
       catch(Exception e)
       {
           system.debug('Exception has occurred'+e.getmessage());
       }
        
    }
    
    /***************************
             *  Purpose             : Test for onSaveLog Outbound call
             *  Parameters          : 
             *  Returns             : 
             * 
             *  Throws
             *  Expectations        :
    */
    @isTest
    static void testOnSaveLogOutbound(){
        try
        {
             Task newTask = new Task();
            insert newTask; 
            String testData = '{"interaction":{"isDisconnected":true,"direction":"Outbound","state":"CONNECTED","isMessage":false,"isInternal":false,"phone":""},"callLog":{"calldurationinseconds":16,"id":"'+newTask.id+'"}}';
            
            QCC_PurecloudExtension var = new QCC_PurecloudExtension();
            Test.startTest();
            String Result = var.onSaveLog(testData);
            Test.stopTest();
            
            Task TaskCreated = [Select Subject From Task where Id =: newTask.id];
            System.assertEquals('Outbound Call', TaskCreated.Subject);
            System.assertEquals(newTask.id, Result);
        }
        catch(exception e)
        {
            system.debug('Exception has occurred'+e.getmessage());
        }
    }
    /***************************
             *  Purpose             : Test for onScreenPop create new Case
             *  Parameters          : 
             *  Returns             : 
             * 
             *  Throws
             *  Expectations        :
    */
    @isTest
    static void testOnScreenPopNewCase(){
        Id b2cRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact newContactWithFf = new Contact(LastName = 'sample', Frequent_Flyer_Number__c = '1234567890', RecordTypeId = b2cRecTypeId);
        insert newContactWithFf; 
        
        String testData = '{"interaction":{"attributes":{"Participant.CaseNumber":"","Participant.EnquiryType":"Credit","Participant.QFFNumber":"1234567890","Participant.BookingPNR":"1I4LY3"},"isMessage":false,"isInternal":false}}';
        
        QCC_PurecloudExtension var = new QCC_PurecloudExtension();
        Test.startTest();
        String Result = var.onScreenPop(testData);
        Test.stopTest();
        
        Case caseCreated = [Select ID From Case where ContactId =: newContactWithFf.id Order by CreatedDate desc limit 1];
        String toReturn = '{"defaultScreenPop":false,"url":"/lightning/r/Case/' + caseCreated.id + '/view"}';
        //System.assertEquals('Not Applicable', TaskCreated.QCC_Caller_Verified__c);
        System.assertEquals(toReturn, Result, 'Error on Case Create');
    }
    /***************************
             *  Purpose             : Test for onScreenPop create new Case
             *  Parameters          : 
             *  Returns             : 
             * 
             *  Throws
             *  Expectations        :
    */
    @isTest
    static void testOnScreenPopUpdateCase(){
        Id b2cRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact newContactWithFf = new Contact(LastName = 'sample', Frequent_Flyer_Number__c = '1234567890', RecordTypeId = b2cRecTypeId);
        Case newCase = new Case(Subject = 'Test Case');
        insert newContactWithFf;
        insert newCase;
        Case caseCreated = [Select ID, CaseNumber From Case where ID =: newCase.id Order by CreatedDate desc limit 1];
        String testData = '{"interaction":{"attributes":{"Participant.CaseNumber":"' + caseCreated.CaseNumber + '","Participant.EnquiryType":"Credit","Participant.QFFNumber":"1234567890","Participant.BookingPNR":"1I4LY3"},"isMessage":false,"isInternal":false}}';
        QCC_PurecloudExtension var = new QCC_PurecloudExtension();
        Test.startTest();
        String Result = var.onScreenPop(testData);
        Test.stopTest();
        
        String toReturn = '{"defaultScreenPop":false,"url":"/lightning/r/Case/' + caseCreated.id + '/view"}';
        //System.assertEquals('Not Applicable', TaskCreated.QCC_Caller_Verified__c);
        System.assertEquals(toReturn, Result, 'Error on Update');
    }
    //Test method for onClickToDial
      @isTest
    static void testonClickToDialGeneralQueue()
    {
        Id b2cRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        test.starttest();
        Case newCase = new Case(Subject = 'Test Case',recordtypeid=b2cRecTypeId, contact_phone__c='61123123123');
        insert newCase;
        
        Case caseCreated = [Select ID,contact_phone__c, CaseNumber From Case where ID =: newCase.id Order by CreatedDate desc limit 1];
        String testData = '{"number":'+newCase.contact_phone__c+',"objectId":"'+newCase.id+'","objectName":"'+newCase.CaseNumber+'","object":"Case"}';
        //Map<String,object> maptestData=(Map<String,Object>)JSON.deserializeUntyped(testData);
        //testData =(String)JSON.serialize(maptestData);
        
        QCC_PurecloudExtension obj=new QCC_PurecloudExtension();
         obj.onClickToDial(testData);
         test.stoptest();

    }
    //Test method2 for onClickToDial
     @isTest
    static void testonClickToDialOutboundLastQueue()
    {
        Id b2cRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        Test.startTest();
        Case newCase = new Case(Subject = 'Test Case',recordtypeid=b2cRecTypeId, contact_phone__c='61123123123');
        insert newCase;
        
            Task newTask = new Task();
            newTask.whatid=newCase.id;
            //newTask.CallObject='6a0f6216-7acb-4fb8-810d-0512b86347aa';
        	newTask.CallObject='6a0f62167acb4fb8810d0512b86347aa';
            newTask.CallType='Outbound';
            insert newTask; 
        
            String testData = '{"interaction":{"id":"'+newTask.CallObject+'","isDisconnected":true,"direction":"Outbound","state":"CONNECTED","isMessage":false,"isInternal":false,"phone":""},"callLog":{"calldurationinseconds":16,"id":"'+newTask.id+'"}}';
            
            QCC_PurecloudExtension var = new QCC_PurecloudExtension();
            var.onSaveLog(testData);
            
            Task TaskCreated = [Select Subject,whatid,callobject From Task where Id =: newTask.id];
        
        	Case caseCreated = [Select ID,contact_phone__c, CaseNumber From Case where ID =: newCase.id Order by CreatedDate desc limit 1];
        	String testDataCase = '{"number":'+newCase.contact_phone__c+',"objectId":"'+newCase.id+'","objectName":"'+newCase.CaseNumber+'","object":"Case"}';
        
        	var.onClickToDial(testDataCase);
			Test.stopTest();
    }
    //Test method3 for onClickToDial
    @isTest
    static void testonClickToDialExceptionQueue()
    {
        Id b2cRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        Case newCase = new Case(Subject = 'Test Case',recordtypeid=b2cRecTypeId, contact_phone__c='+61123123123');
        insert newCase;
        
        Case caseCreated = [Select ID,contact_phone__c, CaseNumber From Case where ID =: newCase.id Order by CreatedDate desc limit 1];
        String testData = '{"number":"'+newCase.contact_phone__c+'","objectId":"'+newCase.id+'","objectName":"'+newCase.CaseNumber+'","object":"Case"}';
        
        QCC_PurecloudExtension obj=new QCC_PurecloudExtension();
         obj.onClickToDial(testData);

    }
}