/***********************************************************************************************************************************

Description: Handler class to call the main class AccountContractUpdater for
Populating the contract fields on account based on contract status , contracted flag and active . 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2698    Contracts & Agreements: technical redesign                  T01
                                    
Created Date    : 15/07/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
 public class ContractTriggerHandler{
 
    
    /**
      *@purpose : On contract after insert.
      *@param   : 
      *@return  : -
     */ 
    public static void onAfterInsert(List<Contract__c> newContractList){
        
        AccountContractUpdater.initAccountUpdateprocess(newContractList,null,false);
        
    }
    
    /**
      *@purpose : On contract after update.
      *@param   : a) newContractList
      *           b) oldContractMap
      *@return  : -
     */ 
    public static void onAfterUpdate(List<Contract__c> newContractList, Map<Id, Contract__c> oldContractMap){
        
        AccountContractUpdater.initAccountUpdateprocess(newContractList,oldContractMap,true);
        
    }
    
    /**
      *@purpose : On contract after update.
      *@param   : a) newContractList
      *           b) oldContractMap
      *@return  : -
     */ 
    public static void onAfterDelete(List<Contract__c> oldContractList){
        
        AccountContractUpdater.initAccountUpdateprocess(oldContractList,null,false);
        
    }
    
    
    /**
      *@purpose : On contract after update.
      *@param   : a) newContractList
      *           b) oldContractMap
      *@return  : -
     */ 
    public static void onAfterUnDelete(List<Contract__c> newContractList){
        
        AccountContractUpdater.initAccountUpdateprocess(newContractList,null,false);
        
    }
 }