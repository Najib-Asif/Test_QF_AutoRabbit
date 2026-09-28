/* Created By : Ajay Bharathan | TCS | Cloud Developer */
public with sharing class QAC_FulfillmentController {
    
    @AuraEnabled
    public static list<Case_Fulfilment__c> getAllFFRecords(String caseId){

        list<Case_Fulfilment__c> myFFList = new list<Case_Fulfilment__c>();
        if(String.isNotBlank(caseId)){
            for(Case_Fulfilment__c eachFF : [Select Id,Name,Case__c,Status_Flag__c,Category__c,Timestamp__c,Message__c,Status__c from Case_Fulfilment__c where Case__c =: caseId]){
                if(eachFF != null)
                    myFFList.add(eachFF);
            }
        }
        return myFFList;
    }
    
    @AuraEnabled 
    public static Case_Fulfilment__c updateFulfillment(Case_Fulfilment__c fulfillment){
        update fulfillment;
        return fulfillment;
    }    
}