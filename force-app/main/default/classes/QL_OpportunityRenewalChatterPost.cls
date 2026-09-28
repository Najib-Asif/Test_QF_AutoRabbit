/**********************************************************************************************************************************

Created Date    : 13/12/2019 (DD/MM/YYYY)
Added By        : Karpagam Swaminathan
Description     : Batch Job notify Account Owners Renewal Oppty Creation.
JIRA            : CRM - 4101
Version         : V1.0 -  Initial version


**********************************************************************************************************************************/

global class QL_OpportunityRenewalChatterPost implements Database.Batchable<sObject> {
    Database.SaveResult[] lsterroResult = new Database.SaveResult[0]; 
    List < String > convertMsgs = new List < String > ();
    global Database.QueryLocator start(Database.BatchableContext BC){
        Map<string, Opportunity_main__c> categoryCY = Opportunity_main__c.getAll();
        
        List<String> category = new List<String>();
        
        List<String> categoryDate = new List<String>();
        if(categoryCY.containsKey('Corporate Airfares')){
            category.add(categoryCY.get('Corporate Airfares').Category__c);
        }
        if(categoryCY.containsKey('Qantas Business Savings')){
            category.add(categoryCY.get('Qantas Business Savings').Category__c);
        }
        
        
        
        return Database.getQueryLocator([SELECT Id, Contract_Start_Date__c, Contracted__c, Contract_End_Date__c, Account__c, Account__r.Name,
                                         Farthest_Signed_Contract_End_Date_check__c, Account__r.OwnerId,Opportunity__r.StageName,Opportunity__r.RecordType.Name,Opportunity__r.CloseDate, Type__c, Status__c,Account__r.Active__c, Account__r.RecordType.Name, Account__r.BillingCountry, Account__r.Count_of_open_opportunities__c,Account__r.Opportunity_Maximum_Close_Date__c, Account__r.Proposed_Revenue_Amount__c
                                         FROM Contract__c where (Account__r.Active__c = TRUE AND 
                                                                 Account__r.RecordType.Name = 'Customer Account' AND 
                                                                 Farthest_Signed_Contract_End_Date_check__c = TRUE AND Account__r.BillingCountry = 'AU' AND Account__r.Count_of_open_opportunities__c = 0 AND
                                                                 Type__c IN:category)]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Contract__c> activecontracts){
        
        
        Map<string, Opportunity_main__c> categoryCY = Opportunity_main__c.getAll();
        List<Id> lstRecId = new List<Id>();
        for(Contract__c theContracts: activecontracts){
            
            
            
            Date d = theContracts.Contract_End_Date__c;
            
            System.debug('Contract End date: '+d);
            
            Date t = Date.today();
            
            
            Decimal decimalvalue1 =  categoryCY.get('Corporate Airfares').Create_an_Opportunity_before_in_months__c;
            Integer integerValue1 = decimalvalue1.intValue();
            
            System.debug('Corp Create an opportunity before in months : '+integerValue1);
            
            Decimal decimalvalues1 =  categoryCY.get('Qantas Business Savings').Create_an_Opportunity_before_in_months__c;
            Integer integerValues1 = decimalValues1.intValue();
            
            System.debug('QBS Create an opportunity before in months : '+integerValues1);
            
            
            if(theContracts.Account__r.Opportunity_Maximum_Close_Date__c <> null) {
                
                
                if((theContracts.Type__c == categoryCY.get('Corporate Airfares').Category__c && ((t.addMonths(integerValue1)) - 1) == d && categoryCY.get('Corporate Airfares').Active__c == true &&
                    ((theContracts.Account__r.Opportunity_Maximum_Close_Date__c < (categoryCY.get('Corporate Airfares').Close_Date__c)))) || 
                   (theContracts.Type__c == categoryCY.get('Qantas Business Savings').Category__c && ((t.addMonths(integerValues1)) - 1) == d  && categoryCY.get('Qantas Business Savings').Active__c == true &&
                    ((theContracts.Account__r.Opportunity_Maximum_Close_Date__c < (categoryCY.get('Qantas Business Savings').Close_Date__c))))){
                        String convertMsg = System.Label.RenewalOpportunityNotification;
                        convertMsgs.add(convertMsg);
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        
                        messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                        
                        mentionSegmentInput.id = theContracts.Account__r.OwnerId;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        textSegmentInput.text = ' ' + convertMsg;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = theContracts.Account__c;
                        try{
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                        }
                        catch(Exception e){
                            
                            
                            System.debug('Exception Occured: '+e.getMessage());   
                        } 
                    }
            }
            
            if(theContracts.Account__r.Opportunity_Maximum_Close_Date__c == null){
                
                if((theContracts.Type__c == categoryCY.get('Corporate Airfares').Category__c && ((t.addMonths(integerValue1)) - 1) == d && categoryCY.get('Corporate Airfares').Active__c == true) || 
                   (theContracts.Type__c == categoryCY.get('Qantas Business Savings').Category__c && ((t.addMonths(integerValues1)) - 1) == d  && categoryCY.get('Qantas Business Savings').Active__c == true ))
                    
                {
                    
                    String convertMsg = System.Label.RenewalOpportunityNotification;
                    
                    convertMsgs.add(convertMsg);
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    
                    messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                    
                    mentionSegmentInput.id = theContracts.Account__r.OwnerId;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                    
                    textSegmentInput.text = ' ' + convertMsg;
                    messageBodyInput.messageSegments.add(textSegmentInput);
                    
                    feedItemInput.body = messageBodyInput;
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    feedItemInput.subjectId = theContracts.Account__c;
                    
                    try{
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                    }
                    catch(Exception e){
                        
                        
                        System.debug('Exception Occured: '+e.getMessage());   
                    }   
                    
                }                
                
                
            }
        }            
        
        
        
    }
    
    global void finish(Database.BatchableContext ctx){
        
    }
}