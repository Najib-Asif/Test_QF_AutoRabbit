/**
 * REST API for updating AWS-generated call summaries against a conversation.
 */
@RestResource(urlMapping='/QCCAWSSummary/*')
global with sharing class QCC_AWSSummaryRestApi {
    /**
     * Receives a summary payload from AWS and updates the related Salesforce task/case record.
     */
    @HttpPost
    global static void updateSummary() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> payload;
        String reqBody;
        Savepoint sp;
        try{
            reqBody = req.requestBody.toString();
            payload = (Map<String, Object>) Json.deserializeUntyped(reqBody);

            // Validate required fields
            String validationError = validatePayload(payload);
            
            // Extract and parse the payload

            String summary = (String) payload.remove('summary');
            String wrapupCodeName = (String) payload.remove('wrapupCodeName');
            String wrapupCodeId = (String) payload.remove('wrapupCodeId');

            if (validationError != null) {
                throw new IllegalArgumentException(validationError);
            }

            String conversationId = (String) payload.get('conversationId');
            List<Object> participants = (List<Object>) payload.get('participants');
            Map<String, Object> participant = (Map<String, Object>) participants.get(0);
            String participantId = (String) participant.get('id');
            Map<String, Object> attributes = (Map<String, Object>) participant.get('attributes');
            String genesyspsExperienceId = attributes != null ? (String) attributes.get('genesysps_ExperienceId') : '';
            String scvExternalObjectId = attributes != null ? (String) attributes.get('scv_externalObjectId') : '';
            
            // Implement your logic here, for example:
            if (String.isNotBlank(genesyspsExperienceId)) { 
                // Update the summary in Salesforce for Messaging based on the Experience Id, TODO when Genesys Messaging is implemented
                // This is a placeholder for your actual update logic
            } else if (String.isNotBlank(scvExternalObjectId)) {
                // Update the summary in Salesforce for Voice based on the External Object Id, TODO when Genesys Voice is implemented
                // This is a placeholder for your actual update logic
            }else {
                // Implemtent logic for CTI Voice calls based on the conversationId and participantId.
                List<Task> getTask=[SELECT id,TECH_Genesys_Participant_Id__c,WhatId, QCC_Classification__c FROM Task 
                                        WHERE CallObject=:conversationId 
                                            AND TECH_Genesys_Participant_Id__c=:participantId 
                                            WITH USER_MODE
                                        ORDER BY CreatedDate DESC LIMIT 1];
                if (getTask.isEmpty()) {
                    throw new IllegalArgumentException('No Task found for the given conversationId and participantId');
                }
                Task taskToUpdate = new Task(Id = getTask[0].Id);
                String caseId = getTask[0].WhatId;
                if (String.isBlank(caseId)) {
                    List<Case> caseList = [SELECT Id FROM Case WHERE InteractionId__c = :conversationId WITH USER_MODE LIMIT 1];
                    if (!caseList.isEmpty()) {
                        caseId = caseList[0].Id;
                    }
                }
                if (String.isBlank(caseId)) {
                    throw new IllegalArgumentException('No Case found for the given conversationId');
                }
                //Fire to Genesys to update the wrapup code for the call, TODO when Genesys Voice is implemented
                // Below code TO BE enabled when AWS changes are finalized
                
                if (wrapupCodeId != '00000000-0000-0000-0000-000000000000' && !Test.isRunningTest()) {
                    HttpResponse genesysApiResponse = purecloud.SDK.Rest.patch('/platform/api/v2/conversations/' + conversationId + '/participants/' + participantId + 
                                    '', '{"wrapup":{"code":"' + wrapupCodeId + '","notes":""}}');
                    if (genesysApiResponse.getStatusCode() != 202) {
                        throw new HandledException('Failed to update wrapup code in Genesys: ' + genesysApiResponse.getBody());
                    }   
                    taskToUpdate.QCC_Classification__c = wrapupCodeName;
                    taskToUpdate.CallDisposition = wrapupCodeName;
                } 
                
                sp = Database.setSavepoint();
                if (String.isNotBlank(caseId)) {
                    CaseComment awsComment = new CaseComment(ParentId = caseId, CommentBody = summary.left(4000));
                    Database.insert(awsComment, AccessLevel.USER_MODE);
                    taskToUpdate.Summary_Comment_Id__c = awsComment.Id;
                }
                
                //Updating Salesforce Task with the wrapup code name and disposition
                //taskToUpdate.Description = summary.left(32000);
                Database.update(taskToUpdate, AccessLevel.USER_MODE);
            }
            
            //Handle response to AWS and update the summary in Salesforce based on the conversationId and participantId
            
            response.put('success', 'true');
            response.put('message', 'Summary updated successfully');
            
            
        }catch(Exception ex){
            if(sp != null) {
                Database.rollback(sp);
            }
            res.statusCode = 500;
            response.put('success', 'false');
            response.put('message', 'Error returned: '+ ex.getMessage());
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - AWS Summary Update', 'QCC_AWSSummaryRestApi', 
                                    'updateSummary', reqBody, Json.serialize(response), true,'', ex);
        } finally {
            if (payload != null) {
                response.put('conversationId', payload.get('conversationId'));
                response.put('participants', payload.get('participants'));
            } 
            res.responseBody = Blob.valueOf(JSON.serialize(response)); 
        }
    }
    
    private static String validatePayload(Map<String, Object> payload) {
        List<String> missingFields = new List<String>();
        
        // Check conversationId
        if (!payload.containsKey('conversationId') || String.isBlank((String) payload.get('conversationId'))) {
            missingFields.add('conversationId');
        }
        
        // Check participants and participants[0].id
        if (!payload.containsKey('participants') || payload.get('participants') == null) {
            missingFields.add('participants');
        } else {
            List<Object> participants = (List<Object>) payload.get('participants');
            if (participants.isEmpty()) {
                missingFields.add('participants[0]');
            } else {
                Map<String, Object> participant = (Map<String, Object>) participants.get(0);
                if (!participant.containsKey('id') || String.isBlank((String) participant.get('id'))) {
                    missingFields.add('participants[0].id');
                }
            }
        }
        
        // Check summary
        if (!payload.containsKey('summary') || String.isBlank((String) payload.get('summary'))) {
            missingFields.add('summary');
        }
        
        // Check wrapupCodeName
        if (!payload.containsKey('wrapupCodeName') || String.isBlank((String) payload.get('wrapupCodeName'))) {
            missingFields.add('wrapupCodeName');
        }
        
        // Check wrapupCodeId
        if (!payload.containsKey('wrapupCodeId') || String.isBlank((String) payload.get('wrapupCodeId'))) {
            missingFields.add('wrapupCodeId');
        }
        
        // Throw combined error if any fields are missing
        if (!missingFields.isEmpty()) {
            return 'Missing required fields: ' + String.join(missingFields, ', ');
        }
        return null;
    }
}

/* JSON Request Example:
{
  "conversationId": "00000000-0000-4000-8000-000000000001",
  "participants": [
    {
      "id": "00000000-0000-4000-8000-0000000000a1",
      "attributes": {
        "genesysps_ExperienceId": "",
        "scv_externalObjectId": "0LQ000000000001AAA"
      }
    }
  ],
  "summary": "Ask: Customer called to change the return date on an existing domestic booking (SYD-MEL) from 12 Aug to 15 Aug for two passengers.\nAdvise: Advised the fare rules permit a date change with a change fee plus any fare difference, and that the 15 Aug evening service had availability in the same fare class.\nAction: Rebooked both passengers onto QF445 departing 15 Aug 18:05, collected the change fee and fare difference, and reissued the tickets. Updated itinerary emailed to the address on file.",
  "confidence": 0.95,
  "wrapupCodeName": "GE - Existing Bookings",
  "wrapupCodeId": "734bfcd0-a900-46d5-afab-c5eb662a85ba"
}
*/