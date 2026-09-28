/*
* MOdified By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to add Record Type on Contract Payments & Payments object for Qantas Payments
Test Class:     ContractPaymentHandlerTest
************************************************************************************************
    History
************************************************************************************************
 09-Oct-2019      Jay                 paymentContractTerminationMethod
************************************************************************************************
*/

public class ContractPaymentHandler 
{
    public static boolean firstRun = true;
    
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
    //public static Id invRTIdNew = Schema.SObjectType.Invoices__c.getRecordTypeInfosByDeveloperName().get('New_Corporate_Payments').getRecordTypeId();
    public static String[] paymentsRTName = new String[]{'New_Corporate_Payments', 'Approved_Corporate_Payments'};
    public static List<Id> pRTIds = getObjectRecordTypeId('Invoices__c',paymentsRTName);
    
    public static String[] contractPaymentsRTName = new String[]{'Corporate_Contract_Payments'};
    public static List<Id> cPRTIdList = getObjectRecordTypeId('Contract_Payments__c',contractPaymentsRTName);

    public static List<Id> getObjectRecordTypeId(String objectName, String[] recTypeName) {
        // Convert to schema.sObjectType
        system.debug('rec type name**'+recTypeName);
        List<Id> recTypeIds = new List<Id>();
        //Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName); 
        Schema.SObjectType convertType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = convertType.getDescribe().getRecordTypeInfosByDeveloperName();
        if(!recordTypeInfos.isEmpty())
        {
            for(String eachRecName : recTypeName){
                recTypeIds.add(recordTypeInfos.get(eachRecName).getRecordTypeId());
            }    
        }
        return recTypeIds;
    }
    // Ajay : ended
    
    public static void ContracPaytMethod(List < Contract__c > newList, Map < Id, Contract__c > oldMap) {
        try {
            List < Invoices__c > lstInv = new List < Invoices__c > ();
            Map < String, Integer > CounterMap = new Map < String, Integer > ();
            Map < String, Id > MasterIds = New Map < String, Id > ();
            String IDs = '';
            Integer DurationYears;
            Decimal Amtdiv;
            Decimal SignOnAmt;
            Integer counter;
            Boolean SignOnFlag;
            Integer DueDateMonths;
            Date contractStartDate;
            Date contractStartDateNew;
            Date contractStartDateSignOn;
            String PayFrequency = '';
            List < string > Paymentfrequency = New List < String > ();
            List < string > ContractDuration = New List < string > ();
            system.debug('newList*********' + newList);
            Integer i = 0;
            List < Contract_Payments__c > conPay = new List < Contract_Payments__c > ();
            Set < ID > contractID = new Set < ID > ();
            for (Contract__c crt: newList) {
                contractID.add(crt.Proposal__c);
            }
            System.debug('contractID$$$$$$$$$$$$' + contractID);
            System.debug('newList$$$$$$$$$$$$' + newList);
            System.debug('pay RT Ids** '+pRTIds);
            
            // Ajay : added for JIRA : AE - 82
            conPay = [SELECT Id, Payment_Frequency__c, Payment_Criteria__c, Amount__c FROM Contract_Payments__c WHERE Proposal__c IN: contractID AND RecordTypeId =: cpRTId];
            // Ajay : ended
            
            System.debug('conPay @@@@@@@@@@@@' + conPay);
            for (Contract__c Prop: newList) {
                System.debug('Insde for lop^^^^^^^^^');
                if (Prop.Contract_End_Date__c != null) {
                    //Claculating number of years between Contract Start Date and Contract End Date
                    DurationYears = ((((Prop.Contract_End_Date__c + 1).YEAR()) * 12 + ((Prop.Contract_End_Date__c + 1).MONTH()) -
                                      ((Prop.Contract_Start_Date__c.YEAR() * 12) + (Prop.Contract_Start_Date__c.MONTH()))) / 12);
                    
                    system.debug('DurationYears@@@@@@@@' + DurationYears);
                    contractStartDate = Prop.Contract_Start_Date__c;
                    contractStartDateSignOn = Prop.Contract_Start_Date__c;
                }
            }
            if (conPay.size() > 0) {
                for (Contract_Payments__c Prop: conPay) {
                    contractStartDateNew = contractStartDate;
                    if (Prop.Payment_Frequency__c != null) {
                        
                        //Claculating number of years between Contract Start Date and Contract End Date
                        
                        //For Quarterly Payment logic
                        if (Prop.Payment_Frequency__c == 'Quarterly') {
                            counter = Integer.valueof(Label.ContractPay_CounterQuarterly);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Quarterly);
                        }
                        //For Yearly Payment logic
                        else if (Prop.Payment_Frequency__c == 'Yearly') {
                            counter = Integer.valueof(Label.ContractPay_CounterYealy);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Yearly);
                        }
                        //For HalfYearly Payment logic
                        else if (Prop.Payment_Frequency__c == 'Half-Yearly') {
                            counter = Integer.valueof(Label.ContractPay_CounterHalfYear);
                            DueDateMonths = Integer.valueof(Label.ContractPay_Half_Yealy);
                        }
                        
                        IDs = Prop.Id;
                        i = DurationYears * counter;
                        // i =  counter;
                        system.debug('i###########' + i);
                        // Amtdiv = Prop.Amount__c / i;
                        Amtdiv = Prop.Amount__c / counter;
                        
                        system.debug('Ids********' + Ids);
                        PayFrequency = Prop.Payment_Frequency__c;
                        system.debug('PaymentFrequency********' + PaymentFrequency);
                        
                        // Logic for creating Invoicess
                        for (Integer j = 0; j < i; j++) {
                            system.debug('inside for loop');
                            Invoices__c Inv = new Invoices__c();
                            //Inv.Name = 'Not generated yet';
                            Inv.Contract_Payments__c = Ids;
                            Inv.RecordTypeId = pRTIds[0];
                            Inv.Amount__c = Amtdiv;
                            Integer dueDays = Integer.Valueof(Label.Contract_DueDateDays);
                            Inv.Start_Date__c=contractStartDateNew;
                            Inv.End_Date__c=contractStartDateNew.addmonths(DueDateMonths) - 1;
                            Inv.Payment_Due_Date_System__c = contractStartDateNew.addmonths(DueDateMonths).adddays(dueDays);
                            Inv.Invoice_Reason__c = PayFrequency + ' ' + 'Invoices';
                            Inv.Status__c = 'Draft';    
                            lstInv.add(Inv);
                            system.debug('lstInv**********' + lstInv);
                            contractStartDateNew = Inv.Payment_Due_Date_System__c.adddays(-dueDays);
                        }
                    }
                }
            }
            
