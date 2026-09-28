/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : Utility Class for Processing Payments 
* Referred in : QAC_ServiceReqCaseCreationProcess
  History
  ************************************************************************************************
  01-Jul-2019      Jay               Agency Credits related Changes.
  ************************************************************************************************
  
  Modified Date   : 30/11/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : CRM-4017
  Version         : V2.0 - Work Order Line Item Product Credit Value needs to calculate for Per Passenger
  
  Modified Date   : 11/02/2020 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : CRM-4166
  Version         : V3.0 - Payment Initiation Enabled for Online Cases
  
*/

public with sharing class QAC_PaymentsProcess 
{
    // do work order, work order line item, service payment record creation
    public static Map<String,SObject> doPaymentsCreation(String subTypeCombo, DateTime myCreatedDate, Case myCase, Boolean myPaxSeq)
    {
        Map<String,SObject> allPaymentResponses = new Map<String,SObject>();
        
        system.debug('myPaxSeq **'+myPaxSeq);
        
        if(String.isNotBlank(myCase.QAC_Request_Country__c) && String.isNotBlank(myCase.Travel_Type__c)){
            
            // to fetch Price Book Name, Product and PBE Id
            String PrBkName = fetchPBName(myCase);
            Product2 currentProd = fetchProduct(subTypeCombo.split('_')[0]);
            String pbId = (fetchPriceBook(PrBkName) != null) ? fetchPriceBook(PrBkName).Id : null;
            String pbeId = (currentProd != null) ? fetchPriceBookEntry(currentProd.Id,pbId).Id : null;
            String isoCode = (currentProd != null) ? fetchPriceBookEntry(currentProd.Id,pbId).CurrencyIsoCode : null;
                
            // create WO
            WorkOrder newWO = new WorkOrder();
            newWO.CaseId = myCase.Id;
            newWO.RecordTypeId = fetchRecordTypeId('WorkOrder','Service Request');
            newWO.StartDate = myCreatedDate;
            newWO.Travel_Type__c = myCase.Travel_Type__c;
            newWO.Pricebook2Id = pbId;
            newWO.Status = 'New';
            newWO.CurrencyIsoCode = isoCode;
            insert newWO;
            system.debug('newWO:'+newWO);
            allPaymentResponses.put(newWO.Id+'_WO',newWO);
            
            // create WOLI
            WorkOrderLineItem newWOLI = new WorkOrderLineItem();
            newWOLI.WorkOrderId = newWO.Id;
            newWOLI.RecordTypeId = fetchRecordTypeId('WorkOrderLineItem','Service Request');
            newWOLI.PricebookEntryId = pbeId;
            newWOLI.Quantity = Decimal.valueOf(calcQuantityforWOLI(myCase,currentProd,myPaxSeq));
            if(fetchPriceBookEntry(currentProd.Id,pbId).Product_Credit_Value__c != null ){
            newWOLI.Product_Credit_Value__c = fetchPriceBookEntry(currentProd.Id,pbId).Product_Credit_Value__c;
            }
            system.debug('newWOLI:'+newWOLI);
            insert newWOLI;
            allPaymentResponses.put(newWOLI.Id+'_WOLI',newWOLI);
            
            // to fetch Work Order and create Service Payments
            WorkOrder createdWO = fetchWorkOrder(newWO.Id);
            system.debug('WO Values'+createdWO);
            
            Service_Payment__c newSPay = new Service_Payment__c();
            newSPay.Case__c = myCase.Id;
            newSPay.RecordTypeId = fetchRecordTypeId('Service_Payment__c','Service Request');
            //Changes added as per JIRA:TS-3165
            newSPay.Payment_Due_Date__c = addBusinessDays(myCase, myCreatedDate, 3);
            //Changes End as per JIRA:TS-3165
            newSPay.Work_Order__c = createdWO.Id;
            newSPay.CurrencyIsoCode = isoCode;
            newSPay.Payment_Currency__c = createdWO.CurrencyIsoCode;
            newSPay.Total_Amount__c = createdWO.TotalPrice.setScale(2);
            newSPay.RFIC_code__c = currentProd.RFIC_code__c;
            newSPay.Quantity_UOM__c = currentProd.QuantityUnitOfMeasure;
            newSPay.Payment_Status__c = 'Pending';
      // Changes Start for CRM-4017
            //newSPay.Total_Payable_credits__c =  createdWO.Total_Payable_credits__c;
            newSPay.Total_Payable_credits__c = Decimal.valueOf(calcQuantityforWOLI(myCase,currentProd,myPaxSeq)) * createdWO.Total_Payable_credits__c;
            // Changes end for CRM-4017    
            insert newSPay;
            system.debug('newSPay:'+newSPay);
            
            allPaymentResponses.put(newSPay.Id+'_SP',newSPay);
            system.debug('all resp**'+allPaymentResponses);
        }
        return allPaymentResponses;
    }    
    
    public static WorkOrder fetchWorkOrder(Id woId){
        return [SELECT Id,CurrencyIsoCode,TotalPrice,Total_Payable_credits__c FROM WorkOrder WHERE Id =: woId];
    }
    
    public static Id fetchRecordTypeId(String obj, String rtName)
    {
        //String myId = Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().get(rtName).getRecordTypeId();        
        List<Schema.DescribeSObjectResult> describes = Schema.describeSObjects(new String[] { obj }, SObjectDescribeOptions.DEFERRED);
        return describes[0].getRecordTypeInfosByName().get(rtName).getRecordTypeId();
    }
    
    public static String fetchPBName(Case myCase){
    // Changes Start for CRM-4166
    //String caseOrigin = (myCase.Origin == 'QAC Website') ? 'Online' : 'Call';
    Id caseId = myCase.Id; 
    String caseOrigin;
    
    for(Case eachCase : [Select Id, Origin, Service_Fee_Applies__c, QAC_Request_Country__c from Case where Id =: caseId]){
		if(eachCase.Origin == 'QAC Website' && String.isBlank(eachCase.Service_Fee_Applies__c)) caseOrigin = 'Online';
		else caseOrigin = 'Call';
    }
    //Changes End for CRM-4166
        String pbName = getPBData(myCase.QAC_Request_Country__c,caseOrigin);
        return pbName;
    }
    
    public static Pricebook2 fetchPriceBook(String pbName)
    {
        Pricebook2 myPricebook;
        if(String.isNotBlank(pbName))
        {
            for(Pricebook2 eachPB : [Select Id, Name, IsActive from Pricebook2 where Name =: pbName]){
                myPricebook = eachPB;                
            }
        }
        return myPricebook;
    }
    
    public static Product2 fetchProduct(String prodName)
    {
        Product2 myProd;
        for(Product2 eachProd : [Select Id,ProductCode,CurrencyIsoCode,Name,QuantityUnitOfMeasure,IsActive,RFIC_code__c
                                 FROM Product2 WHERE Name =: prodName LIMIT 1])
        {
            myProd = eachProd;            
        }
        return myProd;    
    }
    
    public static PricebookEntry fetchPriceBookEntry(Id prodId,Id pbId)
    {
        PricebookEntry myPBE;
        
        if(String.isNotBlank(prodId) && String.isNotBlank(pbId))
        {
            for(PricebookEntry eachPBE : [Select Id,Pricebook2id,Product2Id,CurrencyIsoCode,UnitPrice,ProductCode,IsActive,Product_Credit_Value__c
                                          FROM PricebookEntry WHERE Product2Id =: prodId AND Pricebook2id =: pbId LIMIT 1])
            {
                myPBE = eachPBE;    
            }
        }
        return myPBE;
    }
    
    // to calculate Quantity for LineItem
    public static Integer calcQuantityforWOLI(Case myCase, Product2 currentProd, Boolean paxExists)
    {
        Integer myQuantity;
        String myQuery;
        list<AggregateResult> results;
        Id caseId = myCase.Id;
        String pRTID = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();                    
        
        if(currentProd != null && currentProd.QuantityUnitOfMeasure == 'Ticket' && paxExists){
            if(myCase.Travel_Type__c == 'Domestic'){
                myQuery = 'Select Case__c, COUNT(Id) idCount, COUNT(Passenger_Sequence__c) notNull_qty,COUNT_DISTINCT(Passenger_Sequence__c) Distinct_qty from Affected_Passenger__c WHERE Case__c =: caseId AND RecordTypeId =: pRTID GROUP BY Case__c';
            }
            else if(myCase.Travel_Type__c == 'International'){
                myQuery = 'Select COUNT(Id) idCount from Affected_Passenger__c WHERE Case__c =: caseId AND RecordTypeId =: pRTID';   
            }
            results = Database.query(myQuery);
            
            if(results != null){
                for (AggregateResult ar : results){
                    system.debug('values Id:'+ar);
                    // with Null Values
                    if(myCase.Travel_Type__c == 'Domestic'){
                        myQuantity = ((Integer)ar.get('idCount') - (Integer)ar.get('notNull_qty')) + (Integer)ar.get('Distinct_qty'); }
                    else if(myCase.Travel_Type__c == 'International'){
                        myQuantity = ((Integer)ar.get('idCount'));}
                }
            }
        }
        else if(currentProd != null && currentProd.QuantityUnitOfMeasure == 'PNR'){
            myQuantity = 1;
        }
        return myQuantity;
    }
    
    // to add business days to due date
    public static Datetime addBusinessDays(Case myCase, Datetime currentDT, Integer noOfDays)
    {
        Integer businessDaysAdded = 0;
        while (businessDaysAdded < noOfDays) 
        {
            currentDT = currentDT.addDays(1);
            if (currentDT.format('E') != 'Sat' && currentDT.format('E') != 'Sun' && validWorkingDay(myCase.QAC_Request_Country__c,currentDT)) {
                // it's a business day, so add 1 to the counter that works towards the amount of days to add
                businessDaysAdded = businessDaysAdded + 1;
            } 
        }       
        return currentDT;
    }
    
    public static List<Holiday> getHolidays(String countryCode){
        String ccode = 'QAC '+countryCode+'%';
        List<Holiday> holidays = new list<Holiday>();
        
        for(Holiday eachHol : [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h WHERE h.Name LIKE :ccode]){
            if(eachHol != null){
                holidays.add(eachHol);    
            }
        }
        system.debug('holidays **'+holidays);
        return holidays;        
    }
    
    /*
    public static List<Holiday> holidays {
    get {
    if(holidays == null)
    holidays = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h WHERE h.Name LIKE 'QAC%'];
    return holidays;
    }
    private set;
    }
    */
    
    public static boolean validWorkingDay(String countryCode,Datetime myDT)
    {
        Date currentDate = myDT.date();
        Date weekStart = currentDate.toStartofWeek();
        
        for(Holiday hDay : getHolidays(countryCode)){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) return false;
        }
        //return (weekStart.daysBetween(currentDate) == 0 || weekStart.daysBetween(currentDate) == 6) ? false : true ;
        return true ;
    }
    
    public static String getPBData(String countryCode, String origin){
        String pbName;
        for(QAC_Pricebook_Detail__mdt eachPBDmdt : [Select MasterLabel,Pricebook_Country_Code__c,DeveloperName,Pricebook_Channel__c
                                                    from QAC_Pricebook_Detail__mdt where Pricebook_Country_Code__c =: countryCode AND Pricebook_Channel__c =: origin])
        {
            if(eachPBDmdt != null){
                pbName = eachPBDmdt.MasterLabel;
                break;
            }
        }
        system.debug('PB Name'+pbName);
        return pbName;
    }
    
}