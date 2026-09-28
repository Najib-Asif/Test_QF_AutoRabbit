/**
* @author huangxy
*/
@isTest
private class QCC_EFTRefundControllerTest {
    static User u1;
    static Account objAcc;
    
    @testSetup
    static void createTestData(){ 
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        //GRAPHITE-154/155: Contact Model Redesign - Set the role for the running user
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                      Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
                      EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                      TimeZoneSidKey = 'Australia/Sydney', Location__c='Sydney', UserRoleId = rolesMap.get('QF-QDC-OM-MNL-TL').Id
                     );
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        system.runAs(thisUser) {
            List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
            insert lsttrgStatus;
            TestUtilityDataClassQantas.insertQantasConfigData();
            List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
            insert lstQantas;
            
            List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType','Qantas Points'));
            
            insert lstConfigData;
        }

        System.runAs(u1) {
            //Create Account
            //Account objAcc = TestUtilityDataClassQantas.createAccount();
            //GRAPHITE-154/155: Contact Model Redesign - Create person account to be used as parent of contact record for which Compliment case is created.
            //Scenario: Assuming that the Person Account was created by QCC user (via Search Frequent Flyer Number) and that account is already existing.
            //NOTE on limitation: Criteria-based sharing rule cannot be tested via apex. So the account and contact in this test is created by the same user
            Account objAcc = TestUtilityDataClassQantas.createPersonAccount();
            objAcc.Airline_Level__c = '1';
            objAcc.Active__c = true;
            insert objAcc;
            system.assert(objAcc != Null, 'Account is not inserted');
        	
            //Create Contact
            Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
            objContact.LastName='ContTest2';
            objContact.CAP_ID__c='710000000017';
            objContact.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
            system.debug('>>>Before Contact is inserted');
            insert objContact;
            System.assert(objContact.Id != Null, 'Contact is not inserted');
            
            //Create Case
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(objContact);
            String recordType = 'CCC Compliment';
            String type = 'Compliment';
            List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
            system.assert(lstCase.size()>0, 'Case List is Zero');
            system.assert(lstCase[0].Id != Null, 'Case is not inserted');

            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(lstCase);
            system.assert(lstRecovery.size()>0, 'Recovery List is Zero');
            system.assert(lstRecovery[0].Id != Null, 'Recovery is not inserted');
        }
    }
    static testMethod void updateRecoveryServer() {
        try {
            String type = 'Compliment';
            String recordType = 'CCC Complaints';
            //User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

            System.runAs(u1) {
                List<Contact> contacts = [SELECT Id, Name FROM Contact limit 1];
                Test.startTest();
                List<Case> cases1 = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Qantas.com','','','');       
                List<Recovery__c> recoveries = TestUtilityDataClassQantas.insertRecoveries(cases1);
                for(Recovery__c rec : recoveries){
                	rec.Type__c = 'EFT Refund';
                	rec.Status__c = 'Submit for Finalisation';
                	rec.Payment_Status__c = 'Declined';
                }
                update recoveries;
                QCC_EFTRefundController.updateRecoveryServer(recoveries , 'Declined');
                
                Test.stopTest();
            }
            
        } catch(Exception ex) {
            System.debug('Error occured: '+ex.getMessage());
        }        
    }

    static testmethod void updateRecoveryTypeTestApproved(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Test.startTest();

        //EFT recovery gets approved
        objRecovery.Type__c = 'EFT Refund';
        objRecovery.Status__c = 'Submit for Finalisation';
        update objRecovery;
        List<Recovery__c> recs = new List<Recovery__c>();
        recs.add(objRecovery);
        Case temp = [select Id , OwnerId , Resolution_Method__c , Status from Case where Id =:objRecovery.Case_Number__c];
        List<Recovery__c> results = QCC_EFTRefundController.updateRecoveryServer(recs , 'Approved');
        System.assert(results.size() > 0);
        temp = [select Id , OwnerId , Resolution_Method__c , Status from Case where Id =:objRecovery.Case_Number__c];
        //System.assert(temp.Status == 'Closed');
        Test.stopTest();
    }

    static testmethod void updateRecoveryTypeTestRejected(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c limit 1];
        Test.startTest();

        //EFT recovery gets approved
        objRecovery.Type__c = 'EFT Refund';
        objRecovery.Status__c = 'Submit for Finalisation';
        update objRecovery;
        List<Recovery__c> recs = new List<Recovery__c>();
        recs.add(objRecovery);
        Case temp = [select Id , OwnerId , Resolution_Method__c , Status from Case where Id =:objRecovery.Case_Number__c];
        List<Recovery__c> results = QCC_EFTRefundController.updateRecoveryServer(recs , 'Declined');
        System.assert(results.size() > 0);
        temp = [select Id , OwnerId , Resolution_Method__c , Status from Case where Id =:objRecovery.Case_Number__c];
        System.assert(temp.Status == 'Recovery Error');
    }

    static testmethod void getRecoveries(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        UserRole adminRole = [select Id from UserRole where developerName = 'QF_QDC'];
        System.assert(adminRole != null);
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        //User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
        // Username = 'sampleuser1username@sample1.com', ProfileId = profMap.get('Qantas CC Team Lead').Id,
        // EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
        // TimeZoneSidKey = 'Australia/Sydney', Location__c='Sydney',UserRoleId=adminRole.Id
        //);
        //insert u1;

        User u1 = [select Id from User where Username ='sampleuser1username@sample.com'];

        System.runAs(u1){
            
            objRecovery.Type__c = 'Credit Card Refund';
            objRecovery.Status__c = 'Submit for Finalisation';
            objRecovery.Payment_Status__c = 'Pending';
            Test.startTest();
            update objRecovery;
            Test.stopTest();
            List<recovery__c> recs = QCC_EFTRefundController.getRecoveries('eft');
            //System.assert(recs.size() > 0);
        }
       
    }

    static testmethod void getOrgSettings(){
        Map<String , String> settings = new Map<String , String>();
        Test.startTest();
        Object res = QCC_EFTRefundController.getOrgSettings();
        System.assert(res != null);
        Test.stopTest();
    }

    static testmethod void getRecovery(){
        Recovery__c objRecovery = [Select id , Name , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        objRecovery.Type__c = 'EFT Refund';
        objRecovery.Status__c = 'Submit for Finalisation';
        objRecovery.Payment_Status__c = 'Declined';
        Test.startTest();
        update objRecovery;
        Test.stopTest();
        Recovery__c rec = QCC_EFTRefundController.getRecovery(objRecovery.Name);
        System.assert(rec != null);
        
    }

}