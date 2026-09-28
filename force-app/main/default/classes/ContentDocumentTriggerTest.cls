@isTest(seeAllData = False)
private class ContentDocumentTriggerTest
{
    @testSetup
    static void createTestData(){
        //Enable Account, Contact,Case Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentTriggerSetting());
         lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CongaTriggerIntegrationUser','Conga Trigger Integration User'));
        insert lstConfigData;

        //Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');

        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaint';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Flight Disruptions','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');


        ContentVersion objContVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert objContVersion; 

        List<ContentDocument> objCOnDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink objCDL = New ContentDocumentLink();
        objCDL.LinkedEntityId =  lstCase[0].Id;
        objCDL.ContentDocumentId = objCOnDoc[0].Id;
        objCDL.shareType = 'V';
        insert objCDL;
        system.assert(objCDL.Id != Null, 'ContentDocumentLink is not inserted');

    }
    
    static TestMethod void eligiblityCheckOnAttachmentDelIPositive(){

        //Enable Validation 
        List<EnableValidationRule__c> lstEnableValidation = new List<EnableValidationRule__c>();
        lstEnableValidation.add(TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getprofileID()));
        insert lstEnableValidation;

        List<ContentDocument> lstConDoc = [select Id from ContentDocument Limit 1 ];
        Id conDocId = lstConDoc[0].ID;
        ContentDocumentLink objCDL = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where 
                                      ContentDocumentId =: conDocId limit 1];
        system.assert(lstConDoc.size() == 1, 'Email has not Attachment');
        Test.startTest();
        try{
            delete lstConDoc;
        }catch(Exception ex){}
        List<ContentDocument> lstAttAftDel =  [select Id from ContentDocument Where Id =: objCDL.ContentDocumentId ];
        system.assert(lstAttAftDel.size() != 1, 'Attachment is deleted');
        Test.stopTest();
    }

    

    static TestMethod void eligiblityCheckOnAttachmentDelNegative(){
        //Enable Validation 
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        enableVal.PreventAttachmentDelete__c = false;
        insert enableVal;

        List<ContentDocument> lstConDoc = [select Id from ContentDocument Limit 1 ];
        Id conDocId = lstConDoc[0].ID;
        ContentDocumentLink objCDL = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where 
                                      ContentDocumentId =: conDocId limit 1];
        system.assert(lstConDoc.size() == 1, 'Email has not Attachment');
        Test.startTest();
        delete lstConDoc;
    
        List<ContentDocument> lstcontAftDel =  [select Id from ContentDocument Where Id =: objCDL.ContentDocumentId ];
        system.assert(lstcontAftDel.size() == 0, 'Attachment is deleted');
        Test.stopTest();
    }

    static TestMethod void eligiblityCheckOnAttachmentDelException(){
        //Enable Validation 
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        enableVal.PreventAttachmentDelete__c = true;
        insert enableVal;

        Map<Id, ContentDocument> mapcontDoc = new Map<ID, ContentDocument>();
        ContentDocument objCD = new ContentDocument();
        mapcontDoc.put(null, objCD);
        system.assert(mapcontDoc.size() > 0, 'No Content Document ');
        Set<Id> contDocId = mapcontDoc.keySet();
        
        Test.startTest();
            ContentDocumentTriggerHelper.eligiblityCheckOnContentDocDel(mapcontDoc);
            List<Log__c> lstLogs = [select Id from Log__c];
            system.assert(lstLogs.size() != 0, ' Log Record is not inserted');
        Test.stopTest();
    }

    static testMethod void testAvoidingUploadFileToEvent() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        insert lsttrgStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@qantas.com.au', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        List<ContentDocument> objCOnDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.runAs(u1) {
            Event__c newEvent = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent.OwnerId = u1.Id;
            newEvent.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
            newEvent.FlightNumber__c = 'QF0001';
            newEvent.DeparturePort__c = 'SYD';
            newEvent.ArrivalPort__c = 'MEL';
            insert newEvent;
            //create ContentDocumentLink  record 
            ContentDocumentLink objCDL = New ContentDocumentLink();
            objCDL.LinkedEntityId =  newEvent.Id;
            objCDL.ContentDocumentId = objCOnDoc[0].Id;
            objCDL.shareType = 'V';
            Test.startTest();
            try {
                insert objCDL;
            } catch(Exception ex) {
                //System.assert(ex.getMessage().contains('Consultant can\'t upload file to Flight Event'));
                System.assert(ex.getMessage().contains('You do not have the level of access necessary to perform the operation'));
            }
            Test.stopTest();
        }
    }
    static testMethod void testAvoidingUploadFileToEventThrowException() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        insert lsttrgStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@qantas.com.au', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        List<ContentDocument> objCOnDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.runAs(u1) {
            Test.startTest();
            try {
                ContentDocumentLinkTriggerHelper.avoidingUploadFileToEvent(null);
            } catch(Exception ex) {
                //System.assert(ex.getMessage().contains('Consultant can\'t upload file to Flight Event'));
                System.assert(ex.getMessage().contains('Attempt to de-reference a null object'));
            }
            Test.stopTest();
        }
    }
}