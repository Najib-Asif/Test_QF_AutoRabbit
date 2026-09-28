/***********************************************************************************************************************************

Description: Trigger which calls the handler class contract trigger handler  
Created Date    : 15/07/17 (DD/MM/YYYY)
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2698    Contracts & Agreements: technical redesign                  T01
Jay                       Qantas Channel Payment Contract Termination Invoices method           09-Oct-2019
                                    


**********************************************************************************************************************************/
trigger ContractTrigger on Contract__c(After Insert, After Update, after Delete, after undelete) {    
    
    try{
 
       if(Trigger.isAfter){
           
           if(Trigger.isInsert){
           
           
               ContractTriggerHandler.onAfterInsert(Trigger.new);
               ContractPaymentHandler.ContracPaytMethod(Trigger.New,Trigger.oldMap);

           }
           
           if(Trigger.isUpdate){
               
               ContractTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
               ContractPaymentHandler.paymentContractTerminationMethod(Trigger.new, Trigger.oldMap);
           }
            if(Trigger.isUpdate && ContractPaymentHandler.firstRun){
                
                ContractPaymentHandler.firstRun=false;
                ContractPaymentHandler.SignOnMethod(Trigger.New,Trigger.oldMap);
                ContractPaymentHandler.handleContractTermination(Trigger.New,Trigger.oldMap);
               
                
            }

           
           if(Trigger.isDelete){
               
               ContractTriggerHandler.onAfterDelete(Trigger.old);
           }
           
           if(Trigger.isUndelete){
               
               ContractTriggerHandler.onAfterUnDelete(Trigger.new);
           }
       } 
    
}catch(Exception e){
        System.debug('Error Occured From contract  Trigger: '+e.getMessage());
    }
    
  try {
    Trigger_Status__c ts = Trigger_Status__c.getValues('ConAgrCount');
  if (ts.Active__c) {  
    if ((trigger.isafter && trigger.isInsert) || (trigger.isafter && trigger.isdelete)|| (trigger.isafter && trigger.isUndelete))      
         {
          Contract__c[] conAgr  ;
            if (Trigger.isDelete)
                    conAgr  = Trigger.old;
            else
                    conAgr  = Trigger.new;
            ContractAgrCountHandler.CountNumofContractAgr(conAgr );    
         } 
       }
   }catch(Exception e){
        System.debug('Error Occured From ContractPayment  Trigger: '+e.getMessage());
    }
}