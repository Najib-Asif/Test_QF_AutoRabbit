/*****************************************************************************************
* Created By : Veni Gonzales | ACN | Developer 
* Purpose : Test Class for QCCTaskController
* Modified Date   : 14/04/23 (DD/MM/YYYY)
* Modified By     : Veni Gonzales
* Version         : 1.2 
******************************************************************************************/
@isTest
public class QCCTaskControllerTest {
    /************************************
     * Purpose      : Insert test data 
     * Expectations : Will be used in the test methods below
     ************************************/
    @testSetup static void setup() {
        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        update statToUpdate;

        Trigger_Status__c ts1 = new Trigger_Status__c();
        ts1.Name = 'QCC_SetNonFFContactOnCase';
        ts1.Active__c = false;
        insert ts1;
        
        //Case test data
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        
        Map<String, StaticResource> resourceMap2 = new Map<String, StaticResource>();
            for (StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name = 'QCCTestData_ADT_Case']) {
                resourceMap2.put(sr.Name, sr);
            }
        String caseJSON = resourceMap2.get('QCCTestData_ADT_Case').Body.toString();
        caseJSON = caseJSON.replaceAll('RecordTypeIdValue', caseRecordTypeId);
        System.debug('@@@ caseJSON: '+ caseJSON);
        List<Case> caseRecords = (List<Case>) JSON.deserialize(caseJSON, List<Case>.class);
        insert caseRecords;
        
        Case cas = [SELECT Id from Case LIMIT 1];
        
