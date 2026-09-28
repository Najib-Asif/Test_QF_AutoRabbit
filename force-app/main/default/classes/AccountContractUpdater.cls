/***********************************************************************************************************************************

Description: Populating the contract fields on account based on contract status , contracted flag and active . 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2698    Contracts & Agreements: technical redesign                  T01
                                    
Created Date    : 15/07/17 (DD/MM/YYYY)

Loyalty Commercial Team             Modified to handle Loyalty Record Type process (22/09/2017)
Test class : ContractTriggerHandlerTest - Code coverage: 78%

**********************************************************************************************************************************/
public class AccountContractUpdater{

    public static Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Contract__c', 'Loyalty Commercial');
    /**
      *@purpose :
      *@param   :
      *@return  : 
     */
    public static void initAccountUpdateprocess( List<Contract__c> newContractList, 
                                                 Map<Id,Contract__c> oldContractMap,
                                                 Boolean isUpdate){
        
        /*if(isUpdate){
            
            newContractList = findValidContractToUpdateAccount(newContractList, oldContractMap);
        }*/

        List<Contract__c> nonLoyaltyContracts = new List<Contract__c>{};
        List<Contract__c> loyaltyQBRContracts = new List<Contract__c>{};
        List<Contract__c> loyaltyQFFContracts = new List<Contract__c>{};
                                                     
        for(Contract__c contractRec: newContractList)
        {
        system.debug('contractRec.RecordTypeId**********'+contractRec.RecordTypeId);
            if(contractRec.RecordTypeId == LoyaltyRecordTypeId) 
            {
                if(contractRec.Type_Loyalty__c == 'Qantas Business Rewards') {
                    system.debug('contractRec.Type_Loyalty__c'+contractRec.Type_Loyalty__c);
                    loyaltyQBRContracts.add(contractRec);
                }
                if(contractRec.Type_Loyalty__c
                   == 'Qantas Frequent Flyer') 
                {
                    loyaltyQFFContracts.add(contractRec);}} 
            else 
            {
                nonLoyaltyContracts.add(contractRec);
            }
        }
                                                     
        if(nonLoyaltyContracts.size() > 0) {
            set<Id> accountIdRelatedToContractsSet = findContractRelatedAccountId(nonLoyaltyContracts); 
            Map<Id, Contract__c> accountIdToActiveContractMap = populateAccountIdToActiveContractMap(accountIdRelatedToContractsSet, 'non-loyalty');
            updateAccountFieldsFromContractObj(accountIdToActiveContractMap, accountIdRelatedToContractsSet);
        }

        if(loyaltyQBRContracts.size() > 0) {
            system.debug('inside QBR');
            set<Id> accountIdRelatedToContractsSet = findContractRelatedAccountId(loyaltyQBRContracts);
            Map<Id, Contract__c> accountIdToActiveQBRContractMap = populateAccountIdToActiveContractMap(accountIdRelatedToContractsSet, 'Qantas Business Rewards');
            updateAccountFieldsFromContractObj(accountIdToActiveQBRContractMap, accountIdRelatedToContractsSet);
        }
                                                     
        if(loyaltyQFFContracts.size() > 0) {
            set<Id> accountIdRelatedToContractsSet = findContractRelatedAccountId(loyaltyQFFContracts);
            Map<Id, Contract__c> accountIdToActiveQFFContractMap = populateAccountIdToActiveContractMap(accountIdRelatedToContractsSet, 'Qantas Frequent Flyer');
            updateAccountFieldsFromContractObj(accountIdToActiveQFFContractMap, accountIdRelatedToContractsSet);
        }
    }
    
    
    
