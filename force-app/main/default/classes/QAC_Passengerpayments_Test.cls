/*
Created By  : Vinothkumar Balasubramanian

Main class Name: QAC_Passengerpayments
*/

@isTest
public class QAC_Passengerpayments_Test {
    
    @testSetup
    public static void setup() {
        
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QIC_Service_request').getRecordTypeId();
        String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        
        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        
        Trigger_Status__c ts1 = new Trigger_Status__c(Name = 'QACPassengerPayments', Active__c = true);
        insert ts1;
        
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565399',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9797979');
        insert myAccount;
        
        list<Case> newCases = new list<Case>();
        Case newCase1 = new Case(Origin = 'Phone',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                 Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                 Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                 Subject = 'validCase',Justification__c = 'must give',AccountId = myAccount.Id, 
                                 QAC_Request_Country__c = 'AU', Travel_Type__c = 'Domestic', Service_Fee_Applies__c = 'Yes - Apply');
        
        newCases.add(newCase1);
        insert newCases;
        
        waiverTypes.add(newCases[0].Problem_Type__c);
        waiverSubTypes.add(newCases[0].Waiver_Sub_Type__c);
        
        list<Flight__c> flightlist = new list<Flight__c>();
        Flight__c newTA = new Flight__c();
        newTA.RecordTypeId = flightRTId;
        newTA.Case__c = newCases[0].Id;
        flightList.add(newTA);
        insert flightList;
        
        
        
        // insert Product
        Product2 NameChangeProd = new Product2(Name = 'Name Correction',ProductCode = 'Name_Corr_NZ',QuantityUnitOfMeasure = 'Ticket',
                                               IsActive = TRUE, RFIC_code__c='AFPT');
        insert NameChangeProd;
        
        // insert Pricebook
        Pricebook2 customPB1 = new Pricebook2(Name='QAC AU Call', isActive=true, Description='Pricebook for the Services provided over Phone');
        insert customPB1;            
        
        // Standard PB ID
        Id StdPricebookId = Test.getStandardPricebookId();
        
        // Insert PriceBookEntry - Std PB entry Mandatory for PB and Product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = StdPricebookId, Product2Id = NameChangeProd.Id,UnitPrice = 100, IsActive = true);
        insert standardPrice;        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB1.Id, Product2Id = NameChangeProd.Id,UnitPrice = 70, Product_Credit_Value__c = 100 ,IsActive = true);
        insert customPrice1;               
        
        list<QAC_Waiver_Default__mdt> WDmdt = [SELECT MasterLabel,DeveloperName,Approve__c,Condition_Met__c,
                                               Cost_of_Sale__c,Cost_of_Sale_NZD__c,Paid_Service__c,Waiver_Sub_Type__c,Waiver_Type__c
                                               from QAC_Waiver_Default__mdt 
                                               where Waiver_Type__c IN: waiverTypes AND Waiver_Sub_Type__c IN: waiverSubTypes];
        system.debug('WD mdt**'+WDmdt);
        
        list<QAC_Pricebook_Detail__mdt> PBDmdt = [Select MasterLabel,Pricebook_Country_Code__c,DeveloperName,Pricebook_Channel__c
                                                  from QAC_Pricebook_Detail__mdt];
        system.debug('PBD mdt**'+PBDmdt);
    }
    
    @isTest
    public static void CaseUpdation(){
        
        List<Affected_Passenger__c> pslist = new List<Affected_Passenger__c>();
        String paxRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Case myCase = [Select Id from Case where Subject = 'validCase'];
        Test.startTest();
        Affected_Passenger__c newPassenger = new Affected_Passenger__c();
        newPassenger.RecordTypeId = paxRTId;
        newPassenger.Case__c = myCase.Id;
        pslist.add(newPassenger);
        insert pslist;
        
        Test.stopTest();
    }     
}