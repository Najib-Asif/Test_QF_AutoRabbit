/*********************************************************************************

Name         : FreightExceptionTileController

Created By   : Vinothkumar Balasubramanian

Company Name : TCS

Project      : Freight Track & Trace

Created Date : 19 February 2019

Usage       : This Class shows the Freight Exception related information on the Case Record Page
3-June-2026   Jesus Suarez       CRM-12993 - Added code security best practices and exception handling as part of code remediation        

*********************************************************************************/

public with sharing class FreightExceptionTileController {
    @AuraEnabled
    public static Case getCase(Id CaseId) {
    try{    
        Case caseRec;
        for (Case caseRecord : [select Id, Type, Freight_Scanned_By__c, Freight_Scanning_Location__c, Freight_Shipment__c,
                                Freight_Scanned_Before__c,Freight_Scanned_Time__c, Freight_Stated_Pieces__c, 
                                Freight_Weight__c,Freight_AWB_Pieces__c, Freight_Received_Pieces__c, Freight_Port__r.Name,
                                Freight_Function__c, Freight_ULD_Number__c, Freight_AWB_Number__c, Sub_Type_1__c,
                                Other_Damage_Description__c, Freight_AWB_Shipment_Description__c, Freight_Damage_Code__c,
                                Freight_Customer_Name__c, Freight_Customer_No__c, Freight_AWB_Handling_Code__c,
                                Freight_AWB_s__c, Freight_Destination__c, Freight_Origin__c, Freight_Placed_Location__c,
                                Freight_Scanned_before_time__c, (select Freight_Arrival_Flight_No__c,  
                                                                 Freight_Arrival_Flight_Date_Time__c, Freight_Arrival_Flight_Destination__c,
                                                                 Freight_Arrival_Flight_Origin__c, Freight_Arrival_Flight_Sector__c,
                                                                 Freight_Booked_Flight_Date_Time__c, Freight_Booked_Flight_Destination__c,
                                                                 Freight_Booked_Flight_No__c, Freight_Booked_Flight_Origin__c,
                                                                 Freight_Booked_Flight_Sector__c                                                             
                                                                 from Flights__r) 
                                from Case where Id =: CaseId AND Origin = 'Elenium' WITH USER_MODE]){ //jira : CRM-12993: Added code security best practices and exception handling as part of code remediation
                                    
                                    if (caseRecord != null)  caseRec = caseRecord ;
                                }
        return caseRec; 
                             
    } catch (QueryException ex) { //CRM-12993 added Catch for Code Security Remediation
 
       Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
          CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightExceptionTileController', 'FreightExceptionTileController','getCase', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
            String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
           throw new AuraHandledException(msg);}
    
    }
}