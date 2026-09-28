@isTest
private class AgencyInvitationControllerTest {

    @testSetup
    public static void setup() {
        
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();       

        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c calculateFeesAndDiscounts = new Trigger_Status__c(Name = 'AssetCalculateFeesandDiscounts',Active__c = false);
        lsttrgStatus.add(calculateFeesAndDiscounts);
        Trigger_Status__c assetConvertingAssetType  = new Trigger_Status__c(Name = 'AssetConvertingAssetType',Active__c = false);
        lsttrgStatus.add(assetConvertingAssetType);
        Trigger_Status__c chAsset = new Trigger_Status__c(Name = 'AssetChannel',Active__c = true);
        lsttrgStatus.add(chAsset);

        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAccountTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;

        Sales_Region__c mySR = new Sales_Region__c();
        mySR.Brand_Code__c = 'AU';
        mySR.sales_h_eq_type__c = 'Industry';
        mySR.sales_h_end_date__c = Date.today().addDays(1);
        mySR.Name = 'FCm Travel Solutions Test';
        insert mySR;
        
        //Inserting Account
        list<Account> accList = new list<Account>();
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', Agency_Sales_Region__c = mySR.Id,
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        //insert myAccount;
        
        accList.add(myAccount);
        insert accList;
        
        
        // inserting GDS Reference
        list<GDS_Reference__c> gdsList = new list<GDS_Reference__c>();
        GDS_Reference__c gds1 = new GDS_Reference__c(Name='Amadeus',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=8,PCC_Min_Length__c=3);
        GDS_Reference__c gds2 = new GDS_Reference__c(Name='Sabre',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=6,PCC_Min_Length__c=3);
        gdsList.add(gds1);
        gdsList.add(gds2);
        insert gdsList;
        
        // inserting Asset
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today(), 
                                    Premium_Channel_Status__c='Active'); 
        Asset myAsset2 = new Asset(Name='Sample2',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds2.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset1);
        allAssets.add(myAsset2);
        insert allAssets;

        Offer_Catalogue__c offrCat = new Offer_Catalogue__c(Name = 'Test-1', Marketing_Description__c = 'testr', 
            Offer_Customer_Selection__c = 'General Offer', Offer_Audience__c = 'PNDC - Agent Specific', Offer_Start_Date__c = Date.today().addDays(1),
            /*Cabin__c = 'Business Class', */CurrencyIsoCode = 'AUD', Offer_Type__c = 'Fare Offer', Point_of_Sale_Country__c = 'AU');
        insert offrCat;

        Offer_Allocation__c offrAlloc = new Offer_Allocation__c(Offer_Catalogue__c = offrCat.Id,  Account__c = myAccount.Id, 
                                                                Status__c = 'Allocated', Effective_Date__c = Date.today());
        insert offrAlloc;
    }

    @IsTest
    private static void getAllocationsTestSuccess() {
        List<String> agencyIATA = new List<String>();
        List<String> agencyBrand = new List<String>();
        List<String> agencyGroup = new List<String>{'fcm%'};
        List<String> agencyIATACodes = new List<String>();
        Object agencyAllocations;
        Offer_Catalogue__c selectedOffer = [SELECT Id FROM Offer_Catalogue__c WHERE Name = 'Test-1' LIMIT 1];
        Test.startTest();
            agencyAllocations = AgencyInvitationController.getAllocations(agencyBrand, agencyGroup, agencyIATA, agencyIATACodes, selectedOffer.Id);
        Test.stopTest();
    }

    @IsTest
    private static void getAgencyInvitationsTestSuccess() {
        List<String> agencyIATA = new List<String>();
        List<String> agencyBrand = new List<String>();
        List<String> agencyGroup = new List<String>{'fcm%'};
        List<String> agencyIATACodes = new List<String>();
        List<sObject> agencyInvitation = new List<sObject>();
        Test.startTest();
            agencyInvitation = AgencyInvitationController.getAgencyInvitations(agencyBrand, agencyGroup, agencyIATA, agencyIATACodes);
        Test.stopTest();
    }

    @isTest
    static void testSendInvitationsSuccess() {
        // Arrange
        List<String> managerEmails = new List<String>{'test1@example.com'};
        String invitationType = 'Commercial Agreement';

        // Act
        Test.startTest();
        AgencyInvitationController.sendInvitations(managerEmails, invitationType);
        Integer sentEmails = Limits.getEmailInvocations();
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, sentEmails, 'One emails should have been sent.');
        // Verify that emails were sent
    }

    @isTest
    static void testSendInvitationsInvalidType() {
        // Arrange
        List<String> managerEmails = new List<String>{'test1@example.com'};
        String invitationType = 'Invalid Type';

        // Act & Assert
        try {
            Test.startTest();
            AgencyInvitationController.sendInvitations(managerEmails, invitationType);
            Test.stopTest();
            System.assert(false, 'Exception should have been thrown for invalid invitation type.');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception message should match.');
        }
    }

    @isTest
    static void testSendInvitationsEmptyEmails() {
        // Arrange
        List<String> managerEmails = new List<String>{};
        String invitationType = 'Commercial Agreement';

        // Act
        Test.startTest();
        AgencyInvitationController.sendInvitations(managerEmails, invitationType);
        Test.stopTest();

        // Assert
        // Verify that no emails were sent
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
    }

@IsTest
    private static void getAgencyNamesFromIATAsTest() {
        Test.startTest();
            List<sObject> results = AgencyInvitationController.getAgencyNamesFromIATAs(new List<String>{'2020202'});
        Test.stopTest();
        
        System.assert(results != null, 'Results should not be null');
        System.assert(!results.isEmpty(), 'Results should not be empty');
        System.assert(results.size() >= 1, 'Results should contain at least one record');
    }

}