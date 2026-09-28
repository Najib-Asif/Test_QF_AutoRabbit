public class QCC_BankSearchCallHelper{
    public static string updateRecoveries(list<id> recordIds,string response , boolean isException,string responsebody){
        
        String query = getallFieldsRecovery(); 
        query += ' FROM Recovery__c WHERE Id IN :recordIds ';
        list<Recovery__c> tobeUpdatedRecovery = Database.query(query);
        for(Recovery__c recov : tobeUpdatedRecovery ){
            if(isException){
                recov.Process_Status__c = 'Exception';
            }else{
                QCC_BankBranchRecordsResponse responseObj = QCC_BankBranchRecordsResponse.parseJSON(response);
                system.debug('responseObj>>>'+responseObj);
                system.debug('recvy>>>'+recov);
                if(responseObj != null && responseObj.P_BANK_BRANCH_RECORDS != null
                  && responseObj.P_BANK_BRANCH_RECORDS.P_BANK_BRANCH_RECORDS_ITEM != null){

                    //Todo:add code here to select bank record with exact swift match if available, else select first record

                      QCC_BankBranchRecordsResponse.P_BANK_BRANCH_RECORDS_ITEM item; // = responseObj.P_BANK_BRANCH_RECORDS.P_BANK_BRANCH_RECORDS_ITEM[0];
                      for(QCC_BankBranchRecordsResponse.P_BANK_BRANCH_RECORDS_ITEM temp : responseObj.P_BANK_BRANCH_RECORDS.P_BANK_BRANCH_RECORDS_ITEM){
                          item = temp;
                          if(temp.EFT_SWIFT_CODE == recov.Branch_Swift_BIC_Code__c){
                              break;
                          }
                      }
                      //system.debug('item>>>'+item != null);
                      if( item.ERROR_CODE != null && item.ERROR_CODE != '' && item.ERROR_CODE != 'EC01' && item.ERROR_CODE != 'EC02'){ 
                          recov.Process_Status__c = 'Exception';
                          responsebody =  '<span style="color: red;">FAIL</span> '+item.ERROR_CODE+ ' ' +item.MESSAGE;
                      }
                      else if ( recov.Cost_Centre_Account_Number__c.contains('EU Regulation') 
                               && item.EFT_SWIFT_CODE == null && recov.Original_Currency_Acronym__c == 'AUD'){// added from CDP2-703
                          recov.Process_Status__c = 'Exception';
                          responsebody =  '<span style="color: red;">FAIL</span> RITM Needed to add Bank Swift code ';
                      }
                      else{
                          recov.Bank_Details_Updated_Date__c = System.now();
                          recov.Branch_Name__c = item.BANK_BRANCH_NAME;
                          recov.Branch_Party_Id__c = item.BRANCH_ID;
                          recov.Branch_Swift_BIC_Code__c = item.EFT_SWIFT_CODE;
                          //CDP2-997 Payment EFT and Recovery reason - EU Compensation
                          //1061 - Reset Skip Exception flag 
                          if(recov.Type__c == 'Payment (EFT)' && recov.Recovery_Reason__c == 'EU Compensation' && !recov.SkipExceptionForEUComp__c){
                            recov.Process_Status__c = 'Exception';
                          } 
                          else if(recov.Process_Status__c != 'Exception')//added 21/8/2024 CDP2-531 to ensure if status already exception due to currency conversion failure, no change allowed
                          {
                              recov.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng');
                          }
                          //1061 - Reset Skip Exception flag 
                          if(recov.SkipExceptionForEUComp__c) {
                            recov.SkipExceptionForEUComp__c = false;
                          }
                          responsebody =  '<span style="color: green;">SUCCESS </span> '+ (item.ERROR_CODE != 'EC01' && item.ERROR_CODE != 'EC02' ? 'Multiple ': '') +'Record found. Updating recovery branch name to '+item.BANK_BRANCH_NAME;
                      }
                    
                }
            }
            recov.Recovery_System_log__c = recov.Recovery_System_log__c == null ? '':recov.Recovery_System_log__c ;
            
            recov.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (BANK SEARCH) ' +responsebody + '</li></ul>' + recov.Recovery_System_log__c;
            
            
        }
        RecoveryTriggerHelper.hasRun = true;
        update tobeUpdatedRecovery;
        return null;
    }
    public static string getallFieldsRecovery(){
        String query = 'SELECT ';        
        List<String> fieldNames = new List<String>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Recovery__c.fields.getMap();
        
        for (String fieldName : fieldsMap.keySet()) {
            fieldNames.add(fieldName);
        }        
        query += String.join(fieldNames, ', ');
        return query;
    }
    public static string preparePayload(list <id> recordIds){
        
        String query = getallFieldsRecovery(); 
        
        query += ' , Case_Number__r.Contact.Salutation, Case_Number__r.Contact.FirstName,Case_Number__r.Contact.LastName FROM Recovery__c WHERE Id IN :recordIds';
        requestJson request = new requestJson();
        request.inputParameters = new InputParameters();
        request.inputParameters.P_BANK_BRANCH_RECORDS = new P_BANK_BRANCH_RECORDS();
        request.inputParameters.P_BANK_BRANCH_RECORDS.P_BANK_BRANCH_RECORDS_ITEM = new List<P_BANK_BRANCH_RECORDS_ITEM>();
        
       
        for (recovery__c record : Database.query(query)) {
            P_BANK_BRANCH_RECORDS_ITEM item = new P_BANK_BRANCH_RECORDS_ITEM();
            item.CLAIM_NO = record.Name;
            item.BANK_COUNTRY = record.Country_Name__c;
            //Changes by Navya CDP2-1018
            if (!((record.type__c =='Payment (EFT)' || record.type__c =='Ticket Refund EFT' ) && 
                (record.Original_Currency__c =='AUD Australian Dollar' || record.Original_Currency__c == 'NZD New Zealand Dollar') ) && 
                record.payment_Details_added_manually__c ){
                   item.BANK_NAME = record.Bank_Name__c;
             }
            item.BANK_BRANCH_NAME = record.Branch_Name__c;
            item.BRANCH_NUMBER = record.Branch_Number_BSB_Sort_Code__c;
            item.EFT_SWIFT_CODE = record.Branch_Swift_BIC_Code__c;

            // Add the item to the list
            request.inputParameters.P_BANK_BRANCH_RECORDS.P_BANK_BRANCH_RECORDS_ITEM.add(item);
        }
        
        return JSON.serialize(request);        
    }
    public class requestJson{
        public InputParameters InputParameters;
    }

    public class InputParameters {
        public P_BANK_BRANCH_RECORDS P_BANK_BRANCH_RECORDS;
    }

    public class P_BANK_BRANCH_RECORDS {
        public List<P_BANK_BRANCH_RECORDS_ITEM> P_BANK_BRANCH_RECORDS_ITEM;
    }

    public class P_BANK_BRANCH_RECORDS_ITEM {
        public String CLAIM_NO;
        public String BANK_COUNTRY;
        public String BANK_NAME;
        public String BANK_BRANCH_NAME;
        public String BRANCH_NUMBER;
        public String BRANCH_ID;
        public String EFT_SWIFT_CODE;
    }
    // Example usage:
    //String jsonString = '{ "InputParameters": { "P_BANK_BRANCH_RECORDS": { "P_BANK_BRANCH_RECORDS_ITEM": [ { "CLAIM_NO": "TEST_01", "BANK_COUNTRY": "XXX", "BANK_NAME": "Citi", "BANK_BRANCH_NAME": "C", "BRANCH_NUMBER": "600037002", "EFT_SWIFT_CODE": "" } ] } } }';
    //BankBranchRecords bankBranchRecords = BankBranchRecords.parse(jsonString);
    //System.debug(bankBranchRecords);
}