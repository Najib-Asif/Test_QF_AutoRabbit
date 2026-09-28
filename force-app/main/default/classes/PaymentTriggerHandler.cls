/*----------------------------------------------------------------------------------------------------------------------
    Author:        Jay
    Company:       TCS
    Description:   To restrict sales performance manager action on future invoice (Channel Payment)
    Inputs:
    Test Class:    PaymentTriggerHandlerTest
    ************************************************************************************************
    History
    ************************************************************************************************
    09-Oct-2019      Jay                        futureInvoiceRestrictionMethod
-----------------------------------------------------------------------------------------------------------------------*/

public class PaymentTriggerHandler
{
    
    public static void futureInvoiceRestrictionMethod(List < Invoices__c > newList, Map < Id, Invoices__c > oldMap){
        try{
            Set < ID > cpaymentID = new Set < ID > ();
            Map<Id,Invoices__c>  paymentIdwithRecord = new Map<Id,Invoices__c>();
            Map<Id,Contract__c>  paymentIdwithContractRecord = new Map<Id,Contract__c>();
            List < Invoices__c > lstnewInv = new List < Invoices__c > ();
            Id paymentRTId = Schema.SObjectType.Invoices__c.getRecordTypeInfosByDeveloperName().get('Agency_Payments').getRecordTypeId();
            
            for (Invoices__c py: newList) {
                
                if (py.Id == oldMap.get(py.Id).Id && py.RecordTypeId == paymentRTId && py.Contract_Terminated__c != true) {
                    cpaymentID.add(py.Contract_Payments__c);
                    paymentIdwithRecord.Put(py.Contract_Payments__c, py);
                    system.debug('contractID%%%%%%%%%%' + cpaymentID);
                    system.debug('contractID%%%%%%%%%%1' + paymentIdwithContractRecord);
                }
            }
            
            if(cpaymentID.size() >0){
                lstnewInv = [SELECT Name, Id, Status__c, Start_Date__c,Contract_Payments__c, Contract_Termination_Date_System__c, Payment_Due_Date_System__c FROM Invoices__c 
                             WHERE Contract_Payments__r.Id IN: cpaymentID
                             AND Status__c ='Draft'
                             //AND Start_Date__c < 
                            ];   
            }
            
            if (lstnewInv.size() > 0) {
                for (Invoices__c Inv: lstnewInv) {                
                    if (Inv.Start_Date__c<paymentIdwithRecord.get(Inv.Contract_Payments__c).Start_Date__c ) {
                        Invoices__c i = paymentIdwithRecord.get(Inv.Contract_Payments__c);
                        i.addError('You cannot save this Invoice since previous invoice is not yet submitted for Approval', false);
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QC Agency future Invoice Restriction Payment Trigger', 'PaymentTriggerHandler', 
                                    'futureInvoiceRestrictionMethod', String.valueOf(''), String.valueOf(''),false,'', ex);   
            
        } 
    }
    
}