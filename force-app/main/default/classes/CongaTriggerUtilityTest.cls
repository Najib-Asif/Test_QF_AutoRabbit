@IsTest
public class CongaTriggerUtilityTest {
    
    @testSetup
    static void setup() {

        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentTriggerSetting());
         lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        insert lsttrgStatus;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CongaTriggerIntegrationUser','Conga Trigger Integration User'));
        insert lstConfigData;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center,Conga, Advocacy and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(FirstName = 'Conga Trigger', LastName = 'Integration User', Alias = 'User', Email = 'sampleuser1@sample.com', 
             Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Advocacy Agent').Id,
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        List<Contact> contacts = new List<Contact>();
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        System.runAs(u1) {
            
            Account acc1 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                       RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565369',Email__c='managefile.qac@qantas.com.au',
                                       IATA_Number__c = '0239209', Tradesite__c = True);

            for(Integer i = 0; i < 2; i++) {
                    Contact con = new Contact(LastName='Sample'+i, FirstName='User', Email='test@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager',
                                                Function__c='Advisory Services', Frequent_Flyer_Number__c = '12345' + i);
                    contacts.add(con);
            }
            insert contacts;

            String type = 'Specific Needs';
            String recordType = 'Specific Needs';
            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Qantas.com','','','');
        }

    }
    
    @IsTest
    static void testGetLatestAttachmentPositive() {

        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        Test.startTest();
        System.runAs(usr) {

            Case cs = [SELECT Id, status FROM Case limit 1];
            ContentVersion objContVersion1 = new ContentVersion(
                Title = 'QCC_getEmailTemplate - 12235835 - 2025-09-13 09_42_39Z',
                PathOnClient = 'QCC_getEmailTemplate - 12235835 - 2025-09-13 09_42_39Z.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );

            ContentVersion objContVersion2 = new ContentVersion(
                Title = 'QCC_getEmailTemplate - 12235835 - 2025-09-12 09_42_39Z',
                PathOnClient = 'QCC_getEmailTemplate - 12235835 - 2025-09-12 09_42_39Z.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );

            ContentVersion objContVersion3 = new ContentVersion(
                Title = 'QCC_getEmailTemplate - 12235835 - 2025-09-14 09_42_39Z',
                PathOnClient = 'QCC_getEmailTemplate - 12235835 - 2025-09-14 09_42_39Z.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            List<ContentVersion> cvs = new List<ContentVersion>();
            cvs.add(objContVersion1);
            cvs.add(objContVersion2);
            cvs.add(objContVersion3);

            insert cvs;

            List<ContentDocument> objCOnDocs = [SELECT Id, Title, LatestPublishedVersionId, CreatedById FROM ContentDocument];

            List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
            for (ContentDocument objCOnDoc: objCOnDocs) {
                //create ContentDocumentLink  record 
                ContentDocumentLink objCDL = New ContentDocumentLink();
                objCDL.LinkedEntityId =  cs.Id;
                objCDL.ContentDocumentId = objCOnDoc.Id;
                objCDL.shareType = 'V';
                cdls.add(objCDL);
            }
            insert cdls;
            Object cdl = CongaTriggerUtility.getLatestAttachment(cs.Id, 'QCC_getEmailTemplate - 12235835 - 2025-09-14 09_42_39Z', usr.Id);
            system.assert(cdl != Null, 'Latest attachment should be retrieved');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetIntegrationUserId() {
        Id userId = CongaTriggerUtility.getIntegrationUserId();
        system.assert(userId != Null, 'Integration user Id should be retrieved');
    }

}