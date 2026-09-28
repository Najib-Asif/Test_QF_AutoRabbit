/**********************************************************************
Name:  QP_ContractPaymentControllerTest
Copyright © 2019  Qantas Airways.
======================================================
Req: 
To return record types for opportunity, quote, contract and agreement and contract payment objects
======================================================
Purpose:                                                            
Test class for QP_ContractPaymentController
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 	Anil Nair       27/08/2019      Initial Development
========================================================
Methods
1. testCreateRecord() - performs data insert and call the createRecord method to check the ids of the record types
***********************************************************************/
@isTest
public class QP_ContractPaymentControllerTest {
    public static testmethod void testCreateRecord() {
        QP_ContractPaymentController obj = QP_ContractPaymentController.createRecord();
        System.assertEquals(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId(), obj.opptyRTId);
        System.assertEquals(Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId(), obj.quoteRTId);
        System.assertEquals(Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId(), obj.contractRecordTypeID);
        System.assertEquals(Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Incentive').getRecordTypeId(), obj.cpIncentiveRTId);
        System.assertEquals(Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Tech_Fund').getRecordTypeId(), obj.cpTechFundRTId);
    }
}