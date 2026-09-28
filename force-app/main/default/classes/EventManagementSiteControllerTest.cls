@IsTest
public class EventManagementSiteControllerTest {
    @testSetup 
    static void generateTestData() {
        final Id RTID_CAMPAIGN_MEM_EVENT = Schema.SobjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('Marketing_Event').getRecordTypeId();
        final Id RTID_CAMPAIGN_EVENT = Schema.SobjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Events').getRecordTypeId();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        Contact contactRecord = new Contact(
            FirstName='Test',
            LastName='User1',
            Email='testuser1@qantas.com.au', 
            Business_Types__c='Agency', 
            Job_Role__c='Agency Manager',
            Function__c='Advisory Services',
            Frequent_Flyer_Number__c = '12345'
        );
        insert contactRecord;
        System.debug('contact inserted - '+contactRecord.Id);
        Campaign cRecord = new Campaign(
            RecordTypeId = RTID_CAMPAIGN_EVENT,
            Name = 'Test One',
            Type = 'Cricket',
            StartDate = System.today() + 4,
            EndDate = System.today() + 4
        );
        insert cRecord;
        System.debug('campaign inserted - '+cRecord.Id);
        CampaignMember cmRecord = new CampaignMember(
            ContactId = contactRecord.Id,
            Number_of_Tickets__c = 10,
            CampaignId = cRecord.Id
        );
        insert cmRecord;
        System.debug('campaign member inserted - '+cmRecord.Id);
    }
    
    @isTest
    static void testGetInitialData() {
        Campaign cRecord = [ SELECT Id, Name, Final_RSVP_Date__c FROM Campaign LIMIT 1 ];
        cRecord.Final_RSVP_Date__c = System.today() + 1;
        update cRecord;
        CampaignMember cmrecord = [ SELECT Id, Name, CampaignId, Email FROM CampaignMember LIMIT 1 ];
        String token = EventManagementEmailSender.generateToken(cRecord, cmrecord);
        System.debug('inside method - '+token);
        EventManagementSiteController.getInitialData(token);
    }
    
    @isTest
    static void testCreateEventResponse() {
        Campaign cRecord = [ SELECT Id, Name, Final_RSVP_Date__c FROM Campaign LIMIT 1 ];
        cRecord.Final_RSVP_Date__c = System.today() + 1;
        update cRecord;
        CampaignMember cmrecord = [ SELECT Id, Name, CampaignId, Email FROM CampaignMember LIMIT 1 ];
        String token = EventManagementEmailSender.generateToken(cRecord, cmrecord);
        System.debug('inside method - '+token);
        EventManagementSiteController.createEventResponse(token, 'accept');
    }
    
    @isTest
    static void testCreateEventResponseReject() {
        Campaign cRecord = [ SELECT Id, Name, Final_RSVP_Date__c FROM Campaign LIMIT 1 ];
        cRecord.Final_RSVP_Date__c = System.today() + 1;
        update cRecord;
        CampaignMember cmrecord = [ SELECT Id, Name, CampaignId, Email FROM CampaignMember LIMIT 1 ];
        String token = EventManagementEmailSender.generateToken(cRecord, cmrecord);
        System.debug('inside method - '+token);
        EventManagementSiteController.createEventResponse(token, 'reject');
    }
}