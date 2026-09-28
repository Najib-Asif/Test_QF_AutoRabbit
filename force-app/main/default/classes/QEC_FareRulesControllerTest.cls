/***********************************************************************************************************************************
Description: Test class for Handling Fare rules in Contract Object
Apex Class : QEC_FareRulesController.apxc
Lightning Component : QEC_FareRules

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Ram Kolli             EXPRCON-67     Manage Fare rules in Contract  object                      T01		        	
Created Date    : 09/09/19 (DD/MM/YYYY)
**********************************************************************************************************************************/

@isTest
public class QEC_FareRulesControllerTest {
    
    static testMethod void validateTestDataActiveProposal() {
        //Insert Fare rule guidlines
        Test.startTest();
        List<QEC_Rule_Guidelines__c> guidelineList = new List<QEC_Rule_Guidelines__c>();
        List<QEC_FareRulesController.guidelines> wrapper = new List<QEC_FareRulesController.guidelines>();
        QEC_FareRulesController.guidelines rec = new QEC_FareRulesController.guidelines();
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        List<Contract__c> contractList = TestUtilityDataClassQantas.getContracts(proposalList);
        
        rec.dealType='INTERNATIONAL';
        rec.location='AU';
        rec.mktSgmt='CORPORATE';
        rec.recommended=true;
        rec.ruleName='Test name1';
        rec.sequence=1;
        rec.textAreaData='Test data1';
        wrapper.add(rec);
        for(Integer i=0;i<10;i++){
            QEC_Rule_Guidelines__c record = new QEC_Rule_Guidelines__c();
            record.Location__c ='AU';
            record.Deal_Type__c='INTERNATIONAL';
            record.Market_Segment__c='CORPORATE';
            record.Recommended__c = true;
            record.Sequence_Number__c = i;
            record.Name ='Test name'+i;
            record.Text__c='Test Data'+i;
            guidelineList.add(record);
        }
        
        insert guidelineList;
        delete [select id from QEC_Rule__c limit 100];
        //insert wrapper;
        QEC_FareRulesController.getRuleGuidelines(Label.QEC_Deal_Type,Label.QEC_Market_Segment,contractList.get(0).Id);
        QEC_FareRulesController.saveFareRules(wrapper,contractList.get(0).Id);
        QEC_FareRulesController.getRuleGuidelines(Label.QEC_Deal_Type,Label.QEC_Market_Segment,contractList.get(0).Id);
        Test.stopTest();
    }
}