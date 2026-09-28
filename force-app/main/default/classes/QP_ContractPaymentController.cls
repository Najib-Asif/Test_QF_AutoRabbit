/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Modified By : Anil Nair | TCS | Cloud Developer
* description : to add to Flow and reference the same in lightning component
* Purpose : To return record types for opportunity, quote, contract and agreement and contract payment objects & return details to the flow

*/
global with sharing class QP_ContractPaymentController 
{
    @AuraEnabled public Id opptyRTId {get;set;}
    @AuraEnabled public Id quoteRTId {get;set;}
    @AuraEnabled public Id cpIncentiveRTId {get;set;}
    @AuraEnabled public Id cpTechFundRTId {get;set;}
    @AuraEnabled public Id contractRecordTypeID {get;set;}
    //@AuraEnabled public String flowContractId {get;set;}
    
    //public static Flow.Interview.Qantas_Payments_Contract_Creation myFlow {get; set;}
    
    @AuraEnabled
    global static QP_ContractPaymentController createRecord()
    {
        //String ContractId;
        QP_ContractPaymentController org = new QP_ContractPaymentController();
        org.opptyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        org.quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        org.contractRecordTypeID = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
        org.cpIncentiveRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Incentive').getRecordTypeId();
        org.cpTechFundRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Tech_Fund').getRecordTypeId();
        
        // this Variable is received from Flow and 
        // its Value is sent to lightning markup for File Upload
        /*
		if(myFlow != null){
			ContractId = (String) myFlow.getVariableValue('createdContractId');
		}
		org.flowContractId = (ContractId == null) ? '' : ContractId;
		*/
        return org;
    } 
    @AuraEnabled
    global static void deleteFile(Id fileId) {
        //ContentDocumentLink[] cdlList = [select id from ContentDocumentLink where ContentDocumentId  =: fileId];
        //delete cdlList;
        ContentDocument cd = new ContentDocument(Id = fileId);
        delete cd;
    }
    @AuraEnabled
    global static Boolean contractCheck(String accountId, String contType, Date startDate, Date endDate) {
        List<Contract__c> contractList = [select id from Contract__c where Account__c = :accountId and Contract_Type__c = :contType 
                                          and ((Contract_Start_Date__c >= :startDate and Contract_Start_Date__c  <= :endDate) or (Contract_End_Date__c >=:startDate and Contract_End_Date__c <=:endDate ))
                                     	  and Expired__c = false and Status__c != 'Terminated'];
        if (contractList.size() > 0) {
            return false;
        }
        else {
            return true;
        }
    }
}