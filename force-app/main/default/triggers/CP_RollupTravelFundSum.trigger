/**********************************************************************************************************************************
 
    Created Date: 29/09/17
 
    Description: Roll up of CP Amount on Proposal.
  
    Versión:
    V1.0 - 29/09/17 - Initial version [FO]
======================================================================================================================
Name                          Jira           Description                                             Tag
======================================================================================================================
Karpagam Swaminathan         CRM-2771        CP amount rollup on Proposal
Priyadharshini Vellingiri    CRM-2804        Count of Contract Payment on Proposal
**********************************************************************************************************************************/

trigger CP_RollupTravelFundSum on Contract_Payments__c(after insert, after update, after delete) {
 /*try {
  Trigger_Status__c ts = Trigger_Status__c.getValues('RollupTravelFundSum');
  if (ts.Active__c) {
   if (!Trigger.isDelete) {
    CP_RollupTravelFundSumHandler.SumofCPs(Trigger.New);
   }

   if (Trigger.isDelete) {
    CP_RollupTravelFundSumHandler.SumofCPs(Trigger.oldMap.values());

   }
  }
 } catch (Exception e) {
  System.debug('Error Occured From ContractPayment  Trigger: ' + e.getMessage());
 }
   try {
    Trigger_Status__c ts = Trigger_Status__c.getValues('ConPaymentCount');
  if (ts.Active__c) {  
    if ((trigger.isafter && trigger.isInsert) || (trigger.isafter && trigger.isdelete)|| (trigger.isafter && trigger.isUndelete))      
         {
          Contract_Payments__c[] conPmt ;
            if (Trigger.isDelete)
                    conPmt = Trigger.old;
            else
                    conPmt = Trigger.new;
            CP_ConPaymentCountHandler.CountNumofConPayments(conPmt);    
         } 
       }
   }catch(Exception e){
        System.debug('Error Occured From ContractPayment  Trigger: '+e.getMessage());
    }*/
}