/***********************************************************************************************************************************

Description: Use for ContractTriggerHandlerTest.accountUpdaterTest . 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2698    Contracts & Agreements: technical redesign                  T01
                                    
Created Date    : 17/07/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
public class AccountContractUpdaterTestUtil {
    
    
    /**
      *@purpose : Create inactive contract
      *@param   : a) proposalListToInsert
      *           b) oppotunityList
      *@return  : Inserted contract list
     */
    public static List<Contract__c> createInactiveContract( List<Proposal__c> proposalListToInsert, 
                                                            List<Opportunity> oppotunityList){
        
        
         List<Contract__c> contractListToInsert = new List<Contract__c>();
         
         for(Integer i =0; i< 10; i++){
             
             contractListToInsert.add(new Contract__c( Name = 'Contract '+oppotunityList[i].Name , 
                                                       Account__c = proposalListToInsert[i].Account__c, 
                                                       Opportunity__c = proposalListToInsert[i].Opportunity__c, 
                                                       Proposal__c = proposalListToInsert[i].Id,
                                                       Active__c = false, 
                                                       Type__c = 'Corporate Airfares', 
                                                       International_Annual_Share__c = 70,
                                                       Domestic_Annual_Share__c = 90, 
                                                       Frequent_Flyer_Status_Upgrade__c = 'No',
                                                       Contracted__c = false,
                                                       MCA_Routes_Annual_Share__c = 70, 
                                                       Contract_Start_Date__c = Date.Today().adddays(-30), 
                                                       Contract_End_Date__c = Date.Today().adddays(3),
                                                       Qantas_Annual_Expenditure__c = 500000, 
                                                       Qantas_Club_Discount__c = 'No', 
                                                       Status__c = 'Signed by Customer',QL_Effective_Tier__c ='Tier 1' ,QL_Discount_Model__c='Tiered'));//Signature Required by Customer
         }
                  
         INSERT contractListToInsert;
         
         return contractListToInsert;
    }
    
    
    /**
      *@purpose : Update contract end date
      *@param   : a) contractList
      *@return  : Updated contract list
     */
    public static List<Contract__c> updateContractStartEndDate(List<Contract__c> contractList){
        
        
        for(Contract__c contractRec: contractList){
            
            contractRec.Contract_End_Date__c = Date.today().addDays(3);
        }
        
        UPDATE contractList;
        
        return contractList;
    }
    
    
    /**
      *@purpose : Create active contract
      *@param   : a) proposalListToInsert
      *           b) oppotunityList
      *@return  : Inserted contract list
     */
    public static List<Contract__c>  createContracts( List<Proposal__c> proposalListToInsert, 
                                                       List<Opportunity> oppotunityList){
         
         List<Contract__c> contractListToInsert = new List<Contract__c>();
         
         for(Integer i =0; i< 10; i++){
             
             contractListToInsert.add(new Contract__c( Name = 'Contract '+oppotunityList[i].Name , 
                                                       Account__c = proposalListToInsert[i].Account__c, 
                                                       Opportunity__c = proposalListToInsert[i].Opportunity__c, 
                                                       Proposal__c = proposalListToInsert[i].Id,
                                                       Active__c = true, 
                                                       Type__c = 'Corporate Airfares', 
                                                       International_Annual_Share__c = 70,
                                                       Domestic_Annual_Share__c = 90, 
                                                       Frequent_Flyer_Status_Upgrade__c = 'No',
                                                       Contracted__c = true,
                                                       MCA_Routes_Annual_Share__c = 70, 
                                                       Contract_Start_Date__c = Date.Today().adddays(-30), 
                                                       Contract_End_Date__c = Date.Today().adddays(3),
                                                       Qantas_Annual_Expenditure__c = 500000, 
                                                       Qantas_Club_Discount__c = 'No', 
                                                       Status__c = 'Signed by Customer',
                                                       QL_Effective_Tier__c ='Tier 1',QL_Discount_Model__c='Tiered'
                                                     ));//Signature Required by Customer
         }
                  
         INSERT contractListToInsert;
         
         return contractListToInsert;
    }
    
    
    /**
      *@purpose : Create Proposal
      *@param   : a) oppotunityList
      *@return  : Inserted Proposal list
     */
    public static List<Proposal__c> createProposals(List<Opportunity> oppotunityList){
        
        List<Proposal__c> proposalListToInsert = new List<Proposal__c>();
        
        for(Integer i =0; i< 10; i++){
            
            proposalListToInsert.add( new Proposal__c(  Name = 'Proposal '+oppotunityList[i].Name , 
                                                        Account__c = oppotunityList[i].AccountId, 
                                                        Opportunity__c = oppotunityList[i].Id,
                                                        Forecast_MCA_Revenue__c=20000,
                                                        Active__c = true, 
                                                        Type__c = 'Corporate Airfares', 
                                                        International_Annual_Share__c = 70,
                                                        Domestic_Annual_Share__c = 90, 
                                                        Frequent_Flyer_Status_Upgrade__c = 'No',
                                                        MCA_Routes_Annual_Share__c = 70, 
                                                        Valid_From_Date__c = Date.Today(),
                                                        Qantas_Annual_Expenditure__c = 500000, 
                                                        Qantas_Club_Discount__c = 'No',
                                                        Status__c = 'Draft',
                                                        NAM_Approved__c = false, 
                                                        NAM_Rejected__c = false, 
                                                        Pricing_Approved__c = false, 
                                                        Pricing_Rejected__c = false,
                                                        DO_Approved__c = false, 
                                                        DO_Rejected__c = false, 
                                                        TeamLead_Approved__c = false, 
                                                        TeamLead_Rejected__c = false,
                                                        Approval_Required_Others__c = false,
                                                      QL_Discount_Model__c='Tiered' ));
            
        }
        
                                                
        
       INSERT proposalListToInsert;
       
       return proposalListToInsert;
    }
    
    
    /**
      *@purpose : Create Opportunity
      *@param   : a) accountList
      *@return  : Inserted Opportunity list
     */
    public static List<Opportunity> createOpportunity(List<Account> accountList){
        
        List<Opportunity> opportunityToInsert = new List<Opportunity>();
        
        for(Integer i = 0; i<10; i++){
            
            opportunityToInsert.add(new Opportunity(  Name = 'Opp'+accountList[i].Name, 
                                                      AccountId = accountList[i].Id,
                                                      Amount = 500000, 
                                                      Category__c = 'Corporate Airfares', 
                                                      CloseDate = Date.Today(),
                                                      StageName = 'Qualify',Forecast_MCA_Revenue__c=20000));

        }
        
                                              
        INSERT opportunityToInsert;
        
        return opportunityToInsert;
    }
    
    
    /**
      *@purpose : Create Accounts
      *@param   : -
      *@return  : Inserted Accounts list
     */
    public static List<Account> createAccounts(){
        
        String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        
        List<Account> accountListToInsert = new List<Account>();
        
        for(Integer i =0; i< 10; i++){
            
            accountListToInsert.add(new Account( Name = 'Sample'+i, 
                                                 Active__c = true, 
                                                 Aquire__c = true, 
                                                 Type = 'Prospect Account', 
                                                 RecordTypeId = prospectRecordTypeId, 
                                                 Migrated__c = false, 
                                                 Estimated_Total_Air_Travel_Spend__c = 0, 
                                                 Manual_Revenue_Update__c = false,
                                                 Agency__c = 'N', 
                                                 Dealing_Flag__c = 'N', 
                                                 Aquire_Override__c = 'N' ,
                                                 Contract_End_Date__c = Date.Today().adddays(3),
                                                Contract_Expiry_Date__c=Date.Today().adddays(3),Contract_Commencement_Date__c=Date.Today().adddays(-30),Contract_Start_Date__c = Date.Today().adddays(-30),QL_Current_Contract__c='Tiered'));
        }
                        
        INSERT accountListToInsert;
        
        return accountListToInsert;
    }
    
    
    /**
      *@purpose : On contract delete check assert
      *@param   : a) accountList
      *           b) inActiveContractList
      *@return  : -
     */
    public static void doAssertCheckOnDelete(List<Account> accountList, List<Contract__c> inActiveContractList){
        
        Map<Id, Contract__c> accountIdToInActiveContractMap = new Map<Id, Contract__c>();
        
        for(Contract__c contractRec: inActiveContractList){
            
            accountIdToInActiveContractMap.put(contractRec.Account__c, contractRec);
        }
        
        for(Account accRec: [ SELECT id, Contract_Start_Date__c, Contract_End_Date__c, 
                                     Active__c, Contract_Commencement_Date__c,
                                     Contract_Expiry_Date__c, Dealing_Flag__c 
                              FROM Account
                              WHERE ID IN: accountList]){
            
            contract__c inActiveContractRec = new contract__c();
            if(accountIdToInActiveContractMap.containsKey(accRec.Id))
                 inActiveContractRec = accountIdToInActiveContractMap.get(accRec.Id);
            
           // system.assertEquals(null, accRec.Contract_Start_Date__c);
           // system.assertEquals(null, accRec.Contract_End_Date__c);
            system.assertEquals(inActiveContractRec.Contract_Start_Date__c, accRec.Contract_Commencement_Date__c);
            system.assertEquals(inActiveContractRec.Contract_End_Date__c, accRec.Contract_Expiry_Date__c);
        }
    }
    
    
    /**
      *@purpose : Assert check for inactive contract
      *@param   : a) accountList
      *           b) activeContractList
      *           c) inActiveContractList
      *@return  : -
     */
    public static void doAssertCheckForInActiveContract(List<Account> accountList, 
                                                         List<Contract__c> activeContractList,
                                                         List<Contract__c> inActiveContractList){
        
        Map<Id, Contract__c> accountIdToActiveContractMap = new Map<Id, Contract__c>();
        for(Contract__c contractRec: activeContractList){
            
            accountIdToActiveContractMap.put(contractRec.Account__c, contractRec);
        }
        
        Map<Id, Contract__c> accountIdToInActiveContractMap = new Map<Id, Contract__c>();
        for(Contract__c contractRec: inActiveContractList){
            
            accountIdToInActiveContractMap.put(contractRec.Account__c, contractRec);
        }
        
        
        for(Account accRec: [ SELECT id, Contract_Start_Date__c, Contract_End_Date__c, 
                                     Active__c, Contract_Commencement_Date__c,
                                     Contract_Expiry_Date__c, Dealing_Flag__c 
                              FROM Account
                              WHERE ID IN: accountList]){
            
            contract__c activeContractRec = new contract__c();
            if(accountIdToActiveContractMap.containsKey(accRec.Id))
                activeContractRec = accountIdToActiveContractMap.get(accRec.Id);
            
            contract__c inActiveContractRec = new contract__c();
            if(accountIdToInActiveContractMap.containsKey(accRec.Id))
                 inActiveContractRec = accountIdToInActiveContractMap.get(accRec.Id);
            
            system.assertEquals(activeContractRec.Contract_Start_Date__c, accRec.Contract_Start_Date__c);
            system.assertEquals(activeContractRec.Contract_End_Date__c, accRec.Contract_End_Date__c);
            //system.assertEquals(activeContractRec.Active__c == true?'Y':'N', accRec.Dealing_Flag__c);
            system.assertEquals(inActiveContractRec.Contract_Start_Date__c, accRec.Contract_Commencement_Date__c);
            system.assertEquals(activeContractRec.Contract_End_Date__c, accRec.Contract_Expiry_Date__c);
        }
    }
    
    
    
    /**
      *@purpose : Assert check for active contract
      *@param   : a) accountList
      *           b) contractList
      *@return  : -
     */
    public static void doAssertCheckForActiveContract(List<Account> accountList, List<Contract__c> contractList){
        
        Map<Id, Contract__c> accountIdToContractMap = new Map<Id, Contract__c>();
        for(Contract__c contractRec: contractList){
            
            accountIdToContractMap.put(contractRec.Account__c, contractRec);
        }
        
        for(Account accRec: [ SELECT id, Contract_Start_Date__c, Contract_End_Date__c, 
                                     Active__c, Contract_Commencement_Date__c,
                                     Contract_Expiry_Date__c, Dealing_Flag__c,QL_Current_Contract__c 
                              FROM Account
                              WHERE ID IN: accountList]){
            
            contract__c contractRec = accountIdToContractMap.get(accRec.Id);                                 
                                  
            system.assertEquals(contractRec.Contract_Start_Date__c, accRec.Contract_Start_Date__c);
            system.assertEquals(contractRec.Contract_End_Date__c, accRec.Contract_End_Date__c);
            //system.assertEquals(contractRec.Active__c == true?'Y':'N', accRec.Dealing_Flag__c);
            system.assertEquals(contractRec.Contract_Start_Date__c, accRec.Contract_Commencement_Date__c);
            system.assertEquals(contractRec.Contract_End_Date__c, accRec.Contract_Expiry_Date__c);
            system.assertEquals(contractRec.QL_Discount_Model__c , accRec.QL_Current_Contract__c );
                                
        }
    }
}