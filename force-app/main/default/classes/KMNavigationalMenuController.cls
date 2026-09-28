/*----------------------------------------------------------------------------------------------------------------------
Author:        Bhakti M
Company:       TCS
Description:   Controller class for KMNavigationMenu
Inputs:
Test Class:   KMNavigationMenuTest.apxc 
************************************************************************************************
History
************************************************************************************************
06-Dec-2022    Bhakti M   Separated previous code which was in KM_NoticeBoardController here and added funtionality.

Modified By : Venkata Suresh Kumar (TCS Team), 24-July-2026
Desc : FLS enforcement via WITH USER_MODE changes. Updated queries in all methods.
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class KMNavigationalMenuController {
	
    public static final String ARTICLE_TYPE='article';
    
    public static final String TOPIC_TYPE='topic';
    
    public static final String KNOWLEDGEIQ='Knowledge iQ';
    
    public static final String MANAGEDTYPE='Navigational';
    
    //description	This method is used to get the URL for the selected topic/article
    //@params		name is the topic/article name passed from selection
    //@params		type is either topic/article 
    @AuraEnabled
    public static String getUrl(String name)
    {
        String returnURL='';
        Id networkId = getNetworkID(KNOWLEDGEIQ);
        if(name.containsAny('⛬')){
            name=name.substring(2, name.length());
            returnURL ='article/'+[SELECT UrlName FROM Knowledge__kav WHERE Title =:name WITH USER_MODE LIMIT 1].Id;
        }else {
            Id topicId =[SELECT Id from Topic where Name = :name AND NetworkId =: networkId AND ManagedTopicType =:MANAGEDTYPE WITH USER_MODE LIMIT 1].Id;
        	returnURL='topic/'+String.valueOf(topicId);
        }        
        return returnURL;
    }
    
    //description	This method is used to get the network Id
    //@params		name is the community name
    public static Id getNetworkId(String communityName){
        Network networkDetails=[SELECT Id FROM Network where Name=:communityName WITH USER_MODE];
        return networkDetails.Id;
    }
}