@isTest(seeAllData = false)
private class QCC_EmailButtonControllerTest {
    @testSetup
    static void createData(){      
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        for(Trigger_Status__c triggerStatus : lsttrgStatus){
            triggerStatus.Active__c = false;
        }
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubmitForFinalisation','Submit for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalised','Finalised'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalisation Declined','Finalisation Declined'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'test1234@sample.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_NoReplyContactLastName', 'Sample12345'));
        insert lstConfigData;

        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        List<APXTConga4__Conga_Email_Template__c> listCongaEmTemp = new List<APXTConga4__Conga_Email_Template__c>();
        
        APXTConga4__Conga_Email_Template__c congaEmTemp1 = new APXTConga4__Conga_Email_Template__c();
        congaEmTemp1.Category__c = '';
        congaEmTemp1.Classification__c = '';
        congaEmTemp1.Email_Template__c = 'Blank Template';
        congaEmTemp1.APXTConga4__Name__c = 'QCC_Blank Email';
        congaEmTemp1.Group__c = 'Blank Template';
        congaEmTemp1.Sub_category__c = '';
        congaEmTemp1.Type__c = 'Complaint';
        congaEmTemp1.APXTConga4__Template_Group__c = 'QCC_Email_Templates';
        listCongaEmTemp.add(congaEmTemp1);

        APXTConga4__Conga_Email_Template__c congaEmTemp2 = new APXTConga4__Conga_Email_Template__c();
        congaEmTemp2.Category__c = 'Staff Assistance';
        congaEmTemp2.Classification__c = '';
        congaEmTemp2.Email_Template__c = 'Complaint Template';
        congaEmTemp2.APXTConga4__Name__c = 'Complaint Template';
        congaEmTemp2.Group__c = 'In-Flight';
        congaEmTemp2.Sub_category__c = '';
        congaEmTemp2.Type__c = 'Complaint';
        listCongaEmTemp.add(congaEmTemp2);
        
        APXTConga4__Conga_Email_Template__c congaEmTemp3 = new APXTConga4__Conga_Email_Template__c();
        congaEmTemp3.Category__c = 'Refunded with Cancellation Policy';
        congaEmTemp3.Classification__c = '';
        congaEmTemp3.Email_Template__c = 'Complaint Template';
        congaEmTemp3.APXTConga4__Name__c = 'Complaint Template';
        congaEmTemp3.Group__c = 'Booking Cancelled by Customer';
        congaEmTemp3.Sub_category__c = '';
        congaEmTemp3.Type__c = 'Insurance Letter';
        listCongaEmTemp.add(congaEmTemp3);

        insert listCongaEmTemp;

        APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c();
        congaTemplate.APXTConga4__Name__c = 'Payment Details Form';
        congaTemplate.Email_Template_Name__c = 'EFT Authorisation';
        congaTemplate.APXTConga4__Template_Group__c = 'QCC_Email_Templates';
        congaTemplate.APXTConga4__Template_Type__c  = 'Document';

        insert congaTemplate;

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
        Contact cons = new Contact(LastName='Sample12345', FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test1234@sample.com');
        insert cons;
        
        System.runAs(u1) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', 
                              Email='test@sample.com', MailingStreet = '15 hobart rd', MailingCity = 'south launceston', MailingState = 'TAS',
                                          Frequent_Flyer_Number__c = '12345', MailingPostalCode = '7249', CountryName__c = 'Australia');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
            
        }


        
    }
    static TestMethod void testSessionId(){
    	Test.startTest();
        string sId = UserInfo.getSessionId();
        System.debug('UserInfo++++++++++++'+UserInfo.getName());
        string sId2 = QCC_EmailButtonController.userSessionId();
        System.debug('UserInfo++++++++++++'+QCC_EmailButtonController.userSessionId());
        //system.assertEquals(sId,sId2);
    	Test.stopTest();
    }

    static TestMethod void testorgServerURLs(){
        string url1 = URL.getSalesforceBaseUrl().toExternalForm();
        string url2 = QCC_EmailButtonController.orgServerURLs();
        system.assertEquals(url1,url2);
    }
    
    @isTest
    static void testGetOrgWideAndCaseTypeServer() {
        String type = 'On the Spot Recovery';
        String recordType = 'CCC On The Spot Recovery';
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight','','','');
        insert cs;
        Test.startTest();
        String result = QCC_EmailButtonController.getOrgWideAndCaseTypeServer(cs.id);
        System.assertEquals(type+',0D2N00000004EXCKA2,', result);
        String result2 = QCC_EmailButtonController.getOrgWideAndCaseTypeServer('500N000000BLRRX');
        System.assertEquals(null, result2);
        Test.stopTest();
    }

    // without Group
    @isTest static void testGetCaseValues() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Issued_by_TravelAgent__c = true;
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }

    // without Group
    @isTest static void testValidateCaseDetailsForLetter() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Issued_by_TravelAgent__c = true;
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');

            List<String> resultList = new List<String>();
            Test.startTest();
                List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
                resultList = QCC_EmailButtonController.validateCaseDetailsForLetter(newCases);
            Test.stopTest();
            System.debug('### testValidateCaseDetailsForLetter - resultList : '+ resultList);
            System.assert(resultList[0] == 'No', 'Response is meant to be No the result is :'+ resultList[0]);

        }
    }

    // with Group
    @isTest static void testGetCaseValuesWithGroup() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Issued_by_TravelAgent__c = true;
                cs.Group__c = 'Delayed Flight';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }

    @isTest static void testGetCaseValuesWithAffectedPassenger() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            Test.startTest();
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact Limit 1];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Qantas';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Tax only Refund';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            String caseId = cases[0].Id;
            Affected_Passenger__c passenger = TestUtilityDataClassQantas.createAffectedPassengerWithValues(contacts[0].id);
            passenger.case__c = caseId;
            passenger.Issued_by_TravelAgent__c = true;
            passenger.Ticket_Number__c = '903-9901234522';
            passenger.Fare_Total__c = null;
            insert passenger;         
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case Where Id =: caseId];
            Case caseObj;
            String actualResult = QCC_EmailButtonController.getCaseValues(newCases[0].id,newCases[0].Type,false,caseObj);
            String expectedResult = 'No';
            System.assertEquals(expectedResult, actualResult, 'Pass Validation');
            Test.stopTest();
        }
    }

    @isTest static void testDynamicAffectedPassengerQueryBuilderIneligible() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            Test.startTest();
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact Limit 1];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Jetstar';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Tax only Refund';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            String caseId = cases[0].Id;
            Affected_Passenger__c passenger = TestUtilityDataClassQantas.createAffectedPassengerWithValues(contacts[0].id);
            passenger.case__c = caseId;
            passenger.Issued_by_TravelAgent__c = true;
            passenger.Ticket_Number__c = '903-9901234522';
            passenger.Fare_Total__c = null;
            insert passenger;         
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case Where Id =: caseId];
            Case caseObj;
            //System.assertEquals(newCases[0].Type, newCases[0].Type, 'Pass Validation');
            //String actualResult = QCC_EmailButtonController.getCaseValues(null,newCases[0].Type,false,newCases[0]);
            String actualResult = QCC_EmailButtonController.dynamicAffectedPassengerQueryBuilder('Flight_Leg_Flown_Statuses__c,Id', null, newCases[0], false);
            String expectedResult = 'Ineligible';
            System.assertEquals(expectedResult, actualResult, 'Pass Validation');
            Test.stopTest();
        }
    }

    @isTest static void testDynamicAffectedPassengerQueryBuilderError() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            Test.startTest();
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact Limit 2];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Booking Cancelled by Customer','','','');
                cs.Origin = 'Email';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Airline__c = 'Jetstar';
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Tax only Refund';
                cases.add(cs);
            }
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            String caseId = cases[0].Id;
            List<Affected_Passenger__c> listPassenger = new List<Affected_Passenger__c>();
            Affected_Passenger__c passenger = TestUtilityDataClassQantas.createAffectedPassengerWithValues(contacts[0].id);
            Affected_Passenger__c passenger2 = TestUtilityDataClassQantas.createAffectedPassengerWithValues(contacts[1].id);
            passenger.case__c = caseId;
            passenger.Issued_by_TravelAgent__c = true;
            passenger.Ticket_Number__c = '081-9901234522';
            passenger.Fare_Total__c = null;

            listPassenger.add(passenger);

            passenger2.case__c = caseId;
            passenger2.Issued_by_TravelAgent__c = true;
            passenger2.Ticket_Number__c = '081-9901234523';
            passenger2.Fare_Total__c = null;
            
            listPassenger.add(passenger2);
            insert listPassenger;         
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case Where Id =: caseId];
            Case caseObj;
            String actualResult = QCC_EmailButtonController.dynamicAffectedPassengerQueryBuilder('Flight_Leg_Flown_Statuses__c,Id,Fare_Total__c,Ticket_Number__c', caseId, newCases[0], false);
            String expectedResult = Null;
            System.assertNotEquals(expectedResult, actualResult, 'Pass Validation');
            Test.stopTest();
        }
    }

    @isTest static void test_method_seven() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Contact> contacts = [SELECT Id FROM Contact WHERE CAP_ID__c = '710000000017'];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.TECH_SelectedPassengers__c = '{"passengers": [{"firstname": "STEVE","lastname": "WAUGH"}]}';
                cases.add(cs);
            }
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            insert cases;
            system.assert(cases.size() != 0, ' Case List is zero');
            system.assert(cases[0].Id != Null, ' Case Id is null');
            Test.startTest();
            
            
            List<Case> newCases = [SELECT Id, FCR__c, Type FROM Case];
            for(Case c: newCases) {                
                //QCC_CaseCreator.autoCaseProcess(c.id);
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_eight() {
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
                cs.Flight_Number__c = '0401';
                cs.ContactId = con.Id;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
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
                cs.Flight_Number__c = '0400';
                cs.Airline__c = 'Emirates';
                cs.ContactId = con.Id;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_ten() {
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
                cs.Airline__c = 'Emirates';
                cs.ContactId = con.Id;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0402';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = true;
                cs.Segment_Id__c = '1234567';
                cs.Ticket_Status__c = 'Open';
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_elevenWithGroup1() {
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
                cs.Flight_Number__c = '0402';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = true;
                cs.Segment_Id__c = '1234567';
                cs.Ticket_Status__c = 'Open';
                cs.Group__c = 'Delayed Flight';
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_elevenWithGroup2() {
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
                cs.Flight_Number__c = '0402';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = true;
                cs.Segment_Id__c = '1234567';
                cs.Ticket_Status__c = 'Flown';
                cs.Group__c = 'Flight Cancelled by Qantas';
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void test_method_elevenWithGroup3() {
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
                cs.Flight_Number__c = '0402';
                cs.Airline__c = 'Qantas';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = true;
                cs.Segment_Id__c = '1234567';
                cs.Ticket_Status__c = 'Flown';
                cs.Group__c = 'Proof of Boarding or No Show';
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
            }
            Test.stopTest();
        }
    }
    

    @isTest static void test_method_twelve() {
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
                cs.Airline__c = 'Emirates';
                cs.ContactId = con.Id;
                cs.Flight_Cancellation__c = false;
                cs.Segment_Id__c = '1234567';
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
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0401';
                cs.ContactId = con.Id;
                cs.Arrival_Date_Time__c = '24/01/2018 11:46:00';
                cs.Actual_Arrival_Date_Time__c = '24/01/2018 11:46:00';
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Tax only Refund';
                cs.Issued_by_TravelAgent__c = true;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Ticket held in Credit';
                cs.Issued_by_TravelAgent__c = true;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
                cs.Refund_Type__c = 'Refunded with Cancellation Policy';
                cs.Issued_by_TravelAgent__c = true;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
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
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
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
                cs.Flight_Number__c = '0901';
                cs.ContactId = con.Id;
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
                System.enqueueJob(new QCC_CaseCreator(c, UserInfo.getSessionId()));
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
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
                cs.Flight_Number__c = '0401';
                cs.Lost_Property_Name__c = 'Bag';
                cs.Departure_Date_Time__c = '24/01/2018 11:46:00';
                cs.ContactId = con.Id;
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
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }

    @isTest static void test_method_twenty() {
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
                cs.Flight_Number__c = '0401';
                cs.ContactId = con.Id;
                cs.Issued_by_TravelAgent__c = true;
                cs.Country__c = 'Australia';
                cs.Post_Code__c = '2145';
                cs.Suburb__c = 'Westmead';
                cs.State__c = 'NSW';
                cs.Street__c = '15 hassall st';
                cs.Ticket_Issue_Date__c = Date.newInstance(2018, 01, 10);
                cs.Flight_Segments__c = 'Test';
                cs.Segment_Id__c = '123443545';
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
                QCC_EmailButtonController.getCaseValues(c.id,c.Type,false,null);
                //System.assertEquals(true, c.FCR__c);
            }
            Test.stopTest();
        }
    }
    //start QDCUSCON-2086
    @isTest static void testFetchSalesforceEmailTemplateId() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
            insert caseComplaint;
            Test.startTest();            
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }
    
    @isTest static void testFetchSalesforceEmailTemplateId2() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) { 
            String caseType = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            String sfEmailTemplateName = 'Insurance Letter';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'Booking Cancelled by Customer','','','');
            caseComplaint.Refund_Type__c = 'Refunded with Cancellation Policy';
            insert caseComplaint;
            Test.startTest();            
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }
    
    @isTest static void testFetchSalesforceEmailTemplateId3() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) { 
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'QCC_Blank Email';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;


            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            for(Recovery__c r : lstRecovery){
                r.Status__c = 'Rejected';
            }
            update lstRecovery;
            Test.startTest();            
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }

    @isTest static void testFetchSalesforceEmailTemplateId4() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) { 
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'QCC_Blank Email';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;

            Test.startTest();  
            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            for(Recovery__c r : lstRecovery){
                r.Status__c = 'Awaiting Approval';
            }
            update lstRecovery;
                      
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }

    @isTest static void testFetchSalesforceEmailTemplateId5() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) { 
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'QCC_Blank Email';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;


            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            for(Recovery__c r : lstRecovery){
                r.Status__c = 'Approved';
            }
            update lstRecovery;
            Test.startTest();            
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }

    @isTest static void testFetchSalesforceEmailTemplateId6() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) { 
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'QCC Digital Lounge Pass - Non Frequent Flyer';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;


            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            for(Recovery__c r : lstRecovery){
                r.Status__c = 'Approved';
            }
            update lstRecovery;
            Test.startTest();            
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId != null, ' Salesforce Email Template Id is Null');
            Test.stopTest();
        }
    }

    @isTest static void testFetchEmailTemplateValuesForFFM() {
        String caseType = 'Complaint';
        String recordType = 'CCC Complaints';
        Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
        List<Contact> contacts = [Select Id From Contact];           
        contacts[0].Frequent_Flyer_Number__c = '0006142208';
        update contacts;
        caseComplaint.ContactId = contacts[0].id;
        insert caseComplaint;


        //Create Recovery
        List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
        for(Recovery__c r : lstRecovery){
            r.Status__c = 'Approved';
            r.Type__c = CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes');
        }
        update lstRecovery;
        Test.startTest();            
        List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(recordType, caseComplaint.id);  
        system.assert(listEmTempMapping.size() == 6, 'Size of Email Template List is not match');         
        Test.stopTest();
    }

    @isTest static void testFetchEmailTemplateValuesForNonFFM() {
        String caseType = 'Complaint';
        String recordType = 'CCC Complaints';
        Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','Staff Assistance','','');
        List<Contact> contacts = [Select Id From Contact];           
        caseComplaint.ContactId = contacts[0].id;
        insert caseComplaint;


        //Create Recovery
        List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
        for(Recovery__c r : lstRecovery){
            r.Status__c = 'Awaiting Customer Response';
            r.Type__c = CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes');
        }
        update lstRecovery;
        Test.startTest();            
        List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(recordType, caseComplaint.id);  
        Test.stopTest();
    }

    //end QDCUSCON-2086
    /*
    //start QDCUSCON-2086
    @isTest static void testFetchCongaEmailTemplateIdBlankTemplate() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Blank Template';
            String congaEmailTemplateName = 'QCC_Blank Email';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
            insert caseComplaint;
            Test.startTest();            
            List<String> congaEmTempId = QCC_EmailButtonController.fetchCongaEmailTemplateId(caseComplaint, emailTemplateName, congaEmailTemplateName);           
            system.assert(congaEmTempId != null, ' Conga Email Template Id is Null');
            Test.stopTest();
        }
    }
    //end QDCUSCON-2086
    */

    //start QDCUSCON-2086
    @isTest static void testEmptyFetchSalesforceEmailTemplateId() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String sfEmailTemplateName = 'Complaint Template';

            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;


            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});

            
            Test.startTest();          
            List<String> emailTempId = QCC_EmailButtonController.fetchSalesforceEmailTemplateId(caseComplaint, sfEmailTemplateName);           
            system.assert(emailTempId == null, ' Conga Email Template Id is not Null');
            Test.stopTest();
        }
    }
    //end QDCUSCON-2086

    //start QDCUSCON-2086
    @isTest static void testFetchEmailTemplateValues() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Complaint Template';
            String congaEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
			List<Contact> contacts = [Select Id From Contact];           
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;

            String caseRecordType = 'CCC Complaints';
            List<QCC_EmailButtonController.WrapperEmailTemplate> expectedResult = new List<QCC_EmailButtonController.WrapperEmailTemplate>{new QCC_EmailButtonController.WrapperEmailTemplate('Complaint Template', 'Complaint Template') , 
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('Blank Template', 'QCC_Blank Email') ,
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation', 'EFT Authorisation'),
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('Acknowledgement Template', 'QCC_Acknowledgement_Letter'),
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation - No Receipt', 'EFT Authorisation - No Receipts')};
            Test.startTest();            
            List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(caseRecordType, caseComplaint.id);           
            system.assert(listEmTempMapping.size() == 5, 'Size of Email Template List is not match');
            Test.stopTest();
        }
    }
    
    @isTest static void testFetchEmailTemplateValues2() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Complaint Template';
            String congaEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;
            System.debug(LoggingLevel.ERROR, caseComplaint);

            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});

            String caseRecordType = 'CCC Complaints';
            List<QCC_EmailButtonController.WrapperEmailTemplate> expectedResult = new List<QCC_EmailButtonController.WrapperEmailTemplate>{new QCC_EmailButtonController.WrapperEmailTemplate('Complaint Template', 'Complaint Template') , 
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('Blank Template', 'QCC_Blank Email') ,
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation', 'EFT Authorisation'),
																	new QCC_EmailButtonController.WrapperEmailTemplate('Acknowledgement Template', 'QCC_Acknowledgement_Letter'),
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation - No Receipt', 'EFT Authorisation - No Receipts')};
            Test.startTest();            
            List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(caseRecordType, caseComplaint.id);           
            system.assert(listEmTempMapping.size() == 5, 'Size of Email Template List is not match');
            Test.stopTest();
        }
    }
    //end QDCUSCON-2086

	// test with Recovery.Type__c = 'Qantas Points' AND Recovery.Status__c = 'Awaiting Customer Response'
    @isTest static void testFetchEmailTemplateValues3() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Complaint Template';
            String congaEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;
            System.debug(LoggingLevel.ERROR, 'caseComplaint ==> ' + caseComplaint);

            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            System.debug(LoggingLevel.ERROR, 'lstRecovery ===> ' + lstRecovery);
            for(Recovery__c r : lstRecovery) {
             	r.Type__c = 'Qantas Points';
                r.Status__c = 'Awaiting Customer Response';
            }
            System.debug(LoggingLevel.ERROR, 'after lstRecovery ===> ' + lstRecovery);
            upsert lstRecovery;

            String caseRecordType = 'CCC Complaints';
            List<QCC_EmailButtonController.WrapperEmailTemplate> expectedResult = new List<QCC_EmailButtonController.WrapperEmailTemplate>{new QCC_EmailButtonController.WrapperEmailTemplate('Complaint Template', 'Complaint Template') , 
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('Blank Template', 'QCC_Blank Email') ,
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation', 'EFT Authorisation'),
																	new QCC_EmailButtonController.WrapperEmailTemplate('Acknowledgement Template', 'QCC_Acknowledgement_Letter'),
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation - No Receipt', 'EFT Authorisation - No Receipts')};
            Test.startTest();            
            List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(caseRecordType, caseComplaint.id);           
            system.assert(listEmTempMapping.size() == 6, 'Size of Email Template List is not match');
            Test.stopTest();
        }
    }
    
    // test with Recovery.Type__c = 'Credit Card Refund' AND Recovery.Status__c = 'Submit for Finalisation'
    @isTest static void testFetchEmailTemplateValues4() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Complaint Template';
            String congaEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
            List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;
            System.debug(LoggingLevel.ERROR, 'caseComplaint ==> ' + caseComplaint);

            //Create Recovery
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(new List<Case>{caseComplaint});
            System.debug(LoggingLevel.ERROR, 'lstRecovery ===> ' + lstRecovery);
            for(Recovery__c r : lstRecovery) {
             	r.Type__c = 'Credit Card Refund';
                r.Status__c = 'Submit for Finalisation';
            }
              Test.startTest();  
            System.debug(LoggingLevel.ERROR, 'after lstRecovery ===> ' + lstRecovery);
            upsert lstRecovery;

            String caseRecordType = 'CCC Complaints';
            List<QCC_EmailButtonController.WrapperEmailTemplate> expectedResult = new List<QCC_EmailButtonController.WrapperEmailTemplate>{new QCC_EmailButtonController.WrapperEmailTemplate('Complaint Template', 'Complaint Template') , 
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('Blank Template', 'QCC_Blank Email') ,
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation', 'EFT Authorisation'),
																	new QCC_EmailButtonController.WrapperEmailTemplate('Acknowledgement Template', 'QCC_Acknowledgement_Letter'),
                                                                    new QCC_EmailButtonController.WrapperEmailTemplate('EFT Authorisation - No Receipt', 'EFT Authorisation - No Receipts')};
                    
            List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(caseRecordType, caseComplaint.id);           
            system.assert(listEmTempMapping.size() == 6, 'Size of Email Template List is not match');
            Test.stopTest();
        }
    }

    //start QDCUSCON-2086
    @isTest static void testEmptyFetchEmailTemplateValues() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String caseType = 'Complaint';
            String recordType = 'CCC Complaints';
            String emailTemplateName = 'Complaint Template';
            String congaEmailTemplateName = 'Complaint Template';
            Case caseComplaint = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, caseType, 'In-Flight','','','');
			List<Contact> contacts = [Select Id From Contact];
            caseComplaint.ContactId = contacts[0].id;
            insert caseComplaint;

            String caseRecordType = 'Complaint';
            
            Test.startTest();          
            List<QCC_EmailButtonController.WrapperEmailTemplate> listEmTempMapping = QCC_EmailButtonController.fetchEmailTemplateValues(caseRecordType, caseComplaint.id);           
            system.assert(listEmTempMapping.size() == 0, 'Email Template List is not empty');
            Test.stopTest();
        }
    }
    //end QDCUSCON-2086

    //start QDCUSCON-3550
    @isTest static void testGetCongaQueryAffectedPassenger() {
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];

        System.runAs(u1) {
            String expectedResult;           
            APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
            congaQuery.APXTConga4__Name__c = 'QCC Affected Passenger For Insurance Letter';
            congaQuery.APXTConga4__Query__c = 'select firstname__c, lastname__c, Ticket_Number__c, Fare_Total__c, Refund_Amount__c, Booking_Change_Fee__c, Cancellation_Fee__c from Affected_Passenger__c where Case__c = \'{pv0}\'';
            insert congaQuery;
            expectedResult = congaQuery.Id;
            Test.startTest();          
            String actualResult = QCC_EmailButtonController.getCongaQueryAffectedPassenger();
            system.assert(expectedResult == actualResult, 'Email Template List is not empty');
            Test.stopTest();
        }
    }
    //end QDCUSCON-3550

    static testMethod void testHasCaseAffectedPassenger() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
        cs.Origin = 'Qantas.com';
        cs.Booking_PNR__c = 'K5F5ZE';
        cs.Flight_Number__c = 'QF0401';
        cs.ContactId = contacts[0].Id;
        cs.Suburb__c = 'NSW';
        cs.Street__c = 'Jackson';
        cs.State__c = 'Mascot';
        cs.Post_Code__c = '20020';
        cs.Country__c = 'Australia';
                
        insert cs;
        Test.startTest();
        Boolean result = QCC_EmailButtonController.hasCaseAffectedPassenger(cs.Id);
        Test.stopTest();
        System.assertEquals(false, result);
    }
}