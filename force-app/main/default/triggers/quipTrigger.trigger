/*
Created Date: October 2023
Description: This Trigger is being called on the update event and updates the account's field (QL_Ineligible_for_QUIP__c) to true
Developer: Navpreet Kaur
CRM-7300*/
trigger quipTrigger on QL_QuipScheduledJob__c (before update) 
{
    try
    {
        List<QL_QuipScheduledJob__c> accuList=new List<QL_QuipScheduledJob__c>();
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            for(QL_QuipScheduledJob__c getRec: Trigger.new)
            {
                if(getRec.QL_Job_Name__c!=trigger.oldMap.get(getRec.Id).QL_Job_Name__c)
                {
                    accuList.add(getRec);
                }
            }
            if(accuList!=null && accuList.size()>0)
            {
                quipTriggerHelper.changeIneligibilityStatus(accuList);
            }
            
        }
    }
    catch(Exception e)
    {
        system.debug('Exception has occurred'+e.getmessage());
    }
   
}