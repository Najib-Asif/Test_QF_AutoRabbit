public without sharing class FlightEventLinkage {

    @AuraEnabled
    public static List<Event__c> getFlightEvents(Id caseId){
        try {
            Set<String> pnrSet = new Set<String>();
            List<Event__c> flightEvents = new List<Event__c>();
            if (caseId == null) {
                return null;
            }
            for (Case caseRecord : [ SELECT Id, Booking_PNR__c, CaseNumber FROM Case WHERE Id = :caseId ])
            {
                if (String.isNotBlank(caseRecord.Booking_PNR__c)) {
                    pnrSet.add(caseRecord.Booking_PNR__c);
                }
            }
            for (PNR__c pnrRecord : [ SELECT Id, Case__c, PNR__c FROM PNR__c WHERE Case__c = :caseId ]) {
                if (String.isNotBlank(pnrRecord.PNR__c)) {
                    pnrSet.add(pnrRecord.PNR__c);
                }
            }
            if (pnrSet.isEmpty()) {
                return null;
            }
            for (Event__c fERecord : [ SELECT Id, Name, Flight_Status__c, Status__c FROM Event__c 
                                        WHERE Id IN (SELECT Event__c FROM Affected_Passenger__c 
                                                        WHERE PNR__c IN :pnrSet ) ])
            {
                if (fERecord.Status__c != 'Closed') {
                    flightEvents.add(fERecord);
                }
            }
            return flightEvents;
        } catch (QueryException e) {
            throw new AuraHandledException('query exception - ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('an exception occurred - ' + e.getMessage());
        }
    }

    /*
    @AuraEnabled
    public static Case getCaseRecord(Id caseId) {
        if (caseId == null) {
            return null;
        }
        return [ SELECT Id, Booking_PNR__c, CaseNumber FROM Case WHERE Id = :caseId ];
    }
    
    @AuraEnabled
    public static String getPNRNumber(Id caseId) { 
        if (caseId == null) {
            return '';
        }
        for (Case record : [ SELECT Id, Booking_PNR__c FROM Case WHERE Id = :caseId ]) 
        {
            return record.Booking_PNR__c;
        }
        return '';
    }
    
    @AuraEnabled 
    public static List<Event__c> fetchFlightEventsFromPNR(String pnrNumber) {
        Set<Id> eventIds = new Set<Id>(); 
        if (String.isBlank(pnrNumber)) {
            return null;
        }
        for (Affected_Passenger__c record : [ SELECT Id, Event__c FROM Affected_Passenger__c 
                                            	WHERE PNR__c = :pnrNumber])
        {
            eventIds.add(record.Event__c);
        }
        system.debug(eventIds);
        if (eventIds.size() > 0) {
        	return [ SELECT Id, Name, Flight_Status__c, Status__c FROM Event__c WHERE Id IN :eventIds ];
        }
        return new List<Event__c>();
    }
    */
    
    @AuraEnabled
    public static List<Id> getLinkedFlightIdsFromCase(Id caseId) {
        Set<Id> flightEventIds = new Set<Id>();
        if (caseId == null) {
            return new List<Id>();
        }
        for (Case_Flight_Event__c cFERecord : [ SELECT Id, Name, Flight_Event__c FROM Case_Flight_Event__c 
                                                WHERE Case__c = :caseId ])
        {
            if (cFERecord.Flight_Event__c != null) {
                flightEventIds.add(cFERecord.Flight_Event__c);
            }
        }
        return new List<Id>(flightEventIds);
    }

    @AuraEnabled
    public static Boolean createLinkedFlightEvents(Id caseId, Event__c flightEventRecord) {
        try {
            Case caseRecord = [ SELECT Id, Booking_PNR__c, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1 ];
            insert new Case_Flight_Event__c(
                Case__c = caseRecord.Id,
                Flight_Event__c = flightEventRecord.Id,
                Name = caseRecord.CaseNumber + ' - ' + flightEventRecord.Name
            );
        } catch (Exception e) {
            return false;
        }
        return true;
    }
}