        //Task test data
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        
        Map<String, StaticResource> resourceMap1 = new Map<String, StaticResource>();
            for (StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name = 'QCCTestData_ADT_Task']) {
                resourceMap1.put(sr.Name, sr);
            }
        String taskJSON = resourceMap1.get('QCCTestData_ADT_Task').Body.toString();
        taskJSON = taskJSON.replaceAll('RecordTypeIdValue', taskRecordTypeId);
        taskJSON = taskJSON.replaceAll('WhatIdValue', cas.Id);
        List<Task> taskRecords = (List<Task>) JSON.deserialize(taskJSON, List<Task>.class);
        insert taskRecords;
    }
	
    /************************************
     * Purpose      : To test getCaseFromTask method in QCCTaskController
     * Parameter    : CallObject of the task record
     * Returns      : A Task List
     ************************************/
    @isTest
    static void testGetCaseFromTask(){    
        Task tas = [SELECT Id, CallObject FROM Task LIMIT 1];
                    
        Test.startTest();
			List<Task> lstTask = QCCTaskController.getCaseFromTask(tas.CallObject);
        	System.assert( lstTask != null);
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCaseFromTask method in QCCTaskController
     ************************************/
    @isTest
    static void testNoCaseFromTaskRetrieved(){    
        Task tas = [SELECT Id, CallObject FROM Task LIMIT 1];

        test.startTest();
       	 	List<Task> lstTask = QCCTaskController.getCaseFromTask('Incorrect CallObject');
        	System.assertEquals ( lstTask, null);
        test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCallReasonWrapupCode method in QCCTaskController
     ************************************/
    @isTest
    static void testGetCallReasonWrapupCode(){    
        Task tas1 = [SELECT Id, QCC_IVR_Selection__c, QCC_Call_Reason__c, CallObject FROM Task 
                    WHERE TaskSubtype='Call'  
                    AND QCC_Call_Reason__c ='Flight Credits & Travel Passes' LIMIT 1];
                    
        Test.startTest();
			String strWrapupCode = QCCTaskController.getCallReasonWrapupCode(tas1.CallObject);
        	System.assert(strWrapupCode != null );  

            Task tas2 = [SELECT Id, QCC_Call_Reason__c FROM Task WHERE Id =: tas1.Id ];
            String callReason = tas2.QCC_Call_Reason__c;
            QCC_Call_Reason_Wrapup_Code__mdt[] lstIVRmdt2 = [SELECT MasterLabel, Wrapup_Code__c 
            FROM QCC_Call_Reason_Wrapup_Code__mdt WHERE MasterLabel =: callReason];
        
            System.assertEquals('Flight Credits & Travel Passes', lstIVRmdt2[0].MasterLabel);    
        	System.assertEquals('b55caaac-5e71-49a6-8815-50dd0e71df47', lstIVRmdt2[0].Wrapup_Code__c);  
        	System.assertEquals(strWrapupCode, lstIVRmdt2[0].Wrapup_Code__c); 
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCallReasonWrapupCode method in QCCTaskController
     ************************************/
    @isTest
    static void testNoCallReasonWrapupCode1(){    
        Task tas = [SELECT Id, CallObject FROM Task WHERE TaskSubtype='Call' LIMIT 1];
                    
        Test.startTest();
			String strWrapupCode = QCCTaskController.getCallReasonWrapupCode('Incorrect CallObject');
        	System.assertEquals ( null, null);
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCallReasonWrapupCode method in QCCTaskController
     ************************************/
    @isTest
    static void testNoCallReasonWrapupCode2(){    
        Task tas = [SELECT Id, CallObject FROM Task WHERE TaskSubtype='Task' LIMIT 1];
                    
        Test.startTest();
			String strWrapupCode = QCCTaskController.getCallReasonWrapupCode(tas.CallObject);
        	System.assertEquals ( null, null);
        	System.assertEquals ( '', strWrapupCode);
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getLatestTask method in QCCTaskController
     ************************************/
    @isTest
    static void testGetLatestTask(){    
        Task tas = [SELECT Id, WhatId, CallObject FROM Task LIMIT 1];
          
        Test.startTest();
			List<Task> lstTask = QCCTaskController.getLatestTask(tas.WhatId);
        	System.assert( lstTask != null);
        	System.assertEquals('Call', lstTask[0].TaskSubtype);
        Test.stopTest();
    }
	
    /************************************
     * Purpose      : To test getLatestTask method in QCCTaskController
     ************************************/
    @isTest
    static void testNoLatestTaskRetrieved1(){    
        Task tas = [SELECT Id, WhatId, CallObject FROM Task WHERE TaskSubtype='Task' LIMIT 1];

        test.startTest();
       	 	List<Task> lstTask = QCCTaskController.getLatestTask(tas.WhatId);
        	System.assertEquals( null, null);
        test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCallReason method in QCCTaskController with valid input
     ************************************/
    @isTest
    static void testGetCallReason(){    
        Task tas = [SELECT Id, QCC_IVR_Selection__c FROM Task WHERE CallType ='Inbound' LIMIT 1];
                
        Test.startTest();
			List<QCC_Case_Record_Type_IVR__mdt> lstIVRmdt1 = QCCTaskController.getCallReason(tas.QCC_IVR_Selection__c);
        	System.assert( lstIVRmdt1 != null);
        
        	QCC_Case_Record_Type_IVR__mdt[] lstIVRmdt2 = [SELECT MasterLabel, Call_Reason__c 
            FROM QCC_Case_Record_Type_IVR__mdt WHERE MasterLabel = 'Credit'];
            System.assertEquals('Credit', lstIVRmdt2[0].MasterLabel);    
        	System.assertEquals('Flight Credits & Travel Passes', lstIVRmdt2[0].Call_Reason__c);  
        Test.stopTest();
    }
	
    /************************************
     * Purpose      : To test getCallReason method in QCCTaskController invalid TaskSubtype
     ************************************/
    @isTest
    static void testNoCallReasonRetrieved1(){    
        Task tas = [SELECT Id, QCC_IVR_Selection__c, WhatId, CallObject FROM Task WHERE TaskSubtype='Task' LIMIT 1];

        test.startTest();
       	 	List<QCC_Case_Record_Type_IVR__mdt> lstIVRmdt = QCCTaskController.getCallReason(tas.QCC_IVR_Selection__c);
        	System.assertEquals( null, null);
        test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCallReason method in QCCTaskController invalid Call Reason entered
     ************************************/
    @isTest
    static void testNoCallReasonRetrieved2(){    
        Task tas = [SELECT Id, QCC_IVR_Selection__c, WhatId, CallObject FROM Task LIMIT 1];

        test.startTest();
       	 	List<QCC_Case_Record_Type_IVR__mdt> lstIVRmdt = QCCTaskController.getCallReason('Incorrect QCC_IVR_Selection__c');
        	System.assertEquals( null, null);
        test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCaseDetailsBasedOnInteraction method in QCCTaskController
     ************************************/
    @isTest
    public static void testGetCaseBasedOnInteraction(){
 		test.startTest();
        Case caseRec = [SELECT Id, Status, InteractionId__c FROM Case LIMIT 1];
        List<Case> lstCase = QCCTaskController.getCaseDetailsBasedOnInteraction(caseRec.InteractionId__c,caseRec.Id,caseRec.Id);
        System.assert( lstCase != null);
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCaseDetailsBasedOnInteraction method in QCCTaskController invalid entry
     ************************************/
    @isTest
    public static void testGetNoCaseBasedOnInteraction(){
        Test.startTest();
        Case caseRec = [SELECT Id, Status, InteractionId__c FROM Case LIMIT 1];
        List<Case> lstCase = QCCTaskController.getCaseDetailsBasedOnInteraction('Incorrect InteractionId','Incorrect CaseId','Incorrect Outbound CaseId');
        System.assertEquals ( null, null);
        Test.stopTest();
    }

    /************************************
     * Purpose      : To test getCaseDetails method in QCCTaskController 
     ************************************/
    @isTest
    static void testGetCaseDetails() {
        Test.startTest();
        Case caseRec = [SELECT Id, Status, InteractionId__c FROM Case LIMIT 1];
        Case caseRecs = [SELECT Id, Status, CaseNumber, InteractionId__c FROM Case WHERE ID = :caseRec.Id];
        List<Case> lstCase = QCCTaskController.getCaseDetails(caseRecs.InteractionId__c, caseRecs.CaseNumber, caseRecs.Id);
        System.assert( lstCase != null);
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test getCaseDetails method in QCCTaskController invalied parameters entered
     ************************************/
    @isTest
    static void testGetNoCaseDetails() {
        Test.startTest();
        Case caseRec = [SELECT Id, Status, InteractionId__c FROM Case LIMIT 1];
        Case caseRecs = [SELECT Id, Status, CaseNumber, InteractionId__c FROM Case WHERE ID = :caseRec.Id];
        String errMsg = '';
            try{
                QCCTaskController.getCaseDetails('Incorrect InteractionId', 'Incorrect CaseNumber', 'Incorrect CaseId');     
            }catch(exception e){
                errMsg = e.getMessage();
            }
        System.assertEquals(errMsg != '', true, 'Invalid entry');
        Test.stopTest();
    }
    
    /************************************
     * Purpose      : To test stampAWSURLRedirect method in QCCTaskController
     ************************************/
    @isTest
    static void teststampAWSURLRedirect(){    
        Task tas = [SELECT Id, CallObject FROM Task LIMIT 1];
        String awsURLConnection = QCC_VoiceUtils.getEnvSetting().Genesys_Wrap_Up_URL__c;

        test.startTest();
        Task taskForUpdate = QCCTaskController.stampAWSURLRedirect(awsURLConnection, tas.Id);
        System.assertEquals(true, taskForUpdate.Id != NULL);
        test.stopTest();
    }
    /************************************
     * Purpose      : To test stampFFOnCase method in QCCTaskController
     ************************************/
    @isTest
    static void stampFFOnCaseTest(){    
        Case cas = [SELECT Id,casenumber, Frequent_Flyer_Number__c FROM Case LIMIT 1];
        String FFNum = '2002918338';
        String caseNumber=cas.CaseNumber;

        test.startTest();
         QCCTaskController.stampFFOnCase(FFNum, caseNumber);
        test.stopTest();
    }
    /************************************
     * Purpose      : To test createTransferTask method in QCCTaskController
     ************************************/
    @isTest
    static void createTransferTaskTest(){    
        Map<String,Object> newMap=new Map<String,object>();
        newMap.put('Data','12345-76767-87654-ghgh789');
        Case cas = [SELECT Id,casenumber, Frequent_Flyer_Number__c FROM Case LIMIT 1];
        String message=JSON.serialize(newMap);
        Task createT=new Task();
        createT.Status='Open';
        createT.Subject='Voice Transer';
        createT.Type='Voice';
        createT.CallType='Outbound';
        createT.CallObject='12345-76767-87654-ghgh789';
        createT.qcc_IVR_Phone_Number__c='+61415765230';
        createT.whatid=cas.id;


        test.startTest();
        insert createT;
         QCCTaskController.createTransferTask(message);
        test.stopTest();
    }
}