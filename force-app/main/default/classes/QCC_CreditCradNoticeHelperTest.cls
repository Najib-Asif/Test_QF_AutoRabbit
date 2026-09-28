/*----------------------------------------------------------------------------------------------------------------------
Author:        Bharathkumar
Company:       Tata Consultancy services
Description:   QCC CreditCardNoticeHelperTest
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
21-July-2018      Bharathkumar               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class QCC_CreditCradNoticeHelperTest {
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
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center,Ticketing and Genesys permission sets on the user as part of RBAC CRM-11628               
        User user = new User(   LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                            Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                            TimeZoneSidKey = 'Australia/Sydney'
                            );
        insert user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            user.UserRoleId =  rolesMap.get('QF-QDC').Id; 
            update user;
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Ticketing_and_Refunds_Agent_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(user.Id,permissionSetIds);
        }

        //Create Contact
        List<Contact> contacts = new List<Contact>();
        List<Case> cases = new List<Case>();
        System.runAs(user) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston', MailingState = 'TAS',
                                          Frequent_Flyer_Number__c = '12345' + i, MailingPostalCode = '7249', CountryName__c = 'Australia');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
			System.debug('contacts==============> ' + contacts);
            System.debug('contacts.size()===============> ' + contacts.size());
            //Create Case
            String type = 'Baggage';
            String recordType = 'CCC Baggage';
            Boolean isCreditCardCaseCreated = false;
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Damaged Baggage','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.type='Baggage';
                cs.Group__c='Damaged Baggage';
                cs.Category__c='Checked Baggage';
               cs.Description = isCreditCardCaseCreated ? '<https://yourbooking.qantas.com.au/LinkTracking?id=101973461&url=https://www.qantas.com/au/en/travel-info/travel-advice/your-health-inflight.html?alt_cam=au:dg:15b:edm:etr:visa-and-health-information:your-health-inflight:tl:n:n>' : 
                		'credit testing for test class 4324-5677-8876-3456';
                isCreditCardCaseCreated = true;
                cases.add(cs);
            }
            insert cases;

        }

        //Create Case_Relationships
        List<Case_Relationships__c> caseRelationships = new List<Case_Relationships__c>();
        Case_Relationships__c caseRelationship1 = new Case_Relationships__c(
                                                    Case_1__c = cases[0].Id,
                                                    Case_2__c = cases[0].Id
                                                );
        Case_Relationships__c caseRelationship2 = new Case_Relationships__c(
                                                    Case_1__c = cases[1].Id,
                                                    Case_2__c = cases[1].Id
                                                );
        caseRelationships.add(caseRelationship1);
        caseRelationships.add(caseRelationship2);
        insert caseRelationships;
    }

    public static testmethod void hasCreditCardTest(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        List<Case> caseRecords = [SELECT Id, CaseNumber, Contact_Fullname__c,RecordTypeId,
                         Origin,Description,Type,CreatedDate FROM Case WHERE Type = 'Baggage' limit 2 ];
        Case_Relationships__c caseRel = [SELECT Id, CreatedDate FROM Case_Relationships__c limit 1];
        Contact contactRecord = [ SELECT Id FROM Contact LIMIT 1];
        System.runAs(u1){
            Test.startTest();
                List<QCC_CaseRelationshipsController.CaseRelationshipWrapper> caseRels = QCC_CaseRelationshipsController.fetchCaseRelationshipsByCaseId(caseRecords[0].Id);
                System.assertEquals(caseRels[0].caseNumber, caseRecords[0].CaseNumber);
            
            	//List<QCC_CaseRelationshipsController.CaseRelationshipWrapper> 
                caseRels = QCC_CaseRelationshipsController.fetchCaseRelationshipsByCaseId(caseRecords[1].Id);
                System.assertEquals(caseRels[0].caseNumber, caseRecords[1].CaseNumber);
            	Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage', 'Baggage', 'Damaged Baggage','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = contactRecord.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.type='Baggage';
                cs.Group__c='Damaged Baggage';
                cs.Category__c='Checked Baggage';
               cs.Description = 'This is a sample text.';
                insert cs;
                QCC_CreditCradNoticeHelper.hasCreditCard(cs.Id);
                //QCC_CreditCradNoticeHelper.hasCreditCard(cs[1].Id);
                QCC_CreditCradNoticeHelper.maskCreditCard(caseRecords);
            Test.stopTest();
        }
    }
}