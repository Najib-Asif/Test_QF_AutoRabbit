/**********************************************************************************************************************************

Author:        Raghavendra Chakali
Company:       TCS
Date Implemented:  31 MAY 2023
Description:   This is a Batch Class to update Unresolved case business hours from the created date of the case excluding holidays if any
//Added Bipass check for the schedule job issue

**********************************************************************************************************************************/
global class UpdateCaseUnresolvedHoursBatch implements Database.Batchable<sObject>{
    
    private static final String FREIGHT_BUSINESS_HOURS = 'Freight Business Hours ';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        //return Database.getQueryLocator([SELECT Id,CreatedDate FROM Case WHERE RecordType.Name = 'Qantas Freight' AND Status Not IN ('Closed','Resolved')]);
        //CRM-8119: added a last 90 days filter
        return Database.getQueryLocator([SELECT Id, Resolve_Closeddate__c,Freight_Region__c,IsClosed,Status,Case_Unresolved_Hours__c ,FRT_Case_Reopened_Date__c,FRT_Case_Reopen_Status__c,CreatedDate FROM Case WHERE RecordType.Name = 'Qantas Freight' AND Status NOT IN ('Closed','Resolved') AND CreatedDate = LAST_N_DAYS:90]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        if(!caseList.isEmpty()){
            TriggerSwitchHelper.caseTriggerRunFlag = false;
            List<Case> caseBusinessHoursList = new List<Case>();
            Double Case_reopened;
            Double Case_closed;
            Id BusinessHoursId;
            Map<String, Id> businessHoursMap = new Map<String, Id>();
            for (BusinessHours bh : [SELECT Id, Name FROM BusinessHours WHERE name like '%Freight%']) {
                businessHoursMap.put(bh.Name, bh.Id);
            }

            for(Case cas: caseList){
                BusinessHoursId = getBusinessHoursId(businessHoursMap,cas.Freight_Region__c);
                if(cas.FRT_Case_Reopen_Status__c == 'Reopened'){//Reset Unresolved Hours for Reopened cases-CRM 6594
                    Case_reopened= BusinessHours.diff(BusinessHoursId,cas.FRT_Case_Reopened_Date__c,System.now())/3600000;
                    Case_closed= BusinessHours.diff(BusinessHoursId,cas.CreatedDate,cas.Resolve_Closeddate__c)/3600000;
                    cas.Case_Unresolved_Hours__c = Case_reopened + Case_closed ;//Reset + unresolved hours for Reopened/Reply-Received-CRM 6694
                }else{
                    cas.Case_Unresolved_Hours__c = BusinessHours.diff(BusinessHoursId,cas.CreatedDate,System.now())/3600000;
                }
                caseBusinessHoursList.add(cas);
            }
            if(!caseBusinessHoursList.isEmpty()){
                Database.update(caseBusinessHoursList,false);
            }
        }
    }
    
    public Id getBusinessHoursId(Map<String, Id> businessHoursMap, String region){
        String regionToLookup = CustomSettingsUtilities.getConfigDataMap(FREIGHT_BUSINESS_HOURS+region);
        if (String.isNotBlank(region) && businessHoursMap != null && businessHoursMap.containsKey(regionToLookup)) {
                return businessHoursMap.get(regionToLookup);
            }
            return System.Label.CaseBusinessHourID;

    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}