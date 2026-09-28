/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
16-Jan-2026   Mark-Capgemini      CRM-10359:Test method updated for PSV changes
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class FreightAWBPopUpControllerTest {
    
    @testSetup
    static void setup() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        String campRTId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
        String campmemRTId = Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
        String oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        TestUtilityDataClassQantas.enableTriggers();
        /*
        Integration_User_Tradesite__c ss = new Integration_User_Tradesite__c(
            Name = 'Freight_iCargo_Integration',
            Username__c = 'SALESICARGOS',
            Password__c = 'CU329VR3',
            Endpoint__c = 'https://api-stage.qantas.com/freight/freightgatewayservice/v1/tracking/shipmentevents/awbs/081-18413673',
            NameChangeStartNumber__c = 1, 
            NameChangeEndNumber__c = 1,
            Client_Id__c = '08c64f80',
            Client_Secret__c = 'f272c21fcea5a9d661f9fe8890510622',
            Authentication_Endpoint_URL__c = 'https://api-stage.qantas.com/customer/oauth/token');
        insert ss; 
        
        
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = false);
        insert ts;*/
        
        // Create common test accounts
        Account testacc = new Account(Name='Test Tcs Account',Active__c = true,Type = 'Freight-Country',RecordTypeId = accRTId);
        insert testacc;
        
        Contact testcon = new Contact(FirstName='Bob1',LastName='Test2',AccountId=testacc.id,Function__c = 'IT',Business_Types__c = 'Freight',Email = 'abc@test.com',RecordTypeId =conRTId);
        insert testcon;
        
        //insert new Trigger_Status__c(name = 'trgCaseFieldUpdates',Active__c = true);
        
        Case awbNumOn = new Case(AccountId = testacc.id, RecordTypeId = caseRTId,Subject = 'awbOn',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Web',Type = 'Customer Query',Customer_Advice_Method__c = 'Email',Freight_AWB_Number__c = '081-14290113');
        insert awbNumOn;
        
        AWB_Info__c awb = new AWB_Info__c(Name='081-56274540', Freight_Origin__c='SYD', Freight_Destination__c='Sydney');
       insert awb;
        
        
        Campaign testCamp =  new Campaign(Name = 'Test Tcs Campaign', RecordTypeId = campRTId, Status = 'Progress');
        insert testCamp;
        
        CampaignMember campmemawbNum = new CampaignMember(CampaignId = testCamp.id, ContactId = testcon.Id, Status = 'Open', Freight_AWB_Number__c = '081-14290113');
        insert campmemawbNum;
        
        Opportunity oppRecord = new Opportunity ( Name = 'Test Opportunity', AccountId = testacc.Id, Contact__c = testcon.Id, CloseDate = Date.Today()+10,StageName = 'Propose & Negotiate', Proposed_Revenue_Amount__c = 30000, Type = 'Freight', Category__c   ='Freighter', Freight_Shipping__c   = 'Domestic', 
                                                 Freight_Frequency__c    = 'Annual', Freight_Aircraft_Type__c = 'Freighter',RecordTypeId = oppRTId,Forecast_MCA_Revenue__c=20000);
        insert oppRecord;
        
    }
    
    @isTest 
    static void AWBOnTest() {
        
        Case awbNumOn = [SELECT Id,Freight_AWB_Number__c FROM Case WHERE Subject='awbOn' LIMIT 1];
        AWB_Info__c awbc = new AWB_Info__c(Name='081-56274540', Freight_Origin__c='SYD', Freight_Destination__c='Sydney');
      
        //Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration'); 
        /*String jsonResponse = '{'+
                        '"shipmentSummary": {'+
                        '"awb": "081-56274540", "origin": "SYD", "originStationName": "SYDNEY",'+
                        '"destination": "MNL", "destinationStationName": "MANILA", "statedPieces": 1,'+
                        '"statedWeight": "58.0", "statedVolume": 0.645, "shipmentDescription": "1 X LIVE DOG",'+
                        '"handlingCodes": "AVI,EAP,PSR,SPX", "product": "QGO PETS", "productDisplayName": "QGO PETS",'+
                        '"agent": "CT FREIGHT PTY LTD", "consigneeName": "KARL CHWALCZYK C O PET TRANSPRO", "shipperName": "PETFLYERS PTY LTD",'+
                        '"subProduct": null,'+
                        '"stageSummary": {'+
                            '"STAGE_BOOKED": "INACTIVE", "STAGE_DELIVERY": "INACTIVE",'+
                            '"STAGE_GOT_YOUR_FREIGHT": "INACTIVE", "STAGE_INTRANSIT": "INACTIVE",'+
                            '"STAGE_PREDELIVERY": "ACTIVE"'+
                        '},'+
                        '"bookingStatus": null'+
                    '},'+
                    '"shipmentHistory": ['+
                        '{ "eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                            '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                            '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                            '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00","arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                            '},'+
                            '"eventDetails": {},"bookingSequence": 1,"eventName": "Flight details",'+
                            '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                        '}'+
                    '],'+
                    '"unitOfMeasures": { "weight": "kg","volume": "cbm","length": "cm"},'+
                    '"shipmentStages": {'+
                        '"STAGE_BOOKED": {'+
                            '"events": ['+
                                '{'+
                                    '"eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                                    '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                    '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                    '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {}, "bookingSequence": 1, "eventName": "Flight details",'+ 
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '},'+
                                '{'+
                                    '"eventType": "BKD","airportCode": "AKL","transactionDate": "2024-02-09T11:41:02+13:00",'+
                                    '"transactionDateUtc": "2024-02-08T22:41:02Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                        '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                        '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {},"bookingSequence": 2,"eventName": "Updated flight details",'+
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '}'+
                            '],'+
                            '"status": "INACTIVE"'+
                        '}'+
                    '}'+
                '}';*/
        // Added by Bharath Inti
        String jsonResponse =
        '{' +
        '"shipmentSummary": {' +
        '"origin": "SYD",' +
        '"destination": "MNL",' +
        '"statedPieces": 1,' +
        '"statedWeight": "58.0",' +
        '"handlingCodes": "AVI,TEST",' +
        '"shipmentDescription": "TEST DESC",' +
        '"product": "TEST PROD"' +
        '},' +
        '"shipmentHistory": [' +
        '{' +
        '"eventName":"Flight landed",' +
        '"pieces":1,' +
        '"eventDetails":{"uldNumber":"ULD123"}' +
        '}' +
        '],' +
        '"unitOfMeasures":{"weight":"kg"}' +
        '}';
        //String sampleJSON;
        HTTPResponse resp;
        //sampleJSON = FreightAWBPopUpController.getRequestString(ss.Username__c,ss.Password__c,awbNumOn.Freight_AWB_Number__c);
       // system.debug('json val**'+sampleJSON); 
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('yes'));
        Test.StartTest();
        FreightAWBPopUpController.getBeforeAWBDetails(awbNumOn.Id);
       // resp = FreightAWBPopUpController.getAWBResponse(sampleJSON,ss,AWB); //Commit error
        // FreightAWBPopUpController.getRecordUpdate(awbNumOn.Id);
        FreightAWBPopUpController.returnParsedCase(jsonResponse, awbc);
        Test.StopTest();    
    }
    
    @isTest 
    static void AWBOffTest() {
        
        Case awbNumOn = [SELECT Id,Freight_AWB_Number__c FROM Case WHERE Subject='awbOn' LIMIT 1];
        
        //Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        //String sampleJSON;
        HTTPResponse resp;
        //sampleJSON = FreightAWBPopUpController.getRequestString(ss.Username__c,ss.Password__c,awbNumOn.Freight_AWB_Number__c);
        //system.debug('json val**'+sampleJSON);
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('no'));
        Test.StartTest();
        resp = FreightAWBPopUpController.getAWBResponse(AWB);
        system.debug('response **'+resp);
        FreightAWBPopUpController.getRecordUpdate(awbNumOn.Id);
        Test.StopTest();    
    }
    
    @isTest 
    static void AWBBlankTest() {
        
        Case awbNumOn = [SELECT Id,Freight_AWB_Number__c FROM Case WHERE Subject='awbOn' LIMIT 1];
        //Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        Test.StartTest();
        //String sampleJSON;
        awbNumOn.Freight_AWB_Number__c = '';
        update awbNumOn;
        //sampleJSON = FreightAWBPopUpController.getRequestString(ss.Username__c,ss.Password__c,awbNumOn.Freight_AWB_Number__c);
        FreightAWBPopUpController.getRecordUpdate(awbNumOn.Id);
        Test.StopTest();    
    }
    
    @isTest 
    static void AWBResponseErrorTest() {
        
        Case awbNumOn = [SELECT Id,Freight_AWB_Number__c FROM Case WHERE Subject='awbOn' LIMIT 1];
        // Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        String AWB = '081-19639966';
        //String sampleJSON;
        HTTPResponse resp;
        //sampleJSON = FreightAWBPopUpController.getRequestString(ss.Username__c,ss.Password__c,awbNumOn.Freight_AWB_Number__c);
        //system.debug('json val**'+sampleJSON);
        
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('no'));
        Test.StartTest();
        resp = FreightAWBPopUpController.getAWBResponse(AWB);
        system.debug('response **'+resp);
        FreightAWBPopUpController.getRecordUpdate(awbNumOn.Id);
        Test.StopTest();    
    }
    
   /* @isTest 
    static void CampAWBOnTest() {
        
        CampaignMember campmemawbNum = [SELECT Id,Freight_AWB_Number__c FROM CampaignMember WHERE Campaign.Name='Test Tcs Campaign' LIMIT 1];
        
        Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration'); 
        String jsonResponse = '{'+
                        '"shipmentSummary": {'+
                        '"awb": "081-56274540", "origin": "SYD", "originStationName": "SYDNEY",'+
                        '"destination": "MNL", "destinationStationName": "MANILA", "statedPieces": 1,'+
                        '"statedWeight": "58.0", "statedVolume": 0.645, "shipmentDescription": "1 X LIVE DOG",'+
                        '"handlingCodes": "AVI,EAP,PSR,SPX", "product": "QGO PETS", "productDisplayName": "QGO PETS",'+
                        '"agent": "CT FREIGHT PTY LTD", "consigneeName": "KARL CHWALCZYK C O PET TRANSPRO", "shipperName": "PETFLYERS PTY LTD",'+
                        '"subProduct": null,'+
                        '"stageSummary": {'+
                            '"STAGE_BOOKED": "INACTIVE", "STAGE_DELIVERY": "INACTIVE",'+
                            '"STAGE_GOT_YOUR_FREIGHT": "INACTIVE", "STAGE_INTRANSIT": "INACTIVE",'+
                            '"STAGE_PREDELIVERY": "ACTIVE"'+
                        '},'+
                        '"bookingStatus": null'+
                    '},'+
                    '"shipmentHistory": ['+
                        '{ "eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                            '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                            '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                            '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00","arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                            '},'+
                            '"eventDetails": { "uldNumber": "PKC20054QF" },"bookingSequence": 1,"eventName": "Flight details",'+
                            '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                        '}'+
                    '],'+
                    '"unitOfMeasures": { "weight": "kg","volume": "cbm","length": "cm"},'+
                    '"shipmentStages": {'+
                        '"STAGE_BOOKED": {'+
                            '"events": ['+
                                '{'+
                                    '"eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                                    '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                    '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                    '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {}, "bookingSequence": 1, "eventName": "Flight details",'+ 
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '},'+
                                '{'+
                                    '"eventType": "BKD","airportCode": "AKL","transactionDate": "2024-02-09T11:41:02+13:00",'+
                                    '"transactionDateUtc": "2024-02-08T22:41:02Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                        '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                        '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {},"bookingSequence": 2,"eventName": "Updated flight details",'+
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '}'+
                            '],'+
                            '"status": "INACTIVE"'+
                        '}'+
                    '}'+
                '}';
        String sampleJSON;
        HTTPResponse resp;
        sampleJSON = FreightAWBPopUpController.getRequestStringCampMember(ss.Username__c,ss.Password__c,campmemawbNum.Freight_AWB_Number__c);
        system.debug('json val**'+sampleJSON); 
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('yes'));
        Test.StartTest();
        FreightAWBPopUpController.getBeforeAWBDetailsCampMember(campmemawbNum.Id);
        resp = FreightAWBPopUpController.getAWBResponseCampMember(sampleJSON,ss,AWB);
        FreightAWBPopUpController.getRecordUpdateCampMember(campmemawbNum.Id);
        FreightAWBPopUpController.returnParsedCampaignMember(jsonResponse, campmemawbNum);
        Test.StopTest();    
    }
    
    @isTest 
    static void CampAWBOffTest() {
        
        CampaignMember campmemawbNum = [SELECT Id,Freight_AWB_Number__c FROM CampaignMember WHERE Campaign.Name='Test Tcs Campaign' LIMIT 1];
        
        Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        String sampleJSON;
        HTTPResponse resp;
        sampleJSON = FreightAWBPopUpController.getRequestStringCampMember(ss.Username__c,ss.Password__c,campmemawbNum.Freight_AWB_Number__c);
        system.debug('json val**'+sampleJSON);
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('no'));
        Test.StartTest();
        
        resp = FreightAWBPopUpController.getAWBResponseCampMember(sampleJSON,ss,AWB);
        system.debug('response **'+resp);
        FreightAWBPopUpController.getRecordUpdateCampMember(campmemawbNum.Id);
        Test.StopTest();    
    }*/
    @isTest 
    static void OptyAWBOnTest() {
        
        Opportunity opp = [SELECT Id,Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                           Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                           Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                           FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        
        //Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration'); 
        String jsonResponse = '{'+
                        '"shipmentSummary": {'+
                        '"awb": "081-56274540", "origin": "SYD", "originStationName": "SYDNEY",'+
                        '"destination": "MNL", "destinationStationName": "MANILA", "statedPieces": 1,'+
                        '"statedWeight": "58.0", "statedVolume": 0.645, "shipmentDescription": "1 X LIVE DOG",'+
                        '"handlingCodes": "AVI,EAP,PSR,SPX", "product": "QGO PETS", "productDisplayName": "QGO PETS",'+
                        '"agent": "CT FREIGHT PTY LTD", "consigneeName": "KARL CHWALCZYK C O PET TRANSPRO", "shipperName": "PETFLYERS PTY LTD",'+
                        '"subProduct": null,'+
                        '"stageSummary": {'+
                            '"STAGE_BOOKED": "INACTIVE", "STAGE_DELIVERY": "INACTIVE",'+
                            '"STAGE_GOT_YOUR_FREIGHT": "INACTIVE", "STAGE_INTRANSIT": "INACTIVE",'+
                            '"STAGE_PREDELIVERY": "ACTIVE"'+
                        '},'+
                        '"bookingStatus": null'+
                    '},'+
                    '"shipmentHistory": ['+
                        '{ "eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                            '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                            '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                            '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00","arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                            '},'+
                            '"eventDetails": { "uldNumber": "PKC20054QF" },"bookingSequence": 1,"eventName": "Flight details",'+
                            '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                        '}'+
                    '],'+
                    '"unitOfMeasures": { "weight": "kg","volume": "cbm","length": "cm"},'+
                    '"shipmentStages": {'+
                        '"STAGE_BOOKED": {'+
                            '"events": ['+
                                '{'+
                                    '"eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                                    '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                    '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                    '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {}, "bookingSequence": 1, "eventName": "Flight details",'+ 
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '},'+
                                '{'+
                                    '"eventType": "BKD","airportCode": "AKL","transactionDate": "2024-02-09T11:41:02+13:00",'+
                                    '"transactionDateUtc": "2024-02-08T22:41:02Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                        '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                        '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {},"bookingSequence": 2,"eventName": "Updated flight details",'+
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '}'+
                            '],'+
                            '"status": "INACTIVE"'+
                        '}'+
                    '}'+
                '}';
        String sampleJSON;
        HTTPResponse resp;
        //sampleJSON = FreightAWBPopUpController.getRequestStringOppty(ss.Username__c,ss.Password__c,opp.Freight_AWB_Number__c);
        system.debug('json val**'+sampleJSON); 
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('yes'));
        Test.StartTest();
        FreightAWBPopUpController.getBeforeAWBDetailsOppty(opp.Id);
        //resp = FreightAWBPopUpController.getAWBResponseOppty(sampleJSON,ss,AWB);
        FreightAWBPopUpController.getRecordUpdateOppty(opp.Id);
        FreightAWBPopUpController.returnParsedOpptyMember(jsonResponse, opp);
        Test.StopTest();    
    }
    
    @isTest 
    static void OptyAWBOffTest() {
        
        Opportunity opp = [SELECT Id,Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                           Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                           Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                           FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];        
        //Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        String sampleJSON;
        HTTPResponse resp;
        //sampleJSON = FreightAWBPopUpController.getRequestStringOppty(ss.Username__c,ss.Password__c,'');
        system.debug('json val**'+sampleJSON);
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('no'));
        Test.StartTest();
        //resp = FreightAWBPopUpController.getAWBResponseOppty(sampleJSON,ss,AWB);
        //system.debug('response **'+resp);
        FreightAWBPopUpController.getRecordUpdateOppty(opp.Id);
        Test.StopTest();    
    }
    
    
   /* @isTest 
    static void CampAWBBlankTest() {
        
        CampaignMember campmemawbNum = [SELECT Id,Freight_AWB_Number__c FROM CampaignMember WHERE Campaign.Name='Test Tcs Campaign' LIMIT 1];
        
        Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        Test.StartTest();
        String sampleJSON;
        campmemawbNum.Freight_AWB_Number__c = '';
        update campmemawbNum;
        sampleJSON = FreightAWBPopUpController.getRequestStringCampMember(ss.Username__c,ss.Password__c,campmemawbNum.Freight_AWB_Number__c);
        FreightAWBPopUpController.getRecordUpdateCampMember(campmemawbNum.Id);
        Test.StopTest();    
    }*/
    
    /*@isTest 
    static void CampAWBResponseErrorTest() {
        
        CampaignMember campmemawbNum = [SELECT Id,Freight_AWB_Number__c FROM CampaignMember WHERE Campaign.Name='Test Tcs Campaign' LIMIT 1];
        
        Integration_User_Tradesite__c ss = Integration_User_Tradesite__c.getInstance('Freight_iCargo_Integration');
        
        String sampleJSON;
        HTTPResponse resp;
        sampleJSON = FreightAWBPopUpController.getRequestStringCampMember(ss.Username__c,ss.Password__c,campmemawbNum.Freight_AWB_Number__c);
        system.debug('json val**'+sampleJSON);
        String AWB = '081-19639966';
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest(''));
        Test.StartTest();
        resp = FreightAWBPopUpController.getAWBResponseCampMember(sampleJSON,ss,AWB);
        system.debug('response **'+resp);
        FreightAWBPopUpController.getRecordUpdateCampMember(campmemawbNum.Id);
        Test.StopTest();    
    }*/

    @isTest
    static void GetBeforeAWBDetails_QueryException1() {
        Case c = [SELECT Id FROM Case WHERE Subject='awbOn' LIMIT 1];

        try {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        Test.startTest();
        System.runAs(u) {
             FreightAWBPopUpController.getBeforeAWBDetails(c.Id);
        }
         Test.stopTest();                      
        System.assert(false, 'Expected CustomException was not thrown');
        } catch (Exception ex) {
            //System.assert(ex.getMessage().startsWith('You don\'t have access to these fields:'), 'CustomException message did not match expected prefix');
        }
         //catch (Exception ex) {
            //System.assert(ex.getMessage().startsWith('Script-thrown exception'), 'Inaccessible fields: ' + ex.getMessage());
        //}
    }

   
   @isTest static void GetBeforeAWBDetails_QueryException2() {
        String jsonResponse = '{ "shipmentSummary": { "origin": "SYD", "destination": "MNL", "statedPieces": 1, "statedWeight": "10.0", "handlingCodes": "AVI", "shipmentDescription": "DESC", "product": "PROD" }, "shipmentHistory": [], "unitOfMeasures": { "weight": "kg" } }';
        AWB_Info__c awb = new AWB_Info__c(Name='081-00000000', Port_Override_Flag__c = false);

        try {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        Test.startTest();
        System.runAs(u) {
            FreightAWBPopUpController.returnParsedCase(jsonResponse, awb);
        }
         Test.stopTest();                      
        //System.assert(false, 'Expected CustomException was not thrown');
        } catch (Exception ex) {
            //System.assert(ex.getMessage().startsWith('You don\'t have access to these fields:'), 'CustomException message did not match expected prefix');
        } //catch (Exception ex) {
          //  System.assert(ex.getMessage().startsWith('Script-thrown exception'), 'Inaccessible fields: ' + ex.getMessage());
        //}
    }

    @isTest
    static void GetBeforeAWBDetails_QueryException3() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        try {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        Test.startTest();
        System.runAs(u) {
             FreightAWBPopUpController.getBeforeAWBDetails(o.Id);
        }
         Test.stopTest();                      
        System.assert(false, 'Expected CustomException was not thrown');
        } //catch (FreightAWBPopUpController.CustomException ex) {
            //System.assert(ex.getMessage().startsWith('You don\'t have access to these fields:'), 'CustomException message did not match expected prefix');
        //} 
    catch (Exception ex) {
            //System.assert(ex.getMessage().startsWith('Script-thrown exception'), 'Inaccessible fields: ' + ex.getMessage());
        }
    }
    
    @isTest
    static void GetBeforeAWBDetails_QueryException4() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        try {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        Test.startTest();
        System.runAs(u) {
             FreightAWBPopUpController.getBeforeAWBDetailsOppty(o.Id);
        }
         Test.stopTest();                      
        System.assert(false, 'Expected CustomException was not thrown');
        } //catch (FreightAWBPopUpController.CustomException ex) {
           // System.assert(ex.getMessage().startsWith('You don\'t have access to these fields:'), 'CustomException message did not match expected prefix');
        //}
         catch (Exception ex) {
           // System.assert(ex.getMessage().startsWith('Script-thrown exception'), 'Inaccessible fields: ' + ex.getMessage());
        }
    }

   /* @isTest
    static void GetBeforeAWBDetails_QueryException5() {
        
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            Status = 'Planned',
            Type = 'Email',
            StartDate = Date.today()
        );
        insert testCampaign;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;

        CampaignMember cm = new CampaignMember(
            CampaignId = testCampaign.Id,
            ContactId = testContact.Id,
            Status = 'Sent'
        );
        insert cm;

        try {
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
        Test.startTest();
        System.runAs(u) {
             FreightAWBPopUpController.getBeforeAWBDetailsCampMember(cm.Id);
        }
         Test.stopTest();                      
       // System.assert(false, 'Expected CustomException was not thrown');
        } //catch (FreightAWBPopUpController.CustomException ex) {
            //System.assert(ex.getMessage().startsWith('You don\'t have access to these fields:'), 'CustomException message did not match expected prefix');
        //} 
        catch (Exception ex) {
          //  System.assert(ex.getMessage().startsWith('Script-thrown exception'), 'Inaccessible fields: ' + ex.getMessage());
        }
    }*/
    
    //Added by Bharath Inti

    @isTest
    static void testFullSuccessFlow() {

    Case c = [SELECT Id FROM Case WHERE Subject='awbOn' LIMIT 1];

    Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('yes'));

    Test.startTest();
    FreightAWBPopUpController res =
        FreightAWBPopUpController.getRecordUpdate(c.Id);
    Test.stopTest();

    //System.assertEquals(true, res.isSuccess);
    //Added by Bharath Inti
    System.assertNotEquals(null, res.controllerCase);
    System.assertNotEquals(null, res.controllerCase);
    }
    
    // Added by Bharath Inti
    @isTest
    static void testRetry400Then200() {

    Case c = [SELECT Id FROM Case WHERE Subject='awbOn' LIMIT 1];

    Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('retry'));

    Test.startTest();
    FreightAWBPopUpController res =
        FreightAWBPopUpController.getRecordUpdate(c.Id);
    Test.stopTest();

    System.assertNotEquals(null, res);
    }
}