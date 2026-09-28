/*
Purpose : Test Class for QAC_CaseOwnerHistoryController which displays case owner from history
Developed By : 
Yuvraj :        For My Agency profile response
Main Class :    QAC_CaseOwnerHistoryController

Modified By : Venkata Suresh Kumar Yalla (TCS Team), 29-May-2026
Desc : Rmediated test class failures. Updated caseAssignToUser(), caseAssignToQueue() method. Updated 'Platinum One & SSU Service' profile ref with 'Qantas Service Lightning' 
*/
@isTest
private class QAC_CaseOwnerHistoryController_Test 
{   
    @testSetup
    static void datasetup()
    {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
    }
    
    @isTest
    public static void caseAssignToUser()
    {        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        user newuser1 = new user(FirstName = 'User1',
                                 LastName = 'Manager',
                                 Email = 'user1M@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User1 Manager',
                                 Username = 'user1M@yopmail.com',
                                 Alias = 'user1',
                                 //ProfileId = profMap.get('Platinum One & SSU Service').Id, //CRM-11408 Commented line
                                 ProfileId = profMap.get('Sales and Distribution-Sales').Id, //CRM-11408 Added line //RBAC SND
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney');
        insert newuser1;
        
        //RBAC SND - Permission Set Update
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Sales_Account_Manager_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(newuser1.Id,permissionSetIds);
        }
        system.runAs(newuser1)
        {
            string agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
            
            Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                            RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',BillingCountry='NZ',
                                            Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9797979');
            insert myAccount;
            String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            Case newCase1 = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                     Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Open',
                                     Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                     AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                     PNR_number__c = '454599',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
            
            insert newCase1;
            Test.startTest();
            
            QAC_CaseOwnerHistoryController.returnCaseHistory(newCase1.Id);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void caseAssignToQueue()
    {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        Case newCase3;
        //user newuser2 = [select id,Username,firstname,lastname from user where Username = 'user2M@yopmail.com'];
        user newuser3 = new user(FirstName = 'User3',
                                 LastName = 'Manager',
                                 Email = 'user3M@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User2 Manager',
                                 Username = 'user3M@yopmail.com',
                                 Alias = 'user1',
                                 //ProfileId = profMap.get('Platinum One & SSU Service').Id, //CRM-11408 Commented line
                                 ProfileId = profMap.get('Sales and Distribution-Sales').Id, //CRM-11408 Added line //RBAC SND - Profile Update
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney');
        insert newuser3;
		//RBAC SND - Permission Set Update
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Sales_Account_Manager_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(newuser3.Id,permissionSetIds);
        }
        //Create a Queue
        group newQueue = new group (name='TestQueue',type='Queue');
        insert newQueue;
        
        //Add user to the queue
        groupmember adduser = new groupmember();
        adduser.GroupId = newQueue.Id;
        adduser.UserOrGroupId = newuser3.Id;
        insert adduser;
        
        //Assign queue to the SObject
        QueuesObject caseQueue = new QueueSObject(QueueID = newQueue.id, SObjectType = 'Case');
        insert caseQueue;
        
        system.runAs(newuser3)
        {
            string agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
            
            Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                            RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',BillingCountry='NZ',
                                            Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '8797979');
            insert myAccount;
            
            String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
            newCase3 = new Case(External_System_Reference_Id__c = 'C-002002002009',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Open',
                                Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                PNR_number__c = '654546',Old_PNR_Number__c = '1021513',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
            
            insert newCase3;
            newCase3.ownerid = newQueue.Id;
            update newCase3;
            
            test.startTest();
            QAC_CaseOwnerHistoryController.returnCaseHistory(newCase3.Id);
            Test.stopTest();
        }
    }
}