    /**
      *@purpose : update Account fields from contract
      *@param   : accountIdToActiveContractMap
      *@return  : -
     */
     private static void updateAccountFieldsFromContractObj( Map<Id, Contract__c> accountIdToActiveContractMap,
                                                             set<Id> accountIdToProcessForFieldUpdateSet){
         
         

         Map<Id, AccountAdditionaInfoDTO> acctIdToAcctAddlInfoMAP = populateAcctIdToAcctAddlInfoMAP(accountIdToProcessForFieldUpdateSet);
 
         List<Account> accountListToUpdate = new List<Account>();
         for(Account accountRec: fetchAccountList(accountIdToProcessForFieldUpdateSet)){
             
            
            // find account related additional info(contract_Commencement_Date & contract_Expiry_Date).
            AccountAdditionaInfoDTO acctAddlInfo = new AccountAdditionaInfoDTO(); 
            if(acctIdToAcctAddlInfoMAP.containsKey(accountRec.id))
            {
                acctAddlInfo = acctIdToAcctAddlInfoMAP.get(accountRec.id);}
            
            // find account related active contract.
            Contract__c activeContract = new Contract__c();
            if(accountIdToActiveContractMap.containsKey(accountRec.id))
            {
                activeContract = accountIdToActiveContractMap.get(accountRec.id);
                system.debug('activeContract@102 '+activeContract);
            }

            
            //update account fields from Contract
            if(isAccountNeedToUpdate( acctAddlInfo, accountRec, activeContract)){
            // Fix for CRM-2879 Contracted Flag issue    
                system.debug('LoyaltyRecordTypeId*************'+LoyaltyRecordTypeId);  
                system.debug('activeContract.RecordTypeId############'+activeContract.RecordTypeId);  
                if(activeContract.RecordTypeId != LoyaltyRecordTypeId) {
                  // Added for CRM-2937
                if(activeContract.Active__c == true 
                   && activeContract.Contracted__c == true ) {
                    system.debug('inside if above rule satisfied!!!!!!!!!!!!!');
                    system.debug('activeContract****************'+activeContract);
                    system.debug('activeContract.Id****************'+activeContract.Id);
                    //added joint EK and joint AA field for CRM - 4753
                    accountRec.Joint_EK_Customer__c = activeContract.Eligible_for_EK_ticket_stock__c;
                    accountRec.Joint_AA_Customer__c = activeContract.AA_Joint_Customer__c;
                    accountRec.Contract_Commencement_Date__c = acctAddlInfo.contract_Commencement_Date;
                    accountRec.contract_Expiry_Date__c = acctAddlInfo.contract_Expiry_Date;
                    accountRec.Dealing_Flag__c = activeContract.Active__c == true? 'Y' : 'N';
                    accountRec.Contracted__c = activeContract.Contracted__c;
                    accountRec.Contract_Start_Date__c = activeContract.Contract_Start_Date__c;
                    accountRec.Contract_End_Date__c = activeContract.Contract_End_Date__c;
                    accountRec.Domestic_Annual_Share__c = activeContract.Domestic_Annual_Share__c;
                    accountRec.MCA_Routes_Annual_Share__c = activeContract.MCA_Routes_Annual_Share__c;
                    accountRec.International_Annual_Share__c = activeContract.International_Annual_Share__c;
                    accountRec.Qantas_Annual_Expenditure__c = activeContract.Qantas_Annual_Expenditure__c;
                    accountRec.Unit_Spend_per_term__c = activeContract.Unit_Spend_per_term__c;
                    accountRec.Type__c = activeContract.Type__c;
                    accountRec.Contract_term_in_months__c = activeContract.Contract_Term_in_Months__c;
                    accountRec.Group_Travel_Discount__c = activeContract.Group_Travel_Discount__c;
                    accountRec.Forecast_Group_Booking_Expenditure__c = activeContract.Forecast_Group_Booking_Expenditure__c;
                    accountRec.QL_Current_Contract__c = activeContract.QL_Discount_Model__c;//Proposal 2-Tier changes CRM-5209
}
  // Added for CRM-2937 [Fixes for Contracted flag off scenario]
  if(activeContract.Active__c == false && activeContract.Contracted__c == false) {
                    system.debug('inside if above rule satisfied!!!!!!!!!!!!!');
                    system.debug('activeContract****************'+activeContract);
                    system.debug('activeContract.Id****************'+activeContract.Id);
                  //  accountRec.Contract_Commencement_Date__c = null;
                  //  accountRec.contract_Expiry_Date__c = null;
                    accountRec.Dealing_Flag__c = 'N';
                    accountRec.Contracted__c =false;
                    accountRec.Contract_Start_Date__c = null;
                    accountRec.Contract_End_Date__c = null;
                    accountRec.Domestic_Annual_Share__c = null;
                    accountRec.MCA_Routes_Annual_Share__c = null;
                    accountRec.International_Annual_Share__c = null;
                    accountRec.Qantas_Annual_Expenditure__c = null;
                    accountRec.Unit_Spend_per_term__c = null;
                    accountRec.Type__c = null;
                    accountRec.Contract_term_in_months__c = null;
                    accountRec.Group_Travel_Discount__c = null;
                    accountRec.Forecast_Group_Booking_Expenditure__c = null;
                    accountRec.Joint_EK_Customer__c = false;
                    accountRec.Joint_AA_Customer__c = false;
                    accountRec.QL_Current_Contract__c = null;
}
                }
                
                else {               
                 system.debug('inside loyaLTY block');
                    
                    if(activeContract.Type_Loyalty__c == 'Qantas Business Rewards' ){accountRec.QBR_Contracted__c = activeContract.Contracted__c;
						//CRM-3381-Loyalty: Superceeded Contract Status 
                        if(activeContract.Status__c == 'Superceded' || activeContract.Status__c == 'Current') accountRec.QBR_Contracted__c = true;    }else{ accountRec.QFF_Contracted__c = activeContract.Contracted__c; 
                         //CRM-3381-Loyalty: Superceeded Contract Status 
                        if(activeContract.Status__c == 'Superceded' || activeContract.Status__c == 'Current') accountRec.QFF_Contracted__c = true; 
                    }  }
                
                system.debug('accountRecId********'+accountRec.Id);
                system.debug('accountRecQBR_Contracted__c********'+accountRec.QBR_Contracted__c);

                accountListToUpdate.add(accountRec);
            }
         }
         if(accountListToUpdate.size()>0){
         system.debug('accountListToUpdate******'+accountListToUpdate);
          //CRM-9795 Introducing queueable class to separate the Account fields update after contract generation to reduce SOQL consumption
        ID jobID = System.enqueueJob(new QL_UpdateAccountFromContract(accountListToUpdate));    
         //UPDATE accountListToUpdate;
         }
         
     }
     
     
     /**
      *@purpose : Use to validate whether account fields value need to update.
      *@param   : a) acctAddlInfo - account related additional info.
      *           b) accountRec
      *           c) activeContract - account related active contract.
      *@return  : Boolean, true means need to update otherwise false
     */
     private static Boolean isAccountNeedToUpdate( AccountAdditionaInfoDTO acctAddlInfo, 
                                                   Account accountRec,
                                                   Contract__c activeContract){
         // Additional functionality included to consider loyalty commercial
         Boolean isAccountNeedToUpdate = false;

         if( (acctAddlInfo.contract_Commencement_Date != accountRec.Contract_Commencement_Date__c ||
             acctAddlInfo.contract_Expiry_Date != accountRec.contract_Expiry_Date__c ||
             activeContract.Active__c == true && accountRec.Dealing_Flag__c == 'Y' ||
             accountRec.Contracted__c != activeContract.Contracted__c  || accountRec.Contract_Start_Date__c != activeContract.Contract_Start_Date__c ||
             accountRec.Contract_End_Date__c != activeContract.Contract_End_Date__c || accountRec.Domestic_Annual_Share__c != activeContract.Domestic_Annual_Share__c || accountRec.MCA_Routes_Annual_Share__c != activeContract.MCA_Routes_Annual_Share__c ||
             accountRec.International_Annual_Share__c != activeContract.International_Annual_Share__c || accountRec.Qantas_Annual_Expenditure__c != activeContract.Qantas_Annual_Expenditure__c || accountRec.Unit_Spend_per_term__c != activeContract.Unit_Spend_per_term__c || accountRec.Type__c != activeContract.Type__c ||
             accountRec.Group_Travel_Discount__c != activeContract.Group_Travel_Discount__c || accountRec.Forecast_Group_Booking_Expenditure__c != activeContract.Forecast_Group_Booking_Expenditure__c ||accountRec.Contract_term_in_months__c != activeContract.Contract_Term_in_Months__c )
             && activeContract.RecordTypeId != LoyaltyRecordTypeId){
                 
             isAccountNeedToUpdate = true;
             System.debug('inside line#205##########');
         }

         else if((activeContract.RecordTypeId == LoyaltyRecordTypeId) && (activeContract.Active__c == true || accountRec.QBR_Contracted__c != activeContract.Contracted__c || accountRec.QFF_Contracted__c != activeContract.Contracted__c)) {system.debug('activeContract%%%%%%%%%%%%%'+activeContract); isAccountNeedToUpdate = true;         
         }
         system.debug('isAccountNeedToUpdate&&&&&&&&&&&&'+isAccountNeedToUpdate);
         return isAccountNeedToUpdate;
         
     }
     
     
     /**
      *@purpose : Use to validate whether account fields value need to update.
      *@param   : a) acctAddlInfo - account related additional info.
      *           b) accountRec
      *           c) activeContract - account related active contract.
      *@return  : Boolean, true means need to update otherwise false
     */
     private static List<Account> fetchAccountList(Set<Id> accountIdSet){
         
         return [ SELECT Id, Name, Dealing_Flag__c, Contracted__c,
                 Contract_Commencement_Date__c, Contract_Expiry_Date__c,
                 Contract_Start_Date__c, Contract_End_Date__c,
                 Domestic_Annual_Share__c, MCA_Routes_Annual_Share__c, International_Annual_Share__c,
                 Qantas_Annual_Expenditure__c, Unit_Spend_per_term__c,
                 Type__c,Contract_term_in_months__c,Group_Travel_Discount__c,Forecast_Group_Booking_Expenditure__c,
                 Joint_AA_Customer__c,Joint_EK_Customer__c,QBR_Contracted__c,QL_Current_Contract__c
                 FROM Account
                  WHERE ID IN: accountIdSet];
     }
     
     
     /**
      *@purpose : Use to find account related contract_Commencement_Date & contract_Expiry_Date.
      *@param   : a) accountIdSet 
      *@return  : Map of account id and related additional info
     */
     private static Map<Id, AccountAdditionaInfoDTO> populateAcctIdToAcctAddlInfoMAP(Set<Id> accountIdSet){
        
        Map<Id, AccountAdditionaInfoDTO> accountIdToAccountAdditionaInfo = new Map<Id, AccountAdditionaInfoDTO>();
        
        // Populate account related all the contract List.
        // Status__c = 'Current' added for loyalty commercial purpose
        for(Contract__c contractRec: [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, Account__c
                                      FROM Contract__c
                                      WHERE Account__c IN: accountIdSet AND
                                            (Status__c = 'Signed by customer' OR Status__c = 'Current') ]){
            
            
            if(accountIdToAccountAdditionaInfo.containsKey(contractRec.Account__c)){
                
                AccountAdditionaInfoDTO acctAdditionalInfo = accountIdToAccountAdditionaInfo.get(contractRec.Account__c);
                
                // Earliest Contract_Start_Date__c (contract_Commencement_Date)
                if(contractRec.Contract_Start_Date__c < acctAdditionalInfo.contract_Commencement_Date )
                    acctAdditionalInfo.contract_Commencement_Date = contractRec.Contract_Start_Date__c;
                
                // farthest Contract_End_Date__c (contract_Expiry_Date)
                if(contractRec.Contract_End_Date__c > acctAdditionalInfo.contract_Expiry_Date) acctAdditionalInfo.contract_Expiry_Date = contractRec.Contract_End_Date__c;
                    
            }
            else{
                
                AccountAdditionaInfoDTO acctAdditionalInfo = new AccountAdditionaInfoDTO();
                acctAdditionalInfo.contract_Commencement_Date = contractRec.Contract_Start_Date__c;
                acctAdditionalInfo.contract_Expiry_Date = contractRec.Contract_End_Date__c;
                
                accountIdToAccountAdditionaInfo.put(contractRec.Account__c, acctAdditionalInfo);
            }
                
        }
        
        return accountIdToAccountAdditionaInfo;

     }
     
    

