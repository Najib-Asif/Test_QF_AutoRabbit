/*  Created By : Ajay Bharathan | TCS | Cloud Developer
    ************************************************************************************************
    History
    ************************************************************************************************
    25-Jun-2019      Jay               QAC Agency Credits related Changes.
	
	Modified Date   : 28/11/19 (DD/MM/YYYY)
    Modified By     : Vinothkumar Balasubramanian
    JIRA            : CRM-4018
    Version         : V2.0 - Work order need to be closed after service payment record Status changed to paid 
-----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping = '/QAC_ServReqCaseUpdation/')
global with sharing class QAC_ServiceReqCaseUpdationProcess 
{
    public static String responseJSON = '';
    public static String findObject = '';
    public static list<Case_Fulfilment__c> newCFList = new list<Case_Fulfilment__c>();
    public static list<Service_Payment__c> newSPList = new list<Service_Payment__c>();
    public static map<String,Case> existingCaseMap = new map<String,Case>();    
    public static map<String, map<String,Case_Fulfilment__c>> existingFFMap = new map<String, map<String,Case_Fulfilment__c>>();  
    public static QAC_ServiceReqCaseUpdationAPI caseApi;
    public static map<Id,Case_Fulfilment__c> caseCFMap = new map<Id,Case_Fulfilment__c>();
    public static map<String, Service_Payment__c> caseSPMap = new map<String, Service_Payment__c>();
    public Static map<String, Service_Payment__c> caseSPNumberToSPMap = new map<String, Service_Payment__c>();
    public static Map<String, Asset> caseAssetMap = new Map<String, Asset>();
    public static list<Asset> newAsstList = new list<Asset>();
    public static list<WorkOrder> newWorderList = new list<WorkOrder>();
    public static list<Ledger__c>  newledgerList = new list<Ledger__c>();
    public class customException extends Exception {}
    
    @HttpPost
    global static void doServReqCaseUpdation() 
    {
        // Responses Classes for Case Updation
        QAC_CaseResponses qacResp = new QAC_CaseResponses();
        QAC_CaseResponses.QACCaseUpdationResponse myCaseUpdationResp;
        QAC_CaseResponses.CaseFulfilmentResponse myCFResp;      
        QAC_CaseResponses.CaseCommentResponse myCaseCommentResp;
        QAC_CaseResponses.ExceptionResponse myExcepResp;        
        QAC_CaseResponses.ServicePaymentResponse myServicePaymentResp;
        
        list<QAC_CaseResponses.QACCaseUpdationResponse> myCaseUpdationRespList = new list<QAC_CaseResponses.QACCaseUpdationResponse>();    
        list<QAC_CaseResponses.CaseCommentResponse> myCCRespList = new list<QAC_CaseResponses.CaseCommentResponse>();
        list<QAC_CaseResponses.CaseFulfilmentResponse> myFFRespList = new list<QAC_CaseResponses.CaseFulfilmentResponse>();
        
        // local variables for business logic
        String receivedReq;
        String jsonErrMessage;
        Boolean isException = false;
        Integer i = 0;
        
        // collection variables for handling incoming and existing Case Numbers
        Set<String> incomingCaseNums = new Set<String>();
        Set<String> incomingFFType = new Set<String>();
        //Set<Id> existingAccountIds = new Set<Id>();
        map<String,list<Case_Fulfilment__c>> caseCFMap = new map<String,list<Case_Fulfilment__c>>();
        map<String,list<QAC_ServiceReqCaseUpdationAPI.Comments>> caseJSONCCMap = new map<String,list<QAC_ServiceReqCaseUpdationAPI.Comments>>();
        list<Case> toUpdateCaseList = new list<Case>();
        //list<Account> toUpdateAccList = new list<Account>();
        list<CaseComment> newCommentsList = new list<CaseComment>();
        map<String, Case> mapCaseIdToCase = new map<String, Case>();
        Id servicePaymentRecTypeId = QAC_PaymentsProcess.fetchRecordTypeId('Service_Payment__c','Service Request');
        map<String, Case> mapAcctIdToCase = new map<String, Case>();
        Map<String, Asset> asstIdAssetMap = new Map<String, Asset>();
        Map<String, Ledger__c> caseNumLedgMap = new Map<String, Ledger__c>();
        Map<String, WorkOrder> caseIdWorderMap = new Map<String, WorkOrder>();
        Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Id ledRecTypeId = Schema.SObjectType.Ledger__c.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Id woRecTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        // Reading Request parameters, JSON extraction from Body of request is primary
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        receivedReq = req.requestBody.toString();
        
        Savepoint sp = Database.setSavepoint();
        try 
        {
            system.debug(' @@ request 1 @@' +receivedReq);
            
            // to convert the received String into object
            caseApi = QAC_ServiceReqCaseUpdationAPI.parse(receivedReq);
            
            system.debug('caseAPI @@ ' + caseApi);
            
            if(caseApi.serviceRequestUpdate != null)
            {           
                for (QAC_ServiceReqCaseUpdationAPI.ServiceRequestUpdate caseUpd: caseApi.serviceRequestUpdate)
                {
                    if(String.isNotBlank(caseUpd.requestNumber))
                    {
                        incomingCaseNums.add(caseUpd.requestNumber);
                        
                        if(caseUpd.comments != null){
                            for(QAC_ServiceReqCaseUpdationAPI.Comments commentsRecResp : caseUpd.comments)
                            {
                                if(caseJSONCCMap.containsKey(caseUpd.requestNumber)){
                                    caseJSONCCMap.get(caseUpd.requestNumber).add(commentsRecResp);
                                }
                                else{
                                    caseJSONCCMap.put(caseUpd.requestNumber, new list<QAC_ServiceReqCaseUpdationAPI.Comments>{commentsRecResp});
                                }
                            }
                        }
                    }
                }
                
                system.debug('incoming **'+incomingCaseNums);
                system.debug('Case Comment Map **'+caseJSONCCMap);
                
                if(!incomingCaseNums.isEmpty())
                {
                    for(Case eachCase : [SELECT Id,External_System_Reference_Id__c,Status,CaseNumber,Authority_Number__c,AccountId
                                         FROM Case WHERE CaseNumber IN: incomingCaseNums])
                    {
                        if(eachCase != null){
                            existingCaseMap.put(eachCase.CaseNumber,eachCase);
                            mapCaseIdToCase.put(eachCase.Id, eachCase);
                            mapAcctIdToCase.put(eachCase.AccountId, eachCase);
                        }
                    }
                    system.debug('existing ***'+existingCaseMap);
                    existingFFMap = new map<String, map<String,Case_Fulfilment__c>>();
                    if(!incomingCaseNums.isEmpty()){
                        for(Case_Fulfilment__c eachFF : [Select Id, Case__c, Case__r.CaseNumber, Fulfilment_Name__c, Category__c, Message__c,Status__c,Timestamp__c
                                                         From Case_Fulfilment__c WHERE Case__r.CaseNumber IN: incomingCaseNums]) // AND Category__c IN: incomingFFType
                        {
                            if(existingFFMap.containsKey(eachFF.Case__r.CaseNumber)){
                                existingFFMap.get(eachFF.Case__r.CaseNumber).put(eachFF.Category__c, eachFF);
                            }
                            else{
                                existingFFMap.put(eachFF.Case__r.CaseNumber, new Map<String,Case_Fulfilment__c>{eachFF.Category__c => eachFF});
                            }
                        }
                        
                        for(String eachCaseNumber : incomingCaseNums){
                            if(!existingFFMap.containsKey(eachCaseNumber)){
                                existingFFMap.put(eachCaseNumber, new Map<String,Case_Fulfilment__c>());
                            }
                        }
                        system.debug('existing FF***'+existingFFMap);
                        
                        for(Service_Payment__c eachSP : [SELECT Id, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Case__c, 
                                                         Work_Order__c, Work_Order__r.WorkOrderNumber, Payment_Type__c,Case__r.CaseNumber,
                                                         Payment_Timestamp__c, Payment_Due_Date__c, Payment_Currency__c,Payment_Confirmation_Number__c,
                                                         Payment_Status__c, EMD_Number__c, EMD_Issued_Date__c, EMD_Issued_IATA__c,Total_Payable_credits__c/**JIRA:3769, QAC_Recipient_Email__c**/
                                                         FROM Service_Payment__c 
                                                         WHERE Case__r.CaseNumber IN: incomingCaseNums
                                                         AND RecordTypeId =: servicePaymentRecTypeId]) // AND Category__c IN: incomingFFType
                        {
                            caseSPMap.put(eachSP.Case__r.CaseNumber, eachSP);
                            caseSPNumberToSPMap.put(eachSP.Name, eachSP);
                        }  
                        
                        for(Asset eachAsst :[select id, Name, RecordTypeId, AccountId, Total_Acquired_credits__c, Total_Consumed_credits__c, Total_Outstanding_credits__c, Active__c FROM asset WHERE AccountId IN:mapAcctIdToCase.Keyset() AND RecordTypeId =: assRecTypeId AND Active__c =: True FOR UPDATE])
                        {
                            caseAssetMap.put(mapAcctIdToCase.get(eachAsst.AccountId).CaseNumber, eachAsst );
                            asstIdAssetMap.put(eachAsst.Id, eachAsst);
                        }
                        
                        for(Ledger__c eachledg :[SELECT id, Case__c, Account__c, Asset__c, RecordTypeId FROM Ledger__c WHERE Case__r.CaseNumber IN: incomingCaseNums AND RecordTypeId =: ledRecTypeId])
                        {   
                            caseNumLedgMap.put(eachledg.Case__c,eachledg);      
                        }
                        
                        for(WorkOrder eachwo :[SELECT id, CaseId, RecordTypeId FROM WorkOrder WHERE CaseId IN: mapCaseIdToCase.Keyset() AND RecordTypeId =: woRecTypeId])
                        {
                          caseIdWorderMap.put(eachwo.CaseId, eachwo);  
                        }
                        
                    }
                    
                    if(!existingCaseMap.isEmpty())
                        incomingCaseNums.removeAll(existingCaseMap.keySet());
                    
                    system.debug('invalid Case Numbers**'+incomingCaseNums);
                    for(String eachCaseNum : incomingCaseNums)
                    {
                        system.debug('inside invalid case**');
                        // these case numbers are not found in salesforce
                        res.statusCode = 404;
                        myCaseUpdationResp = new QAC_CaseResponses.QACCaseUpdationResponse('404','the Request Number is not found in salesforce system',eachCaseNum);
                        myCaseUpdationRespList.add(myCaseUpdationResp);                         
                    }
                    qacResp.serviceRequestUpdateResponses = myCaseUpdationRespList;
                    
                }
                
                for(QAC_ServiceReqCaseUpdationAPI.ServiceRequestUpdate caseUpd: caseApi.serviceRequestUpdate)
                {
                    if(caseUpd != null && !existingCaseMap.isEmpty() && existingCaseMap.get(caseUpd.requestNumber) != null )
                    {
                        if (caseUpd.servicePayment != NULL ){
                            if(caseUpd.servicePayment.paymentType == 'Credit' && asstIdAssetMap.size() == 1 ){
                                toUpdateCaseList.add(doCaseUpdation(caseUpd,existingCaseMap.get(caseUpd.requestNumber),existingFFMap.get(caseUpd.requestNumber), caseSPMap.get(caseUpd.requestNumber), caseAssetMap.get(caseUpd.requestNumber), mapCaseIdToCase, caseIdWorderMap ));
                            }
                            
                            else if(caseUpd.servicePayment.paymentType == 'Credit' && asstIdAssetMap.size() > 1){
                                findObject ='Asset';
                                throw new customException('Two active assets are available.');
                            }
                            
                            else if(caseUpd.servicePayment.paymentType == 'Credit' && asstIdAssetMap.size() == 0)
                            {
                                findObject ='Asset';
                                throw new customException('Active asset is not available for the selected Agency Account.');  
                            }
                            else
                            {
                                toUpdateCaseList.add(doCaseUpdation(caseUpd,existingCaseMap.get(caseUpd.requestNumber),existingFFMap.get(caseUpd.requestNumber), caseSPMap.get(caseUpd.requestNumber), null, null, caseIdWorderMap));   
                            }
                        }
                        else
                        {
                            // String caseNum_FFType_Combo = caseUpd.requestNumber+'_'+caseUpd.fulfillCategory;
                            toUpdateCaseList.add(doCaseUpdation(caseUpd,existingCaseMap.get(caseUpd.requestNumber),existingFFMap.get(caseUpd.requestNumber), caseSPMap.get(caseUpd.requestNumber), null, null, caseIdWorderMap));
                        }
                    }
                    
                }
                
                if(!toUpdateCaseList.isEmpty())
                {
                    findObject = 'Case';   
                    update toUpdateCaseList;
                    
                    if(!newCFList.isEmpty()){
                        findObject = 'Case Fulfilment';
                        upsert newCFList;
                        
                        for(Case_Fulfilment__c eachCF : newCFList)
                        {
                            if(caseCFMap.containsKey(eachCF.Case__c)){
                                caseCFMap.get(eachCF.Case__c).add(eachCF);
                            }
                            else{
                                caseCFMap.put(eachCF.Case__c, new list<Case_Fulfilment__c>{eachCF});
                            }
                        }
                        system.debug('updated CF Map**'+caseCFMap);
                    }
                    
                    caseSPMap = new map<String, Service_Payment__c>();
                    if(!newSPList.isEmpty()){
                        findObject = 'Service Payment';
                        upsert newSPList;
                        
                        for(Service_Payment__c eachSP : newSPList)
                        {
                            caseSPMap.put(mapCaseIdToCase.get(eachSP.Case__c).CaseNumber, eachSP);
                        }
                        system.debug('updated CF Map**'+caseSPMap);
                    }
                    
                    if(!newAsstList.isEmpty()){
                        findObject = 'Asset';
                        update newAsstList;    
                    }
                    if(!newledgerList.isEmpty()){
                        if(caseNumLedgMap.Size() == 0){
                            findObject = 'Ledger';
                            insert newledgerList; 
                        }
                        else
                        {
                            //res.statusCode = 404;
                            findObject = 'Ledger';
                            throw new customException('Ledger Debit entry is already available against the Case');   
                        }
                        
                    }
                    if(!newWorderList.isEmpty())
                    {
                        findObject = 'WorkOrder';
                        update newWorderList;  
                    }
                    
                    
                    for(Case eachCase : toUpdateCaseList)
                    {
                        res.statusCode = 201;
                        if(caseCFMap.size()>0){
                            if(caseCFMap.get(eachCase.Id).size()>0){
                                for(Case_Fulfilment__c eachFF : caseCFMap.get(eachCase.Id)){
                                    myCFResp = new QAC_CaseResponses.CaseFulfilmentResponse('201',' Case Fulfilment Record(s) Modified Successfully',eachFF);
                                    myFFRespList.add(myCFResp); 
                                }
                            }   
                        }
                        
                        if(caseSPMap.get(eachCase.CaseNumber) != NULL){
                            myServicePaymentResp = new QAC_CaseResponses.ServicePaymentResponse('201',' Service Payment Record(s) Modified Successfully',caseSPMap.get(mapCaseIdToCase.get(eachCase.Id).CaseNumber));    
                        }
                        
                        myCaseUpdationResp = new QAC_CaseResponses.QACCaseUpdationResponse('201',' Case record(s) Updated Successfully',
                                                                                           eachCase,myFFRespList, myServicePaymentResp);
                        myCaseUpdationRespList.add(myCaseUpdationResp);                         
                        
                    }
                    qacResp.serviceRequestUpdateResponses = myCaseUpdationRespList;
                }
                
                // Case Comments record creation
                if(!caseJSONCCMap.isEmpty())
                {
                    for(String caseNum : caseJSONCCMap.keySet()){
                        if(!existingCaseMap.isEmpty() && existingCaseMap.get(caseNum) != null){
                            newCommentsList.addAll(doCaseCommentsCreation(existingCaseMap.get(caseNum).Id,caseJSONCCMap.get(caseNum)));
                        }
                    }
                    if(!newCommentsList.isEmpty())
                    {
                        findObject = 'Case Comments';   
                        insert newCommentsList;
                        for(CaseComment eachComment : newCommentsList){
                            if(eachComment.Id != null){
                                
                                res.statusCode = 201;
                                myCCRespList.add(new QAC_CaseResponses.CaseCommentResponse('201','Case Comment record(s) Created Successfully'));
                            }
                        }
                        qacResp.commentResponses = myCCRespList;
                    }
                }
            }
            
            responseJson += JSON.serializePretty(qacResp,true);
            system.debug('arr val**'+responseJson);
            res.responseBody = Blob.valueOf(responseJson);
            
        }
        catch (Exception ex) 
        {
             Database.rollback(sp);
            // if exception found, update Logs for Exception details
            system.debug('Exception we got'+ex);
            isException = true;
            if((findObject =='Ledger' && ex.getMessage() == 'Ledger Debit entry is already available against the Case') || (findObject =='Asset' && ex.getMessage() =='Two active assets are available.') || (findObject =='Asset' && ex.getMessage() =='Active asset is not available for the selected Agency Account.') )
            {
                res.statusCode = 404;
            }
            else{
                res.statusCode = 400;      
            }
           
            
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseUpdationProcess', 'QAC_ServiceReqCaseUpdationProcess',
                                    'doServReqCaseUpdation', (receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', ex);
            system.debug('Stack Tracke @@ ' + ex.getStackTraceString());
            system.debug('Stack Tracke @@ ' + ex.getCause());
            String sfErrMessage = ex.getMessage();
            
            if(ex.getMessage().contains(':')){
                sfErrMessage = ex.getMessage().substringAfter(':');
            }
            
            // exception response for JSON and Non JSON Exceptions
            if(ex.getTypeName().contains('JSON')){
                jsonErrMessage = 'Issue with JSON Format. Please check your Payload';
            }
            else{
                jsonErrMessage = 'Found errors.Please contact Salesforce.';
                jsonErrMessage += (String.isNotBlank(findObject)) ? 'Creation Process Failed for - '+findObject : 'Creation Failed.';
            }
            
            myExcepResp = new QAC_CaseResponses.ExceptionResponse(String.valueOf(res.statusCode),jsonErrMessage,
                                                                  'Exception Found',sfErrMessage);
            qacResp.exceptionResponse = myExcepResp;
            
            // create case for exception response as well
            system.debug('QAC Response**'+qacResp);
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
        }
        finally{
            // if no exception found, update Logs for Integration details
            if(!isException){
                CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseUpdationProcess', 'QAC_ServiceReqCaseUpdationProcess',
                                        'doServReqCaseUpdation',(receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', null);
            }
        }
        
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doCaseUpdation
    Description:        Method for Updating Case Information
    Parameter:          QAC_ServiceReqCaseUpdationAPI - ServiceRequestUpdate, existingCase
  --------------------------------------------------------------------------------------*/
    public static Case doCaseUpdation(QAC_ServiceReqCaseUpdationAPI.ServiceRequestUpdate myJSONCase, Case existingCase,map<String, Case_Fulfilment__c>  existingFF, Service_Payment__c existingSP, Asset existingAsst, Map<String, Case> mapCaseIdToCase, Map<String, WorkOrder> caseIdWorderMap)
    {
        system.debug('inside case Updation**');
        
        Case toUpdateCase = new Case();
        newSPList = new list<Service_Payment__c>();
        toUpdateCase.Id = existingCase.Id;
        newAsstList = new list<Asset>();
        newWorderList = new list<WorkOrder>();
        newledgerList = new list<Ledger__c>();
        Id ledRecTypeId = Schema.SObjectType.Ledger__c.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Map<String, QAC_Agency_Credit_Detail__mdt> allAcCmdRecords = new Map<String, QAC_Agency_Credit_Detail__mdt>();
        
        for(QAC_Agency_Credit_Detail__mdt eachcmrec : [SELECT DeveloperName, Approval_Status__c, Case_Status__c, Case_Type__c,
                                                       Fulfilled__c, Ledger_Reason__c, Ledger_Transaction_frequency__c, 
                                                       Ledger_Transaction_Type__c, SubType1__c FROM QAC_Agency_Credit_Detail__mdt]){
                                                           if(eachcmrec != null){
                                                               allAcCmdRecords.put(eachcmrec.DeveloperName, eachcmrec);   
                                                           }                                                 
                                                       }
        
        if(myJSONCase.agencyIdentification != NULL){
            if(myJSONCase.agencyIdentification.agentName != NULL){
                toUpdateCase.Consultants_Name__c = myJSONCase.agencyIdentification.agentName;
            }
            if(myJSONCase.agencyIdentification.agentEmail != NULL){
                toUpdateCase.Consultant_Email__c = myJSONCase.agencyIdentification.agentEmail;
            }
            if(myJSONCase.agencyIdentification.agentPhone != NULL){
                toUpdateCase.Consultant_Phone__c = myJSONCase.agencyIdentification.agentPhone;
            }
        }
        
        if(myJSONCase.authorityStatus != NULL){
            toUpdateCase.Authority_Status__c = myJSONCase.authorityStatus;
        }
        
        if(myJSONCase.requestStatus != NULL){
            toUpdateCase.Status = myJSONCase.requestStatus;
        }
        
        system.debug('@@ FF MAP @@ ' + existingFF);
        if(myJSONCase.fulfillmentStatus != NULL){
            for(QAC_ServiceReqCaseUpdationAPI.FulfillmentStatus eachFFMessage : myJSONCase.fulfillmentStatus){
                
                if( existingFF.get(eachFFMessage.fulfillCategory) != null && existingFF.get(eachFFMessage.fulfillCategory).Category__c == eachFFMessage.fulfillCategory)
                {
                    system.debug('inside FF Updation**');
                    existingFF.get(eachFFMessage.fulfillCategory).Status__c = eachFFMessage.fulfillStatus;
                    existingFF.get(eachFFMessage.fulfillCategory).Message__c = eachFFMessage.fulfillMessage;
                    existingFF.get(eachFFMessage.fulfillCategory).Timestamp__c = String.isNotBlank(eachFFMessage.fulfillTimestamp) ? DateTime.valueOf(eachFFMessage.fulfillTimestamp) : null;
                    newCFList.add(existingFF.get(eachFFMessage.fulfillCategory));          
                }
                else
                {
                    system.debug('inside FF Insertion**');
                    Case_Fulfilment__c newFF = new Case_Fulfilment__c();
                    newFF.Case__c = existingCase.Id;
                    newFF.Category__c = eachFFMessage.fulfillCategory;
                    newFF.Timestamp__c = System.now();
                    newFF.Status__c = eachFFMessage.fulfillStatus;
                    newFF.Message__c = eachFFMessage.fulfillMessage;
                    newCFList.add(newFF);
                }    
            }
        }
        
        system.debug(' @@ myJSONCase.servicePayment @@ ' + myJSONCase.servicePayment);
        
        if(myJSONCase.servicePayment != NULL){
            Service_Payment__c toUpdateSP = new Service_Payment__c();
            if(myJSONCase.servicePayment.paymentType != NULL){
                toUpdateSP.Payment_Type__c = myJSONCase.servicePayment.paymentType;    
            }
            if(myJSONCase.servicePayment.paymentStatus != NULL){
                toUpdateSP.Payment_Status__c = myJSONCase.servicePayment.paymentStatus;
            }
            if(myJSONCase.servicePayment.paymentRemarks != NULL){
                toUpdateSP.Payment_Remarks__c = myJSONCase.servicePayment.paymentRemarks;
            }
            if(myJSONCase.servicePayment.paymentReferenceNumber != NULL){
                toUpdateSP.Payment_Confirmation_Number__c = myJSONCase.servicePayment.paymentReferenceNumber;
            }
            if(myJSONCase.servicePayment.emdNumber != NULL && myJSONCase.servicePayment.paymentType != 'Credit'){
                toUpdateSP.EMD_Number__c = myJSONCase.servicePayment.emdNumber;
            }
            if(myJSONCase.servicePayment.emdIssueDate != NULL && myJSONCase.servicePayment.paymentType != 'Credit'){
                toUpdateSP.EMD_Issued_Date__c = myJSONCase.servicePayment.emdIssueDate;
            }
            if(myJSONCase.servicePayment.emdIssueIATA != NULL && myJSONCase.servicePayment.paymentType != 'Credit'){
                toUpdateSP.EMD_Issued_IATA__c = myJSONCase.servicePayment.emdIssueIATA;
            }
            /**JIRA:3769
            if(myJSONCase.servicePayment.receiptEmail != NULL){
            toUpdateSP.QAC_Recipient_Email__c = myJSONCase.servicePayment.receiptEmail;
            }**/
            if(myJSONCase.servicePayment.paymentTimestamp != NULL){
                toUpdateSP.Payment_Timestamp__c = DateTime.valueOf(myJSONCase.servicePayment.paymentTimestamp);
            }
            
            toUpdateSP.Id = caseSPNumberToSPMap.get(myJSONCase.servicePayment.paymentNumber).Id;
            toUpdateSP.Case__c = existingCase.Id;
            newSPList.add(toUpdateSP);
            
            if (myJSONCase.servicePayment.paymentType != NULL){
                if (myJSONCase.servicePayment.paymentType == 'Credit'){
                    if(existingAsst != NULL){
                        
                        Asset toUpdateAsset = new Asset();
                        toUpdateAsset.Total_Consumed_credits__c = existingAsst.Total_Consumed_credits__c + caseSPNumberToSPMap.get(myJSONCase.servicePayment.paymentNumber).Total_Payable_credits__c;
                        toUpdateAsset.Id = existingAsst.Id;
                        newAsstList.add(toUpdateAsset);
                        
                        Ledger__c toInsertLedger = new Ledger__c(Account__c = mapCaseIdToCase.get(myJSONCase.requestId).AccountId, Asset__c = toUpdateAsset.Id, 
                                                                 Case__c = mapCaseIdToCase.get(myJSONCase.requestId).Id, RecordTypeId = ledRecTypeId, Transaction_type__c = allAcCmdRecords.get('DebitLedgerValuesOnline').Ledger_Transaction_Type__c, 
                                                                 Transaction_frequency__c = allAcCmdRecords.get('DebitLedgerValuesOnline').Ledger_Transaction_frequency__c, Transaction_date__c = System.Today(),
                                                                 Reason__c = allAcCmdRecords.get('DebitLedgerValuesOnline').Ledger_Reason__c, Total_Credit_value__c = caseSPNumberToSPMap.get(myJSONCase.servicePayment.paymentNumber).Total_Payable_credits__c,
                                                                 Total_Outstanding_Credits__c = existingAsst.Total_Acquired_credits__c - toUpdateAsset.Total_Consumed_credits__c);
                        newledgerList.add(toInsertLedger); 
                    }  
                }
            }
			// Changes for CRM-4018 (Checking the Service Payment Status on the below condition)
            if(caseIdWorderMap.get(existingCase.Id).Id != NULL && myJSONCase.servicePayment.paymentStatus == 'Paid'){
                
                WorkOrder toUpdateWorder = new WorkOrder(Id = caseIdWorderMap.get(existingCase.Id).Id, Status = 'Closed' );
                newWorderList.add(toUpdateWorder);
            } 
        }
        
        return toUpdateCase;
    }   
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doCaseCommentsCreation
    Description:        Method for inserting Case Comments Information
    Parameter:          list of QAC_ServiceReqCaseUpdationAPI - Case Comments, myCaseNum
  --------------------------------------------------------------------------------------*/
    public static list<CaseComment> doCaseCommentsCreation(String myCaseId, list<QAC_ServiceReqCaseUpdationAPI.Comments> myComments){
        
        list<CaseComment> newCCList = new list<CaseComment>();
        system.debug('inside CaseComments**');
        
        for(QAC_ServiceReqCaseUpdationAPI.Comments eachComment : myComments)
        {
            CaseComment newComment = new CaseComment();
            newComment.CommentBody = eachComment.commentDescription;
            newComment.ParentId = myCaseId;
            newCCList.add(newComment);
        }
        return newCCList;
    }
}