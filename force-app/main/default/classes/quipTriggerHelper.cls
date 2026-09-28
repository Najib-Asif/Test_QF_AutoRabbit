/*
Created Date: October 2023
Description: This helper class updates the account's field (QL_Ineligible_for_QUIP__c) to true
Developer: Navpreet Kaur
CRM-7300*/
public with sharing class quipTriggerHelper 
{
    public static void changeIneligibilityStatus(List<QL_QuipScheduledJob__c> getQuipRecs)
    {
        try
        {
            List<Id> listAccountIds=new List<Id>();
            ID accountTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
            List<Account> updateAcctsList=new List<Account>();
            Map<Id,QL_QuipScheduledJob__c> mapGetQuips=new Map<Id,QL_QuipScheduledJob__c>();

            
            if(getQuipRecs!=null && getQuipRecs.size()>0)
            {
                for(QL_QuipScheduledJob__c getQuip: getQuipRecs)
                {
                        mapGetQuips.put(getQuip.QL_Account_Id__c,getQuip);
                        listAccountIds.add(getQuip.QL_Account_Id__c);
                    
                }
            }
            
           
           for(Account getAccts: [select id,QL_Ineligible_for_QUIP__c from Account where id IN: listAccountIds and recordtypeid=:accountTypeId ])
           {
                if(mapGetQuips.containsKey(getAccts.id) && mapGetQuips.get(getAccts.id).QL_Job_Name__c=='Batch To Send Comms Aborted')
                {
                    getAccts.QL_Ineligible_for_QUIP__c=true;
                      
                } 
                else if(mapGetQuips.containsKey(getAccts.id) && mapGetQuips.get(getAccts.id).QL_Job_Name__c!='Batch To Send Comms Aborted')
                {
                     getAccts.QL_Ineligible_for_QUIP__c=false;
                }   
                updateAcctsList.add(getAccts);    
           }
           
           if(updateAcctsList!=null && updateAcctsList.size()>0)
           {
               update updateAcctsList;
           }
         
        }
        catch(Exception e)
        {
            system.debug('Exception has occurred'+e.getmessage());
        }
                
    }
}