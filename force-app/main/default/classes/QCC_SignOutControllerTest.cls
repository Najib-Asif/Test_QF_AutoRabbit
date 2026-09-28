/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
30-Jan-2026   Mark-Capgemini      CRM-10420 Test method updated for PSV changes    
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_SignOutControllerTest {
    @TestSetUp
    public static void testSetUp(){    
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
        Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1];        
        
        
        List<Qantas_API__c> qantasAPIs = TestUtilityDataClassQantas.createQantasAPI( );
        insert qantasAPIs;
        
        List<AirlineCarrierCodes__c> lstAirlineData = new List<AirlineCarrierCodes__c>();
        lstAirlineData.add(TestUtilityDataClassQantas.createAirlineCarrierData('QF','Qantas'));
        insert lstAirlineData;
        
        List<Airport_Code__c> airportCodes = new List<Airport_Code__c>();
        Airport_Code__c sydney = new Airport_Code__c();
        sydney.Name = 'SYD';
        sydney.Freight_Airport_Country_Name__c = 'Australia';
        sydney.Freight_Station_Name__c = 'SYDNEY';
        airportCodes.add(sydney);
        Airport_Code__c mel = new Airport_Code__c();
        mel.Name = 'MEL';
        mel.Freight_Airport_Country_Name__c = 'Australia';
        mel.Freight_Station_Name__c = 'MELBOURNE';
        airportCodes.add(mel);
        insert airportCodes;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628        
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', City='Manila', location__c = 'Manila'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        List<Contact> contacts = new List<Contact>();
        
        System.runAs(u1) {
            
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', 
                                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd', 
                                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249', 
                                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Silver',Frequent_Flyer_Number__c = '12345');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
        }
        
        //User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            contacts = [SELECT Id FROM Contact];
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
                cs.QCC_Combined_Case_Description__c = 'QCC_Combined_Case_Description__c';
                cs.Last_Queue_Owner__c = g.id;
                cs.Last_Queue_Owner_Name__c = g.Name;
                cases.add(cs);
            }
            insert cases;
        }
    }
    
    @isTest
    public static void getBaseUrlTest(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        
        System.runAs(u1) {
            String jsonString = QCC_SignOutController.getBasicInfo();
            QCC_SignOutController.infoWrapper iw = (QCC_SignOutController.infoWrapper)JSON.deserialize(jsonString, QCC_SignOutController.infoWrapper.class);
            
            System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm(), iw.baseURL);
            System.assertEquals(u1.Id, iw.currentUser.id);
        }
    }
    
    @isTest
    public static void caseAssignedBackTestPostive(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        
        System.runAs(u1) {
            Test.startTest();
            
            try{QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = false];
        list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
        Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1]; 
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        //System.assertEquals(g.id, listCase[0].OwnerId);
        //System.assertEquals(true, listCase[0].Returned_to_Queue__c);
    }
    
    @isTest
    public static void caseAssignedBackTestNegative_BlankLastQueue(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        case c = [Select id, Last_Queue_Owner__c from Case limit 1];
        c.Last_Queue_Owner__c = '';
        update c;
       
        System.runAs(u1) {
            Test.startTest();
             try{QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = false];
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        System.assertEquals(false, listCase[0].Returned_to_Queue__c);
    }

    @isTest
    public static void caseAssignedBackTestNegative_BlankLastQueue1(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        case c = [Select id, Last_Queue_Owner__c from Case limit 1];
        c.Last_Queue_Owner__c = '';
        c.Status  = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
        c.Is_Response_Requested__c  = CustomSettingsUtilities.getConfigDataMap('QCC_ResponseRequired');
        update c;
        
        System.runAs(u1) {
            Test.startTest();
            
             try{QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = True];
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        System.assertEquals(false, listCase[0].Returned_to_Queue__c);
    }
    
    @isTest
    public static void caseAssignedBackTestNegative_BlankLastQueue2(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        case c = [Select id, Last_Queue_Owner__c from Case limit 1];
        c.Last_Queue_Owner__c = '';
        c.Description = 'blind + burn';
        c.Status  = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
        c.Is_Response_Requested__c  = CustomSettingsUtilities.getConfigDataMap('QCC_ResponseRequired');
        update c;
        
        System.runAs(u1) {
            Test.startTest();
          
             try{QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = True];
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        System.assertEquals(false, listCase[0].Returned_to_Queue__c);
    }
    
    @isTest
    public static void caseAssignedBackTestNegative_BlankLastQueue3(){
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        case c = [Select id, Last_Queue_Owner__c from Case limit 1];
        c.Last_Queue_Owner__c = '';
        c.Description = 'blind + burn';
        c.Status  = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
        c.Is_Response_Requested__c  = CustomSettingsUtilities.getConfigDataMap('QCC_ResponseRequired');
        c.group__c='Damaged Baggage';
        update c;
        
        System.runAs(u1) {
            Test.startTest();
            try{QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = True];
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        System.assertEquals(false, listCase[0].Returned_to_Queue__c);
    }
    
    @isTest
    public static void caseAssignedBackTestNegative_SydneyConsultant(){
        
        List<String> CCATRole = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Roles, ';');
        List<UserRole> userRole = [SELECT DeveloperName,Id,Name,ParentRoleId FROM UserRole where Name IN: CCATRole];

        User u1 = [SELECT Id, city, Location__c,Profile.Name FROM User WHERE Username = 'sampleuser1username@sample.com'];
        u1.Location__c = 'Sydney';
        u1.UserRoleId = userRole[0].id;
        update u1;        
        System.runAs(u1) {
            Test.startTest();
            
         try{QCC_SignOutController.checkForInProgressCases();
            QCC_SignOutController.caseAssignedBack();}
             Catch(Exception e){}
            Test.stopTest();
        }
        List<Case> listCase = [Select id, OwnerId, Returned_to_Queue__c, Assign_using_active_assignment_rules__c from Case where isClosed = false];
        System.debug(listCase[0]);
        list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
        Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1]; 
        //System.assertNotEquals(u1.id, listCase[0].OwnerId);
        //System.assertEquals(g.id, listCase[0].OwnerId);
        //System.assertEquals(false, listCase[0].Returned_to_Queue__c);
    }
    //CRM-10420: Method added to support Code Security Remediation changes
    @isTest
    static void caseAssignedBackNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@example.com',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        insert u;

        System.runAs(u) {
            List<Case> caseList = [SELECT Id, Last_Queue_Owner__c FROM Case WHERE IsClosed = false LIMIT 1];
            if (!caseList.isEmpty()) {
                Case c = caseList[0];
                c.Last_Queue_Owner__c = '';
                update c;
            }
           
            Test.startTest();
           try{
            QCC_SignOutController.caseAssignedBack();
           }catch(Exception e){}
            Test.stopTest();
        }
    }
    //Method added to support Code Security Remediation changes
    @isTest
    static void checkForInProgressCasesNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'QL Qantas No Access' LIMIT 1];
        User u = new User(
            Alias = 'noaccess',
            Email='noaccess@example.com',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='noaccess'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        insert u;

        System.runAs(u) {
            List<Case> caseList = [SELECT Id, Last_Queue_Owner__c FROM Case WHERE IsClosed = false LIMIT 1];
            if (!caseList.isEmpty()) {
                Case c = caseList[0];
                c.Last_Queue_Owner__c = '';
                update c;
            }

            Test.startTest();
            try{
            QCC_SignOutController.checkForInProgressCases();
           }catch(Exception e){}
            Test.stopTest();
        }
    }
}