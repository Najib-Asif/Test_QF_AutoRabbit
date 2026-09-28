/*----------------------------------------------------------------------------------------------------------------------
Author:        Ram Kolli
Company:       TCS
Description:   NoticeBoard component in Internal community Telesales portal.
Inputs:
Test Class:   KM_NoticeBoardControllerTest.apxc 
************************************************************************************************
History
************************************************************************************************
10-Mar-2020    Ram Kolli   InitialDesign

Modified By : Venkata Suresh Kumar (TCS Team), 24-July-2026
Desc : FLS enforcement via WITH USER_MODE changes. Updated queries in all methods.
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class KM_NoticeBoardController {
    
    @AuraEnabled
    public static  List<Knowledge__kav> findCategoriesQCC(){
        
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<String> classifications =  getPicklist();
        try{
            
            articles = [SELECT Title,Announcement__c,Article_Overview__c, Answer__c,PublishStatus,Start_Date__c,End_Date__c 
                        from Knowledge__kav where Classification__c =: classifications
                        and PublishStatus='Online' and Visible_in_Noticeboard__c=true WITH USER_MODE order by createddate desc LIMIT 1];
            
            for(Knowledge__kav eachArticle : articles)
            {
                if((eachArticle.Answer__c)!=null)
                {
                    eachArticle.Answer__c = eachArticle.Answer__c.replace('/articles/Knowledge','/s/article');
                    eachArticle.Announcement__c = eachArticle.Announcement__c.replace('/articles/Knowledge','/s/article');
                    eachArticle.Article_Overview__c = eachArticle.Article_Overview__c.replace('/articles/Knowledge','/s/article');
                }   
                else
                {
                    eachArticle.Announcement__c = eachArticle.Announcement__c.replace('/articles/Knowledge','/s/article');
                    eachArticle.Article_Overview__c = eachArticle.Article_Overview__c.replace('/articles/Knowledge','/s/article');
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Question and answer field should not be empty'+e.getMessage());
        }
        system.debug('articles' +articles);
        return articles;
    }
    
    @AuraEnabled
    public static  List<Knowledge__kav> findCategoriesForce(){
        
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        List<String> classifications =  getPicklist();
        try{
            
            articles = [SELECT Title,Announcement__c,Article_Overview__c, Answer__c,PublishStatus,Start_Date__c,End_Date__c 
                        from Knowledge__kav where Classification__c =: classifications
                        and PublishStatus='Online' and Visible_in_Noticeboard__c=true WITH USER_MODE order by createddate desc LIMIT 1];
            
        }
        catch(Exception e)
        {
            System.debug('Question and answer field should not be empty'+e.getMessage());
        }
        system.debug('articles' +articles);
        return articles;
    }
    
    @AuraEnabled
    public static  List<Knowledge__kav> switchMethod(string currURL){
        // List<Knowledge__kav> listOfArticles = new List<Knowledge__kav>();
        string orgURL= URL.getOrgDomainURL().toExternalForm();
        String updURL = orgURL.replace('my.salesforce.com','lightning.force.com');
        system.debug(orgURL);
        system.debug(updURL);
        if(currURL.contains(updURL)){
            return findCategoriesForce();
        }
        else{
            return findCategoriesQCC();
        }
    }

    @AuraEnabled
    public static Topic getTopic(String artUrl){
        Network netId = [SELECT Id FROM Network where UrlPathPrefix =:Label.KM_Customer_FAQ_Prefix and Status = 'Live'];
        knowledge__kav knwId = [SELECT Id from knowledge__kav where Language = 'en_US' AND PublishStatus = 'Online' and urlname = : artUrl];
        List<TopicAssignment> TpcData = new List<TopicAssignment>();
        TpcData = [SELECT TopicId FROM TopicAssignment where EntityId = : knwId.Id and NetworkId = : netId.Id and isDeleted = false WITH USER_MODE];
        Topic tpc = new Topic();
        if (TpcData.size() == 1)
        {
            tpc = [SELECT Id, Name FROM Topic where Id = : TpcData[0].TopicId];            
        }
        else
        {
            String dummy = 'xx';
            return null;
            //tpc = [SELECT Id, Name FROM Topic where Id = : dummy];            
        }
        return tpc;
    }  
    
    /*   public static Map<String,Map<String,Knowledge__kav>> createTab(List<String> categories, List<Knowledge__kav> articles){
    Map<String,Map<String,Knowledge__kav>> returnObj = new Map<String,Map<String,Knowledge__kav>>();
    for(Integer i=0; i< categories.size(); i++){
    returnObj.put(categories[i],findSubCategory(categories[i], articles));
    }
    return returnObj;
    }
    
    public static Map<String,Knowledge__kav> findSubCategory(String category, List<Knowledge__kav> articles){
    Map<String,Knowledge__kav> subcategory = new Map<String,Knowledge__kav>();
    for(Knowledge__kav k : articles){
    if(k.classification__c == category){
    subcategory.put(k.Title, k);
    }
    }
    return subcategory;
    }*/  //commented as per new knowledge changes
    
    @AuraEnabled
    public static List<String> getPicklist() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Classification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getLabel());
        }     
        system.debug('-------Optionss-----'+options);
        return options;
    }
    
    @AuraEnabled
    public static  List<Knowledge__kav> findArticles(String recordType){
        
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        try{
            system.debug('Inside findArticles');
            articles = [SELECT Title,Summary,Content__c, Answer__c,PublishStatus,Start_Date__c,End_Date__c 
                        from Knowledge__kav where RecordType.DeveloperName = :recordType 
                        and PublishStatus='Online' and Visible_in_Noticeboard__c=true WITH DATA CATEGORY Internal_topics__c AT Newsletter__c WITH USER_MODE order by createddate desc LIMIT 1];
        }
        catch(Exception e)
        {
            System.debug('Question and answer field should not be empty'+e.getMessage());
        }
        system.debug('articles' +articles);
        return articles;
    }
}