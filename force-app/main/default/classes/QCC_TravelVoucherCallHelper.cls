public class QCC_TravelVoucherCallHelper{
    public static boolean isdecrypted = false;
    public static string checkTravelVoucherNumber(list<Recovery__c> newlist, map<id,Recovery__c> oldmap){
        QCC_Recovery_DGCT_Request_Header__mdt headsConfig = QCC_Recovery_DGCT_Request_Header__mdt.getInstance('DGCT_Header_Attributes'); 
        Id TVRecordTypeId = Schema.SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Travel_Voucher_Recovery').getRecordTypeId();
        // Blob cryptoKey = EncodingUtil.base64Decode(QCC_Recovery_DGCT_AES_Key__mdt.getInstance('TV_Encryption_Key').AES256Key__c);
        List<Qantas_API__c> dgctKeyList = New List<Qantas_API__c>([SELECT Id, Name, Token__c FROM Qantas_API__c WHERE Name = 'TV_Encryption_Key' WITH SYSTEM_MODE]);    
        Blob cryptoKey = !dgctKeyList.isEmpty() ? EncodingUtil.base64Decode(dgctKeyList[0].Token__c) : null;
        
        for(Recovery__c rec : newlist){
            if(!isdecrypted && rec.recordtypeId == TVRecordTypeId && rec.Voucher_Number__c != null 
              && rec.Voucher_Number__c != oldmap.get(rec.id).Voucher_Number__c){
                isdecrypted = true;               
                rec.Voucher_Number__c = decrypt(rec.Voucher_Number__c,cryptoKey);
            }
        }
        return null;
    }

    public static string decrypt(string inputString,Blob cryptoKey){
        Blob input_blob = EncodingUtil.base64Decode(inputString);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, input_blob);            
        return decryptedData.toString();
        
    }

    public static String createRecoveryJson(List<Id> recoveryIds, Date scheduledSentDate) {
        List<Recovery__c> recoveries = [SELECT id,name,CaseNumber__c,Contact_First_Name__c,Contact_LastName__c,
                                        Monetary_Value__c,Voucher_Validity_in_Months__c,Refund_Cost_Centre_Number__c,
                                        Refund_Account_Number__c FROM Recovery__c WHERE Id IN :recoveryIds];

        // Create Header
        QCC_Recovery_DGCT_Request_Header__mdt headsConfig = QCC_Recovery_DGCT_Request_Header__mdt.getInstance('DGCT_Header_Attributes');        
        //Blob cryptoKey = EncodingUtil.base64Decode(QCC_Recovery_DGCT_AES_Key__mdt.getInstance('TV_Encryption_Key').AES256Key__c);
        List<Qantas_API__c> dgctKeyList = New List<Qantas_API__c>([SELECT Id, Name, Token__c FROM Qantas_API__c WHERE Name = 'TV_Encryption_Key' WITH SYSTEM_MODE]);    
        Blob cryptoKey = !dgctKeyList.isEmpty() ? EncodingUtil.base64Decode(dgctKeyList[0].Token__c) : null;
        
        Header header = new Header();
        header.sender_system_name = headsConfig.Sender_System_Name__c;
        header.from_name =  headsConfig.From_Name__c;
        header.business_department =  headsConfig.Business_Department__c;
        header.voucher_template =  headsConfig.Voucher_Template__c;
        header.voucher_message =  headsConfig.Voucher_Message__c;
            
        header.scheduled_sent_date = scheduledSentDate.format();
        
        
        if (recoveries.isEmpty()) {
            return null;
        }
        
        header.account_number = 'A'+ recoveries[0].Refund_Account_Number__c;
        header.cost_centre = 'C'+ recoveries[0].Refund_Cost_Centre_Number__c;

       
        List<RequestDetails> requestDetailsList = new List<RequestDetails>();
        for (Recovery__c recovery : recoveries) {
            RequestDetails requestDetail = new RequestDetails();  
            requestDetail.reference_number = encrypt(recovery.Name,cryptoKey);
                     
            requestDetail.campaign_reference = recovery.CaseNumber__c;
            
            string fName = recovery.Contact_First_Name__c.replaceAll('[^a-zA-Z\\s]', '');
            
            requestDetail.first_name = encrypt(fName,cryptoKey);
            
            string LName = recovery.Contact_LastName__c.replaceAll('[^a-zA-Z\\s]', '');
            
            requestDetail.last_name = encrypt(LName,cryptoKey);
           
            requestDetail.value = String.valueOf((Integer)Math.ceil(recovery.Monetary_Value__c));
            requestDetail.validity_in_months = headsConfig.Voucher_Validity_in_Months__c;
            requestDetail.recipient_mail =  headsConfig.Recipient_Email__c;
            requestDetail.send_to_mail = headsConfig.Send_to_Email__c;   

            requestDetailsList.add(requestDetail);
        }

        
        JsonRequest jsonRequest = new JsonRequest();
        jsonRequest.header = header;
        jsonRequest.request_details = requestDetailsList;

       
        return JSON.serialize(jsonRequest);
    }
    public static string encrypt(string inputString,Blob cryptoKey){
        Blob input_blob = Blob.valueOf(inputString);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, input_blob);            
        return (EncodingUtil.base64Encode(encryptedData));
        
    }
    public static void updateRecoveries(list<id> recordIs,string response , boolean isException,string responsebody){
        list<Recovery__c> tobeUpdatedRecovery = [SELECT id,name,CaseNumber__c,Contact_First_Name__c,Contact_LastName__c,
                                        Monetary_Value__c,Voucher_Validity_in_Months__c,Refund_Cost_Centre_Number__c,
                                        Refund_Account_Number__c,Recovery_System_log__c FROM Recovery__c WHERE Id IN :recordIs];
        for(Recovery__c recov : tobeUpdatedRecovery ){
            if(isException){
                recov.Process_Status__c = 'Exception';
            }else{
                BatchStatus batStatus = (BatchStatus) JSON.deserialize(response, BatchStatus.class);
                if(batStatus.batch_reference != null && batStatus.submit_status_details != null && batStatus.submit_status_details[0].status == 'SUCCESS'){
                    recov.Process_Status__c = 'Submitted for Voucher Issuance ';
                    recov.Batch_Number__c = batStatus.batch_reference;
                    recov.Batch_Date__c = Date.valueof(batStatus.batch_timestamp);  
                    responsebody =  '<span style="color: green;">SUCCESS </span> BatchNumber :'+batStatus.batch_reference+' BatchDate: '+batStatus.batch_timestamp;
                    
                }
                if(batStatus.code != null || (batStatus.submit_status_details != null && batStatus.submit_status_details[0].status == 'FAIL')){
                    recov.Process_Status__c = 'Exception';
                    responsebody =  '<span style="color: red;">FAIL</span> '+batStatus.submit_status_details[0].errorCode+ ' ' +batStatus.submit_status_details[0].message;
                }
               
                
            }
            recov.Recovery_System_log__c = recov.Recovery_System_log__c == null ? '':recov.Recovery_System_log__c ;
            
            recov.Recovery_System_log__c =  '<ul><li>'+DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (DGCT) ' +responsebody + '</li></ul>' + recov.Recovery_System_log__c;
            
        }
        
        RecoveryTriggerHelper.hasRun = true;
        update tobeUpdatedRecovery;
        
    }
    public static Note createNoteForRecord(Id parentId, String noteTitle, String noteBody) {
        Note newNote = new Note();
        newNote.Title = noteTitle;
        newNote.Body = noteBody;
        newNote.ParentId = parentId;
        return newNote;       
    }
    public class Header {
        public String sender_system_name;
        public String from_name;
        public String business_department;
        public String voucher_template;
        public String voucher_message;        
        public String account_number;
        public String cost_centre;
        public String scheduled_sent_date;
    }

    public class RequestDetails {
        public String reference_number;
        public String campaign_reference;
        public String first_name;
        public String last_name;
        public String value;
        public String validity_in_months;
        public String recipient_mail;
        public String send_to_mail;
        
    }

    public class JsonRequest {
        public Header header;
        public List<RequestDetails> request_details;
    }    

    
    public class BatchStatus {
        public String batch_reference { get; set; }
        public String batch_timestamp { get; set; }
        public String code { get; set; }
        public String message { get; set; }
        public String description { get; set; }
        public List<SubmitStatusDetail> submit_status_details { get; set; }
    
    }
     public class SubmitStatusDetail {
        public String referenceNumber { get; set; }
        public String campaign_reference { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        public String errorCode { get; set; }
        
    }
}