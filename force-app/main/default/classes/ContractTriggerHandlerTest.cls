/***********************************************************************************************************************************

Description: Test class for contract trigger handler 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2698    Contracts & Agreements: technical redesign                  T01
                                    
Created Date    : 15/07/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
public class ContractTriggerHandlerTest{
    
    /**
      *@purpose : Test method for AccountContractUpdater Class
      *@param   :
      *@return  : -
     */
    public static testMethod void accountUpdaterTest(){
        
        TestUtilityDataClassQantas.insertQantasConfigData();
            List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
            for(Trigger_Status__c triggerStatus : listTriggerConfigs){
                triggerStatus.Active__c = false;
            }
            insert listTriggerConfigs;

        List<Account> accountList = AccountContractUpdaterTestUtil.createAccounts();
        List<Opportunity> opportunityList = AccountContractUpdaterTestUtil.createOpportunity(accountList);
        List<Proposal__c> proposalList = AccountContractUpdaterTestUtil.createProposals(opportunityList);
        List<Contract__c> contractList = AccountContractUpdaterTestUtil.createContracts(proposalList, opportunityList);
        
        


        //CRM-3381-Loyalty: Superceeded Contract Status
        List<Opportunity> opportunityLisToUpd = AccountContractUpdaterTestUtil.createOpportunity(accountList);
        
        opportunityLisToUpd[0].Type = 'Qantas Business Rewards';
        opportunityLisToUpd[1].Type = 'Qantas Frequent Flyer';      
        update opportunityLisToUpd;
        
        List<Proposal__c> proposalListLoyalty = AccountContractUpdaterTestUtil.createProposals(opportunityLisToUpd);
        List<Contract__c> contractListLoyalty = AccountContractUpdaterTestUtil.createContracts(proposalListLoyalty, opportunityLisToUpd);
        Map<Id,Contract__c> oldContractMap= new Map<Id,Contract__c>(AccountContractUpdaterTestUtil.createContracts(proposalListLoyalty, opportunityLisToUpd));       
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Contract__c', 'Loyalty Commercial');
        
        contractListLoyalty[0].RecordTypeId = LoyaltyRecordTypeId;
        contractListLoyalty[0].Status__c = 'Current';
        contractListLoyalty[1].RecordTypeId = LoyaltyRecordTypeId;
        contractListLoyalty[1].Status__c = 'Current';
        
        
        //insert a false contract
        List<Contract__c> contractListToInsert=new List<Contract__c>();

        Contract__c newContr=   new Contract__c( Name = 'Contract '+proposalListLoyalty[0].Name , 
            Account__c = proposalListLoyalty[0].Account__c, 
            Opportunity__c = proposalListLoyalty[0].Opportunity__c, 
             Proposal__c = proposalListLoyalty[0].Id,
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
                                                       Status__c = 'Signed by Customer',
                                                       QL_Effective_Tier__c ='Tier 1',QL_Discount_Model__c='Tiered'
                                                     );//Signature Required by Customer
        contractListToInsert.add(newContr);                                            
         

        Test.startTest(); 
        insert contractListToInsert;
        update contractListLoyalty;
        Map<Id,Contract__c> oldContr=new Map<Id,Contract__c>(contractListToInsert);  
        AccountContractUpdater.initAccountUpdateprocess(contractListLoyalty, oldContractMap, true);
        AccountContractUpdater.initAccountUpdateprocess(contractListLoyalty, oldContractMap, false);
        AccountContractUpdater.initAccountUpdateprocess(contractListToInsert, oldContr, true);    


        AccountContractUpdater.AccountAdditionaInfoDTO declareInnerClass=new AccountContractUpdater.AccountAdditionaInfoDTO();
        //Insert assert check
        AccountContractUpdaterTestUtil.doAssertCheckForActiveContract(accountList,contractList);
        
        //Update Contract & assert equal
        contractList = AccountContractUpdaterTestUtil.updateContractStartEndDate(contractList);
        AccountContractUpdaterTestUtil.doAssertCheckForActiveContract(accountList,contractList);
        
        
        //Create inactive Contract & assert equal
        List<Contract__c> inActiveContractList = AccountContractUpdaterTestUtil.createInactiveContract(proposalList, 
                                                                                                       opportunityList);
                                                                                                       
        AccountContractUpdaterTestUtil.doAssertCheckForInActiveContract(accountList, contractList, inActiveContractList);
        
        //Delete active Contract & assert equal
        DELETE contractList;
        AccountContractUpdaterTestUtil.doAssertCheckOnDelete(accountList, inActiveContractList);
        
        UNDELETE contractList;
        
        Test.stopTest();

    }
    
}