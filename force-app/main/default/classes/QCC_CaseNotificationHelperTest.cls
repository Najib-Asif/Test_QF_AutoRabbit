@IsTest
public class QCC_CaseNotificationHelperTest {
    @TestSetUp
    public static void setUpdata(){
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lstStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        
        for(Trigger_Status__c ts : lstStatus){
            if(ts.Name != 'CaseTriggerPostNotification'){
                ts.active__c = false;
            }
        }

        insert lstStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', City='Manila', Location__c = 'Manila'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
     		List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }

        List<Contact> contacts = new List<Contact>();
        
        System.runAs(u1) {

            for(Integer i = 0; i < 1; i++) {
                String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
                Account acc = TestUtilityDataClassQantas.createAccount();
                insert acc;

                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', AccountId = acc.id,
                                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd', 
                                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249', 
                                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Platinum One', Frequent_Flyer_Number__c = '12345');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
                insert contacts;
                
            }
            
        }
        
        
    }


    @IsTest
    public static void testNotification(){
        User u1 = [select id from user where Username = 'sampleuser1username@sample.com' limit 1];
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.Cabin_Class__c = 'Business';
                cs.Sensitive__c = true;
                cs.Status = 'In Progress';
                cases.add(cs);
            }
            
            Test.startTest();
            
            insert cases;
            
            Test.stopTest();

            System.debug([Select ParentId, Id, Body From UserFeed LIMIT 5]);
        }
    }
    
    @IsTest
    public static void testNotification2(){
        User u1 = [select id from user where Username = 'sampleuser1username@sample.com' limit 1];
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.Cabin_Class__c = 'Business';
                cs.Sensitive__c = false;
                cases.add(cs);
                
            }

            Test.startTest();
            
            insert cases;
            Set<String> setId = new Set<String>();
            setId.add(cases[0].id);
            QCC_CaseNotificationHelper.postCaseNotification(setId);
            
            Test.stopTest();
            
        }
    }
}