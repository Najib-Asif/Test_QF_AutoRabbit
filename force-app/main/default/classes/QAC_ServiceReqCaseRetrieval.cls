/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to fetch the service request case records & its child records
* REST API : QAC_ServiceReqCaseRetrievalAPI
* Comments : This class is @RestResource due that our class access 
               modifier is global and with sharing already annotated ADDED COMMENTS due JIRA-5510
* Modified By : Abhijeet | Purpose : to include Service Payments Object retrieval
*  History
* TestClasses: QAC_ServiceReqCaseRetrieval_Test
  ************************************************************************************************
  01-Jul-2019      Jay               Agency Credits related Changes.
  13-Feb-2025      Gandla Mallikarjuna               CRM-9196 Included EMD Details for Seats And Baggage Service Request
  ************************************************************************************************
*/

@RestResource(urlMapping = '/QAC_ServReqCaseRetrieval/')
global with sharing class QAC_ServiceReqCaseRetrieval 
{
    @HttpPost
    global static void doCaseRetrieval() 
    {
        // Responses Classes for Case Retrieval
        QAC_CaseResponses qacResp = new QAC_CaseResponses();
        QAC_CaseResponses.QACCaseRetrievalResponse myCaseRetResp;
        list<QAC_CaseResponses.QACCaseRetrievalResponse> myCaseRetRespList = new list<QAC_CaseResponses.QACCaseRetrievalResponse>();    
        
        // local variables
        Boolean isException = false;
        String responseJson = '';
        String request;
        
        // collection variables for handling incoming and existing Case Numbers
        Set<String> incomingCaseKey = new Set<String>();
        Set<String> existingCaseKey = new Set<String>();
        
        Set<String> incomingCaseIds         =  new Set<String>();
        Set<String> incomingCaseNumbers     =  new Set<String>();
        Set<String> existingCaseIds         =  new Set<String>();
        Set<String> existingCaseNumbers     =  new Set<String>();
        
        // Set<Id> existingCaseIds = new Set<id>();
        Set<Id> existingPaidCaseIds = new Set<id>();
        map<Id,Case> existingCaseMap = new map<Id,Case>();
        map<Id,list<CaseComment>> existingCaseCommentsMap = new map<Id,list<CaseComment>>();
        map<Id,list<Flight__c>> existingFlightsMap = new map<Id,list<Flight__c>>();
        map<Id,list<Affected_Passenger__c>> existingPassengersMap = new map<Id,list<Affected_Passenger__c>>();
        map<Id,list<Service_Payment__c>> existingServicePayments = new map<Id,list<Service_Payment__c>>();
        map<Id,list<WorkOrder>> existingWorkOrder = new map<Id,list<WorkOrder>>();
        map<Id,list<EMD_Details__c>> existingEMDDetail = new map<Id,list<EMD_Details__c>>(); //Jira: CRM-9209
        
        // to get files name from Case
        Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
        Map<String,list<ContentVersion>> caseContentVersionMap = new Map<String,list<ContentVersion>>(); 
        
        Id workOrderRecTypeId = QAC_PaymentsProcess.fetchRecordTypeId('WorkOrder','Service Request');
        Id workOrderLineRecTypeId = QAC_PaymentsProcess.fetchRecordTypeId('WorkOrderLineItem','Service Request');
        Id servicePaymentRecTypeId = QAC_PaymentsProcess.fetchRecordTypeId('Service_Payment__c','Service Request');
        
        // Reading Request parameters, JSON extraction from Body of request is primary
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        request = req.requestBody.toString();
        
        try 
        {
            // Retrieving body of request from URI
            QAC_ServiceReqCaseRetrievalAPI caseRetApi = QAC_ServiceReqCaseRetrievalAPI.parse(request);
            
            if(caseRetApi.caseRetrieval.sfCaseId != NULL){
                incomingCaseIds.addAll(caseRetApi.caseRetrieval.sfCaseId);    
            }
            if(caseRetApi.caseRetrieval.sfCaseNumber != NULL){
                incomingCaseNumbers.addAll(caseRetApi.caseRetrieval.sfCaseNumber);
            }
            
            system.debug('incoming **'+ incomingCaseIds);
            system.debug('incoming **'+ incomingCaseNumbers);
            
            if(!incomingCaseIds.isEmpty() || !incomingCaseNumbers.isEmpty())
            {
                for(Case eachCase : [SELECT Id,Paid_Service__c, Fare_Total__c, QAC_Request_Country__c, CaseNumber,External_System_Reference_Id__c,ParentId,Cost_of_Sale__c,
                                     Parent.CaseNumber,Origin,Type,Problem_Type__c,Total_Attachments__c,Waiver_Sub_Type__c,Remark_Category__c,CurrencyIsoCode,
                                     Subject,Description,Reason_for_Waiver__c,Request_Reason_Sub_Type__c,Request_Reason_Others__c,Justification__c,
                                     AccountId,Consultants_Name__c,Consultant_Email__c,Consultant_Phone__c,Account.Name,Account.BillingCountryCode,
                                     Owner.Name,CreatedDate,LastModifiedDate,Expected_Closure_Date__c,Authority_Number__c,ABN_Tax_Reference__c,EMD_Number__c,
                                     PNR_number__c,Old_PNR_Number__c,Passenger_Name__c,Ticket_Number__c,IATA__c,PCC_DI__c,GDS_DI__c,Additional_Requirements__c,
                                     Qantas_Corporate_Identifier__c,Authority_Status__c,Number_of_Passengers__c,Travel_Type__c,First_Flight_Date__c,
                                     Frequent_Flyer_Number__c,Fare_basis_value__c,Fare_Type__c,Private_Fare_Basis__c,Region_Code__c,Waiver_Date__c,
                                     Account.Qantas_Industry_Centre_ID__c,Status,Point_Of_Sale__c,Customer_Tier__c,GDS_Job_Reference__c,Ticketing_Time_Limit__c,
                                     (Select Id,CommentBody,ParentId,CreatedDate,LastModifiedDate,LastModifiedBy.Name from CaseComments)
                                     FROM Case WHERE Id IN: incomingCaseIds OR CaseNumber IN: incomingCaseNumbers])
                {
                    if(eachCase != null)
                    {
                        existingCaseMap.put(eachCase.Id,eachCase);
                        existingCaseIds.add(eachCase.Id);
                        existingCaseNumbers.add(eachCase.CaseNumber);
                        
                        if(eachCase.CaseComments != null){
                            for(CaseComment eachCC : eachCase.CaseComments)
                            {
                                if(existingCaseCommentsMap.containsKey(eachCase.Id)){
                                    existingCaseCommentsMap.get(eachCase.Id).add(eachCC);
                                }
                                else{
                                    existingCaseCommentsMap.put(eachCase.Id, new list<CaseComment>{eachCC});
                                }
                            }
                            
                        }
                        
                        if(eachCase.Paid_Service__c){
                            existingPaidCaseIds.add(eachCase.Id);
                        }
                        
                    }
                }
                system.debug('no of cases**'+existingCaseIds.size());
                
                if(!existingCaseIds.isEmpty())
                {
                    for(ContentDocumentLink eachDocLink : [Select ContentDocumentId, LinkedEntityId, ShareType from ContentDocumentLink where LinkedEntityId IN: existingCaseIds]){
                        if(eachDocLink != null){
                            cdlMap.put(eachDocLink.ContentDocumentId,eachDocLink);
                        }
                    }
                    system.debug('CDL Map'+cdlMap);
                    
                    for(ContentVersion eachDocVersion : [Select ContentLocation, PathOnClient, Title, VersionData, ContentDocumentId from ContentVersion where ContentDocumentId IN: cdlMap.keySet()]){
                        if(eachDocVersion != null){
                            String myCaseId = cdlMap.get(eachDocVersion.ContentDocumentId).LinkedEntityId;
                            if(caseContentVersionMap.containsKey(myCaseId)){
                                caseContentVersionMap.get(myCaseId).add(eachDocVersion);
                            }
                            else{
                                caseContentVersionMap.put(myCaseId, new list<ContentVersion>{eachDocVersion});
                            }
                        }
                    }                
                    
                    String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();                                       
                    for(Flight__c eachFlight : [SELECT Id,Case__c,Flight_Number__c,Cabin_Class__c,Departure_Airport__c,Arrival_Airport__c,
                                                Fare_Basis__c,CreatedDate,LastModifiedDate,Arrival_Time__c,Departure_Time__c,Flight_Date__c
                                                ,New_Cabin_Class__c, Coupon_Number__c 
                                                FROM Flight__c WHERE Case__c IN: existingCaseIds AND RecordTypeId =: flightRTId])
                    {
                        if(eachFlight != null){
                            if(existingFlightsMap.containsKey(eachFlight.Case__c)){
                                existingFlightsMap.get(eachFlight.Case__c).add(eachFlight);
                            }
                            else{
                                existingFlightsMap.put(eachFlight.Case__c, new list<Flight__c>{eachFlight});
                            }
                        }
                        
                    }
                    
                    system.debug('exids**'+existingCaseIds);
                    String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();                    
                    for(Affected_Passenger__c eachPassenger : [Select Id,Name,RecordTypeId,Case__c,Salutation__c,Passenger_Type__c,New_Salutation__c,
                                                               QAC_Passenger_Id__c,FirstName__c,LastName__c,New_First_Name__c,New_Last_Name__c,
                                                               FrequentFlyerNumber__c,QAC_Flight_Number__c,Ticket_Number__c,Date_of_Birth__c,CreatedDate,
                                                               Passenger_Sequence__c,Passenger_Tattoo_Number__c,Old_Ticket_Number__c,LastModifiedDate
                                                               FROM Affected_Passenger__c WHERE Case__c IN: existingCaseIds AND RecordTypeId =: pRTID])
                    {
                        if(eachPassenger != null){
                            if(existingPassengersMap.containsKey(eachPassenger.Case__c)){
                                existingPassengersMap.get(eachPassenger.Case__c).add(eachPassenger);
                            }
                            else{
                                existingPassengersMap.put(eachPassenger.Case__c, new list<Affected_Passenger__c>{eachPassenger});
                            }
                        }
                    }
                    
                    // for Payment Retrieval - Service Payment
                    for(Service_Payment__c eachServciePayment : [SELECT Id, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Case__c, 
                                                                 Work_Order__c, Work_Order__r.WorkOrderNumber, Payment_Type__c,RFIC_code__c, 
                                                                 Payment_Timestamp__c, Payment_Due_Date__c, Payment_Currency__c, 
                                                                 Total_Amount__c , Payment_Remarks__c, Payment_Confirmation_Number__c,
                                                                 Payment_Status__c, EMD_Number__c, EMD_Issued_Date__c, EMD_Issued_IATA__c,/** JIRA:3769, QAC_Recipient_Email__c**/
                                                                 Total_Payable_credits__c FROM Service_Payment__c WHERE Case__c IN: existingCaseIds
                                                                 AND RecordTypeId =: servicePaymentRecTypeId])
                    {
                        if(existingPaidCaseIds.contains(eachServciePayment.Case__c)){
                            if(eachServciePayment != null){
                                if(existingServicePayments.containsKey(eachServciePayment.Case__c)){
                                    existingServicePayments.get(eachServciePayment.Case__c).add(eachServciePayment);
                                }
                                else{
                                    existingServicePayments.put(eachServciePayment.Case__c, new list<Service_Payment__c>{eachServciePayment});
                                }
                            }    
                        }
                        else{
                            existingServicePayments.put(eachServciePayment.Case__c, NULL);    
                        }
                        
                    }
                    
                    // for Payment Retrieval - WorkOrder, WorkOrderLineItem
                    for(WorkOrder eachOrder : [Select Id, WorkOrderNumber, StartDate, EndDate, Travel_Type__c, Pricebook2Id, 
                                               Pricebook2.Name, CurrencyIsoCode, LineItemCount, Sub_Total__c, GST__c, TotalPrice, 
                                               CreatedDate, LastModifiedDate, LastModifiedBy.Name, GST_Amount__c, CaseId, Total_Payable_credits__c,
                                               (SELECT Id, WorkOrderId, WorkOrder.WorkOrderNumber, Product2Id, Product2.ProductCode, 
                                                Product2.Name, Quantity, UnitPrice, Subtotal, TotalPrice, Product_Credit_Value__c, 
                                                Total_Payable_credits__c FROM WorkOrderLineItems WHERE RecordTypeId =: workOrderLineRecTypeId)
                                               FROM WorkOrder WHERE CaseId IN: existingCaseIds
                                               AND RecordTypeId =: workOrderRecTypeId])
                    {
                        if(existingPaidCaseIds.contains(eachOrder.CaseId)){
                            if(eachOrder != null){
                                if(existingWorkOrder.containsKey(eachOrder.CaseId)){
                                    existingWorkOrder.get(eachOrder.CaseId).add(eachOrder);
                                }
                                else{
                                    existingWorkOrder.put(eachOrder.CaseId, new list<WorkOrder>{eachOrder});
                                }
                            }    
                        }
                        else{
                            existingWorkOrder.put(eachOrder.CaseId, NULL);    
                        }
                    }

                    //Jira: CRM-9209
                    for (EMD_Details__c eachEMDDetail: [SELECT Id, EMD_Number__c, EMD_Type__c, Case__c FROM EMD_Details__c WHERE Case__c IN: existingCaseIds]) {

                        if(eachEMDDetail != null){
                            if(existingEMDDetail.containsKey(eachEMDDetail.Case__c)){
                                existingEMDDetail.get(eachEMDDetail.Case__c).add(eachEMDDetail);
                            }
                            else{
                                existingEMDDetail.put(eachEMDDetail.Case__c, new list<EMD_Details__c>{eachEMDDetail});
                            }
                        }

                    }
                }
            }
            
            system.debug('existing ***'+existingCaseMap);
            system.debug('existing cc ***'+existingCaseCommentsMap);
            system.debug('existing EMD Details ***'+existingEMDDetail);
            system.debug('existing flight ***'+existingFlightsMap);
            system.debug('existing pax ***'+existingPassengersMap);
            system.debug('existing SP ***'+existingServicePayments);
            system.debug('existing WO ***'+existingWorkOrder);
            system.debug('CCV Map'+caseContentVersionMap);
            
            if(!existingCaseMap.isEmpty())
            {
                res.statusCode = 200;
                
                for(String eachId : existingCaseMap.keySet())
                {
                    if(incomingCaseIds.contains(eachId) || incomingCaseNumbers.contains(existingCaseMap.get(eachId).CaseNumber))
                    {
                        // constructor to be added for Positive output 
                        myCaseRetResp = new QAC_CaseResponses.QACCaseRetrievalResponse('200',existingCaseMap.get(eachId),
                                                                                       existingFlightsMap.get(eachId),
                                                                                       existingPassengersMap.get(eachId),
                                                                                       existingCaseCommentsMap.get(eachId),
                                                                                       caseContentVersionMap.get(eachId),
                                                                                       existingServicePayments.get(eachId),
                                                                                       existingWorkOrder.get(eachId),
                                                                                       existingEMDDetail.get(eachId)
                                                                                      ); //Jira: CRM-9209
                        myCaseRetRespList.add(myCaseRetResp);
                        existingCaseKey.add(eachId);
                    }
                }
            }
            
            incomingCaseKey.addAll(incomingCaseIds);
            incomingCaseKey.addAll(incomingCaseNumbers);
            incomingCaseKey.removeAll(existingCaseNumbers);
            incomingCaseKey.removeAll(existingCaseIds);
            system.debug('existing ***'+myCaseRetRespList.size());
            
            for(String sfCaseId : incomingCaseKey) 
            {
                res.statusCode = 404;
                
                // constructor to be added for Negative output
                myCaseRetResp = new QAC_CaseResponses.QACCaseRetrievalResponse('404','the Request Id or Request Number is not found in salesforce system',sfCaseId);
                myCaseRetRespList.add(myCaseRetResp);
            }
            qacResp.serviceRequests = myCaseRetRespList;
            
            responseJson += JSON.serializePretty(qacResp,true);
            //responseJson += JSON.serializePretty(qacResp);
            system.debug('arr val**'+responseJson);
            //responseJson = responseJson.unescapeJava();
            res.responseBody = Blob.valueOf(responseJson);
        }
        catch (Exception ex) 
        {
            system.debug('Exception###' + ex);
            isException = true;
            
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseRetrieval', 'QAC_ServiceReqCaseRetrieval',
                                    'doServReqCaseRetrieval', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson,
                                    String.valueOf(''), true,'', ex);
            
            res.statusCode = 500;
            myCaseRetResp = new QAC_CaseResponses.QACCaseRetrievalResponse('500','There is a salesforce internal issue, please contact Salesforce Support team',null);
            myCaseRetRespList.add(myCaseRetResp);
            
            qacResp.serviceRequests = myCaseRetRespList;
            
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
        }
        finally {
            if (!isException) {
                CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseRetrieval', 'QAC_ServiceReqCaseRetrieval',
                                        'doServReqCaseRetrieval', (request.length() > 32768) ? request.substring(0,32767) : request,
                                        String.valueOf(''), true, '', null);
            }
        }
    }
}