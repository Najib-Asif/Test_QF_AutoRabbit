public class KnowledgeController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticles(String categoryGroupName, String categoryName) {
        system.debug('Inside get Knowledge Article method');
        system.debug('categoryName : '+categoryName);
        
        if (String.isEmpty(categoryName)|| categoryName==''||String.isEmpty(categoryGroupName)|| categoryGroupName=='') {
            categoryGroupName = 'Internal_Topics__c'; // Set your default category name
             categoryName = 'National_Memo__c';
            
        }
        
         String query = 'SELECT Id, Title, LastPublishedDate, Article__c  ' +
                        //',(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                        //'FROM DataCategorySelections) ' +
                        'FROM Knowledge__kav ' +
                        'WHERE PublishStatus = \'online\' ' +
             			'WITH DATA CATEGORY ' + categoryGroupName +
             			' below ' + categoryName;
        system.debug(query);

        return Database.query(query);
       
    }


    
}