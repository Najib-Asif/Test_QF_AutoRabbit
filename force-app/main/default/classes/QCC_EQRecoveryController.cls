/*----------------------------------------------------------------------------------------------------------------------
Author:        Swetha
Company:       Qantas
Description:   Retrieve Recovery records and send to EQ system
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
17-Jun-2024      Swetha              Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
//this could be invocable method - from scheduled flow
public without sharing class QCC_EQRecoveryController {
    
    public static QCC_Recovery_EFT_Request_Header__mdt EQ_Defaults = QCC_Recovery_EFT_Request_Header__mdt.getInstance('EFT_Configurations');
    public static Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));

    //1K, 5K, 7K, 11K, maxRecviesAllowed 3
    public static void processEFTBatchRecords(){
        List<List<Recovery__c>> recvyBatchList = new List<List<Recovery__c>>();
        List<Recovery__c> recvyList = new List<Recovery__c>();
        Decimal recvyTotal = 0.00;

        //Retrieve Recovery recs
        for(Recovery__c recvy: [Select Id, Name, type__c, Original_Currency__c, Invoice_Claim_Description__c, payment_Details_added_manually__c, Original_Currency_Acronym__c, Value__c,Recovery_Reason__c,
                                Monetary_Value__c, Refund_Cost_Centre_Number__c, Refund_Account_Number__c, Case_Number__r.Contact.Salutation, Country_Code__c,
                                Case_Number__r.First_Name__c,  Case_Number__r.Last_Name__c, Case_Number__r.Contact.FirstName, Case_Number__r.Contact.LastName, Bank_Name__c, Branch_Name__c, Branch_Number_BSB_Sort_Code__c,
                                Branch_Swift_BIC_Code__c, Branch_Party_Id__c, Bank_Account_Name__c, Bank_Account_Number__c, IBAN__c, TAX_Id_VAT_Reg_No__c,
                                Account_Type__c from Recovery__c where  Process_Status__c =: CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng') and 
                                RecordTypeId =: recvyEFTRecTypeId order by Value__c, Name asc]){

            system.debug('recvyTotal.....'+recvyTotal);
            system.debug('recvy Name.....'+recvy.Name);
            //If one recvy value is greater than or equal to 9900 add directly to batch list
            //CDP2-1244 fix changed from 10000 to 9900
            if(recvy.Value__c > = EQ_Defaults.MaxRecvyTotal__c) {
                system.debug('updating batch list - >= 10K'+recvyBatchList.Size());
                recvyBatchList.add(new List<Recovery__c>{recvy.clone(true, true, true, true)});
            } else {
                recvyTotal += recvy.Value__c;
                //If recyTotal is less than 10000 and not reached configured # of Recoveries per batch
                //Add to temporary list
                if(recvyList.Size() != EQ_Defaults.MaxNoOfRcvyInReq__c && recvyTotal <= EQ_Defaults.MaxRecvyTotal__c){
                    system.debug('updating recvylist - less than 10k and not max reached...'+recvyList.Size());
                    recvyList.add(recvy);
                } else{ //Reached configured limits
                    if(recvyList.Size() > 0 ) {
                        recvyBatchList.add(recvyList.deepClone(true, true, true));
                        system.debug('Initiate new list');
                        //Clear Lists, Total
                        recvyList.clear(); 
                        recvyTotal = 0.00;
                        //Initiate new list
                        recvyList.add(recvy);
                        recvyTotal += recvy.Value__c;
                    }
                }
            }
        }
        //Anything unprocessed lists
        if(recvyList.Size() > 0){
            system.debug('updating recvylist - Left overs');
            recvyBatchList.add(recvyList.deepClone(true, true, true));
        }
        
        system.debug('FINAL BATCH LST.....'+recvyBatchList);
        system.debug('FINAL BATCH LST size.....'+recvyBatchList.Size());
       
        if(recvyBatchList.size() > 0){
            System.enqueueJob(new QCC_EQCalloutsQueuable(recvyBatchList));
        }
    }
}