    /**
      *@purpose : Find validate contract records to process for account update. 
      *@param   : a) newContractList
      *           b) oldContractMap
      *@return  : List of valid contract.
     */
     // It was part of code when user update Contract, but later found issue related to workflow, so I hide it
    /*private static List<Contract__c> findValidContractToUpdateAccount( List<Contract__c> newContractList, 
                                                                       Map<Id, Contract__c> oldContractMap){
    
        List<Contract__c> validContractToUpdateAccountList = new List<Contract__c>();
        
        for(Contract__c newContractRec: newContractList){
            
            Contract__c oldContractRec = oldContractMap.get(newContractRec.id);

            if( newContractRec.Status__c != oldContractRec.Status__c ||
                newContractRec.Contract_Start_Date__c != oldContractRec.Contract_Start_Date__c  ||
                newContractRec.Contract_End_Date__c != oldContractRec.Contract_End_Date__c   ||
                newContractRec.Contracted__c != oldContractRec.Contracted__c   ||
                newContractRec.Active__c != oldContractRec.Active__c ){
                
                validContractToUpdateAccountList.add(newContractRec);
            }   
        }
        
        return validContractToUpdateAccountList;
    }*/
    
    
    /**
      *@purpose : Find validate contract records to process for account update. 
      *@param   : a) contractList
      *@return  : List of valid contract.
     */
    private static Set<Id> findContractRelatedAccountId(List<Contract__c> contractList){
        
        Set<Id> contractIdSet = new Set<Id>();
        
        for(Contract__c contractRec: contractList){
            
            contractIdSet.add(contractRec.Account__c);
        }
        
        return contractIdSet;
    }
    
    
    /**
      *@purpose : Find account id related active contract
      *@param   : a) accountIdSet
                  b) type -- loyalty commercial type
      *@return  : Map of account Id to active Contract__c record.
     */
    private static Map<Id, Contract__c> populateAccountIdToActiveContractMap(Set<Id> accountIdSet, String type){
        
        Map<Id, Contract__c> accountIdToActiveContractMap = new Map<Id, Contract__c>();
        
        // Find active contract and create map.
        // As per client there will be only one active contract for each account.
        // Type_Loyalty__c, RecordTypeId , Status__c = 'Current' added for loyalty commercial purpose
        //CRM-2947 [Fixes for Loyalty contract termination]


        //CRM-9795 Merging two SOQL queries into one to reduce SOQL consumption in a transation
        List<Contract__c> listContractRec=[SELECT Id, Name, Active__c, Contracted__c,
                                          Contract_Start_Date__c, Contract_End_Date__c,Status__c,
                                          Domestic_Annual_Share__c, MCA_Routes_Annual_Share__c, International_Annual_Share__c,
                                          Qantas_Annual_Expenditure__c, Unit_Spend_per_term__c,
                                          Type__c,Contract_Term_in_Months__c,Account__c, Type_Loyalty__c, 
                                          Group_Travel_Discount__c,Forecast_Group_Booking_Expenditure__c,RecordTypeId,
                                          Eligible_for_EK_ticket_stock__c,AA_Joint_Customer__c,QL_Discount_Model__c
                                          FROM Contract__c WHERE Account__c IN: accountIdSet];


        if(listContractRec!=null && listContractRec.size()>0)
        {
            for(Contract__c contractRec:listContractRec)
            {
                if(type == 'non-loyalty' && contractRec.Status__c=='Signed by Customer' && contractRec.Active__c==true)
                {
                    accountIdToActiveContractMap.put(contractRec.Account__c, contractRec);
                }else if(contractRec.Type_Loyalty__c==type){
                     accountIdToActiveContractMap.put(contractRec.Account__c, contractRec);
                }
            }
        }


        //CRM-9795 Commenting this code to replace it with the Merged SOQL above
       /* if(type == 'non-loyalty') {
            for(Contract__c contractRec: [SELECT Id, Name, Active__c, Contracted__c,
                                          Contract_Start_Date__c, Contract_End_Date__c,
                                          Domestic_Annual_Share__c, MCA_Routes_Annual_Share__c, International_Annual_Share__c,
                                          Qantas_Annual_Expenditure__c, Unit_Spend_per_term__c,
                                          Type__c,Contract_Term_in_Months__c,Account__c, Type_Loyalty__c, 
                                          Group_Travel_Discount__c,Forecast_Group_Booking_Expenditure__c,RecordTypeId,
                                          Eligible_for_EK_ticket_stock__c,AA_Joint_Customer__c,QL_Discount_Model__c
                                          FROM Contract__c
                                          WHERE Status__c= 'Signed by Customer'  AND  Active__c=true AND                              
                                          Account__c IN: accountIdSet]){
                                                        
                accountIdToActiveContractMap.put(contractRec.Account__c, contractRec);
                                                    
            }
        }
        
        else{
            for(Contract__c contractRec: [SELECT Id, Name, Active__c, Contracted__c,Status__c,
                                          Contract_Start_Date__c, Contract_End_Date__c,
                                          Domestic_Annual_Share__c, MCA_Routes_Annual_Share__c, International_Annual_Share__c,
                                          Qantas_Annual_Expenditure__c, Unit_Spend_per_term__c,
                                          Type__c,Contract_Term_in_Months__c,Account__c, Type_Loyalty__c,Group_Travel_Discount__c,
                                          Forecast_Group_Booking_Expenditure__c, RecordTypeId,Eligible_for_EK_ticket_stock__c,AA_Joint_Customer__c,QL_Discount_Model__c
                                          FROM Contract__c
                                          WHERE Type_Loyalty__c = :type AND
                                          Account__c IN: accountIdSet]){
                                                        
                accountIdToActiveContractMap.put(contractRec.Account__c, contractRec);
                                                    
            }
        }*/

        return accountIdToActiveContractMap;
    }
    
    
    public class AccountAdditionaInfoDTO{
        
        public Date contract_Commencement_Date;
        public Date contract_Expiry_Date;
    }
}