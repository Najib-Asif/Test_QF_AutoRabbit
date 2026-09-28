/*----------------------------------------------------------------------------------------------------------------------
Author: Praveen Sampath 
Company: Capgemini  
Purpose: When Custom setting is Updated to ypdate  QCD, GDS and key ContactID
Date:    19-Dec-2016
************************************************************************************************
History
************************************************************************************************
19-Dec-2016    Praveen Sampath              Initial Design           
-----------------------------------------------------------------------------------------------------------------------*/
global class QBDOfficeId_PR_Daily_Update_Batch implements Database.Batchable<sObject> {
    
    String  query;
            
    global QBDOfficeId_PR_Daily_Update_Batch(Boolean cSetting){
        query = 'Select Id,Key_Contact_Office_ID__c , Account__c,Active__c, Account__r.QBD__c, RecordType.Name, Account__r.Aquire_Blocking_Classification__c, GDS_QBR_Discount_Code__c, Qantas_Club_Discount_Code__c, ';
        query += ' Account__r.Airline_Level__c,Account__r.Active__c,Account__r.Aquire_Eligibility_f__c, Account__r.Aquire_System__c from  Product_Registration__c where';
        query += ' (RecordType.Name=\'QBD Registration\' or RecordType.Name=\'Aquire Registration\') and (Stage_Status__c =\'Active\' or Active__c = true)';  
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Query is : '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<Product_Registration__c> lstProductReg){
    
        List<Product_Registration__c> updatePR = new List<Product_Registration__c>();        
        for(Product_Registration__c productReg: lstProductReg){
            Account acc = productReg.Account__r;
            updatePR.add(AccountAirlineLevelHandler.productRegMapping(acc, productReg));
        }
        
        try{
            // Update Product Registration List
            if(updatePR.size() > 0) Database.Update(updatePR);

        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext ctx){
         
    }   

}