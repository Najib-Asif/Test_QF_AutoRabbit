/**********************************************************************
Name:  QEC_ProposalFareDiscountsControllerTest
Copyright © 2019  Qantas Airways.
======================================================
Req: 
QEC - inline Editing the fare discounts on proposal
======================================================
Purpose:                                                            
Test class for QEC_ProposalFareDiscountsController
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 	Ram Kolli       05/06/2019      Initial Development
========================================================
Methods
1. validateTestDataActiveProposal() - performs data insert and call QEC_ProposalFareDiscountsController methods
***********************************************************************/
@isTest
public class QEC_ProposalFareDiscountsControllerTest {
    
    static testMethod void validateTestDataActiveProposal() {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        
        Test.startTest();               
            try{
                List<Discount_List__c> discList = [SELECT Id, Discount__c from Discount_List__c where Proposal__r.id =: proposalList[0].id];
                
                //Invoke the controller Method
                String JSONString = JSON.serialize(discList);
                QEC_ProposalFareDiscountsController.getFareDiscounts(proposalList[0].Id);
                QEC_ProposalFareDiscountsController.saveDiscountObject(JSONString);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    
     static testMethod void validateDiscountListInsertion() {
        TestUtilityDataClassQantas.enableTriggers();
         List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        
       // Test.startTest();               
            try{
                List<Discount_List__c> discList = [SELECT Id, Discount__c from Discount_List__c where Proposal__r.id =: proposalList[0].id];
                
                //Invoke the controller Method
                String JSONString = JSON.serialize(discList);
                QEC_ProposalFareDiscountsController.getFareDiscounts(proposalList[0].Id);
                QEC_ProposalFareDiscountsController.saveDiscountObject(JSONString);
               
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
           // Test.stopTest(); 
        }
    
    static testMethod void testDiscountListHandler() {
        
         TestUtilityDataClassQantas.enableTriggers();
         List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
         List<Discount_List__c> discList = new List<Discount_List__c>();
        Map<Id, Discount_List__c> newDiscList = new Map <Id, Discount_List__c> ([SELECT Id, Discount__c from Discount_List__c where Proposal__r.id =: proposalList[0].id]);
        
        for (Discount_List__c  dis : newDiscList.values()){
         
           Discount_List__c dis1  = new Discount_List__c();
            dis1.id = dis.Id;
            dis1.Discount__c = 60;
            discList.add(dis1);
            
        }

    		DiscountListHandler.afterApprovalsDiscountChanged(discList,newDiscList);
        DiscountListHandler.handleAfterDelete(discList);
        
        }
    
}