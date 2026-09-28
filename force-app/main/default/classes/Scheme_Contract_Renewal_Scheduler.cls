/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   Schedular Class to Remap the new Contract when old Contract expies
Inputs:        
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
global class Scheme_Contract_Renewal_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query;
        query = 'select Id, PreviousContract__c, Type__c,  Contract_Start_Date__c, Contract_End_Date__c, Account__c  from Contract__c';
        query += ' where Contract_End_Date__c = YESTERDAY  and Status__c = \'Signed by Customer\'';
        CorporateScheme_Contract_Renewal_Batch corpRenewal = new CorporateScheme_Contract_Renewal_Batch(query);
        database.executebatch(corpRenewal);
    }
}