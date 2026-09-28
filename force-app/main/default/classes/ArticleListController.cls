public with sharing class ArticleListController {
    
    @AuraEnabled
    public static List<SObject> getArticles(String searchVar) {
        List<List<Sobject>> articles = [FIND :searchVar IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, Title,ArticleNumber,PublishStatus,Summary)];
        system.debug('articles:'+articles);
        
        List<KnowledgeArticleVersion> knowledgeresult = (List<KnowledgeArticleVersion>)articles[0];
        system.debug('knowledgeresult:'+knowledgeresult);
        return knowledgeresult;
    }
    @AuraEnabled
    public static List<SObject> getrecentpublishedarticles() {
        
        List<Sobject> articles = [Select Title,Summary,LastPublishedDate from KnowledgeArticleVersion ORDER BY LastPublishedDate Desc LIMIT 5];
        system.debug('articles:'+articles);
        return articles;
    }
}