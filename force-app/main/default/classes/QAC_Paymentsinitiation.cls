/**********************************************************************************************************************************

Created Date    : 18/01/2020 (DD/MM/YYYY)
Created By      : Vinothkumar Balasubramanian
Description     : To Create QAC Payment records when the Paid Service is enabled
JIRA            : CRM-4162
Version         : V1.0 - 18/01/2020 - Initial version

**********************************************************************************************************************************/
public with sharing class QAC_Paymentsinitiation 
{
    
    public static void paymentCreation(list<Case> newCases, map<Id,Case> oldCases)
    {
        String serrequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QIC_Service_request').getRecordTypeId();
        String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        String worderRTID = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        String flightRTID = Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Map<Id,Flight__c> existingflight = new Map<Id,Flight__c>();
        Map<Id,Affected_Passenger__c> existingpassenger = new Map<Id,Affected_Passenger__c>();
        Map<Id,WorkOrder> existingworderMap = new Map<Id,WorkOrder>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> closedcaseIds = new Set<Id>();
        String waivCombo;
        Boolean myPaxSeq;
        
        for(Case eachCase : newCases)
        {
            if(eachCase != null && eachCase.RecordTypeId == serrequestRTId)
            {
                if(eachCase.Service_Fee_Applies__c == 'Yes - Apply' && eachCase.QAC_Request_Country__c == 'AU' && eachCase.Problem_Type__c !=null && 
                   (oldCases == null || (oldCases != null && (eachCase.Service_Fee_Applies__c != oldCases.get(eachCase.Id).Service_Fee_Applies__c || eachCase.QAC_Request_Country__c != oldCases.get(eachCase.Id).QAC_Request_Country__c))))
                {
                    caseIds.add(eachCase.Id);
                    System.debug('Case Ids:' +caseIds);
                }
                if(eachCase.Service_Fee_Applies__c == 'Yes - Apply' && eachCase.IsClosed && eachCase.QAC_Request_Country__c == 'AU' && (oldCases == null || (oldCases != null && eachCase.IsClosed != oldCases.get(eachCase.Id).IsClosed)))
                {
                    closedcaseIds.add(eachCase.Id);
                    System.debug('Closed Case Ids:' +closedcaseIds);
                }
            }
        }
        
        for(Flight__c eachFlight : [Select Id,Name,Case__c, RecordTypeId
                                    FROM Flight__c WHERE Case__c IN: closedcaseIds AND RecordTypeId =: flightRTID])
        {
            if(eachFlight != null){
                existingflight.put(eachFlight.Case__c,eachFlight);
                System.debug('Flight:' +existingflight);
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
                                 Account.Qantas_Industry_Centre_ID__c,Status,Point_Of_Sale__c,Customer_Tier__c,Ticketing_Time_Limit__c
                                 FROM Case WHERE Id IN: caseIds]){
                                     
                                     
                                     if(eachCase != null && !existingworderMap.containsKey(eachCase.Id)){
                                         myPaxSeq = getPaxRecord(eachCase.Id);
                                         System.debug('CasePassengerBoolean:'+myPaxSeq);
                                         waivCombo = eachCase.Problem_Type__c + '_' + eachCase.Waiver_Sub_Type__c;
                                         System.debug('CaseWaiverCombo:'+waivCombo);
                                         if(myPaxSeq)QAC_PaymentsProcess.doPaymentsCreation(waivCombo,eachCase.CreatedDate,eachCase,myPaxSeq);  
                                     }
                                     
                                 }
        }
        if(!closedcaseIds.isEmpty())
        {
            for(Case eachCase : [SELECT Id,Service_Fee_Applies__c, IsClosed FROM Case WHERE Id IN: closedcaseIds]){
                if(eachCase != null){
                    myPaxSeq = getPaxRecord(eachCase.Id);
                    if(myPaxSeq == false || !existingflight.containsKey(eachCase.Id))
                    {
                        eachCase.addError(Label.QAC_Service_Request_without_Flights_and_Passengers);
                    }
                }
            }
        }
    }
    
    public Static Boolean getPaxRecord(String caseId){
        String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();                    
        for(Affected_Passenger__c eachPassenger : [Select Id,Name,Passenger_Sequence__c,Case__c,Salutation__c,Passenger_Type__c,New_Salutation__c,
                                                   QAC_Passenger_Id__c,FirstName__c,LastName__c,New_First_Name__c,New_Last_Name__c,CreatedDate,
                                                   FrequentFlyerNumber__c,QAC_Flight_Number__c,Ticket_Number__c,Date_of_Birth__c,LastModifiedDate 
                                                   FROM Affected_Passenger__c WHERE Case__c =: caseId AND RecordTypeId =: pRTID])
        {
            if(eachPassenger != null)
                return TRUE;
        }
        
        return FALSE;
    }
}