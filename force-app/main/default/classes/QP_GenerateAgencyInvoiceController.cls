/**********************************************************************************************************************

Description: Lightning component handler for QC Generate Agency Invoice functionality.
Test Class Name      : QP_GenerateAgencyInvoiceControllerTest
Created Date         : 20/08/19 (DD/MM/YYYY)
Author               : Jay   TCS    Salesforce Developer  
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================


************************************************************************************************************************/
global with sharing class QP_GenerateAgencyInvoiceController {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    //@AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    global static QP_GenerateAgencyInvoiceController getGenerateInvoice(Id contId)
    {
        system.debug('Fromlightbutton'+contId);
        QP_GenerateAgencyInvoiceController obj = new QP_GenerateAgencyInvoiceController();
        Id caRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
        Id cpciRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Incentive').getRecordTypeId();
        Id cpctfRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Tech_Fund').getRecordTypeId();
        Id inapRTId = Schema.SObjectType.Invoices__c.getRecordTypeInfosByDeveloperName().get('Agency_Payments').getRecordTypeId();
        
        List < Contract_Payments__c > contpayment = new List < Contract_Payments__c > ();
        list<Invoices__c> existingInvoiceList = new list<Invoices__c> ();
        Set<ID> cpids = new Set<ID>();
        Integer DurationYears;
        Integer counter;
        Integer DueDateMonths;
        Integer i = 0;
        Integer dueDays;
        Decimal Amtdiv;
        String IDs = '';
        String PayFrequency = '';
        Date contractStartDate;
        Date contractStartDateNew;
        Id queueId;
        //Set<Id> caIDs = new Set<Id>();
        List < Invoices__c > lstInv = new List < Invoices__c > ();
        //Map<Id,Contract__c> caIdwithrecord = new Map<Id,Contract__c>();
        List<Id> cpIDlist = new List<Id>();
        Map<Id,Contract_Payments__c> cpIdwithrecord = new Map<Id,Contract_Payments__c>();
        List<Invoices__c> toinsertInvoice = new List<Invoices__c>();
        
        //try{
        
        list<Contract__c> existingContractList = [SELECT Id,Status__c,Contract_Start_Date__c,Contract_End_Date__c,Billing_Country_Code__c, Contract_Region__c FROM Contract__c where Id =: contId and Status__c != 'Terminated'];
        
        contpayment = [SELECT Id, RecordTypeId, Payment_Frequency__c, Payment_Criteria__c, Amount__c, Contract_Agreement__c, Type__c, CurrencyIsoCode FROM Contract_Payments__c WHERE Contract_Agreement__c =: contId AND (RecordTypeId =: cpciRTId OR RecordTypeId =: cpctfRTId)];
        if (contpayment.size() > 0) {
            for (Contract_Payments__c cp: contpayment) {
                cpids.add(cp.Id);
            }
        }
        
        if(!cpids.isEmpty())
        {
            existingInvoiceList = [SELECT Id,RecordTypeId,Contract_Payments__c,Status__c FROM Invoices__c where Contract_Payments__c IN: cpids AND RecordTypeId =: inapRTId Limit 1];
            system.debug('Existing Cont***'+existingInvoiceList);
            //Validate the contract exists scenario
            if(!existingInvoiceList.isEmpty()){
                for(Invoices__c eachInvoice : existingInvoiceList){
                    if(eachInvoice.Status__c == 'Draft' ){
                        obj.isSuccess = false;
                        obj.msg = 'Invoice exist for this Contract';
                        return obj;
                    }
                }    
            }
        }
        
        if(existingInvoiceList.isEmpty() && !existingContractList.isEmpty()){
            for (Contract__c ca: existingContractList) {
                if (ca.Contract_End_Date__c != null) { 
                    DurationYears = ((((ca.Contract_End_Date__c + 1).YEAR()) * 12 + ((ca.Contract_End_Date__c + 1).MONTH()) -
                                      ((ca.Contract_Start_Date__c.YEAR() * 12) + (ca.Contract_Start_Date__c.MONTH()))) / 12);
                    system.debug('DurationYears@@@@@@@@' + DurationYears);
                    contractStartDate = ca.Contract_Start_Date__c;
                }
                if(ca.Billing_Country_Code__c == Label.Australia_Country_Code){
                    dueDays = Integer.valueOf(Label.Contract_Due_Date_Australia);
                }
                else {
                    dueDays = Integer.valueOf(Label.Contract_Due_Date_Others);
                }
                if(ca.Contract_Region__c != null) {
                    QP_Region_Queue_Mapping__mdt[] metaList = [select id, Queue_Name__c, MasterLabel from QP_Region_Queue_Mapping__mdt where MasterLabel=: ca.Contract_Region__c limit 1];
                    if (!metaList.isEmpty()) {
                        queueId = [select id from Group where Type = 'Queue' AND DeveloperNAME =: metaList[0].Queue_Name__c].id;
                    }
                }
            }
            if (contpayment.size() > 0) {
                for (Contract_Payments__c cp: contpayment) {
                    contractStartDateNew = contractStartDate;
                    if (cp.Payment_Frequency__c != null) {
                        
                        //For Quarterly Payment logic
                        if (cp.Payment_Frequency__c == 'Quarterly') {
                            counter = Integer.valueof(Label.ContractPay_CounterQuarterly);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Quarterly);
                        }
                        //For Yearly Payment logic
                        else if (cp.Payment_Frequency__c == 'Yearly') {
                            counter = Integer.valueof(Label.ContractPay_CounterYealy);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Yearly);
                        }
                        //For HalfYearly Payment logic
                        else if (cp.Payment_Frequency__c == 'Half-Yearly') {
                            counter = Integer.valueof(Label.ContractPay_CounterHalfYear);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Half_Yealy);
                        }
                        
                        IDs = cp.Id;
                        i = DurationYears * counter;
                        //Amtdiv = cp.Amount__c / counter;
                        Amtdiv = cp.Amount__c / i;
                        PayFrequency = cp.Payment_Frequency__c;
                        
                        for (Integer j = 0; j < i; j++) {
                            system.debug('inside for loop');
                            Invoices__c Inv = new Invoices__c();
                            //Inv.Name = 'Not generated yet';
                            Inv.Contract_Payments__c = Ids;
                            Inv.RecordTypeId = inapRTId;
                            if(cp.Type__c == 'Incentive'){
                                Inv.Amount__c = 0;  
                            }
                            else{
                                Inv.Amount__c = Amtdiv;  
                            }    
                            //Integer dueDays = Integer.Valueof(Label.Contract_DueDateDays);
                            Inv.Start_Date__c=contractStartDateNew;
                            Inv.End_Date__c=contractStartDateNew.addmonths(DueDateMonths) - 1;
                            Inv.Payment_Due_Date_System__c = contractStartDateNew.addmonths(DueDateMonths).adddays(dueDays) -1;
                            Inv.Invoice_Reason__c = PayFrequency + ' ' + 'Invoices';
                            Inv.Status__c = 'Draft';
                            Inv.CurrencyIsoCode = cp.CurrencyIsoCode;
                            if(queueId != null){
                                Inv.OwnerId = queueId;
                            }
                            lstInv.add(Inv);
                            system.debug('lstInv**********' + lstInv);
                            //contractStartDateNew = Inv.Payment_Due_Date_System__c.adddays(-dueDays).adddays(1);
                            contractStartDateNew = Inv.End_Date__c.adddays(1);
                        }
                    }  
                }
                
            }
        }
        
        if(lstInv.size()>0)
        {
            try{
                insert lstInv;
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());    
            }
            obj.isSuccess = true;
            obj.msg = 'Invoices generated Successfully';
        }
        else {
            obj.isSuccess = false;
            obj.msg = 'Invoices could not be generated. Please ensure that the contract is not Terminated.';
        }
        return obj;   
    }
    
}