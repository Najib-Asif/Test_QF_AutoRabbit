/***********************************************************************************************************************************

Description: Lightning component handler for the customer contract approval 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam     CRM-2797   LEx-Contract Approval                  T01

Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/

public with sharing class QL_ContractCustApproved { 
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    
    @AuraEnabled
    public static QL_ContractCustApproved getProposal(Id propId)
    {
        
        QL_ContractCustApproved obj = new QL_ContractCustApproved();
        
        try{
            Set<Id> opptyIds = new Set<Id> ();
            List<Asset> assetList = new List<Asset>();
            List<Contract__c> conToUpdate = new List<Contract__c>();
            List<String> errorMsg = new List<String>();
            Id qbsSignedRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('QBS_Signed_by_Customer').getRecordTypeId();
            Id caSignedRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('CA_Signed_by_Customer').getRecordTypeId(); 
            Id assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate_Scheme').getRecordTypeId();
            Id assetRTId1 = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Public_Scheme').getRecordTypeId();
            Map<Id,Contract__c> conMap = new Map<Id,Contract__c>([SELECT Id,Status__c,Opportunity__c,Type__c,PreviousContract__c,General__c,International_Amendment__c,Domestic_Amendment__c,Amendments__c,Opportunity__r.owner.country FROM Contract__c where Id =: propId]); 
            
            for(Contract__c con : conMap.values()){
                opptyIds.add(con.Opportunity__c);
            }
            Id prevContractId = conMap.get(propId).PreviousContract__c;
            List<Contract__c> relConList = [SELECT Id,Active__c,Type__c FROM Contract__c WHERE Opportunity__c IN :opptyIds AND (RecordTypeId = :qbsSignedRecTypeId OR RecordTypeId = :caSignedRecTypeId)];
            List<Asset> assetToUpd = [SELECT id,Contract__c from Asset where Contract__c =:prevContractId AND (RecordTypeID =: assetRTId OR RecordTypeID =:assetRTId1)];
            
            system.debug('conListt***'+conMap.values());
            // Check the valid contract exist
            if(conMap.size() > 0){
                for(Contract__c c:conMap.values())
                {
                    //Checking mandatory fields General__c,Domestic_Amendment__c,International_Amendment__c 
                    if(String.isEmpty(c.Domestic_Amendment__c) && c.Opportunity__r.owner.country == 'AU'){
                        errorMsg.add('Domestic Amendment');
                    }
                    if(String.isEmpty(c.General__c) && (c.Opportunity__r.owner.country == 'AU' || c.Opportunity__r.owner.country == 'US') ){
                        errorMsg.add('General');
                    }
                    if(String.isEmpty(c.International_Amendment__c)  && c.Opportunity__r.owner.country == 'AU'){
                        errorMsg.add('International Amendment');
                    }
                    if(String.isEmpty(c.Amendments__c) && c.Opportunity__r.owner.country == 'US'){
                        errorMsg.add('Amendments');
                    }
                    // Check for the Status as "Approval Required – Legal"
                    if(c.Status__c == 'Approval Required – Legal')
                    {
                        errorMsg.add('Legal Approval Required!');
                    }
                    //For other Status 
                    else if(errorMsg.size() < 1)
                    {
                        c.status__c = 'Signed by Customer'; 
                        conToUpdate.add(c);
                        
                        for(Contract__c relatedCon : relConList){
                            if(relatedCon.Active__c && relatedCon.Id != propId && relatedCon.Type__c == conMap.get(propId).Type__c){
                                Contract__c contInst = new Contract__c(Id = relatedCon.Id);
                                contInst.Active__c = false;
                                contInst.Contract_End_Date__c = Date.today().addDays(-1);
                                conToUpdate.add(contInst);
                            }
                        }
                        
                        //Reparent asset to the child contract
                        if(conMap.get(propId).PreviousContract__c  != null){
                            for(Asset eachAsset : assetToUpd){
                                Asset newAsset = new Asset(Id=eachAsset.id);
                                newAsset.Contract__c = propId;
                                assetList.add(newAsset);
                            }
                        }
                        
                        if(!assetList.isEmpty()){
                            try{
                                update assetList;
                            }
                            catch(DmlException e) {
                                System.debug('The following exception has occurred updating variation contract assets: ' + e.getMessage());
                            }  
                        }
                        // Update the Contract
                        if(!conToUpdate.isEmpty()){
                            try{
                                update conToUpdate;
                            }
                            catch(DmlException e) {
                                System.debug('The following exception has occurred updating contract: ' + e.getMessage());
                                AuraHandledException excep = new AuraHandledException(e.getMessage());
                                excep.setMessage(e.getMessage());
                                throw excep; 
                            }
                        }
                        obj.isSuccess = true;
                        
                    }
                    if(errorMsg.size() > 0){
                        obj.isSuccess=false;
                        String msg ='';
                        for(String var : errorMsg){
                            msg += ', '+var;
                        }
                        obj.msg= 'Please enter '+msg.removeStart(',');
                    }
                } 
                
            }
            // If Contract not exist or in case of any errors
            else
            {
                obj.isSuccess =false;
                obj.msg='Some Error Occured';
            }
            
            return obj;  
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());    
        }       
    }  
}