/**********************************************************************************************************************************

Created Date    : 10/09/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Batch job for TMC GDs Status Update to Rejected if it is Validating.
JIRA            : CRM - 3908
Version         : V1.0 - 10/09/19 - Initial version

**********************************************************************************************************************************/


global class QC_GDSStatusBatch implements Database.Batchable<sObject> 
{

    String tmcGDSRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
    String accAgencyRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    Database.SaveResult[] srListInsert = new Database.SaveResult[0];	
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([SELECT Id, GDS_Status__c, GDS_Status_Change_Date__c FROM Agency_Info__c where GDS_Status__c = 'Validating' AND RecordTypeId =: tmcGDSRTId AND Account__r.RecordTypeId =: accAgencyRTId]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Agency_Info__c> tmcInfo )
    {
        QC_TMC_GDS_Status__mdt tmcGDSStatus = [Select DeveloperName, Days_from_Validating_GDS_Status__c from QC_TMC_GDS_Status__mdt where Days_from_Validating_GDS_Status__c != NULL AND DeveloperName = 'QC_GDS_Status'];
        Decimal gdsStatusdays =  tmcGDSStatus.Days_from_Validating_GDS_Status__c;
        Integer gdsValidatingdays = gdsStatusdays.intValue();
        Date gdsValidatingdate = system.today().addDays(-gdsValidatingdays);
        
        List<Agency_Info__c> agencyRec = new List<Agency_Info__c>();
        List<Id> lstRecId = new List<Id>();
        
        for(Agency_Info__c gdsStatusValidate : tmcInfo){
             System.debug('GDS Status Validate :'+gdsStatusValidate);
            if(gdsStatusValidate.GDS_Status_Change_Date__c <= gdsValidatingdate){
                gdsStatusValidate.GDS_Status__c = 'Rejected';
                agencyRec.add(gdsStatusValidate);
            }
        }
        
        if(!agencyRec.isEmpty()) srListInsert = Database.Update(agencyRec, false);
    }
    
    global void finish(Database.BatchableContext ctx){
        
    }
}