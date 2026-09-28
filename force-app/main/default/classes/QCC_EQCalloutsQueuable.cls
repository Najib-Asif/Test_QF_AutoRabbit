/*----------------------------------------------------------------------------------------------------------------------
Author:        Swetha
Company:       Qantas
Description:   Send Recovery for Payment Processing to EQ System - Queueable
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
17-Jun-2024      Swetha              Initial Design
18-Nov-2024      Sourabh             updated CDP2-1006
-----------------------------------------------------------------------------------------------------------------------*/

public class QCC_EQCalloutsQueuable implements Queueable, Database.AllowsCallouts{
    public List<List<Recovery__c>> listofRecvyLists;
    public List<Recovery__c> recvyList;
    public QCC_EQCalloutsQueuable(List<List<Recovery__c>> recvyLists) {
        this.listofRecvyLists = recvyLists;
        this.recvyList = this.listofRecvyLists[0];
    }

    public void execute(QueueableContext context) {
        try {
            QCC_EQRequestWrapper requestEQ;
            //prepare json
            requestEQ = preparePayload(recvyList);

            //do callouts - separate class for callout
            QCC_InvokeEQAPI.invokeProcessRecoveries(requestEQ);
            /*To be deleted after testing*/
            String serialedLoad = JSON.serialize(requestEQ);
            List<Note> noteList = new List<Note>();
            for(Recovery__c recvy: recvyList){
                Note n = new Note(Title='EQ Request Paylaod', Body = serialedLoad, ParentId = recvy.Id);
                noteList.add(n);
            }
            insert noteList;
            /*To be deleted after testing*/
            listofRecvyLists.remove(0);
            if(listofRecvyLists != null && listofRecvyLists.size() > 0) {
                System.enqueueJob(new QCC_EQCalloutsQueuable(listofRecvyLists));
            }
        } catch (Exception ex) {
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - EFT Batch Processing', 'QCC_EQCalloutsQueuable',
			                         'execute', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
    }

    public static QCC_EQRequestWrapper preparePayload(List<Recovery__c> recveryList){
        QCC_EQRequestWrapper reqWrapper = new QCC_EQRequestWrapper();
        QCC_EQRequestWrapper.InputParameters reqInpParams = new QCC_EQRequestWrapper.InputParameters();

        //Construct Header
        QCC_EQRequestWrapper.P_CC_CLAIM_HEADER reqHeader = new QCC_EQRequestWrapper.P_CC_CLAIM_HEADER();
        QCC_Recovery_EFT_Request_Header__mdt EQ_Header = QCC_Recovery_EFT_Request_Header__mdt.getInstance('EFT_Header_Attributes');
        reqHeader.SITE_NAME = EQ_Header.Customer_Care_Site_Name__c;
        reqHeader.ADDRESS1 = EQ_Header.Address_Line_1__c;
        reqHeader.ADDRESS2 = EQ_Header.Address_Line_2__c;
        reqHeader.ADDRESS3 = EQ_Header.Address_Line_3__c; //required? blank at the moment
        reqHeader.CITY = EQ_Header.City__c;
        reqHeader.STATE = EQ_Header.State__c;
        reqHeader.ZIP_CODE = EQ_Header.ZIP_Postal_Code__c;
        reqHeader.COUNTRY = EQ_Header.Country__c;
        reqHeader.EMAIL = string.valueof(EQ_Header.Customer_Care_Shared_Mail__c);
        reqHeader.PHONE_EXT = string.valueof(EQ_Header.Uploader_Phone_No__c);
        reqHeader.PREPARED_BY = EQ_Header.Prepared_By__c;
        reqHeader.UNIQUE_SOURCE_CALL_SEQ = string.valueof(Datetime.now()).replaceAll('[^\\w]',''); //20240619101012

        //Construct Claim Lines Item 
        QCC_EQRequestWrapper.P_CC_CLAIM_LINES clis = new QCC_EQRequestWrapper.P_CC_CLAIM_LINES();
        List<QCC_EQRequestWrapper.P_CC_CLAIM_LINES_ITEM> lstOfClisItem = new List<QCC_EQRequestWrapper.P_CC_CLAIM_LINES_ITEM>();
        for(Recovery__c recvy : recveryList){
            QCC_EQRequestWrapper.P_CC_CLAIM_LINES_ITEM clisItem = new QCC_EQRequestWrapper.P_CC_CLAIM_LINES_ITEM();
            clisItem.ACCOUNT_TYPE = recvy.Account_Type__c;
            clisItem.BANK_ACC_NUM = recvy.Bank_Account_Number__c;
            clisItem.TITLE = recvy.Case_Number__r.Contact.Salutation;
            clisItem.FIRST_NAME = recvy.Case_Number__r.First_Name__c; //updated CDP2-1006
            clisItem.LAST_NAME = recvy.Case_Number__r.Last_Name__c;   //updated CDP2-1006
            clisItem.BANK_ACC_NAME = recvy.Bank_Account_Name__c;
            //Changes by Navya CDP2-1018
            if (!((recvy.type__c =='Payment (EFT)' || recvy.type__c =='Ticket Refund EFT' ) && 
                    (recvy.Original_Currency__c =='AUD Australian Dollar' || recvy.Original_Currency__c == 'NZD New Zealand Dollar') ) && 
                    recvy.payment_Details_added_manually__c ){
                clisItem.BANK_NAME = recvy.Bank_Name__c;
             }
            
            clisItem.BRANCH_NAME = recvy.Branch_Name__c;
            clisItem.BRANCH_NUMBER = recvy.Branch_Number_BSB_Sort_Code__c;
            clisItem.BRANCH_PARTY_ID = (recvy.Branch_Party_Id__c != Null)? Integer.valueof(recvy.Branch_Party_Id__c) : Null;
            clisItem.GL_ACCOUNT = recvy.Refund_Account_Number__c;
            clisItem.GL_COST_CENTRE = recvy.Refund_Cost_Centre_Number__c;
            clisItem.BANK_COUNTRY = recvy.Country_Code__c;
            clisItem.AMOUNT = (recvy.Monetary_Value__c != Null)? string.valueof((recvy.Monetary_Value__c).setScale(2)) : Null;
            clisItem.SWIFT_CODE = recvy.Branch_Swift_BIC_Code__c;
            clisItem.CLAIM_NO = recvy.Name;
            clisItem.TAX_ID = recvy.TAX_Id_VAT_Reg_No__c;
            clisItem.EQCURRENCY = recvy.Original_Currency_Acronym__c; 
            clisItem.IBAN = recvy.IBAN__c;
            clisItem.INVOICE_DESCRIPTION = (recvy.Recovery_Reason__c != null ? recvy.Recovery_Reason__c.split(';')[0] : '' ); // CDP2-618 change the recvy.Invoice_Claim_Description__c field to Recovery_Reason__c
            lstOfClisItem.add(clisItem);
        }
        clis.P_CC_CLAIM_LINES_ITEM = lstOfClisItem;
        reqInpParams.P_CC_CLAIM_HEADER = reqHeader;
        reqInpParams.P_CC_CLAIM_LINES = clis;
        reqWrapper.InputParameters = reqInpParams;
        return reqWrapper ;//JSON.serialize(reqWrapper).replaceAll('"EQCURRENCY":','"CURRENCY":');
    }

}