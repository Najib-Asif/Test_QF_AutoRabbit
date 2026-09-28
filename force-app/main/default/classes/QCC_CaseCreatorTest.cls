@isTest
private class QCC_CaseCreatorTest {
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
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249',
                              CountryName__c = 'Australia', Frequent_Flyer_Number__c = '12345');
                if(i == 0) {
                    con.CAP_ID__c = '71000000001'+ (i+7);
                    con.Frequent_Flyer_Number__c = '12345678'+i;
                }
                contacts.add(con);
            }
            insert contacts;
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
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
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
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);            
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_two() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0300';
                cs.ContactId = con.Id;
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());         
            List<Case> newCases = [SELECT Id, Delay_Reason__c FROM Case];
            for(Case c: newCases) {
                //QCC_CaseCreator.autoCaseProcess(c.id);
                //System.assertEquals('Operational', c.Delay_Reason__c);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_three() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'On the Spot Recovery';
            String recordType = 'CCC On The Spot Recovery';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0300';
                cs.ContactId = con.Id;
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            for(Case cs: cases) {
                //QCC_CaseCreator.autoCaseProcess(cs.id);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_four() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';

        System.runAs(u1) {
            List<Contact> contacts = [SELECT Id, CAP_ID__c FROM Contact];
            /*contacts[0].CAP_ID__c = '710000000019';
            contacts[1].CAP_ID__c = '710000000020';
            update contacts;*/
            List<Case> cases = new List<Case>();
            Case cs1 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs1.Origin = 'Qantas.com';
            cs1.Booking_PNR__c = 'K5F5ZE';
            cs1.Flight_Number__c = '0402';
            cs1.ContactId = contacts[0].Id;
            cases.add(cs1);
            Case cs2 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Flight Cancelled by Qantas','','','');
            cs2.Origin = 'Qantas.com';
            cs2.Booking_PNR__c = 'K5F5ZE';
            cs2.Flight_Number__c = '0400';
            cs2.ContactId = contacts[1].Id;
            cases.add(cs2);
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            for(Case cs: cases) {
                //QCC_CaseCreator.autoCaseProcess(cs.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_five() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            String recordType = 'CCC Insurance Letter Case';
            Case cs1 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, 'Insurance Letter', 'Booking Cancelled by Customer','','','');
            cs1.Origin = 'Qantas.com';
            cs1.Booking_PNR__c = 'K5FEFD';
            cs1.Flight_Number__c = 'QF0300';
            cs1.ContactId = contacts[0].Id;
            cases.add(cs1);
            Case cs2 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, 'Insurance Letter', 'Booking Cancelled by Customer','','','');
            cs2.Origin = 'Qantas.com';
            cs2.Booking_PNR__c = 'K5FEFD';
            cs2.Flight_Number__c = 'QF0300';
            cases.add(cs2);
            
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            for(Case cs: cases) {
                //QCC_CaseCreator.autoCaseProcess(cs.id);
            }
            Test.stopTest();
        }
    }

    
    @isTest static void test_method_six() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            List<Contact> contacts = [SELECT Id FROM Contact];
            
            String recordType = 'CCC Insurance Letter Case';
            Case cs1 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, 'Insurance Letter', 'Booking Cancelled by Customer','','','');
            cs1.Origin = 'Qantas.com';
            cs1.Booking_PNR__c = 'K5F5ZE';
            cs1.Flight_Number__c = '0400';
            cs1.ContactId = contacts[0].Id;
            cs1.Status = 'Closed';
            insert cs1;
            Case cs2 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, 'Insurance Letter', 'Booking Cancelled by Customer','','','');
            cs2.Origin = 'Qantas.com';
            cs2.Booking_PNR__c = 'K5F5ZE';
            cs2.Flight_Number__c = 'QF0401';
            cs2.ContactId = contacts[0].id;
            insert cs2;
            system.assert(cs2.Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            //QCC_CaseCreator.autoCaseProcess(cs2.id);
            Test.stopTest();
        }
    }

    @isTest static void test_method_nine() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.Airline__c = 'Emirates';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_eleven() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Flight Cancelled by Qantas','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.Airline__c = 'Qantas';
                cs.Ticket_Status__c = 'Open';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = false;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_thirteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Arrival_Date_Time__c = '24/01/2018 11:46:00';
                cs.Actual_Arrival_Date_Time__c = '24/01/2018 11:46:00';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_fourteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Tax only Refund';
                cs.Issued_by_TravelAgent__c = true;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_fifteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Ticket held in Credit';
                cs.Issued_by_TravelAgent__c = true;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_sixteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Refunded with Cancellation Policy';
                cs.Issued_by_TravelAgent__c = true;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_seventeen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Damaged Baggage','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_eighteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed or Lost Baggage','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            /*List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
            }*/
            Test.stopTest();
        }
    }

    @isTest static void test_method_nineteen() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Personal Property Lost In-flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = 'QF0401';
                cs.Lost_Property_Name__c = 'Bag';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testNonFFWithPBNS() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact WHERE CAP_ID__c = null];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0400';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cs.First_Name__c = 'STEVE';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            Test.stopTest();
        }
    }
    
    @isTest static void testNonFFWithDelayedFlight() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact WHERE CAP_ID__c = null];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0400';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cs.Last_Name__c = 'WAUGH';
                cs.First_Name__c = 'STEVE';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            Test.stopTest();
        }
    }
    
    @isTest static void testNonFFWithoutContactId() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
        cs.Origin = 'Qantas.com';
        cs.Booking_PNR__c = 'K5F5ZE';
        cs.Flight_Number__c = 'QF0400';
        cs.Airline__c = 'Qantas';
        cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
        cs.Last_Name__c = 'WAUGH';
        cs.First_Name__c = 'STEVE';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        insert cs;
        Test.stopTest();
        system.assert(cs.Id != Null, ' Case Id is null');
        List<Case> newCases = [SELECT Id, FCR__c, Type, Is_Response_Requested__c FROM Case WHERE Id =: cs.Id];

        
        
    }
}