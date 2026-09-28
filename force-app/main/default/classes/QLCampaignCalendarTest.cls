@isTest
public class QLCampaignCalendarTest {
    
    // Mock class for HTTP callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
			system.debug('Endooint------'+req.getEndpoint());
            // Mock responses based on the endpoint
            if (req.getEndpoint().contains('/services/data/v50.0/sobjects/Campaign/listviews/')) {
                response.setBody('{"query": "SELECT Id FROM Campaign WHERE Status = \'Active\' Order by Status"}');
                response.setStatusCode(200);
            } else {
                response.setStatusCode(400);
            }
            return response;
        }
    }
    
    @isTest
    public static void campaignCalendarTest()
    {
        List<Id> userIds = new List<Id>();
        List<User> userlist = RoleUtils.getRoleSubordinates(UserInfo.getUserId());
        String[] type = new String[]{'ATL'};
        String[] region = new String[]{'All'};
        String[] emptyRegion = new String[]{};
		String[] emptyType = new String[]{};

            
        for(User u : userlist)
        {
            userIds.add(u.Id);
        }
         // Mock the session ID
        String mockSessionId = 'mockSessionId123';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'monthlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'monthlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, type, emptyRegion);
		QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'monthlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, emptyType, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'monthlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, emptyType, emptyRegion);

        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myactivecampaigns', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myactivecampaigns', UserInfo.getUserId(), userIds, type, emptyRegion);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myactivecampaigns', UserInfo.getUserId(), userIds, emptyType, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myactivecampaigns', UserInfo.getUserId(), userIds, emptyType, emptyRegion);
      
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myteamscampaigns', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myteamscampaigns', UserInfo.getUserId(), userIds, type, emptyRegion);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myteamscampaigns', UserInfo.getUserId(), userIds, emptyType, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'myteamscampaigns', UserInfo.getUserId(), userIds, emptyType, emptyRegion);
        
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'Marketing Campaigns', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'Marketing Campaigns', UserInfo.getUserId(), userIds, type, emptyRegion);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'Marketing Campaigns', UserInfo.getUserId(), userIds, emptyType, region);
        QLCampaignCalendar.populateDateAndCampaigns(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'Marketing Campaigns', UserInfo.getUserId(), userIds, emptyType, emptyRegion);
        
        QLCampaignCalendar.nextMonth(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, type, region);
        QLCampaignCalendar.previousMonth(date.today(), 'yearlyview', date.today(), date.today(), 'SME_Campaigns', 50, 1, 'all', UserInfo.getUserId(), userIds, type, region);

        QLCampaignCalendar.getRecordCampaignRecordtypes(UserInfo.getUserId());
        QLCampaignCalendar.getCampaignListViews();
       // getRecordCampaignRecordtypes
        Test.stopTest();
    }

}