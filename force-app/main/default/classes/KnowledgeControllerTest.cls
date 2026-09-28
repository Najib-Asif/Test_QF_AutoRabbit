@isTest
private class KnowledgeControllerTest {

    @isTest
    static void testGetKnowledgeArticles() {
        Test.startTest();
        List<Knowledge__kav> result = KnowledgeController.getKnowledgeArticles('Internal_Topics__c', 'National_Memo__c');
        List<String> dataCategory = DataCategoryTreeStructure.getCategoryGroups();
        List<DataCategoryTreeStructure.TreeNode> categoryNode = DataCategoryTreeStructure.getCategoryTree('National_Memo__c');
        Test.stopTest();
    }

}