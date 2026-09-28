@isTest
private class QCC_CaseRelationshipsControllerTest {
    @testSetup 
    static void setup() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628               
        User user = new User(   LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                            Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                            TimeZoneSidKey = 'Australia/Sydney'
                            );
        insert user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            user.UserRoleId =  rolesMap.get('QF-QDC').Id; 
            update user;
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(user.Id,permissionSetIds);
        }

        //Create Contact
        List<Contact> contacts = new List<Contact>();
        List<Case> cases = new List<Case>();
        System.runAs(user) {
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston',
                                          Frequent_Flyer_Number__c = '12345', MailingState = 'TAS', MailingPostalCode = '7249', CountryName__c = 'Australia');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;

            //Create Case
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
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
                cases.add(cs);
            }
            insert cases;

        }

        //Create Case_Relationships
        Case_Relationships__c caseRelationships = new Case_Relationships__c(
                                                    Case_1__c = cases[0].Id,
                                                    Case_2__c = cases[0].Id
                                                );
        insert caseRelationships;
    }

    static testMethod void test_fetchCaseRelationshipsByCaseId() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        Case c = [SELECT Id, CaseNumber, Contact_Fullname__c,CreatedDate FROM Case WHERE Type = 'Insurance Letter' limit 1 ];
        Case_Relationships__c caseRel = [SELECT Id, CreatedDate FROM Case_Relationships__c limit 1];
        System.runAs(u1){
            Test.startTest();
                List<QCC_CaseRelationshipsController.CaseRelationshipWrapper> caseRels = QCC_CaseRelationshipsController.fetchCaseRelationshipsByCaseId(c.Id);
                System.assertEquals(caseRels[0].caseNumber, c.CaseNumber);
            Test.stopTest();
        }
    }
}