/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : Manual Payment Processing Class
* Referred : QAC_PaymentsProcess, QAC_InitiatePayments (Lightning Bundle)
  History
  ************************************************************************************************
  01-Jul-2019      Jay               Agency Credits related Changes.
  ************************************************************************************************
*/

public with sharing class QAC_InitiatePaymentsController {
    
    @AuraEnabled
    public String isSuccess { get; set; }
    
    @AuraEnabled
    public String msg { get; set; }
    
    @AuraEnabled
    public static Service_Payment__c getPayRecord(String caseId){
        list<Service_Payment__c> mySPRecords = new list<Service_Payment__c>();
        for(Service_Payment__c eachSP : [Select Id, Name, Payment_Currency__c, Case__c, Work_Order__c, Total_Amount__c,Payment_Status__c,
                                         Payment_Type__c, EMD_Number__c, Quantity_UOM__c, Work_Order__r.WorkOrderNumber, Payment_Due_Date__c,
                                         Total_Amount_with_Currency__c,Total_Payable_credits__c,Payment_Timestamp__c
                                         from Service_Payment__c where Case__c =: caseId])
        {
            if(eachSP != null)    
                mySPRecords.add(eachSP);
        }
        if(!mySPRecords.isEmpty())
            return mySPRecords[0];
        return null;
    }
    
    @AuraEnabled
    public static QAC_InitiatePaymentsController ValidatePayment(String caseId)
    {
        QAC_InitiatePaymentsController obj = new QAC_InitiatePaymentsController(); 
        Case myCase;
        Boolean myPaxSeq, myWorkOrder, myProduct;
        String waivCombo;
        
        if(String.isNotBlank(caseId))
        {
            myCase = getCurrentCase(caseId);
            myPaxSeq = getPaxRecord(caseId);
            myWorkOrder = getWORecord(caseId);
            waivCombo = myCase.Problem_Type__c + '_' + myCase.Waiver_Sub_Type__c;
            //waivType = myCase.Problem_Type__c;
            myProduct = getProductRecord(waivCombo.split('_')[0]);
            
            if(myCase.Paid_Service__c == null || !myCase.Paid_Service__c){
                obj.msg = 'You cannot create payments for Non-Paid Service';
                obj.isSuccess = 'error';
                return obj;
            }
            else if (myCase.Paid_Service__c != null && myProduct == false){
                obj.msg = 'You cannot create payments for Non-Paid Service';
                obj.isSuccess = 'error';
                return obj;
            }   
            else if(String.isBlank(myCase.QAC_Request_Country__c) || String.isBlank(myCase.Travel_Type__c)){
                obj.msg = 'Request Country (or) Travel type is incorrect.You cannot create payments';
                obj.isSuccess = 'error';
                return obj;
            }
            else if(myWorkOrder){
                obj.msg = 'Payment already initiated. Please modify the existing Payments';
                obj.isSuccess = 'error';
                return obj;
            }
            else if(!myPaxSeq){
                obj.msg = 'No Passenger records. Please add Passengers and retry';
                obj.isSuccess = 'error';
                return obj;
            }
            else{
                // Proceed with Payments Creation
                QAC_PaymentsProcess.doPaymentsCreation(waivCombo,myCase.CreatedDate,myCase,myPaxSeq);
                obj.msg = 'Payment Records created successfully';
                obj.isSuccess = 'success';
                return obj;
            }
        }
        system.debug('obj**'+obj);
        return obj;
    }
    
    @AuraEnabled
    public static void UpdatePayment(String caseId, String payType, String emdNum){
        
        map<String, Case> mapAcctIdToCase = new map<String, Case>();
        Map<String, Asset> caseAssetMap = new Map<String, Asset>();
        Map<String, Asset> asstIdAssetMap = new Map<String, Asset>();
        Map<String, Ledger__c> caseNumLedgMap = new Map<String, Ledger__c>();
        Map<String, WorkOrder> caseIdWoMap = new Map<String, WorkOrder>();
        map<String, Service_Payment__c> caseSPNumberToSPMap = new map<String, Service_Payment__c>();
        list<Asset> newAsstList = new list<Asset>();
        list<Ledger__c>  newledgerList = new list<Ledger__c>();
        list<Service_Payment__c> newSPList = new list<Service_Payment__c>();
        list<WorkOrder>  newWorderList = new list<WorkOrder>();
        Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Id ledRecTypeId = Schema.SObjectType.Ledger__c.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Map<String, QAC_Agency_Credit_Detail__mdt> allAcCmdRecords = new Map<String, QAC_Agency_Credit_Detail__mdt>();
        
        for(QAC_Agency_Credit_Detail__mdt eachcmrec : [SELECT DeveloperName, Approval_Status__c, Case_Status__c, Case_Type__c,
                                                       Fulfilled__c, Ledger_Reason__c, Ledger_Transaction_frequency__c, 
                                                       Ledger_Transaction_Type__c, SubType1__c FROM QAC_Agency_Credit_Detail__mdt]){
                                                           if(eachcmrec != null){
                                                               allAcCmdRecords.put(eachcmrec.DeveloperName, eachcmrec);   
                                                           }                                                 
                                                       }
        Savepoint sp = Database.setSavepoint(); 
        try{ 
            
            Case myCase;
            Service_Payment__c mySP;
            
            if(String.isNotBlank(caseId))
            {   
                
                myCase = getCurrentCase(caseId);
                mySP = getPayRecord(caseId); 
                if(myCase != Null){
                    mapAcctIdToCase.put(myCase.AccountId, myCase);
                }
                
                for(Asset eachAsst :[SELECT id, Name, RecordTypeId, AccountId, Total_Acquired_credits__c, Total_Consumed_credits__c, Total_Outstanding_credits__c, Active__c FROM asset WHERE AccountId IN:mapAcctIdToCase.Keyset() AND RecordTypeId =: assRecTypeId AND Active__c =: True FOR UPDATE])
                {
                    caseAssetMap.put(mapAcctIdToCase.get(eachAsst.AccountId).Id, eachAsst );
                    asstIdAssetMap.put(eachAsst.Id, eachAsst);
                }
                
                for(Ledger__c eachledg :[SELECT id, Case__c, Account__c, Asset__c, RecordTypeId FROM Ledger__c WHERE Case__r.Id =: caseId AND RecordTypeId =: ledRecTypeId])
                {   
                    caseNumLedgMap.put(eachledg.Case__c,eachledg);      
                }
                
                for(WorkOrder eachwo :[SELECT id, CaseId, Status FROM WorkOrder WHERE CaseId=:caseId])
                {
                    caseIdWoMap.put(eachwo.CaseId, eachwo);  
                }
                
                if (payType == 'Credit' && asstIdAssetMap.size() == 1){
                    if(caseAssetMap.get(caseId) != Null && mySP != Null && caseIdWoMap.get(CaseId) != Null){
                        if(mySP.Total_Payable_credits__c < caseAssetMap.get(caseId).Total_Outstanding_Credits__c ){
                            Asset toUpdateAsset = new Asset();
                            toUpdateAsset.Total_Consumed_credits__c = caseAssetMap.get(caseId).Total_Consumed_credits__c + mySP.Total_Payable_credits__c;
                            toUpdateAsset.Id = caseAssetMap.get(caseId).Id;
                            newAsstList.add(toUpdateAsset);  
                            
                            Ledger__c toInsertLedger = new Ledger__c(Account__c = myCase.AccountId, Asset__c = toUpdateAsset.Id, 
                                                                     Case__c = myCase.Id, RecordTypeId = ledRecTypeId, Transaction_type__c = allAcCmdRecords.get('DebitLedgerValuesOffline').Ledger_Transaction_Type__c, 
                                                                     Transaction_frequency__c = allAcCmdRecords.get('DebitLedgerValuesOffline').Ledger_Transaction_frequency__c, Transaction_date__c = System.Today(),
                                                                     Reason__c = allAcCmdRecords.get('DebitLedgerValuesOffline').Ledger_Reason__c, Total_Credit_value__c = mySP.Total_Payable_credits__c,
                                                                     Total_Outstanding_Credits__c = caseAssetMap.get(caseId).Total_Acquired_credits__c - toUpdateAsset.Total_Consumed_credits__c);
                            newledgerList.add(toInsertLedger); 
                            
                            Service_Payment__c toUpdateSP = new Service_Payment__c(Id = mySP.Id, Payment_Type__c = payType, Payment_Status__c = 'Paid');
                            newSPList.add(toUpdateSP);   
                            
                            WorkOrder toUpdatWO = new WorkOrder(Id =caseIdWoMap.get(CaseId).Id, Status = 'Closed');
                            newWorderList.add(toUpdatWO);  
                        }
                        else{
                            throw new AuraHandledException('Insufficient Credits - Total Outstanding Credit value is less than Total Payable Credits');
                        }
                    }
                    
                    if(!newAsstList.isEmpty()){
                        update newAsstList;    
                    }
                    if(!newledgerList.isEmpty()){
                        if(caseNumLedgMap.Size() == 0){
                            insert newledgerList; 
                        }
                        else
                        {   
                            system.debug('InsideOfLedgerexception');
                            throw new AuraHandledException('Ledger Debit entry is already available against the Case.');
                            
                        } 
                    }  
                }
                else if(payType == 'Credit' && asstIdAssetMap.size() > 1){
                    throw new AuraHandledException('Multiple active assets are available for the selected Agency Account.');   
                }
                else if(payType == 'Credit' && asstIdAssetMap.size() == 0){
                    throw new AuraHandledException('Active asset is not available for the selected Agency Account.');   
                }
                else{
                    if(mySP != Null){
                        Service_Payment__c toUpdateSP = new Service_Payment__c(Id = mySP.Id, Payment_Type__c = payType, EMD_Number__c = emdNum, Payment_Status__c = 'Paid');
                        newSPList.add(toUpdateSP);                      
                    }
                    if(caseIdWoMap.get(CaseId) != Null){
                        WorkOrder toUpdatWO = new WorkOrder(Id =caseIdWoMap.get(CaseId).Id, Status = 'Closed');
                        newWorderList.add(toUpdatWO);  
                    }  
                }
                
                if(!newSPList.isEmpty()) {
                    update newSPList;
                } 
                if(!newWorderList.isEmpty()){
                    update newWorderList;   
                }
            }
            
        }
        catch (Exception ex)
        {
            //system.debug('InsideCatchblock'+ ex.getMessage());
            Database.rollback(sp);
            throw ex;
            
        }
    }
    
    public static Boolean getPaxRecord(String caseId){
        String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();                    
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
    
    public static Boolean getWORecord(String caseId){
        
        for(WorkOrder eachOrder : [Select Id, WorkOrderNumber, StartDate, EndDate, Travel_Type__c, Pricebook2Id, 
                                   Pricebook2.Name, CurrencyIsoCode, LineItemCount, Sub_Total__c, GST__c, TotalPrice, 
                                   CreatedDate, LastModifiedDate, LastModifiedBy.Name, CaseId,
                                   (SELECT Id, WorkOrderId, WorkOrder.WorkOrderNumber, Product2Id, Product2.ProductCode, 
                                    Product2.Name, Quantity, UnitPrice, Subtotal, TotalPrice FROM WorkOrderLineItems)
                                   FROM WorkOrder WHERE CaseId =: caseId])
        {
            if(eachOrder != null && eachOrder.WorkOrderLineItems != null)
                return true;
        }
        return false;                                                                          
    }
    
    
    public static Boolean getProductRecord(String waivType){
        
        
        for(Product2 eachProd : [Select Id,ProductCode,CurrencyIsoCode,Name,QuantityUnitOfMeasure,IsActive,RFIC_code__c
                                 FROM Product2 WHERE Name =: waivType LIMIT 1])
        {
            if(eachProd != null)
                return true;            
        }
        return false;   
    }   
    
    public static Case getCurrentCase(String caseId)
    {
        Case existingCase;
        String rtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        for(Case eachCase : [SELECT Id,Paid_Service__c, QAC_Request_Country__c,CaseNumber,External_System_Reference_Id__c,ParentId,Parent.CaseNumber,Origin,Type,Problem_Type__c,
                             Subject,Description,Reason_for_Waiver__c,Request_Reason_Sub_Type__c,Request_Reason_Others__c,Justification__c,
                             AccountId,Consultants_Name__c,Consultant_Email__c,Consultant_Phone__c,Account.Name,Account.BillingCountryCode,
                             Owner.Name,CreatedDate,LastModifiedDate,Expected_Closure_Date__c,Authority_Number__c,ABN_Tax_Reference__c,
                             PNR_number__c,Old_PNR_Number__c,Passenger_Name__c,Ticket_Number__c,IATA__c,PCC_DI__c,GDS_DI__c,Additional_Requirements__c,
                             Qantas_Corporate_Identifier__c,Number_of_Passengers__c,Travel_Type__c,First_Flight_Date__c,Waiver_Sub_Type__c,
                             Frequent_Flyer_Number__c,Fare_basis_value__c,Fare_Type__c,Private_Fare_Basis__c,Region_Code__c,
                             Account.Qantas_Industry_Centre_ID__c,Status,Point_Of_Sale__c,Customer_Tier__c,Ticketing_Time_Limit__c
                             FROM Case WHERE Id =: caseId AND RecordTypeId =: rtypeId])
        {
            existingCase = eachCase;
        }
        return existingCase;            
    }
}