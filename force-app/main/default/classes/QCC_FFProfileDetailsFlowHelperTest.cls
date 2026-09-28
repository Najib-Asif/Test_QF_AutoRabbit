/*==============================================================================================================================
Author:         Darwin Herbert Lubas
Company:        Acceture
Purpose:        Test class for QCC_FFProfileDetailsFlowHelper
==============================================================================================================================*/

@isTest
public class QCC_FFProfileDetailsFlowHelperTest {
    @testSetup static void setup(){
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus;

        TestUtilityDataClassQantas.insertQantasConfigData();

        List<Qantas_API__c> lstQantasASPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantasASPI;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'test@mailinator.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_NoReplyContactLastName', 'QCC_NoReplyContactLastName'));
        
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel','NUMBER'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID','DIAMD01'));
        insert lstConfigData;
        
        
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Map<String, StaticResource> resourceMap = new Map<String, StaticResource>();
        for(StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name LIKE 'QCCTestData%']) {
			resourceMap.put(sr.Name, sr);
		}
        String contactJSON = resourceMap.get('QCCTestData_ADT_Contact').Body.toString();
        contactJSON = contactJSON.replaceAll('RecordTypeIdValue', contactRecordTypeId);
        contactJSON = contactJSON.replaceAll('1002918361', '2002918361');
        List<sObject> contactRecord = (List<sObject>) JSON.deserialize(contactJSON, List<sObject>.class);
		insert contactRecord;
    }
    
    @isTest
    public static void getFullFrequentFlyerDetailsTest(){
        List<QCC_FFProfileDetailsFlowHelper.FlowInputs> flowInputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowInputs>(); 
        QCC_FFProfileDetailsFlowHelper.FlowInputs flowInputs = new QCC_FFProfileDetailsFlowHelper.FlowInputs();
        List<Contact> con = [SELECT Id, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, Year_of_Joining__c, QCC_Frequent_Flyer_Anniversary_Date__c,QCC_TECH_Member_Tier_Downgrade_Date__c, Points_Balance__c, QCC_Status_credits_till_next_Level__c, Status_Credits__c, FirstName, LastName, Email, Phone,MailingState,CountryName__c FROM Contact];
        flowInputs.contactRecord = con[0];
        flowInputs.ffNumber = con[0].Frequent_Flyer_Number__c;
        flowInputs.methodName = 'getFullFrequentFlyerDetails';
        flowInputsList.add(flowInputs);
      
        //String testBody = '{"qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        String testBody = '{"dateOfBirth":"1980-05-01","firstName":"tlfwfsdmni","lastName":"test","memberId":"2002918361","preferredName":"lsl","title":"MR","addresses":[{"country":"AU","countryName":"Australia","lineOne":"TEST Bus ADDRESS LINE 1","lineTwo":"TEST Bus ADDRESS LINE 2","postCode":"2020","preferred":false,"state":"NSW","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"AU","countryName":"Australia","lineOne":"TEST ADDRESS LINE 1","lineTwo":"TEST ADDRESS LINE 2","postCode":"2390","preferred":true,"state":"NSW","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":61,"e164Format":"+61022366749","internationalFormat":"+61 02 2366749","nationalFormat":"02 2366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":61,"e164Format":"+6114371592","internationalFormat":"+61 14371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE","qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        List<QCC_FFProfileDetailsFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowOutputs>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testBody, mapHeader));

        
        //flowOutputsList = QCC_FFProfileDetailsFlowHelper.getFullFrequentFlyerDetails(flowInputsList);
        flowOutputsList = QCC_FFProfileDetailsFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.AssertEquals(false, flowOutputsList.isEmpty());
    }
    
    @isTest
    public static void getFullFrequentFlyerDetailsTestForNonAU(){
        List<QCC_FFProfileDetailsFlowHelper.FlowInputs> flowInputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowInputs>(); 
        QCC_FFProfileDetailsFlowHelper.FlowInputs flowInputs = new QCC_FFProfileDetailsFlowHelper.FlowInputs();
        List<Contact> con = [SELECT Id, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, Year_of_Joining__c, QCC_Frequent_Flyer_Anniversary_Date__c,QCC_TECH_Member_Tier_Downgrade_Date__c, Points_Balance__c, QCC_Status_credits_till_next_Level__c, Status_Credits__c, FirstName, LastName, Email, Phone,MailingState,CountryName__c FROM Contact];
        flowInputs.contactRecord = con[0];
        flowInputs.ffNumber = con[0].Frequent_Flyer_Number__c;
        flowInputs.methodName = 'getFullFrequentFlyerDetails';
        flowInputsList.add(flowInputs);
      
        //String testBody = '{"qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        
        String testBody = '{"dateOfBirth":"1980-05-01","firstName":"tlfwfsdmni","lastName":"test","memberId":"2002918361","preferredName":"lsl","title":"MR","addresses":[{"country":"NZ","countryName":"New Zealand","lineOne":"TEST Bus ADDRESS LINE 1","lineTwo":"TEST Bus ADDRESS LINE 2","postCode":"6011","preferred":false,"state":"WELLINGTON","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"NZ","countryName":"New Zealand","lineOne":"TEST ADDRESS LINE 1","lineTwo":"TEST ADDRESS LINE 2","postCode":"6011","preferred":true,"state":"WELLINGTON","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":64,"e164Format":"+64022366749","internationalFormat":"+64 02 2366749","nationalFormat":"02 2366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["NZ","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":64,"e164Format":"+6414371592","internationalFormat":"+64 14371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["NZ","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE","qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        List<QCC_FFProfileDetailsFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowOutputs>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testBody, mapHeader));

        
        //flowOutputsList = QCC_FFProfileDetailsFlowHelper.getFullFrequentFlyerDetails(flowInputsList);
        flowOutputsList = QCC_FFProfileDetailsFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.AssertEquals(false, flowOutputsList.isEmpty());
    }

    @isTest
    public static void getNewFrequentFlyerDetailsTest(){
        List<QCC_FFProfileDetailsFlowHelper.FlowInputs> flowInputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowInputs>(); 
        QCC_FFProfileDetailsFlowHelper.FlowInputs flowInputs = new QCC_FFProfileDetailsFlowHelper.FlowInputs();
        List<Contact> con = [SELECT Id, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, Year_of_Joining__c, QCC_Frequent_Flyer_Anniversary_Date__c,QCC_TECH_Member_Tier_Downgrade_Date__c, Points_Balance__c,Status_Credits__c, FirstName, LastName, Email, Phone FROM Contact];
        flowInputs.contactRecord = con[0];
        flowInputs.ffNumber = con[0].Frequent_Flyer_Number__c;
        flowInputs.methodName = 'getNewFrequentFlyerDetails';
        flowInputsList.add(flowInputs);
      
        //String testBody = '{"qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        String testBody = '{"dateOfBirth":"1980-05-01","firstName":"tlfwfsdmni","lastName":"test","memberId":"2002918361","preferredName":"lsl","title":"MR","addresses":[{"country":"AU","countryName":"Australia","lineOne":"TEST Bus ADDRESS LINE 1","lineTwo":"TEST Bus ADDRESS LINE 2","postCode":"2020","preferred":false,"state":"NSW","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"AU","countryName":"Australia","lineOne":"TEST ADDRESS LINE 1","lineTwo":"TEST ADDRESS LINE 2","postCode":"2390","preferred":true,"state":"NSW","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":61,"e164Format":"+61022366749","internationalFormat":"+61 02 2366749","nationalFormat":"02 2366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":61,"e164Format":"+6114371592","internationalFormat":"+61 14371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE","qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        List<QCC_FFProfileDetailsFlowHelper.FlowOutputs> flowOutputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowOutputs>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testBody, mapHeader));

        
        //flowOutputsList = QCC_FFProfileDetailsFlowHelper.getFullFrequentFlyerDetails(flowInputsList);
        flowOutputsList = QCC_FFProfileDetailsFlowHelper.invokeThisMethod(flowInputsList);
        Test.stopTest();
        System.AssertEquals(false, flowOutputsList.isEmpty());
    }
    
    @isTest
    public static void getContactDetailsTestWithFFNumber(){
		List<Contact> con = [SELECT Id, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, Year_of_Joining__c, QCC_Frequent_Flyer_Anniversary_Date__c,QCC_TECH_Member_Tier_Downgrade_Date__c, Points_Balance__c,Status_Credits__c, FirstName, LastName, Email, Phone FROM Contact];
        String testBody = '{"dateOfBirth":"1980-05-01","firstName":"tlfwfsdmni","lastName":"test","memberId":"2002918361","preferredName":"lsl","title":"MR","addresses":[{"country":"AU","countryName":"Australia","lineOne":"TEST Bus ADDRESS LINE 1","lineTwo":"TEST Bus ADDRESS LINE 2","postCode":"2020","preferred":false,"state":"NSW","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"AU","countryName":"Australia","lineOne":"TEST ADDRESS LINE 1","lineTwo":"TEST ADDRESS LINE 2","postCode":"2390","preferred":true,"state":"NSW","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":61,"e164Format":"+61022366749","internationalFormat":"+61 02 2366749","nationalFormat":"02 2366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":61,"e164Format":"+6114371592","internationalFormat":"+61 14371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE","qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
		Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testBody, mapHeader));
        QCC_FrequentFlyerProfileDetails.ContactResult result = QCC_FrequentFlyerProfileDetails.getContactDetails(con[0].Id);
        Test.stopTest();
        System.assertEquals(con[0].FirstName, result.firstName);
        System.assertEquals(con[0].LastName, result.lastName);
        System.assertEquals(con[0].Email, result.email);
        System.assertEquals(con[0].Phone, result.phone);
        System.assertEquals(con[0].Id, result.contactId);

        
        System.assertEquals('TEST ADDRESS LINE 1 TEST ADDRESS LINE 2', result.street);
        System.assertEquals('Ultimo', result.suburb);
        System.assertEquals('NSW', result.state);
        System.assertEquals('2390', result.postcode);
        System.assertEquals('Australia', result.countryName);
    }
    
    @isTest
    public static void getContactDetailsTestNoFFNumber(){
		List<Contact> con = [SELECT Id, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c, Year_of_Joining__c, QCC_Frequent_Flyer_Anniversary_Date__c,QCC_TECH_Member_Tier_Downgrade_Date__c, Points_Balance__c,Status_Credits__c, FirstName, LastName, Email, Phone FROM Contact];
		con[0].Frequent_Flyer_Number__c = '';
        update con[0];
        String testBody = '{"dateOfBirth":"1980-05-01","firstName":"tlfwfsdmni","lastName":"test","memberId":"2002918361","preferredName":"lsl","title":"MR","addresses":[{"country":"AU","countryName":"Australia","lineOne":"TEST Bus ADDRESS LINE 1","lineTwo":"TEST Bus ADDRESS LINE 2","postCode":"2020","preferred":false,"state":"NSW","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"AU","countryName":"Australia","lineOne":"TEST ADDRESS LINE 1","lineTwo":"TEST ADDRESS LINE 2","postCode":"2390","preferred":true,"state":"NSW","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":61,"e164Format":"+61022366749","internationalFormat":"+61 02 2366749","nationalFormat":"02 2366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":61,"e164Format":"+6114371592","internationalFormat":"+61 14371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE","qantasFrequentFlyerTier":{"startDate":"2023-03-07","expiryDate":"2024-03-31","tierChangeReason":"NORMAL_UPGRADE","tierOverridden":false,"tierCode":"FREQUENT_FLYER_GOLD","tierDescription":"Frequent Flyer Gold","effectiveTier":"GOLD","effectiveTierDescription":"Gold","tierType":"GOLD","tierTypeDescription":"Gold","previousTierCode":"FREQUENT_FLYER_BRONZE","oneWorldTier":"SAPPHIRE"},"pointsClubTier":{"startDate":"2023-03-07","level":"POINTS_CLUB_BASE","levelDescription":"Points Club Base"},"accountStatus":"ACTIVE","enrolmentDate":"2023-03-07","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,"pointBalance":5000000,"statusCredits":{"carryOver":0,"classicFlightStatusCredits":0,"expiryDate":"2024-09-30","jetstar":0,"lifetime":700,"loyaltyBonus":0,"nonFlying":0,"nonQantasGroup":0,"others":0,"platinumBonus":0,"previousYear":0,"promotional":0,"qantas":700,"qantasGroup":700,"rolloverStatusCredits":0,"statusCreditBooster":0,"statusCreditSupport":0,"total":700}}';
		Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testBody, mapHeader));
        QCC_FrequentFlyerProfileDetails.ContactResult result = QCC_FrequentFlyerProfileDetails.getContactDetails(con[0].Id);
        Test.stopTest();

        
        // Assert that the result is as expected
        System.assertEquals(con[0].FirstName, result.firstName);
        System.assertEquals(con[0].LastName, result.lastName);
        System.assertEquals(con[0].Email, result.email);
        System.assertEquals(con[0].Phone, result.phone);
        System.assertEquals(con[0].Id, result.contactId);

        
        System.assertEquals('', result.street);
        System.assertEquals('', result.suburb);
        System.assertEquals('', result.state);
        System.assertEquals('', result.postcode);
        System.assertEquals('', result.countryName);

    }
    
    @isTest
    public static void checkVIPPermissionTest(){
        List<QCC_FFProfileDetailsFlowHelper.FlowInputs> flowInputsList = new List<QCC_FFProfileDetailsFlowHelper.FlowInputs>(); 
        QCC_FFProfileDetailsFlowHelper.FlowInputs flowInputs = new QCC_FFProfileDetailsFlowHelper.FlowInputs();
        flowInputs.methodName = 'checkVIPPermission';
        flowInputsList.add(flowInputs);
        
		List<QCC_FFProfileDetailsFlowHelper.FlowOutputs> flowOutputsList = QCC_FFProfileDetailsFlowHelper.invokeThisMethod(flowInputsList);       
        
    }
    
}