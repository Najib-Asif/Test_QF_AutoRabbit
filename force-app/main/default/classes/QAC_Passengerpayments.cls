/**********************************************************************************************************************************

Created Date    : 28/01/2020 (DD/MM/YYYY)
Created By      : Vinothkumar Balasubramanian
Description     : To Create QAC Payment records when the Paid Service in Case is enabled and Passenger records are created
JIRA            : CRM-4162
Version         : V1.0 - 28/01/2020 - Initial version

**********************************************************************************************************************************/
public with sharing class QAC_Passengerpayments 
{
    
    public static void paymentInitiation(list<Affected_Passenger__c> newPassengers)
    {
        String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        String serrequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QIC_Service_request').getRecordTypeId();
        String worderRTID = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Map<Id,WorkOrder> existingworderMap = new Map<Id,WorkOrder>();
        Set<Id> caseIds = new Set<Id>();
        String waivCombo;
        Boolean myPaxSeq;
        
        for(Affected_Passenger__c eachPassenger : newPassengers)
        {
            if(eachPassenger != null && eachPassenger.RecordTypeId == pRTID && eachPassenger.Case__c != null)
            {
                caseIds.add(eachPassenger.Case__c);
                myPaxSeq = TRUE;
            }
        }
        
        
        for(WorkOrder eachOrder : [Select Id, WorkOrderNumber, StartDate, EndDate, Travel_Type__c, Pricebook2Id, 
                                   Pricebook2.Name, CurrencyIsoCode, LineItemCount, Sub_Total__c, GST__c, TotalPrice, 
                                   CreatedDate, LastModifiedDate, LastModifiedBy.Name, CaseId,
                                   (SELECT Id, WorkOrderId, WorkOrder.WorkOrderNumber, Product2Id, Product2.ProductCode, 
                                    Product2.Name, Quantity, UnitPrice, Subtotal, TotalPrice FROM WorkOrderLineItems)
                                   FROM WorkOrder WHERE CaseId IN: caseIds AND RecordTypeId =: worderRTID])
        {
            if(eachOrder != null && eachOrder.WorkOrderLineItems != null)
                existingworderMap.put(eachOrder.CaseId,eachOrder);
            System.debug('workOrder:'+existingworderMap);
        }                                                                         
        
        
        if(!caseIds.isEmpty()){
            for(Case eachCase : [SELECT Id,Paid_Service__c, QAC_Request_Country__c,CaseNumber,External_System_Reference_Id__c,ParentId,Parent.CaseNumber,Origin,Type,Problem_Type__c,
                                 Subject,Description,Reason_for_Waiver__c,Request_Reason_Sub_Type__c,Request_Reason_Others__c,Justification__c,
                                 AccountId,Consultants_Name__c,Consultant_Email__c,Consultant_Phone__c,Account.Name,Account.BillingCountryCode,
                                 Owner.Name,CreatedDate,LastModifiedDate,Expected_Closure_Date__c,Authority_Number__c,ABN_Tax_Reference__c,
                                 PNR_number__c,Old_PNR_Number__c,Passenger_Name__c,Ticket_Number__c,IATA__c,PCC_DI__c,GDS_DI__c,Additional_Requirements__c,
                                 Qantas_Corporate_Identifier__c,Number_of_Passengers__c,Travel_Type__c,First_Flight_Date__c,Waiver_Sub_Type__c,
                                 Frequent_Flyer_Number__c,Fare_basis_value__c,Fare_Type__c,Private_Fare_Basis__c,Region_Code__c,
                                 Account.Qantas_Industry_Centre_ID__c,Status,Point_Of_Sale__c,Customer_Tier__c,Ticketing_Time_Limit__c, Service_Fee_Applies__c
                                 FROM Case WHERE Id IN: caseIds AND Service_Fee_Applies__c = 'Yes - Apply' AND Account.BillingCountryCode = 'AU' AND RecordTypeId =: serrequestRTId]){
                                     
                                     
                                     if(eachCase != null && !existingworderMap.containsKey(eachCase.Id)){
                                         waivCombo = eachCase.Problem_Type__c + '_' + eachCase.Waiver_Sub_Type__c;
                                         System.debug('CaseWaiverCombo:'+waivCombo);
                                         QAC_PaymentsProcess.doPaymentsCreation(waivCombo,eachCase.CreatedDate,eachCase,myPaxSeq);
                                         
                                     }
                                     
                                 }
        }
    }
}