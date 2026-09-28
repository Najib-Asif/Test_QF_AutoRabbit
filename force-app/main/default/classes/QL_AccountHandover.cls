/***********************************************************************************************************************
Author:        Gnanavelu
Description:   Handle account handover cases from system admin queue automatically. If called via anonymous window
************************************************************************************************************************/
public inherited sharing class QL_AccountHandover 
{
    public static void HandoverAccounts(Id caseOwnerId, Integer noofCases)  
    {
        if(noofCases == null || noofCases < 1)
        {
            noofCases = 15;
        }
        system.debug('inside class');
        Id accHandoverRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Handover').getRecordTypeId();
        Id assetAgencyChannel = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        List<Group> salesANDadminQueue = [select Id, Name from Group where Type = 'Queue' 
                                          AND (DeveloperName = 'Sales_Performance_Team' OR DeveloperName = 'System_Admin_Request_Queue') 
                                          ORDER BY Name];
        
        List<Case> cases = [Select Id, Status, AccountId, New_Owner__c, New_Portfolio__c, Approved__c, OwnerId, 
                            RecordTypeId, CaseNumber,Subject, createdById from case where OwnerId =:caseOwnerId AND RecordTypeId = :accHandoverRecordType
                            AND Status != 'with Sales Performance Team' AND Status != 'Closed - Account moved' AND Status = 'with Salesforce Support  Admin Team' 
                            AND Subject != 'Auto-Created Account Handover case.' LIMIT :noofCases];
        
        system.debug('cases cases '+cases);
        system.debug('No of cases '+cases.size());
        Set<Id> AccIds = new Set<Id>();
        //Map<Id,Account> Accounts = new Map<Id,Account>();
        Map<Id,Id> accIdOwnerIdOld = new Map<Id,Id>();
        Map<Account,String> newAccOwner = new Map<Account,String>();
        Map<Id,Id> newAccIdOwnerId = new Map<Id,Id>();
        Map<Id,Id> accIdOwnerIdNew = new Map<Id,Id>();
        List<Case> casesActioned = new List<Case>();
        List<Case> casesResolved = new List<Case>();
        Map<Account,Case> accCaseObj = new Map<Account,Case>();
        List<User> newOwners = new List<User>();
        Map<String,Id> userNameId = new Map<String,Id>();
        List<Strategic_Account_Plan__c> SAPs = new List<Strategic_Account_Plan__c>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Asset> Assets = new List<Asset>();
        List<Campaign> Campaigns = new List<Campaign>();
        List<sObject> updateRecords = new List<sObject>();
        List<Account_Relation__c> updateAccRel = new List<Account_Relation__c>();
        List<Strategic_Account_Plan__c> updateSAP = new List<Strategic_Account_Plan__c>();
        List<Opportunity> updateoppty = new List<Opportunity>();
        List<Asset> updateAssets = new List<Asset>();
        List<Campaign> updateCamp = new List<Campaign>();
        
        Map<Id,boolean> accUpdated = new Map<Id,boolean>();
        List<Account> relatedListOfAccounts = new List<Account>();
        //Boolean caseSolved = false;
        
        for(Case c : cases)
        {
            if(c.RecordTypeId == accHandoverRecordType && c.Status != 'Closed - Account moved' 
               && c.Status != 'with Sales Performance Team' && c.New_Portfolio__c != 'Other' && c.Approved__c == false
               && c.Status == 'with Salesforce Support  Admin Team')
            {
                system.debug('Case: '+c.CaseNumber+' is not approved.');
            }
            else if(c.RecordTypeId == accHandoverRecordType && c.Status != 'Closed - Account moved' 
                    && c.Status != 'with Sales Performance Team' && c.Status == 'with Salesforce Support  Admin Team')
            {
                AccIds.add(c.AccountId);
                casesActioned.add(c);
            }
        }
        
        if(!AccIds.isEmpty())
        {
            Map<Id,Account> Accounts = new Map<Id, Account>([Select Id, Name, OwnerId from Account where Id IN :AccIds]);
            
            for(case c: casesActioned)
            {
                accIdOwnerIdOld.put(c.AccountId, Accounts.get(c.AccountId).OwnerId);
                newAccOwner.put(Accounts.get(c.AccountId),c.New_Owner__c);
                //newAccIdOwnerId.put(c.AccountId, c.Account_Owner__c);
                accCaseObj.put(Accounts.get(c.AccountId),c);
            }
            
            newOwners = [Select Id, Name from user where Name IN :newAccOwner.values()];
            for(user u : newOwners)
            {
                userNameId.put(u.Name, u.Id);
            }
            for(case c : casesActioned)
            {
                if(userNameId.containsKey(c.New_Owner__c))
                {
                    newAccIdOwnerId.put(c.AccountId, userNameId.get(c.New_Owner__c));
                }else
                {
                    system.debug('user not available please select valid user for the cases '+ c.CaseNumber);
                }
            }
            system.debug('newaccownerkeyset'+newAccOwner.keySet());
            if(!newAccIdOwnerId.isEmpty())
            {
                for(Account acc : Accounts.values())
                {
                    if(newAccIdOwnerId.containsKey(acc.Id))
                    {
                        acc.OwnerId = newAccIdOwnerId.get(acc.Id);
                        updateRecords.add(acc);  
                    }
                    
                }
            }
            
            //Query Related Records
            if(!accIdOwnerIdOld.isEmpty())
            {
                relatedListOfAccounts = [Select Id, Name, (Select Id, Name, Account__c, Account_Manager_user__c from  Strategic_Account_Plans__r
                                          where Account__c IN :accIdOwnerIdOld.keySet() AND Account_Manager_user__c IN :accIdOwnerIdOld.values()
                                          AND Status__c = 'Active'), 
                                         (Select Id, Name, AccountId, OwnerId from Opportunities where AccountId IN :accIdOwnerIdOld.keySet()
                                          AND (StageName != 'Closed - Accepted' OR StageName != 'Closed - Not Accepted' OR StageName != 'Closed Won' 
                                               OR StageName != 'Closed Lost' OR StageName != 'Declined')),
                                         (Select Id, Name, LookupAccount__c, OwnerId from Campaigns__r where LookupAccount__c IN: accIdOwnerIdOld.keySet() 
                                          AND OwnerId IN :accIdOwnerIdOld.values()) from Account where Id IN :accIdOwnerIdOld.keySet()];
                
            }
            //Transfer Account Relationships
            for(Account relatedList : relatedListOfAccounts)
            {
                //Deactivate Strategic Account Plans
                if(!relatedList.Strategic_Account_Plans__r.isEmpty())
                {
                    for(Strategic_Account_Plan__c accSAP : relatedList.Strategic_Account_Plans__r)
                    {
                        if(accIdOwnerIdOld.get(accSAP.Account__c) == accSAP.Account_Manager_user__c && accSAP.Account__c == relatedList.Id)
                        {
                            accSAP.Status__c = 'Inactive';
                            updateSAP.add(accSAP);
                        }
                    }
                }
                //Tramsfer Open Opportunities
                if(!relatedList.Opportunities.isEmpty())
                {
                    for(Opportunity oppty : relatedList.Opportunities)
                    {
                        if(accIdOwnerIdOld.get(oppty.AccountId) == oppty.OwnerId && oppty.AccountId == relatedList.Id)
                        {
                            oppty.OwnerId = newAccIdOwnerId.get(oppty.AccountId);
                            updateoppty.add(oppty);
                        }
                    }
                }
                //Transfer Campaigns
                if(!relatedList.Campaigns__r.isEmpty())
                {
                    for(Campaign accCampaign : relatedList.Campaigns__r)
                    {
                        if(accIdOwnerIdOld.get(accCampaign.LookupAccount__c) == accCampaign.OwnerId && accCampaign.LookupAccount__c == relatedList.Id)
                        {
                            accCampaign.OwnerId = newAccIdOwnerId.get(accCampaign.LookupAccount__c);
                            updateCamp.add(accCampaign);
                        }
                    }
                }
            }
            
            if(!updateRecords.isEmpty())
            {
                Database.SaveResult[] srList = Database.update(updateRecords, false);
                
                system.debug('update result '+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        accUpdated.put(sr.getId(), true);
                        System.debug('Successfully Updated'+accUpdated);
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }                
            }
            
            //Update related list records
            update updateSAP;
            update updateoppty;
            update updateCamp;
            
            //Move/Close cases after account handover
            system.debug('Cases actioned '+casesActioned);
            system.debug('No of Cases actioned '+casesActioned.size());
            if(!accUpdated.isEmpty() && !casesActioned.isEmpty())
            {
                for(Case c : casesActioned)
                {
                    if(accUpdated.containsKey(c.AccountId))
                    {
                        
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;
                        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegment;
                        ConnectApi.MentionSegmentInput mentionSegment1 = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MentionSegmentInput mentionSegment2 = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MentionSegmentInput mentionSegment3 = new ConnectApi.MentionSegmentInput();
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = 'Hi ';
                        messageInput.messageSegments.add(textSegment);
                        
                        mentionSegment1.id = c.CreatedById;
                        messageInput.messageSegments.add(mentionSegment1);
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = '\n \n Account has been transferred from ';
                        messageInput.messageSegments.add(textSegment);
                        
                        mentionSegment2.id = accIdOwnerIdOld.get(c.AccountId);
                        messageInput.messageSegments.add(mentionSegment2);
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = ' to ';
                        messageInput.messageSegments.add(textSegment); mentionSegment3.id = newAccIdOwnerId.get(c.AccountId);messageInput.messageSegments.add(mentionSegment3);
                        
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = '. Kindly check and let us know in case of any concerns. :) \n \n Thanks.';
                        messageInput.messageSegments.add(textSegment);
                        
                        feedItemInput.body = messageInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = c.Id;
                        
                        if (!Test.isRunningTest())
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                        
                        if(c.New_Portfolio__c == 'Other' && accUpdated.get(c.AccountId))
                        {
                            c.Status = 'Closed - Account moved';
                            casesResolved.add(c);
                        }else if(c.New_Portfolio__c != 'Other' && c.Approved__c == true && accUpdated.get(c.AccountId)){
                            c.Status = 'with Sales Performance Team';
                            c.OwnerId = salesANDadminQueue[0].Id;    
                            casesResolved.add(c);
                        }
                    }
                }
                update casesResolved;
            }
        }   
    }  
}