/*----------------------------------------------------------------------------------------------------------------------
Author:        Capgemini
Company:       Capgemini
Description:   Class to be invoked from Variation Trigger
Inputs: 
************************************************************************************************
History
************************************************************************************************
15-09-2017    Capgemini             Initial Design
 
-----------------------------------------------------------------------------------------------------------------------*/
public class VariationTriggerHelper { 
    
    public static Id variationExtensionRecordTypeId= GenericUtils.getObjectRecordTypeId('Variation__c', 'Extension');
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateVariationDetail
    Description:
    ---------------------------------------------------------------*/    
    public static void updateVariationDetail(List<Variation__c> newlstVariation){
        try{
             Date contractEndDate;
            set<Id> contractIds = new set<id>();
            set<Id> activeVariationNewIds = new set<id>();
            list<variation__c> updateInActiveVariations = new list<variation__c>();
            list<Contract__c> contractRecords = new list<Contract__c>();
             //Check the all the related variation
             //Update the previous variation status to inactive
             for(Variation__c aVariation:newlstVariation){
                 
                 if(aVariation.Active__c && aVariation.RecordTypeid==variationExtensionRecordTypeId ){
                     contractIds.add(aVariation.contract_agreement__c);
                     activeVariationNewIds.add(aVariation.Id);
                 }  
                
             }
            
             //Get all the variations for the contract which list active
             list<Variation__c> lstOldActiveVariation= [Select Id, Active__c From Variation__c where RecordTypeid=:variationExtensionRecordTypeId and ID not in :activeVariationNewIds and contract_agreement__c =: contractIds and active__c=true];
             for(Variation__c aVariation:lstOldActiveVariation){
                     aVariation.Active__c=false;
                     updateInActiveVariations.add(aVariation);
             }
            
            if(updateInActiveVariations.size()>0){ 
                update updateInActiveVariations;
            }
        }
        catch(Exception ex){
          //  CreateLogs.insertLogRec( 'Variation Check', 'Variation Trigger', 'VariationTriggerHelper', 
                //                     'updateVariationDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
        }

    }
     /*--------------------------------------------------------------------------------------      
    Method Name:        updateContractStatus
    Description:
    ---------------------------------------------------------------*/    
    public static void updateContractStatus(List<Variation__c> newlstVariation){
        
        try{
         Date contractEndDate;
         Boolean lock;
         set<Id> contractIds = new set<id>();
         list<Contract__c> contractRecords = new list<Contract__c>();
        for(Variation__c aVariation:newlstVariation){
            
            if(aVariation.Active__c){
                if(aVariation.RecordTypeid==variationExtensionRecordTypeId && (aVariation.Contract_Variation_Reason__c=='Extension'|| aVariation.Contract_Variation_Reason__c=='Amendment + Extension')){
                     
                     contractEndDate=aVariation.Contract_End_Date__c;
                 } 
                contractIds.add(aVariation.contract_agreement__c);     
            } 
                       
        }
        
         contractRecords = [Select Id,Status__c,Lock_system__c,Contract_End_Date__c From Contract__c where ID=:contractIds];
           for(Contract__C contract:contractRecords){
                contract.Status__c = 'Superceded';
               contract.Contract_End_Date__c = contractEndDate;
               contract.Lock_system__c = true;
            }
            
            update contractRecords; 
            
           for(Contract__C contract:contractRecords){
             contract.Lock_system__c = false;
           }
            update contractRecords; 
            
 }
        catch(Exception ex){
          //  CreateLogs.insertLogRec( 'Variation Check', 'Variation Trigger', 'VariationTriggerHelper', 
                //                     'updateVariationDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
       
    
  }
}