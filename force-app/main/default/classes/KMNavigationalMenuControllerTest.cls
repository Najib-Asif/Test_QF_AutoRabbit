/*----------------------------------------------------------------------------------------------------------------------
Author:        Bhakti M
Company:       TCS
Description:   Test class for KMNavigationalMenuController
************************************************************************************************
History
************************************************************************************************
06-Dec-2022    Bhakti M   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=True)
public class KMNavigationalMenuControllerTest {
	
    static testMethod void getUrlTest(){
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User runningUser = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('System Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney',UserPermissionsKnowledgeUser=true);
        
        insert runningUser;
        Test.startTest();
        String url ,urlForTopic;
        System.runAs(runningUser){
			TestUtilityDataClassQantas.insertArticles();
        	TestUtilityDataClassQantas.insertTopics();
            url = KMNavigationalMenuController.getUrl('⛬ Test 1');
            urlForTopic = KMNavigationalMenuController.getUrl('Test Topic');            
        }
        Test.stopTest();
        String expectedArtResult ='article/'+[SELECT UrlName FROM Knowledge__kav WHERE Title ='Test 1' LIMIT 1].Id;
        Id topicId =[SELECT Id from Topic where Name = 'Test Topic' LIMIT 1].Id;
        String expectedURL='topic/'+String.valueOf(topicId);
        System.assertEquals(expectedArtResult, url);
        System.assertEquals(expectedURL, urlForTopic);
    }
    
}