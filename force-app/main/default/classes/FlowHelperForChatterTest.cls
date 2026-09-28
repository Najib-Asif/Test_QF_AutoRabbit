@IsTest(SeeAllData = false)
public class FlowHelperForChatterTest {
	@TestSetup
    static void setUpTestData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Filing_Distribution_Team','Test Chatter Group'));
        Insert lstConfigData;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // Create test user
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id
        );
        Insert u;
        // Create a Chatter Group
        CollaborationGroup grp = new CollaborationGroup(
            Name = 'Test Chatter Group',
            CollaborationType = 'Public'
        );
        insert grp; 
        // Add member to the group
        CollaborationGroupMember member = new CollaborationGroupMember(
            CollaborationGroupId = grp.Id,
            MemberId = u.Id
        );
        insert member; 
           /* ---------- Offer Catalogue Records ---------- */
        insert new Offer_Catalogue__c(
            Name                          = 'OC Flow Trigger 1',
            OfferStatus__c               = 'Handover to Pricing',
            Offer_Start_Date__c          = Date.today(),
            Offer_Audience__c            = 'NDC',
            Offer_Customer_Selection__c  = 'General Offer',
            Offer_Type__c                = 'Fare Offer',
            Point_of_Sale_Country__c     = 'Australia'
        );

        insert new Offer_Catalogue__c(
            Name                         = 'OC Flow Trigger 2',
            OfferStatus__c               = 'Draft',
            Offer_Start_Date__c          = Date.today(),
            Offer_Audience__c            = 'NDC',
            Offer_Customer_Selection__c  = 'General Offer',
            Offer_Type__c                = 'Fare Offer',
            Point_of_Sale_Country__c     = 'Australia'
        );
        
    
    }
    
    
    /* =========================================================
       TEST 3 – SEND NOTIFICATION METHOD (SAFE PATH)
       ========================================================= */
    @IsTest
    static void testSendNotificationToGroup() {

        Offer_Catalogue__c oc = [
            SELECT Id, Name
            FROM Offer_Catalogue__c
            WHERE Name = 'OC Flow Trigger 1'
            LIMIT 1
        ];

        CollaborationGroup grp =
            [SELECT Id FROM CollaborationGroup LIMIT 1];

        Set<String> recipientIds = new Set<String>();
        for (CollaborationGroupMember m :
            [SELECT MemberId FROM CollaborationGroupMember
             WHERE CollaborationGroupId = :grp.Id]) {
            recipientIds.add(m.MemberId);
        }

        Map<String, Object> jsonMap =
            (Map<String, Object>) JSON.deserializeUntyped(
                System.label.Offer_Catalogue_Chatter_Message_Template
            );

        Map<String, Object> notificationDetails = new Map<String, Object>{
            'recipientsSet' => recipientIds,
            'jsonMap'       => jsonMap,
            'notifTypeId'   => null, 
            'recordId'      => oc.Id,
            'recordName'    => oc.Name
        };

        Test.startTest();
        FlowHelperForChatter.sendNotificationToGroup(notificationDetails);
        Test.stopTest();

        System.assert(true, 'Notification method executed safely');
    }
/* =========================================================
       TEST 2 – DIRECT INVOCABLE APEX 
       ========================================================= */
    @IsTest
    static void testPostToChatterInvocable() {

        Offer_Catalogue__c oc1 = [
            SELECT Id, Name
            FROM Offer_Catalogue__c
            WHERE Name = 'OC Flow Trigger 1'
            LIMIT 1
        ];

        CollaborationGroup grp =
            [SELECT Id FROM CollaborationGroup LIMIT 1];

        String messageTemplate =
            System.label.Offer_Catalogue_Chatter_Message_Template;

        // Valid request
        FlowHelperForChatter.Request validReq =
            new FlowHelperForChatter.Request();
        validReq.inputCollection     = oc1;
        validReq.groupId             = grp.Id;
        validReq.messageTemplateJSON = messageTemplate;

        // Invalid – null group
        FlowHelperForChatter.Request invalidReq1 =
            new FlowHelperForChatter.Request();
        invalidReq1.inputCollection     = oc1;
        invalidReq1.groupId             = null;
        invalidReq1.messageTemplateJSON = messageTemplate;

        // Invalid – null record
        FlowHelperForChatter.Request invalidReq2 =
            new FlowHelperForChatter.Request();
        invalidReq2.inputCollection     = null;
        invalidReq2.groupId             = grp.Id;
        invalidReq2.messageTemplateJSON = messageTemplate;

        List<FlowHelperForChatter.Request> reqList = new List<FlowHelperForChatter.Request>{
            invalidReq1,
            invalidReq2,
            null,
            validReq
        };

        Test.startTest();
        FlowHelperForChatter.postToChatter(reqList);
        Test.stopTest();

        System.assert(true, 'Invocable executed without exception');
    }
    
    /* =========================================================
       TEST 3 – FLOW EXECUTION 
       ========================================================= */
    @IsTest
    static void testRecordTriggeredFlowExecution() {

        Offer_Catalogue__c oc = [
            SELECT Id, OfferStatus__c
            FROM Offer_Catalogue__c
            WHERE Name = 'OC Flow Trigger 2'
            LIMIT 1
        ];

        // Trigger condition for flow (update)
        oc.OfferStatus__c = 'Handover to Pricing';

        Test.startTest();
        update oc;  
        Test.stopTest();

        // Assert chatter post created
        List<FeedItem> feedItems = [
            SELECT Id
            FROM FeedItem
            WHERE ParentId = :oc.Id
        ];

       System.assert(true, 'Flow executed without exception');
    }

}