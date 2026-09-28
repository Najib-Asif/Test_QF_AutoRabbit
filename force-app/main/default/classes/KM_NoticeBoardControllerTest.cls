/*----------------------------------------------------------------------------------------------------------------------
Author:        Ram Kolli
Company:       TCS
Description:   Test class for NoticeBoard component in Internal community Telesales portal.(KM_NoticeBoardController.apxc)
************************************************************************************************
History
************************************************************************************************
10-Mar-2020    Ram Kolli   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class KM_NoticeBoardControllerTest {
    
    static testMethod void invokeController(){
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User runningUser = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('System Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney',UserPermissionsKnowledgeUser=true);
        
        insert runningUser;
      //  PermissionSetGroup ps = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'KM_Knowledge_Champions'];
      //  PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = ps.id, AssigneeId = runningUser.id);
      //  insert assignment;
        test.startTest();
        //Insert Knowledge article records
        System.runAs(runningUser){
            TestUtilityDataClassQantas.insertArticles();
            //KnowledgeArticleId is null in case if you iterate inserted records, so have to SOQL again
            knowledge__kav obj1 = [SELECT Id,KnowledgeArticleId,urlname FROM knowledge__kav limit 1];
            //Publish articles
            KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
            KM_NoticeBoardController.getTopic(obj1.urlname);
            //call controller
            KM_NoticeBoardController.findCategoriesQCC();
            KM_NoticeBoardController.findCategoriesForce();
            KM_NoticeBoardController.switchMethod('https://qantas.lightning.force.com/');
          // String topicId =[SELECT name from Topic where NetworkId =:'0DB2v0000004JYiGAM'].name;
          //  system.debug('topicId' +topicId);
        }
        //NoticeBoardController.getArticles(3, 1);
        //NoticeBoardController.getTotalArticleCount();
        test.stopTest();
    }
    
    @isTest
    public static void findArticlesTestwithAnswer(){
		Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User runningUser = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('System Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney',UserPermissionsKnowledgeUser=true);
        
        insert runningUser;
        
        test.startTest();
        System.runAs(runningUser){
            //test data for article with answer not null
            Knowledge__kav k= new Knowledge__kav();
            Id recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Qantas_S_D').getRecordTypeId();
            k.title ='Test SD Knowledge';
            k.Summary='Qantas Sales summary';
            k.Answer__c = 'Test answer';
            k.UrlName='testURL11';
            k.Content__c ='test Article Content';
            k.RecordTypeId = recordTypeId;
        	insert k;
        	knowledge__kav obj1 = [SELECT Id,KnowledgeArticleId,urlname FROM knowledge__kav limit 1];
        	KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        	KM_NoticeBoardController.findArticles('Qantas_S_D');
            
        }
        test.stopTest();
    }
    
    @isTest
    public static void findArticlesTestwithNullAnswer(){
		Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User runningUser = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('System Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney',UserPermissionsKnowledgeUser=true);
        
        insert runningUser;
        
        test.startTest();
        System.runAs(runningUser){
            //test data for article with answer as null
            Knowledge__kav k= new Knowledge__kav();
            Id recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Qantas_S_D').getRecordTypeId();
            k= new Knowledge__kav();
            k.title ='Test SD Knowledge';
            k.Summary='Qantas Sales summary';
            k.Answer__c = null;
            k.UrlName='testURL12';
            k.Content__c ='test Article Content';
            k.RecordTypeId = recordTypeId;
        	insert k;
        	knowledge__kav obj1 = [SELECT Id,KnowledgeArticleId,urlname FROM knowledge__kav limit 1];
        	KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        	KM_NoticeBoardController.findArticles('Qantas_S_D');
        }
        test.stopTest();
    }
}