/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_InitiatePaymentController
 *   History
  ************************************************************************************************
  01-Jul-2019      Jay               Agency Credits related Changes.
  ************************************************************************************************
  
   CRM-3936 : Bulkification of Agency Credit Test Class
  * Last Modified By : Vinothkumar Balasubramanian
*/
@isTest
public class QAC_InitiatePaymentsController_Test {

    @testSetup
    public static void setup() {
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String paxRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woliRTId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String spRTId = Schema.SObjectType.Service_Payment__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();

        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        List<Case> agencyCreditCase = new List<Case>();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();

        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        List<Trigger_Status__c> lsttrgStatus1 = TestUtilityDataClassQantas.createAssetTriggerSetting();
        insert lsttrgStatus1;

        //Inserting Account
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9797979');
        insert myAccount;
        
        // Case with Paid as Null & Country Code, Travel Type as Null
        Case invalidCase = new Case(Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                    Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                    Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                    Subject = 'invalidCase',Justification__c = 'must give',AccountId = myAccount.Id);
        //insert invalidCase;
        agencyCreditCase.add(invalidCase);

        Case invalidCase2 = new Case(Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                    Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                    Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                    Subject = 'invalidCase2',Justification__c = 'must give',AccountId = myAccount.Id, Paid_Service__c = true);
        //insert invalidCase2;
        agencyCreditCase.add(invalidCase2);

        Case invalidCase3 = new Case(Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                  Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                  Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                  Subject = 'invalidCase3',Justification__c = 'must give',AccountId = myAccount.Id, Paid_Service__c = true,
                                  QAC_Request_Country__c = 'AU', Travel_Type__c = 'Domestic');
        //insert invalidCase3;
        agencyCreditCase.add(invalidCase3);
        
        Case invalidCase4 = new Case(Origin = 'Phone',RecordTypeId = caseRTId,Status = 'Open',Type = 'Group Waivers',
                                  Problem_Type__c = 'Deposit Deadline',
                                  Reason_for_Waiver__c = 'Public holiday periods',
                                  Subject = 'invalidCase4',Justification__c = 'must give',AccountId = myAccount.Id, Paid_Service__c = true, Service_Fee_Applies__c='Yes - Apply',
                                  QAC_Request_Country__c = 'AU', Travel_Type__c = 'Domestic', Description ='Test');
        //insert invalidCase4;
        agencyCreditCase.add(invalidCase4);
        
        // Valid Case & its child record creations
        Case validCase = new Case(Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                  Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                  Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                  Subject = 'validCase',Justification__c = 'must give',AccountId = myAccount.Id, Paid_Service__c = true,
                                  QAC_Request_Country__c = 'AU', Travel_Type__c = 'Domestic');
        //insert validCase;
        agencyCreditCase.add(validCase);
        
        insert agencyCreditCase;
        
        /*waiverTypes.add(invalidCase.Problem_Type__c);
        waiverSubTypes.add(invalidCase.Waiver_Sub_Type__c);
        waiverSubTypes.add(validCase.Waiver_Sub_Type__c);*/
        
        waiverTypes.add(agencyCreditCase[0].Problem_Type__c);
        waiverSubTypes.add(agencyCreditCase[0].Waiver_Sub_Type__c);
        waiverSubTypes.add(agencyCreditCase[4].Waiver_Sub_Type__c);

        list<Affected_Passenger__c> pslist = new list<Affected_Passenger__c>();
        for(Integer i=0;i<2;i++){
            Affected_Passenger__c newPassenger = new Affected_Passenger__c();
            newPassenger.RecordTypeId = paxRTId;
            //newPassenger.Case__c = validCase.Id;
            newPassenger.Case__c = agencyCreditCase[4].Id;
            newPassenger.Passenger_Sequence__c = Decimal.valueOf(i);
            pslist.add(newPassenger);
        }
        insert pslist;

        // insert Product
        Product2 NameChangeProd = new Product2(Name = 'Name Correction',ProductCode = 'Name_Corr_AU',QuantityUnitOfMeasure = 'Ticket',
                                     IsActive = TRUE, RFIC_code__c='AFPT');
        insert NameChangeProd;

        // insert Pricebook
        Pricebook2 customPB1 = new Pricebook2(Name='QAC AU Online', isActive=true, Description='Pricebook for AU Agents that Register via Website');
        Pricebook2 customPB2 = new Pricebook2(Name='QAC EU Call', isActive=true, Description='Pricebook for AU Agents that Register via Calls');
        insert customPB1;        
        insert customPB2;        

        // Standard PB ID
        Id StdPricebookId = Test.getStandardPricebookId();
        
        // Insert PriceBookEntry - Std PB entry Mandatory for PB and Product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = StdPricebookId, Product2Id = NameChangeProd.Id,UnitPrice = 100, IsActive = true);
        insert standardPrice;        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB1.Id, Product2Id = NameChangeProd.Id,UnitPrice = 70, IsActive = true, Product_Credit_Value__c = 100);
        insert customPrice1;        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = NameChangeProd.Id,UnitPrice = 80, IsActive = true);
        insert customPrice2;        
        
        list<QAC_Waiver_Default__mdt> WDmdt = [SELECT MasterLabel,DeveloperName,Approve__c,Condition_Met__c,
                                               Cost_of_Sale__c,Paid_Service__c,Waiver_Sub_Type__c,Waiver_Type__c
                                               from QAC_Waiver_Default__mdt 
                                               where Waiver_Type__c IN: waiverTypes AND Waiver_Sub_Type__c IN: waiverSubTypes];
        system.debug('WD mdt**'+WDmdt);
        
        // create Work Order & Service Payment record for invalidCase
        WorkOrder newWO = new WorkOrder();
        //newWO.CaseId = invalidCase3.Id;
        newWO.CaseId = agencyCreditCase[2].Id;
        newWO.RecordTypeId = woRTId;
        newWO.StartDate = validCase.CreatedDate;
        newWO.Travel_Type__c = validCase.Travel_Type__c;
        newWO.Pricebook2Id = customPB1.Id;
        newWO.Status = 'New';
        insert newWO;

        WorkOrderLineItem newWOLI = new WorkOrderLineItem();
        newWOLI.WorkOrderId = newWO.Id;
        newWOLI.RecordTypeId = woliRTId;
        newWOLI.PricebookEntryId = customPrice1.Id ;
        newWOLI.Quantity = 2;
        newWOLI.Product_Credit_Value__c = 100;
        insert newWOLI;
        system.debug('newWOLI:'+newWOLI);
        
        WorkOrder createdWO = QAC_PaymentsProcess.fetchWorkOrder(newWO.Id);
        Service_Payment__c newSPay = new Service_Payment__c();
        //newSPay.Case__c = invalidCase.Id;
        newSPay.Case__c = agencyCreditCase[0].Id;
        newSPay.RecordTypeId = spRTId;
        newSPay.Payment_Due_Date__c = Date.today().addDays(-3);
        newSPay.Work_Order__c = createdWO.Id;
        newSPay.Payment_Currency__c = createdWO.CurrencyIsoCode;
        newSPay.Total_Amount__c = createdWO.TotalPrice;
        newSPay.RFIC_code__c = NameChangeProd.RFIC_code__c;
        newSPay.Quantity_UOM__c = NameChangeProd.QuantityUnitOfMeasure;
        newSPay.Payment_Status__c = 'Pending';          
        insert newSPay;
        system.debug('newSPay:'+newSPay);
        
        //QAC Agency Credit related changes
        List<Asset> listAssets = new List<Asset>();
        Asset ass1 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId, AccountId = myAccount.Id, Active__c = True, Total_Acquired_Credits__c = 1000, Total_Consumed_Credits__c = 0 ); 
        listAssets.add(ass1);
        insert listAssets;
        
        
        WorkOrder newWOrd = new WorkOrder();
        //newWOrd.CaseId = validCase.Id;
        newWOrd.CaseId = agencyCreditCase[4].Id;
        newWOrd.RecordTypeId = woRTId;
        /*newWOrd.StartDate = validCase.CreatedDate;
        newWOrd.Travel_Type__c = validCase.Travel_Type__c;*/
        newWOrd.StartDate = agencyCreditCase[4].CreatedDate;
        newWOrd.Travel_Type__c = agencyCreditCase[4].Travel_Type__c;
        newWOrd.Pricebook2Id = customPB1.Id;
        newWOrd.Status = 'New';
        insert newWOrd;
        
        WorkOrder createdWOrd = QAC_PaymentsProcess.fetchWorkOrder(newWOrd.Id);
        Service_Payment__c newSPaym = new Service_Payment__c();
        //newSPaym.Case__c = validCase.Id;
        newSPaym.Case__c = agencyCreditCase[4].Id;
        newSPaym.RecordTypeId = spRTId;
        newSPaym.Payment_Due_Date__c = Date.today().addDays(-3);
        newSPaym.Work_Order__c = createdWOrd.Id;
        newSPaym.Payment_Currency__c = createdWOrd.CurrencyIsoCode;
        newSPaym.Total_Amount__c = createdWOrd.TotalPrice;
        newSPaym.RFIC_code__c = NameChangeProd.RFIC_code__c;
        newSPaym.Quantity_UOM__c = NameChangeProd.QuantityUnitOfMeasure;
        newSPaym.Total_Payable_credits__c = 100;
        newSPaym.Payment_Status__c = 'Pending';          
        insert newSPaym;
    }
    
    @isTest
    public static void invalidDataTest()
    {
        String caseId = '';
        // query invalid case
        for(Case eachCase : [Select Id from Case where Subject = 'invalidCase']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        Test.startTest();
            QAC_InitiatePaymentsController.ValidatePayment(caseId);
            QAC_InitiatePaymentsController.getPayRecord(caseId);
        Test.stopTest();
    }    

    @isTest
    public static void invalidDataTest2()
    {
        String caseId = '';
        // query invalid case
        for(Case eachCase : [Select Id from Case where Subject = 'invalidCase2']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        Test.startTest();
            QAC_InitiatePaymentsController.ValidatePayment(caseId);
        Test.stopTest();
    }    
    
    @isTest
    public static void invalidDataTest3()
    {
        String caseId = '';
        // query invalid case
        for(Case eachCase : [Select Id from Case where Subject = 'invalidCase3']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        Test.startTest();
            QAC_InitiatePaymentsController.ValidatePayment(caseId);
        Test.stopTest();
    }    
    
    
    @isTest
    public static void invalidDataTest4()
    {
        String caseId = '';
        // query invalid case
        for(Case eachCase : [Select Id from Case where Subject = 'invalidCase4']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        Test.startTest();
            QAC_InitiatePaymentsController.ValidatePayment(caseId);
        Test.stopTest();
    } 
    
    @isTest
    public static void validDataTest()
    {
        String caseId = '';
        // query valid case
        for(Case eachCase : [Select Id from Case where Subject = 'validCase']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        Test.startTest();
            QAC_InitiatePaymentsController.ValidatePayment(caseId);
            //QAC_InitiatePaymentsController.getPayRecord(caseId);
        Test.stopTest();
    } 
    
    @isTest
    public static void QAC_PaymentEvaluationTest()
    {        
        Test.startTest();
            Database.executeBatch(new QAC_PaymentEvaluation());
        Test.stopTest();
    }
    
    //QAC Agency Credit related changes 
    @isTest
    public static void UpdatePaymentCreditTest()
    {
        
        String caseId = '';
        String payType = '';
        String emdNum  = '';
        Id assRecTypeId1 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Id ledRecTypeId = Schema.SObjectType.Ledger__c.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Account acc1 =[SELECT id, IATA_Number__c From Account WHERE IATA_Number__c = '9797979' ];
        Asset ass1 =[SELECT id, Total_Acquired_credits__c, Total_Consumed_credits__c From Asset WHERE Total_Acquired_credits__c = 1000];
        
        // query valid case
        for(Case eachCase : [Select Id from Case where Subject = 'validCase']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        // query Service Payment record
        for (Service_Payment__c eachSP : [Select Id,Name,Case__c, Payment_Type__c, EMD_Number__c from Service_Payment__c])
        {
            if(eachSP != null)
                eachSP.Payment_Type__c = 'Credit';
            eachSP.EMD_Number__c = '0818209981826';
            payType = eachSP.Payment_Type__c;
            emdNum  = eachSP.EMD_Number__c;     
        }
        
        //Credit Points Scenario
        Test.startTest();
        QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);
        Test.stopTest(); 
        
        //Two Active Assets Scenario
        Asset ass2 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId1, AccountId = acc1.Id, Active__c = True, Total_Acquired_credits__c = 2, Total_Consumed_credits__c =1 ); 
        insert ass2;
        try{
            QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);
        }
        catch(Exception ex){}
        
        //Zero Active Assets Scenario
        ass1.Active__c = false;
        update ass1;
        ass2.Active__c = false;
        update ass2;
        try{
            QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);
        }
        catch(Exception ex){}
        
        //Insufficient Credits Scenario
        ass1.Active__c = true;
        ass1.Total_Consumed_Credits__c = 2000;
        update ass1;
        try{
            QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);   
        }
        catch(Exception ex){}
        
        //Ledger Debit entry is already available against the Case Scenario
        ass1.Total_Consumed_Credits__c = 0;
        update ass1;
        Ledger__c ledrecord = new Ledger__c (Account__c = acc1.ID,
                                             Asset__c = ass1.Id, Case__c = caseId,                                                        
                                             RecordTypeId = ledRecTypeId, Transaction_type__c = 'Debit', 
                                             Transaction_frequency__c = 'Regular', Transaction_date__c = System.Today(),
                                             Reason__c = 'Paid Service (Offline)',
                                             Total_Credit_Value__c = ass1.Total_Acquired_credits__c, Total_Outstanding_Credits__c = ass1.Total_Acquired_credits__c - ass1.Total_Consumed_credits__c
                                            );
        insert ledrecord;
        try{
            QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);   
        }
        catch(Exception ex){}
        
    }
    
    //QAC Agency Credit related changes for Card 
    @isTest
    public static void UpdatePaymentCardTest()
    {
        String caseId = '';
        String payType = '';
        String emdNum  = '';
        
        // query valid case
        for(Case eachCase : [Select Id from Case where Subject = 'validCase']){
            if(eachCase != null)
                caseId = eachCase.Id;
        }
        
        for (Service_Payment__c eachSP : [Select Id,Name,Case__c, Payment_Type__c, EMD_Number__c from Service_Payment__c])
        {
            if(eachSP != null)
                eachSP.Payment_Type__c = 'Card';
            eachSP.EMD_Number__c = '0818209981826';
            payType = eachSP.Payment_Type__c;
            emdNum  = eachSP.EMD_Number__c;     
        }
        
        Test.startTest();
        QAC_InitiatePaymentsController.UpdatePayment(caseId, payType, emdNum);
        Test.stopTest();  
    }
    
    
}