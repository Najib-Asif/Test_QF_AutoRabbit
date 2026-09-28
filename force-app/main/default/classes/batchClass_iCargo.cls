/*Jira-> CRM-8510 CLONE - (iCargo) AWB Refresh - batch AWB-Refresh at EOD
Description-> This batch will pull the case records with AWB# and update the latest icargo values from ICargo System. 
Creation Date-> Sep 2024
*/
 
global class batchClass_iCargo implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query;
        String foldername='Qantas_Freight';
        Integer num_days = Integer.valueOf(System.Label.AWB_Refresh_Days);
        query='SELECT Id, AWB__r.Name, Case__c , AWB__r.Freight_Weight__c,AWB__r.Booking_Status__c, AWB__r.Freight_AWB_Pieces__c, AWB__r.Latest_Status__c, AWB__r.Freight_AWB_Handling_Code__c,  AWB__r.Freight_Origin__c,  AWB__r.Freight_Destination__c, AWB__r.Freight_AWB_Shipment_Description__c, AWB__r.Freight_AWB_Weight_Unit__c, AWB__r.Freight_AWB_Unit_Type__c, AWB__r.Product__c, AWB__r.Freight_Port__c, AWB__r.Flight_Arrival__c, AWB__r.Pieces_for_Collection__c, AWB__r.Pieces_Arrived__c, AWB__r.Ready_for_Collection__c, AWB__r.Port_Override_Flag__c from AWB_Relationship__c where Case__r.CreatedDate =LAST_N_DAYS:'+num_days ;  
        System.debug('query**'+query);
        //Existing 
        //query=' SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c,Product__c,Freight_Port__c,Flight_Arrival__c,Pieces_for_Collection__c,Pieces_Arrived__c,Ready_for_Collection__c,Override_Flag__c from Case where Freight_AWB_Number__c!=null  and RecordType.DeveloperName=\''+foldername+'\'  and CreatedDate =LAST_N_DAYS:'+num_days ;  
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<AWB_Relationship__c> newAWBMap) 
    {
        try{
            for (AWB_Relationship__c AWBRecord : newAWBMap) {
                System.debug('CaseRecord***'+AWB_Relationship__c.Id);
                FreightAWBPopUpController.getRecordUpdate(AWBRecord.Case__c);
                System.debug('Finish CaseRecord***'+AWB_Relationship__c.Id);
            }
            /*existing logic for case record
            for (Case caseRecord : newCasesMap) {
                System.debug('CaseRecord***'+caseRecord.Id);
                FreightAWBPopUpController.getRecordUpdate(caseRecord.Id);
                System.debug('Finish CaseRecord***'+caseRecord.Id);}
        }*/
        }
        catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
    }
    global void finish(Database.BatchableContext ctx){
    }   
    global void execute(SchedulableContext sc)
    {
            /*Scheduling the batch to update the cases with AWB# at 9PM AEST*/
            batchClass_iCargo Icargo = new batchClass_iCargo();
            Database.executeBatch(Icargo,1);
    }
}