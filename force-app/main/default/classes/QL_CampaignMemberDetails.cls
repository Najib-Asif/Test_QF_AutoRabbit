/***********************************************************************************************************************************

Description: Apex controller for Campaign Member List component

History:
======================================================================================================================
Name                    Jira        Description                                                                Tag
======================================================================================================================
Pushkar Purushothaman   CRM-3081    Apex controller for Campaign Member List component                         T01
                                    
Created Date    : 28/04/2018 (DD/MM/YYYY)

**********************************************************************************************************************************/

public class QL_CampaignMemberDetails {
    @AuraEnabled
    public static CampaignMemPagerWrapper fetchCampMembers(String userId,Decimal pageNumber,Integer recordToDisply,String campaignId){
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        Integer countRec=0;
        List<CampaignMember> totCampMem = new List<CampaignMember>();
        List<CampaignMemWrapper> CampMemWrapList = new List<CampaignMemWrapper>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Account> accIdMap = new Map<Id,Account>();
        // create a instance of wrapper class.
        CampaignMemPagerWrapper obj =  new CampaignMemPagerWrapper();
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        for(CampaignMember cm: [SELECT id,Name,Status,Related_Account__c,Account_Name__c 
                                FROM CampaignMember 
                                WHERE Assigned_to_User__c= :userId
                                AND CampaignId= :campaignId]){
            totCampMem.add(cm);
            if(cm.Related_Account__c != null)
                accIdSet.add(cm.Related_Account__c);
            countRec++;
        }
        for(Account acc : [SELECT Id,Name,ABN_Tax_Reference__c,Qantas_Corporate_Identifier__c,Aquire_System__c,AMEX__c 
                           FROM Account
                           WHERE Id IN :accIdSet]){
            accIdMap.put(acc.Id, acc);           
        }
        obj.total = countRec;      
        
        for(CampaignMember cm : [SELECT id,Name,Status,Related_Account__c,Account_Name__c 
                                 FROM CampaignMember 
                                 WHERE Assigned_to_User__c= :userId 
                                 AND CampaignId= :campaignId 
                                 LIMIT :recordToDisply 
                                 OFFSET :offset]){
            CampaignMemWrapper objInst = new CampaignMemWrapper();
            objInst.CampaignMemURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cm.id;
            objInst.CampaignMemName = cm.Name;
            objInst.CampaignStatus = cm.Status;   
            
            if(accIdMap.containsKey(cm.Related_Account__c)) {
                objInst.AccountABN = accIdMap.get(cm.Related_Account__c).ABN_Tax_Reference__c;
                objInst.AccountName = accIdMap.get(cm.Related_Account__c).Name;
                objInst.AccountQCI = accIdMap.get(cm.Related_Account__c).Qantas_Corporate_Identifier__c;
                objInst.AccountQBR = (accIdMap.get(cm.Related_Account__c).Aquire_System__c)?'Yes':'No';
                objInst.AMEX = (accIdMap.get(cm.Related_Account__c).AMEX__c)?'Yes':'No';
                objInst.AccountURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cm.Related_Account__c;
            }                        
            
            CampMemWrapList.add(objInst);    
        }
        obj.totalCampMems = CampMemWrapList;
        // return the wrapper class instance .
        return obj;
    }
    
        
    public class CampaignMemPagerWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<CampaignMemWrapper> campMems {get;set;}
        @AuraEnabled public List<CampaignMemWrapper> totalCampMems {get;set;}
    }
    
    public class CampaignMemWrapper {
        @AuraEnabled public String CampaignMemName {get;set;}
        @AuraEnabled public String CampaignMemURL {get;set;}
        @AuraEnabled public String CampaignStatus {get;set;}
        @AuraEnabled public String AccountName {get;set;}
        @AuraEnabled public String AccountABN {get;set;}
        @AuraEnabled public String AccountQCI {get;set;}
        @AuraEnabled public String AccountQBR {get;set;}
        @AuraEnabled public String AMEX {get;set;}
        @AuraEnabled public String AccountURL {get;set;}
    }
}