/**
 * description: Handler class for publishing AgentWork CDC Events
 * testclass: AgentWorkCDCHandlerTest
 * author: Bharath Inti
 */

public with sharing class AgentWorkCDCHandler {

    public static void handleAfterInsert(List<AgentWorkChangeEvent> changeEvents) {
        List<Agent_Work_Event__e> eventsToPublish = new List<Agent_Work_Event__e>();

        for (AgentWorkChangeEvent evt : changeEvents) {
            // Ignore routing engine updates
            if (evt.Status == null) {
                continue;
            }

            Agent_Work_Event__e pe = prepareEvent(evt);
            if (pe != null) {
                eventsToPublish.add(pe);
            }
        }

        publishEvents(eventsToPublish);
    }

    /**
     * Publishes platform events and handles logging
     */
    private static void publishEvents(List<Agent_Work_Event__e> events) {
        if (events.isEmpty()) {
            return;
        }

        try {
            EventBus.publish(events);
        } catch (Exception ex) {
            logPublishException(events, ex);
        }
    }


    /**
     * Logs publish exceptions
     */
    @TestVisible
    private static void logPublishException(List<Agent_Work_Event__e> events, Exception ex) {
        CreateLogs.insertLogRec(
            'Log Exception Logs Rec Type',
            'AgentWorkCDCTrigger',
            'AgentWorkCDCHandler',
            'EventBus.publish',
            String.valueOf(events),
            '',
            true,
            '',
            ex
        );
    }

    /**
     * Prepares the platform event record
     * (assuming this already existed in your handler)
     */
    
    public static Agent_Work_Event__e prepareEvent(AgentWorkChangeEvent evt) {

        Agent_Work_Event__e pe = new Agent_Work_Event__e();

        EventBus.ChangeEventHeader header = evt.ChangeEventHeader;

        // ===== Standard Fields =====
        pe.UserId__c = evt.UserId;
        pe.OwnerId__c = evt.OwnerId;
        pe.Status__c = evt.Status;
        pe.LastModifiedDate__c = evt.LastModifiedDate;
        pe.AcceptDateTime__c = evt.AcceptDateTime;
        pe.AssignedDateTime__c = evt.AssignedDateTime;
        pe.CloseDateTime__c = evt.CloseDateTime;
        pe.CancelDateTime__c = evt.CancelDateTime;
        pe.DeclineDateTime__c = evt.DeclineDateTime;
        pe.PushTimeoutDateTime__c = evt.PushTimeoutDateTime;
        pe.PendingServiceRoutingId__c = evt.PendingServiceRoutingId;
        pe.ServiceChannelId__c = evt.ServiceChannelId;


        // ===== ChangeEventHeader as JSON =====
        if (header != null) {

            Map<String,Object> headerMap = new Map<String,Object>();
    
            headerMap.put('commitNumber', header.commitNumber);
            headerMap.put('commitUser', header.commitUser);
            headerMap.put('sequenceNumber', header.sequenceNumber);
            headerMap.put('entityName', header.entityName);
            headerMap.put('changeType', header.changeType);
            headerMap.put('commitTimestamp', header.commitTimestamp);
            headerMap.put('changeOrigin', header.changeOrigin);
            headerMap.put('transactionKey', header.transactionKey);
            headerMap.put('changedFields', header.changedFields);
    
            // recordIds as ARRAY inside header
            if (header.recordIds != null) {
                List<String> ids = new List<String>();
    
                for (Id recId : header.recordIds) {
                    ids.add(String.valueOf(recId));
                }
    
                headerMap.put('recordIds', ids);
            }
        
            pe.ChangeEventHeader__c = JSON.serialize(headerMap);
        }
    
        return pe;
    }
}