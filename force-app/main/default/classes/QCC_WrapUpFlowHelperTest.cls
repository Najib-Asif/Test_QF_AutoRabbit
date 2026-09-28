/*****************************************************************************************
* Created By		Veni Gonzales | ACN | Developer 
* Purpose			Test class for QCC_CallHandlingFlowHelper
* REST API			No Rest API Needed 
* Modified Date		21/04/23 (DD/MM/YYYY)
* Modified By		
* JIRA				ADT-189 - Ability to Verify caller
* Version			1.1 Initial Development
******************************************************************************************/
@isTest
public class QCC_WrapUpFlowHelperTest {
    @testSetup static void setup() {
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
    
    @isTest
    public static void getLatestTaskTest(){
        List <Task> taskList = [SELECT ID, CallObject, CallType, WhoId, TaskSubtype, TECH_Genesys_Participant_Id__c FROM Task LIMIT 1];
       	taskList[0].TECH_Genesys_Participant_Id__c = '65a6a20d-b569-456e-8d2b-b5fed16cedec';
        update taskList[0];
        List<QCC_WrapUpFlowHelper.FlowInputs> flowInputsList = new List<QCC_WrapUpFlowHelper.FlowInputs>();
        QCC_WrapUpFlowHelper.FlowInputs flowInputs = new QCC_WrapUpFlowHelper.FlowInputs();
        flowInputs.methodName = 'getLatestTask';
        flowInputs.callInteractionId = taskList[0].CallObject;
        flowInputs.callParticipantId = taskList[0].TECH_Genesys_Participant_Id__c;    
        flowInputsList.add(flowInputs);
        
        List<QCC_WrapUpFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_WrapUpFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_WrapUpFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.assertEquals(taskList[0].Id, flowOutputsList[0].taskRecord.Id);
        System.assertEquals(taskList[0].CallObject, flowOutputsList[0].taskRecord.CallObject);
    }
    
    @isTest
    public static void getFaultPathErrorTest(){
        
        List<QCC_WrapUpFlowHelper.FlowInputs> flowInputsList = new List<QCC_WrapUpFlowHelper.FlowInputs>();
        QCC_WrapUpFlowHelper.FlowInputs flowInputs = new QCC_WrapUpFlowHelper.FlowInputs();
        flowInputs.methodName = 'getFaultPathError';
        flowInputs.faultMessage = 'Error String';   
        flowInputsList.add(flowInputs);
        
        List<QCC_WrapUpFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_WrapUpFlowHelper.FlowOutputs>();
        Test.startTest();
        	flowOutputsList = QCC_WrapUpFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
		
        List<Log__c> errLog = [SELECT Id, Class_Name__c, Method_Name__c, Error_Message__c from Log__c limit 1];
        
        System.assert( errLog != null);
        System.assertEquals(errLog[0].Class_Name__c, 'QCC_WrapUpFlowHelper');
        System.assertEquals(errLog[0].Method_Name__c, 'getFaultPathError');
        System.assertEquals(errLog[0].Error_Message__c, 'Error String');
    }
    
}