            insert lstInv;
        } catch (Exception e) {
            System.debug('Error Occured From Proposal Trigger: ' + e.getMessage());
        }
    }
    public static void SignOnMethod(List < Contract__c > newList, Map < Id, Contract__c > oldMap) {
        try {
            List < Invoices__c > lstnewInv = new List < Invoices__c > ();
            List < Contract_Payments__c > conPay = new List < Contract_Payments__c > ();
            Set < ID > contractID = new Set < ID > ();
            Set < ID > conPayID = new Set < ID > ();
            for (Contract__c crt: newList) {
                contractID.add(crt.Proposal__c);
            }
            System.debug('contractID$$$$$$$$$$$$' + contractID);
            System.debug('newList$$$$$$$$$$$$' + newList);
            
            // Ajay : added for JIRA : AE - 82
            conPay = [SELECT Id,Payment_Criteria__c, Amount__c,Type__c FROM Contract_Payments__c 
                      WHERE Proposal__c IN: contractID 
                      AND RecordTypeId =: cpRTId 
                      AND Type__c IN('Sign-On Bonus','One-Off Payment')];
            // Ajay : ended
            System.debug('conPay @@@@@@@@@@@@' + conPay);
            
            
            for (Contract__c Prop: newList) {
                if (Prop.Status__c == 'Signed by Customer' && oldMap.get(Prop.Id).Status__c == 'Signature Required by Customer') {
                    
                    // Logic for creating Sign-On Invoicess
                    if (conPay.size() > 0) {
                        for (Contract_Payments__c cp: conPay) {
                            system.debug('inside SignOn loop');
                            Invoices__c Inv1 = new Invoices__c();
                            // Inv1.Name = 'Not generated yet';
                            Inv1.Contract_Payments__c = cp.id;
                            Inv1.RecordTypeId = pRTIds[0];
                            Inv1.Amount__c = cp.Amount__c;
                            Integer dueDays = Integer.valueof(Label.ContractPay_DueDaysSignOn);
                            Inv1.Payment_Due_Date_System__c = system.Today().adddays(dueDays);
                            if(cp.Type__c=='Sign-On Bonus')
                                Inv1.Invoice_Reason__c = 'Sign-On Invoices';
                            else if (cp.Type__c=='One-Off Payment')
                                Inv1.Invoice_Reason__c = 'One-Off Payment Invoices';
                            Inv1.Status__c = 'Draft';       
                            lstnewInv.add(Inv1);
                            system.debug('lstnewInv**********' + lstnewInv);
                        }
                    }
                    
                }
            }
            if (lstnewInv.size() > 0)
                insert lstnewInv;
        } catch (Exception e) {
            System.debug('Error Occured From Proposal Trigger: ' + e.getMessage());
        }
    }
    public static void handleContractTermination(List < Contract__c > newList, Map < Id, Contract__c > oldMap) {
        Set < ID > contractID = new Set < ID > ();
        List < Contract_Payments__c > conPay = new List < Contract_Payments__c > ();
        List < Invoices__c > lstnewInv = new List < Invoices__c > ();
        List < Invoices__c > ToUpdInv = new List < Invoices__c > ();
        List < Contract_Payments__c > contPay = new List < Contract_Payments__c > ();
        try {
            for (Contract__c cn: newList) {
                if (cn.Contract_End_Date__c != oldMap.get(cn.Id).Contract_End_Date__c) {
                    contractID.add(cn.Id);
                    system.debug('contractID%%%%%%%%%%' + contractID);
                }
            }
            
            // Ajay : added for JIRA : AE - 82
            lstnewInv = [SELECT Name, Id, Status__c, Contract_Termination_Date_System__c, RecordTypeId, Payment_Due_Date_System__c FROM Invoices__c 
                         WHERE Contract_Payments__r.Contract_Agreement__c IN: contractID 
                         AND RecordTypeId IN: pRTIds
                         AND Contract_Payments__r.RecordTypeId =: cPRTIdList];
            // Ajay : ended
            
            system.debug('lstnewInv ************' + lstnewInv);
            if (lstnewInv.size() > 0) {
                for (Invoices__c Inv: lstnewInv) {
                    if (Inv.Contract_Termination_Date_System__c < Inv.Payment_Due_Date_System__c) {
                        Inv.Status__c = 'Void';
                        ToUpdInv.add(Inv);
                        system.debug('ToUpdInv&&&&&&&&&&&' + ToUpdInv);
                    }
                }
            }
            if (ToUpdInv.size() > 0)
                update ToUpdInv;
        } catch (Exception e) {
            System.debug('Error Occured From Contract Trigger: ' + e.getMessage());
        }
    }
    
        //Qantas Channel Payment Contract Termination Invoices method
    
    public static void paymentContractTerminationMethod(List < Contract__c > newList, Map < Id, Contract__c > oldMap){
        Set < ID > contractID = new Set < ID > ();
        List < Contract_Payments__c > conPay = new List < Contract_Payments__c > ();
        List < Invoices__c > lstnewInv = new List < Invoices__c > ();
        List < Invoices__c > ToUpdInv = new List < Invoices__c > ();
        List < Contract_Payments__c > contPay = new List < Contract_Payments__c > ();
        try {
            String[] paymentRTName = new String[]{'Agency_Payments'};
                List<Id> paymentRTIds = getObjectRecordTypeId('Invoices__c',paymentRTName);
            
            String[] contpaymentsRTName = new String[]{'Channel_Incentive','Channel_Tech_Fund'};
                List<Id> contpaymentsRTIdList = getObjectRecordTypeId('Contract_Payments__c',contpaymentsRTName);
            
            Id contractRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
            for (Contract__c cn: newList) {
                if (cn.Contract_End_Date__c != oldMap.get(cn.Id).Contract_End_Date__c && cn.RecordTypeId == contractRTId && cn.Status__c =='Terminated') {
                    contractID.add(cn.Id);
                    system.debug('contractID%%%%%%%%%%' + contractID);
                }
            }
            
            if (contractID.size() > 0) {
                lstnewInv = [SELECT Name, Id, Status__c, Contract_Termination_Date_System__c, Payment_Due_Date_System__c, Start_Date__c, End_Date__c FROM Invoices__c 
                             WHERE Contract_Payments__r.Contract_Agreement__c IN: contractID 
                             AND RecordTypeId IN: paymentRTIds
                             AND Contract_Payments__r.RecordTypeId IN: contpaymentsRTIdList];
            }
            
            system.debug('lstnewInv ************' + lstnewInv);
            if (lstnewInv.size() > 0) {
                for (Invoices__c Inv: lstnewInv) {
                    if (Inv.Contract_Termination_Date_System__c >= Inv.Start_Date__c && Inv.Contract_Termination_Date_System__c <= Inv.End_Date__c) {
                        Inv.End_Date__c = Inv.Contract_Termination_Date_System__c;
                        Inv.Contract_Terminated__c = true;
                        ToUpdInv.add(Inv);
                        system.debug('ToUpdInv&&&&&&&&&&&' + ToUpdInv);
                    }
                    else if (Inv.Start_Date__c > Inv.Contract_Termination_Date_System__c)
                    {
                        Inv.Status__c = 'Void';
                        Inv.End_Date__c = Inv.Contract_Termination_Date_System__c; 
                        Inv.Contract_Terminated__c = true;
                        ToUpdInv.add(Inv);
                    }
                }
            }
            if (ToUpdInv.size() > 0) {
                update ToUpdInv;
            }
        } catch (Exception e) {
            System.debug('Error Occured From Contract Trigger: ' + e.getMessage());
        }
        
    }
}