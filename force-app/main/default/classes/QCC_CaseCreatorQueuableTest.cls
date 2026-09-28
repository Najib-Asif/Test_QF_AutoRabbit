/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-27-2024
 * @last modified by  : Praveen Sampath
**/
@isTest
Private class QCC_CaseCreatorQueuableTest {
    @testSetup
    static void createData(){       
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();

        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        List<Qantas_API__c> qantasAPIs = new List<Qantas_API__c>();

        Qantas_API__c capToken = new Qantas_API__c();
        capToken.Name = 'QCC_CAPToken';
        capToken.ClientId__c = '712c7c5f';
        capToken.ClientSecret__c = '7ca2120bcb46cc4176d68442fdce159a';
        capToken.EndPoint__c = 'https://api-stage.qantas.com/customer/oauth/token';
        capToken.GrantType__c = 'client_credentials';
        capToken.Method__c = 'GET';
        capToken.Token__c = 'Bearer bc5785a848e73bf62ccc493b876a812e926a63ab';
        qantasAPIs.add(capToken);

        Qantas_API__c bookingToken = new Qantas_API__c();
        bookingToken.Name = 'QCC_BookingToken';
        bookingToken.ClientId__c = 'b6e2d0f8';
        bookingToken.ClientSecret__c = '7db5b19ef3d00e10a69468c91c6223ef';
        bookingToken.EndPoint__c = 'https://api-stage.qantas.com/booking/oauth/token';
        bookingToken.GrantType__c = 'client_credentials';
        bookingToken.Method__c = 'GET';
        bookingToken.Token__c = 'Bearer 571e4a65ad239ec5a0c51ae86637a1506323070d';
        qantasAPIs.add(bookingToken);

        Qantas_API__c bookingSummaryAPI = new Qantas_API__c();
        bookingSummaryAPI.Name = 'QCC_BookingSummaryAPI';
        bookingSummaryAPI.EndPoint__c = 'https://api-stage.qantas.com/customer/capcre/v1/';
        bookingSummaryAPI.Method__c = 'GET';
        qantasAPIs.add(bookingSummaryAPI);

        Qantas_API__c QCC_CAPPNRRetrieve = new Qantas_API__c();
        QCC_CAPPNRRetrieve.Name = 'QCC_CAPPNRRetrieve';
        QCC_CAPPNRRetrieve.EndPoint__c = 'https://api-stage.qantas.com/booking/capcre/v1/';
        QCC_CAPPNRRetrieve.Method__c = 'GET';
        qantasAPIs.add(QCC_CAPPNRRetrieve);

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
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        List<Contact> contacts = new List<Contact>();
        
        System.runAs(u1) {
            Contact con = new Contact(LastName='Sample', FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249',
                              CountryName__c = 'Australia', Frequent_Flyer_Number__c = '0006142104');
            con.CAP_ID__c = '71000000001';
                    
                
            insert con;
        }
    }
    
    @isTest static void test_method_two() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = '5YPGHJ';
                cs.Flight_Number__c = '0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.First_Name__c = 'STEVE';
                cs.Group__c = 'Booking Cancelled by Customer';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'No';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }

    @isTest static void test_method_three() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = '5YPGHJ';
                cs.Flight_Number__c = '0012';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.First_Name__c = 'STEVE';
                cs.Country__c = 'Australia';
                cs.Group__c = 'Booking Cancelled by Customer';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'No';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }

    @isTest static void test_method_one() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = '5YPGHJ';
                cs.Flight_Number__c = '0012';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.First_Name__c = 'STEVE';
                cs.Country__c = 'Australia';
                cs.Group__c = 'Delayed Flight';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cs.Status = 'closed';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'Yes';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_four() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = '5YPGHJ';
                cs.Flight_Number__c = '0012';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.First_Name__c = 'STEVE';
                cs.Country__c = 'Australia';
                cs.Group__c = 'Delayed Flight';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cs.Status = 'closed';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'Ineligible';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }

        
    @isTest static void test_method_five() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = '5YPGHJ';
                cs.Flight_Number__c = '0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.First_Name__c = 'STEVE';
                cs.Group__c = 'Booking Cancelled by Customer';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'No';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }

    @isTest static void test_method_six() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            Contact con = new Contact(LastName='Sample', FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249',
                              CountryName__c = 'Australia');
            insert con;
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.Origin = 'Qantas.com';
            cs.Booking_PNR__c = 'K5F5ZE';
            cs.Flight_Number__c = '0401';
            cs.ContactId = con.Id;
            cs.Airline__c = 'Qantas';
            cs.Suburb__c = 'NSW';
            cs.Street__c = 'Jackson';
            cs.State__c = 'Mascot';
            cs.Post_Code__c = '20020';
            cs.Country__c = 'Australia';
            cs.First_Name__c = 'STEVE';
            cs.Group__c = 'Booking Cancelled by Customer';
            cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
            cs.Last_Name__c = 'WAUGH';
            cases.add(cs);
            
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c FROM Case];
            QCC_CaseCreatorQueuable.testClassFCR = 'No';
            QCC_CaseCreatorQueuable q = new QCC_CaseCreatorQueuable(cases, UserInfo.getSessionId());
            System.enqueueJob(q);
            Test.stopTest();
        }
    }
}