/*****************************************************************************************
* Created By		Leslie Padilla | ACN | Developer 
* Purpose			Test class for QCC_CallHandlingFlowHelper
* REST API			No Rest API Needed 
* Modified Date		21/04/23 (DD/MM/YYYY)
* Modified By		
* JIRA				ADT-189 - Ability to Verify caller
* Version			1.1 Initial Development

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. 
******************************************************************************************/
@isTest
public class QCC_CallHandlingFlowHelperTest {
    
    @testSetup 
    static void setup() {
        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        
        insert lsttrgStatus;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PlaceHolderAccRectype','Placeholder'));
        upsert lstConfigData;
        
        List<QantasConfigData__c> lstConfigDataExc = new List<QantasConfigData__c>();
        lstConfigDataExc.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigDataExc;
        
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Map<String, StaticResource> resourceMap = new Map<String, StaticResource>();
        for(StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name LIKE 'QCCTestData%']) {
            resourceMap.put(sr.Name, sr);
        }
        String contactJSON = resourceMap.get('QCCTestData_ADT_Contact').Body.toString();
        contactJSON = contactJSON.replaceAll('RecordTypeIdValue', contactRecordTypeId);
        contactJSON = contactJSON.replaceAll('1002918361', '2002918361');
        List<sObject> contactRecord = (List<sObject>) JSON.deserialize(contactJSON, List<sObject>.class);
        insert contactRecord;
    }
    
    @isTest
    static void createAnonymisedContactTest(){ 
        List<QCC_CallHandlingFlowHelper.FlowInputs> requests = new List<QCC_CallHandlingFlowHelper.FlowInputs>();
        QCC_CallHandlingFlowHelper.FlowInputs request = new QCC_CallHandlingFlowHelper.FlowInputs();
        
        //set flow inputs
        request.methodName = 'createAnonymisedContact';
        requests.add(request);
        List<QCC_CallHandlingFlowHelper.FlowOutputs> results = QCC_CallHandlingFlowHelper.createAnonymisedContact(requests);
        system.assertEquals(true, String.IsNotBlank(results[0].contactId));
    }
    
    @isTest
    public static void getContactBasedOnFFTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        flowInputs.ffNumber = '002002918361';
        flowInputs.RecordTypeId = contactRecordTypeId;
        flowInputs.methodName = 'getContactBasedOnFF';
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.assertEquals('2002918361', flowOutputsList[0].contactRecord.Frequent_Flyer_Number__c);
    }
    @isTest
    public static void getExistingNonFFContTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        flowInputs.RecordTypeId = contactRecordTypeId;
        flowInputs.methodName = 'getExistingNonFFCont';
        flowInputs.firstName = 'One';
        flowInputs.lastName = 'nonFFCaller';
        flowInputs.phoneInput = '+61 0463747887';
        flowInputs.emailInput = 'one.nonffcaller@qantas.com.au';
        
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
    }
    @isTest
    public static void removeSpaceTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        
        flowInputs.pnr = '6AO7ST ';
        flowInputs.methodName = 'removeSpace';
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.assertEquals('6AO7ST', flowOutputsList[0].pnr);
    }
    
    @isTest
    public static void validateEmailTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        
        flowInputs.emailInput = 'test.email@testclass.com.au/en';
        flowInputs.methodName = 'validateEmail';
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.assertEquals(false, flowOutputsList[0].isEmailValid);
    }
    
    @isTest
    public static void validatePhoneTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        flowInputs.phoneInput = '61 0346765456';
        flowInputs.methodName = 'validatePhone';
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs2 = new QCC_CallHandlingFlowHelper.FlowInputs();       
        flowInputs2.phoneInput = '+61 0346765456';
        flowInputs2.methodName = 'validatePhone';
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs3 = new QCC_CallHandlingFlowHelper.FlowInputs();       
        flowInputs3.phoneInput = '346765456';
        flowInputs3.methodName = 'validatePhone';
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs4 = new QCC_CallHandlingFlowHelper.FlowInputs();       
        flowInputs4.phoneInput = '+61 346765456';
        flowInputs4.methodName = 'validatePhone';
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs5 = new QCC_CallHandlingFlowHelper.FlowInputs();       
        flowInputs5.phoneInput = '46765456';
        flowInputs5.methodName = 'validatePhone';
        
        flowInputsList.add(flowInputs);
        flowInputsList.add(flowInputs2);
        flowInputsList.add(flowInputs3);
        flowInputsList.add(flowInputs4);
        flowInputsList.add(flowInputs5);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
    }
    
    //Added the test method for CRM-6319
    @isTest
    public static void createNewFFContactTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact newCont=new Contact(Frequent_Flyer_Number__c='2002918362',firstname='TestCont',lastname='ContCont',email='test.email@testclass');
        QCC_CallHandlingFlowHelper.FlowOutputs flowOut=new QCC_CallHandlingFlowHelper.FlowOutputs();
        
        flowInputs.ffNumber = '2002918362';
        flowInputs.methodName = 'createNewFFContact';
        flowInputs.RecordTypeId = contactRecordTypeId;
        flowInputs.contactRecInput=newCont;
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        
        Test.stopTest();
    }
    
    //Added the method for CRM-6320
    @isTest
    public static void createNewNonFFContactTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact newCont=new Contact(firstname='TestCont',lastname='ContCont',email='test.email@qantas.com',phone='87564857487');
        QCC_CallHandlingFlowHelper.FlowOutputs flowOut=new QCC_CallHandlingFlowHelper.FlowOutputs();
        
        flowInputs.methodName = 'createNewNonFFContact';
        flowInputs.emailInput = newCont.Email;
        flowInputs.contactRecInput=newCont;
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        
        Test.stopTest();
    }
    
    //Added the method for CRM-6910
    @isTest
    public static void getFourParamsFromTheCaseTest(){
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        
        Case newCase=new Case(subject='Test Case',recordtypeid=caseRecordTypeId,First_Name__c='test',Last_Name__c='contact',Contact_Email__c='test.contact@qantas.com.au',Contact_Phone__c='+61465776556');
        insert newCase;
        QCC_CallHandlingFlowHelper.FlowOutputs flowOut=new QCC_CallHandlingFlowHelper.FlowOutputs();
        
        flowInputs.methodName = 'getFourParamsFromTheCase';
        flowInputs.caseID = newCase.id;
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        
        Test.stopTest();
    }
    
    //Added the method for CRM-6910
    @isTest
    public static void searchAllContactsTest()
    {
        List<QCC_CallHandlingFlowHelper.FlowInputs> flowInputsList = new List<QCC_CallHandlingFlowHelper.FlowInputs>(); 
        
        QCC_CallHandlingFlowHelper.FlowInputs flowInputs = new QCC_CallHandlingFlowHelper.FlowInputs();       
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        Contact newCont=new Contact(recordtypeid=contactRecordTypeId,firstname='TestCont',lastname='ContCont',email='test.email@qantas.com',phone='87564857487');
        QCC_CallHandlingFlowHelper.FlowOutputs flowOut=new QCC_CallHandlingFlowHelper.FlowOutputs();
        
        insert newCont;
        
        flowInputs.methodName = 'searchAllContacts';
        flowInputs.firstName = newCont.firstname;
        flowInputs.lastName=newCont.lastname;
        flowInputs.emailInput=newCont.Email;
        flowInputs.phoneInput=newCont.Phone;
        flowInputsList.add(flowInputs);
        
        List<QCC_CallHandlingFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_CallHandlingFlowHelper.FlowOutputs>();
        
        Test.startTest();
        flowOutputsList = QCC_CallHandlingFlowHelper.invokeThisMethod(flowInputsList);
        
        Test.stopTest();
    }
}