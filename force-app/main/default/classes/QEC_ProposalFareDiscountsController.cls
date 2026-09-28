/**********************************************************************
Name:  QEC_ProposalFareDiscountsController
Copyright © 2019  Qantas Airways.
======================================================
Req: 

======================================================
Purpose:                                                            
Allows user to modify discounts on Proposal fare discounts
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0       Ram            05/06/2019      Initial Development
2.0      Gayatri         07/27/2022      Introduced QF/EK field in proposal query- CRM 5329
========================================================
Methods
1. getFareDiscounts() - retrieves and send related fare discounts on proposal
2. saveDiscountObject() - updates discount on fare discounts object
***********************************************************************/

public with sharing class QEC_ProposalFareDiscountsController {
    @AuraEnabled
    public static List<Proposal__c> getFareDiscounts(String recordid) {
        List<Proposal__c> proposalList = [SELECT id,
                                          (SELECT id,Booking_Class_Name__c,QL_QF_EK__c,Network__c,Market__c,QL_Tier_1_Offering__c,Discount__c,Discount_Threshold_AM__c, 
                                           Discount_Threshold_TL__c,Discount_Threshold_NAM__c,Discount_Threshold_DO__c,Category__c,FareStructure__r.ProductCode__c,
                                           Fare_Combination__c,Route_O_D__c FROM Fare_Structure_Lists__r  ORDER BY FareStructure__r.ProductCode__c ASC)
                                          FROM proposal__c WHERE id=: recordid AND Status__c = 'Draft' AND Active__c= true]; //CRM-8137
        return proposalList;
    }
    
    @AuraEnabled
    public static String saveDiscountObject(string discountString ){
        List<Discount_List__c>  discountsList = (List<Discount_List__c>) JSON.deserialize(discountString, List<Discount_List__c>.class);
        if(!discountsList.isEmpty()){
            List<Database.SaveResult> updateResults = database.update(discountsList);
            for (Database.SaveResult res : updateResults)
            {
                if (!res.isSuccess())
                {
                    return 'failed';
                }
            }
        }
        return 'SUCCESS';
    }
}