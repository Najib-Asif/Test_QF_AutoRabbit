/*
* description: Handler class for publishing UserServicePresence CDC Events
* testclass: UserServicePresenceCDCHandlerTest
* author: Bharath Inti
*/

public with sharing class UserServicePresenceCDCHandler {
    
    public static void handleAfterInsert(List<UserServicePresenceChangeEvent> changeEvents) {
        List<Agent_Presence_Event__e> eventsToPublish = new List<Agent_Presence_Event__e>();

        for (UserServicePresenceChangeEvent evt : changeEvents) {
            Agent_Presence_Event__e pe = prepareEvent(evt);
            if (pe != null) {
                eventsToPublish.add(pe);
            }
        }

        publishEvents(eventsToPublish);
    }

    /**
     * Publishes Platform Events
     */
    private static void publishEvents(List<Agent_Presence_Event__e> events) {
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
     * Logs publish exception
     */
    @TestVisible
    private static void logPublishException(List<Agent_Presence_Event__e> events,Exception ex) {
        CreateLogs.insertLogRec(
            'Log Exception Logs Rec Type',
            'UserServicePresenceCDCTrigger',
            'UserServicePresenceCDCHandler',
            'logPublishException',
            String.valueOf(events),
            '',
            true,
            '',
            ex
        );
    }

    public static Agent_Presence_Event__e prepareEvent(UserServicePresenceChangeEvent evt) {

        Agent_Presence_Event__e pe = new Agent_Presence_Event__e();

        EventBus.ChangeEventHeader header = evt.ChangeEventHeader;

        // ===== Standard Fields =====
        pe.UserId__c = evt.UserId;
        pe.ServicePresenceStatusId__c = evt.ServicePresenceStatusId;
        pe.IsAway__c = String.valueOf(evt.IsAway);
        pe.IsCurrentState__c = String.valueOf(evt.IsCurrentState);
        pe.IdleDuration__c = evt.IdleDuration;
        pe.StatusStartDate__c = evt.StatusStartDate;
        pe.StatusEndDate__c = evt.StatusEndDate;

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

            // ===== recordIds as ARRAY =====
            if (header.recordIds != null) {
                List<String> ids = new List<String>();
                for (Id recId : header.recordIds) {
                    ids.add(String.valueOf(recId));
                }
                headerMap.put('recordIds', ids);
            }

            // Clean JSON
            pe.ChangeEventHeader__c = JSON.serialize(headerMap);
        }

        return pe;
    }

}