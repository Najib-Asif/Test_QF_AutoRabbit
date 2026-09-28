/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_CaseQueueAssignment , QAC_LogoutController
*/
@isTest
public class QAC_CaseQueueAssignment_Test {

    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();

        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                            RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                            Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
            insert myAccount;
    
            // inserting Case
            Case parentCase = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                       Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Closed',
                                       Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                       AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                       PNR_number__c = '454545',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
            insert parentCase;
            
            Case newCase = new Case(External_System_Reference_Id__c = 'C-002002002003',ParentId = parentCase.Id,Origin = 'QAC Website',
                                    Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Credit',Status = 'Open',RecordTypeId = caseRTId,
                                    Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                    AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                    PNR_number__c = '454546',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic');   
            insert newCase;
        }
        
        list<Group> groupLists = new list<Group>();
        for(Integer i=0;i<2;i++){
            Group eachG = new Group(Name='QAC_test'+i, Type='Queue');
            groupLists.add(eachG);
        }
        insert groupLists;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            list<QueuesObject> queueLists = new list<QueuesObject>();
            for(Integer j=0;j<2;j++){
                QueuesObject eachQ = new QueueSObject(QueueID = groupLists[j].id, SObjectType = 'Case');
                queueLists.add(eachQ);
            }
            insert queueLists;
        }        
    }
    
    // This method covers the test for QAC_CaseQueueAssignment
    @isTest 
    public static void caseQueueAssgTest()
    {
        String queueName = 'QAC_test0';
        Test.startTest();
            QAC_CaseQueueAssignment.getQACCaseQueues();
            QAC_LogoutController.getSignOutURL();
            QAC_CaseQueueAssignment.assignCaseQueue(queueName);
            QAC_CaseQueueAssignment.modifyCacheSettings();
        Test.stopTest();
    }

    // This method covers the test for QAC_LogoutController
    @isTest 
    public static void logoutTest()
    {
        Test.startTest();
            list<Case> allCases = [Select Id from Case];
            delete allCases;
            QAC_LogoutController.getSignOutURL();
        Test.stopTest();
    }
    
    // This method covers the test for QAC_CaseQueueAssignment's Catch Block
    @isTest 
    public static void exceptionCQATest()
    {
        try
        {
            system.debug('Inside Excep');
            String queueName = 'Sample';
            
            Test.startTest();
            QAC_CaseQueueAssignment.assignCaseQueue(queueName);
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
}