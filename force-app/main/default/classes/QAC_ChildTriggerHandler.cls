/* Created By : Ajay Bharathan | TCS | Cloud Developer 

Modified Date   : 29/10/2025 (DD/MM/YYYY)
Modified By     : Gokulakannan Perumal
JIRA            : CRM-9259, CRM-4287
Version         : V2.0 - First Flight Number auto populate for QAC Online Cases
				  V3.0 - NDC/Freight Web Chat code 	

*/
public with sharing class QAC_ChildTriggerHandler
{
    public static map<Id,Case> caseMap = new map<Id,Case>();
    public static String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    public static String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    public static void doCaseUpdateonFlightDelete(list<Flight__c> existingFlights)
    {
        system.debug('old Flights to be deleted**'+existingFlights);
        //String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        for(Flight__c eachFlight : existingFlights){
            if(eachFlight.RecordTypeId == flightRTId && eachFlight.Case__c != null)
            {
                Case myCase = new Case(Id = eachFlight.Case__c,FlightPax_DeleteTimestamp__c = System.now());
                caseMap.put(myCase.Id,myCase);
            }
        }
        if(!caseMap.isEmpty())
            update caseMap.values();
    }
    public static void doCaseUpdateonPaxDelete(list<Affected_Passenger__c> existingPax)
    {
        system.debug('old Passengers to be deleted**'+existingPax);
        String passengerRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();        
        for(Affected_Passenger__c eachPax : existingPax){
            if(eachPax.RecordTypeId == passengerRTId && eachPax.Case__c != null)
            {
                Case myCase = new Case(Id = eachPax.Case__c,FlightPax_DeleteTimestamp__c = System.now());
                caseMap.put(myCase.Id,myCase);
            }
        }
        if(!caseMap.isEmpty())
            update caseMap.values();
    }
    public static void doCaseUpdateonWODelete(list<WorkOrder> existingWO)
    {
        system.debug('old Work Orders to be deleted**'+existingWO);
        String woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        for(WorkOrder eachWO : existingWO){
            if(eachWO.RecordTypeId == woRTId && eachWO.CaseId != null)
            {
                Case myCase = new Case(Id = eachWO.CaseId,FlightPax_DeleteTimestamp__c = System.now());
                caseMap.put(myCase.Id,myCase);
            }
        }
        if(!caseMap.isEmpty())
            update caseMap.values();
    }    
    public static void doCaseUpdateonSPayDelete(list<Service_Payment__c> existingSPay)
    {
        system.debug('old Service Payments to be deleted**'+existingSPay);
        String spRTId = Schema.SObjectType.Service_Payment__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        for(Service_Payment__c eachPay : existingSPay){
            if(eachPay.RecordTypeId == spRTId && eachPay.Case__c != null)
            {
                Case myCase = new Case(Id = eachPay.Case__c,FlightPax_DeleteTimestamp__c = System.now());
                caseMap.put(myCase.Id,myCase);
            }
        }
        if(!caseMap.isEmpty())
            update caseMap.values();
    }
    public static void doCaseUpdateonCaseCommentDelete(list<CaseComment> existingCC)
    {
        system.debug('old Case Comments to be deleted**'+existingCC);
        Boolean isCaseMapUpdated = false;
        for(CaseComment eachCC : existingCC){
            if(eachCC != null && eachCC.ParentId != null)
            {
                Case myCase = new Case(Id = eachCC.ParentId,FlightPax_DeleteTimestamp__c = System.now());
                caseMap.put(myCase.Id,myCase);
                isCaseMapUpdated = true;
            }
        }
        if(!caseMap.isEmpty() && isCaseMapUpdated)
            update caseMap.values();
    }
    
    public static void doCaseUpdateonFileInsUpd(list<ContentDocumentLink> newFiles, map<Id,ContentDocumentLink> existingFilesMap)
    {
        system.debug('files that got changed**'+existingFilesMap);
        Set<Id> caseIds = new Set<Id>();
        for(ContentDocumentLink eachFile : newFiles)
        {
            // files Insert logic
            if(existingFilesMap == null){
                if(eachFile.LinkedEntityId != null && eachFile.ContentDocumentId != null && 
                   ((String)eachFile.LinkedEntityId).substring(0,3) == '500')
                {
                    caseIds.add(eachFile.LinkedEntityId);
                }
            }
            // files Update logic
            /*
            else{
                if((eachFile.LinkedEntityId != null && 
                    eachFile.ContentDocumentId != null && 
                    ((String)eachFile.LinkedEntityId).substring(0,3) == '500') &&
                   (eachFile.LinkedEntityId != existingFilesMap.get(eachFile.Id).LinkedEntityId || 
                    eachFile.ContentDocumentId != existingFilesMap.get(eachFile.Id).ContentDocumentId)
                  )
                {
                    Case myCase = new Case(Id = eachFile.LinkedEntityId,RecordTypeId = caseRTId,FlightPax_DeleteTimestamp__c = System.now());
                    caseMap.put(myCase.Id,myCase);                
                }
            }
      */
        }    
        System.debug('caseIds======> ' + caseIds);
        System.debug('caseRTId===> ' + caseRTId);
        Boolean isCaseMapUpdated = false;
        if(!caseIds.isEmpty()){
            for(Case eachCase : [Select Id,RecordTypeId,FlightPax_DeleteTimestamp__c from Case Where Id in: caseIds AND RecordTypeId =: caseRTId])
            {
                System.debug('eachCase======> ' + eachCase);
                if(eachCase != null){
                    System.debug(' before FlightPax_DeleteTimestamp__c==> ' + eachCase.FlightPax_DeleteTimestamp__c);
                    eachCase.FlightPax_DeleteTimestamp__c = System.now();
                    System.debug(' after FlightPax_DeleteTimestamp__c==> ' + eachCase.FlightPax_DeleteTimestamp__c);
                    caseMap.put(eachCase.Id,eachCase);
                    isCaseMapUpdated = true;
                }
            }
        }
        System.debug('caseMap======> ' + caseMap);
        if(!caseMap.isEmpty() && isCaseMapUpdated)
          update caseMap.values();
    }
    
    // Changes Starts for CRM-4287
     public static void doCaseUpdateonFlightInsert(list<Flight__c> existingFlights)
    {
        Set<Id> flightId = new Set<Id>();
        Set<Id> flightCaseId = new Set<Id>();
        Set<Id> onlineflightCaseId = new Set<Id>();
        List<Case> casetoUpdate = new List<Case>();

        for(Flight__c eachFlight : existingFlights){
            if(eachFlight.RecordTypeId == flightRTId && eachFlight.Case__c != null)
            {
               flightId.add(eachFlight.Id);
               flightCaseId.add(eachFlight.Case__c);
               
            }
        }
        
        if(!flightCaseId.isEmpty() && !flightCaseId.isEmpty()){
            Flight__c[] eachFlight = [SELECT Id, Flight_Departure_Time_and_Date__c, Case__c, Flight_Number__c FROM Flight__c WHERE Case__c = :flightCaseId AND Case__r.Origin = 'QAC Website' AND Case__r.RecordTypeId = :caseRTId  ORDER BY Flight_Departure_Time_and_Date__c ASC LIMIT 1];
            if(eachFlight.size() > 0){
                casetoUpdate.add(new Case(Id = eachFlight[0].Case__c, flight_itinerary__c = eachFlight[0].Flight_Number__c));
            }
        }
        
        if(!casetoUpdate.isEmpty())List<Database.SaveResult> spResults = Database.update(casetoUpdate, false);
    }
    // Changes End for CRM-4287
     
    //	Start - CRM-9259: NDC/Freight Web Chat code 
    public static void contentDocumentToCase(List<ContentDocumentLink> contentDocumentLink){
    // Maps to store MessagingSession to Case IDs
    Map<Id, Id> sessionToCaseMap = new Map<Id, Id>();
    Set<Id> sessionIds = new Set<Id>();
    
    // Collect all LinkedEntityIds (assumed to be MessagingSession Ids)
    for (ContentDocumentLink cdl : contentDocumentLink) {
        if (cdl.LinkedEntityId != null) {
            sessionIds.add(cdl.LinkedEntityId);
        }
    }
    
    // Query MessagingSessions in bulk
    if (!sessionIds.isEmpty()) {
        for (MessagingSession msgSession : [SELECT Id, CaseId FROM MessagingSession WHERE Id IN :sessionIds]) {
            if (msgSession.CaseId != null) {
                sessionToCaseMap.put(msgSession.Id, msgSession.CaseId);
            }
        }
    }
    
    // Collect ContentDocumentIds already linked to Cases
    Set<Id> caseIds = new Set<Id>(sessionToCaseMap.values());
    Map<Id, Set<Id>> caseToContentDocs = new Map<Id, Set<Id>>();
    
    if (!caseIds.isEmpty()) {
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :caseIds]) {
            if (!caseToContentDocs.containsKey(cdl.LinkedEntityId)) {
                caseToContentDocs.put(cdl.LinkedEntityId, new Set<Id>());
            }
            caseToContentDocs.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
        }
    }
    
    // Prepare new ContentDocumentLink records for insertion
    List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();

    for (ContentDocumentLink cdl : contentDocumentLink) {
        if (cdl.LinkedEntityId != null && sessionToCaseMap.containsKey(cdl.LinkedEntityId)) {
            Id caseId = sessionToCaseMap.get(cdl.LinkedEntityId);
            
            for (ContentDocumentLink existingCdl : [SELECT ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :cdl.LinkedEntityId]) {
                if (!caseToContentDocs.containsKey(caseId) || !caseToContentDocs.get(caseId).contains(existingCdl.ContentDocumentId)) {
                    ContentDocumentLink cloned = new ContentDocumentLink(
                        ContentDocumentId = existingCdl.ContentDocumentId,
                        LinkedEntityId = caseId,
                        ShareType = existingCdl.ShareType,
                        Visibility = 'AllUsers'
                    );
                    newCdlList.add(cloned);
                }
            }
        }
    }
    
    // Insert all new ContentDocumentLink records in bulk
    if (!newCdlList.isEmpty()) {
        insert newCdlList;
    }
      }
    //End - CRM-9259: NDC/Freight Web Chat code 
}