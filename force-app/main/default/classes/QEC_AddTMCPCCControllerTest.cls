/***********************************************************************************************************************************

Description: Test class for Handling TMC PCC management in Proposal and Contract Objects
Apex Class : QEC_AddTMCPCCController.apxc
Lightning Component : QEC_AddTMCPCCcmp

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Ram Kolli             EXPRCON-97     Manage TMC/PCC on Proposal and Contract  objects            T01		        	
Created Date    : 20/08/19 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
public class QEC_AddTMCPCCControllerTest {
    
    static testMethod void validateTestDataActiveProposal() {
        List<Trigger_Status__c> tsList = new List<Trigger_Status__c>();
        tsList.add(new Trigger_Status__c(Name='AccconRshipUpdate', Active__c=true));
        tsList.add(new Trigger_Status__c(Name='ContactCeateAccount', Active__c=true));
        tsList.add(new Trigger_Status__c(Name='ContactUpdateContact', Active__c=true));
        tsList.add(new Trigger_Status__c(Name='ContactAttachCase', Active__c=true));
        //tsList.add(Name='', Active__c=true);
        insert tsList;
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        List<Contract__c> contractList = TestUtilityDataClassQantas.getContracts(proposalList);
        List<Agency_Info__c> agencyList = TestUtilityDataClassQantas.getTMC();
        List<QEC_ContractTMCInfo__c> tmcInfo = new List<QEC_ContractTMCInfo__c>();
        System.debug('*****************************************************');
        //creating contract tmc info test data
        QEC_ContractTMCInfo__c contractInfo = new QEC_ContractTMCInfo__c(TMC_Info__c=agencyList[0].Id,Proposal__c=proposalList[0].Id);
        QEC_ContractTMCInfo__c contractInfo1 = new QEC_ContractTMCInfo__c(TMC_Info__c=agencyList[1].Id,Contract__c=contractList[0].Id);
        tmcInfo.add(contractInfo);
        tmcInfo.add(contractInfo1);
        insert tmcInfo;
        System.debug('#####################################################');
        Test.startTest();               
        try{
            List<QEC_AddTMCPCCWrapper> listdata = new List<QEC_AddTMCPCCWrapper>();
            List<QEC_AddTMCPCCWrapper> removelistdata = new List<QEC_AddTMCPCCWrapper>();
            List<QEC_AddTMCPCCWrapper> removelistdata1 = new List<QEC_AddTMCPCCWrapper>();
            QEC_AddTMCPCCWrapper wrap = new QEC_AddTMCPCCWrapper();
            wrap.chkbox = true;
            wrap.edate= System.today() +200;
            wrap.sdate= System.today();
            wrap.gds='test';
            wrap.pcc='test pcc';
            wrap.history= false;
            wrap.iata='12345678';
            wrap.tmcId=agencyList[0].id;
            wrap.accountName ='test account';
            wrap.active = true;
            listdata.add(wrap);
            QEC_AddTMCPCCWrapper removeRecord = new QEC_AddTMCPCCWrapper();
            removeRecord.chkbox = true;
            removeRecord.edate= System.today() +200;
            removeRecord.sdate= System.today();
            removeRecord.gds='test';
            removeRecord.pcc='test pcc';
            removeRecord.history= false;
            removeRecord.iata='12345678';
            removeRecord.tmcId=agencyList[1].id;
            removeRecord.contractTMCId=tmcInfo[0].id;
            removeRecord.accountName ='test account1';
            removeRecord.active = false;
            removelistdata.add(removeRecord);
            QEC_AddTMCPCCWrapper removeRecord1 = new QEC_AddTMCPCCWrapper();
            removeRecord1.chkbox = true;
            removeRecord1.edate= System.today() +200;
            removeRecord1.sdate= System.today();
            removeRecord1.gds='test';
            removeRecord1.pcc='test pcc';
            removeRecord1.history= false;
            removeRecord1.iata='12345678';
            removeRecord1.tmcId=agencyList[1].id;
            removeRecord1.contractTMCId=tmcInfo[0].id;
            removeRecord1.accountName='test account 2';
            removeRecord1.active=true;
            removelistdata1.add(removeRecord1);
            
            String data = JSON.serialize(listdata);
            String removeData = JSON.serialize(removelistdata);
            String linkedRecords = JSON.serialize(removelistdata1);
            String agencyIds = String.valueOf(agencyList[0].Id);
            String tmcIds = String.valueOf(tmcInfo[0].Id);
            // String data ='{active: "Yes", edate: "2019-08-14", gds: "Sabre",iata: "07564", pcc: "EFG", sdate: "2019-08-09", tmcId:'+ agencyIds +'}';
            //String removeData='{chkbox: false, contractTMCId:'+tmcIds+', edate: "2019-08-14", gds: "Sabre", history: false, iata: "07564", pcc: "EFG", sdate: "2019-08-09", tmcId:'+agencyIds+'}';
            
            QEC_AddTMCPCCController.getTMCPCC(String.valueOf(proposalList[0].Id));
            QEC_AddTMCPCCController.getTMCPCC(String.valueOf(contractList[0].Id));
            QEC_AddTMCPCCController.getAccountRelation(accList[0].Id);
            QEC_AddTMCPCCController.fetchPCCData('aaa',String.valueOf(proposalList[0].Id));
            QEC_AddTMCPCCController.fetchPCCData('1234567',String.valueOf(proposalList[1].Id));
            QEC_AddTMCPCCController.fetchPCCData('aaa',String.valueOf(contractList[0].Id));
            QEC_AddTMCPCCController.fetchPCCData('1234567',String.valueOf(contractList[1].Id));
            
            QEC_AddTMCPCCController.performSave(data, String.valueOf(proposalList[0].Id), removeData,linkedRecords,'');
            QEC_AddTMCPCCController.performSave(data, String.valueOf(contractList[0].Id), removeData,linkedRecords,'');
            QEC_AddTMCPCCController.SearchWrapper sw = new QEC_AddTMCPCCController.SearchWrapper();
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        Test.stopTest(); 
    }
}