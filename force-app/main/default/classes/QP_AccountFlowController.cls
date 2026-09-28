/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* description : to add to Flow and reference the same in lightning component
* Purpose : To fetch Account record details & display on the Flow Screen
*/
global with sharing class QP_AccountFlowController 
{
    @AuraEnabled
    public Boolean activeChannelContract {get;set;}
    
    @AuraEnabled
    public Account existingAccount {get;set;}
    
    @AuraEnabled
    public String accountAddress {get;set;}
    
    @AuraEnabled
    public Id ctrtRTId {get;set;}
    
    @AuraEnabled
    public Boolean authorizedUser {get;set;}
    
    @AuraEnabled
    public Boolean authorizedAccount {get;set;}
    
    /*
* Returns Account list to Lex Components
* @recordId - Id of the record
* Set the method as global in order to be accessed in FLOW
*/
    @AuraEnabled
    global static QP_AccountFlowController getAccountRecord(String accId)
    {
        String myDesc = '';
        QAC_Responses.BillingAddress billingAddress;
        QP_AccountFlowController org = new QP_AccountFlowController();
        org.ctrtRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
        //Id contPayRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Agency_Contract_Payments').getRecordTypeId();
        Integer countOfChildAccounts = [select count() from Account where ParentId =: accId];
        System.debug('count ' + countOfChildAccounts);
        for(Account accRecord : [SELECT Id,RecordType.DeveloperName,Qantas_Industry_Centre_ID__c,Name,Type,Legal_Name__c,Agency_TIDS_Number__c,
                                 OwnerId,BillingAddress,BillingCountry,Channel_Subscription_Date__c,Owner.Name,Contract_Group__c,
                                 Tradesite__c, Channel_member__c,Owner.IsActive,Active__c,BillingCountryCode, ParentId
                                 FROM Account where Id =: accId])
        {
            if(accRecord != null)
                org.existingAccount = accRecord;
            System.debug('parent ' + accRecord.ParentId);
            /*if(countOfChildAccounts > 0 && accRecord.ParentId == null) {
                org.authorizedAccount = true;
            } 
            else {
                org.authorizedAccount = false;
            }*/
            // AE-321 Start
            if(accRecord.RecordType.DeveloperName == 'Agency_Account' && accRecord.Active__c == true && accRecord.Contract_Group__c != null 
               && accRecord.Agency_TIDS_Number__c == Label.Head_office_account_TIDS && String.isBlank(accRecord.Qantas_Industry_Centre_ID__c)) {
                org.authorizedAccount = true;
            }
            else {
                org.authorizedAccount = false;
            }
            // AE-321 End
        }
        
        
        
        if(org.existingAccount.BillingAddress != null)
        {
            billingAddress = new QAC_Responses.BillingAddress(org.existingAccount.BillingAddress);
            
            myDesc += (String.isBlank(billingAddress.street) ? '' : billingAddress.street) +'\n'+
                (String.isBlank(billingAddress.city) ? '' : billingAddress.city) +'\n'+
                (String.isBlank(billingAddress.state) ? '' : billingAddress.state) +'\n'+
                (String.isBlank(billingAddress.postalCode) ? '' : billingAddress.postalCode) +'\n'+
                (String.isBlank(billingAddress.country) ? '' : billingAddress.country);            
        }
        
        org.accountAddress = myDesc;
        
        Integer recCount = [Select count() from Contract__c where RecordTypeId =: org.ctrtRTId 
                            and (Contract_Type__c = 'Qantas Channel Incentive' or Contract_Type__c = 'Qantas Channel Tech Fund')
                            and Active__c = true and Expired__c = false and Status__c != 'Terminated' and Account__c =: accId 
                            and Contract_Start_Date__c <= TODAY and Contract_End_Date__c >=TODAY];
        
        org.activeChannelContract = (recCount > 0) ? TRUE : FALSE;
        
        
        Profile p = [select id from Profile where name ='System Administrator'];
        List<PermissionSetAssignment> pSA = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Agency_Sales_Performance_Managers'];
        if(pSA.isEmpty() && UserInfo.getProfileId() != p.Id) {
            org.authorizedUser = false;
        }
        else {
            org.authorizedUser = true;
        }
        return org;
    }    
}