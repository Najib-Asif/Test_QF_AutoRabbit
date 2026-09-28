/*****************************************************************************************
* Created By : Veni Gonzales | ACN | Developer 
* Purpose : QCC_WrapUpFlowHelper is used in the Flow: QCC_Voice_WrapUp_Flow
* REST API :
* Modified Date   : 19/05/2023 (DD/MM/YYYY)
* Modified By     : Veni Gonzales
******************************************************************************************/
public class QCC_WrapUpFlowHelper {
    
    @InvocableMethod(label='QCC Wrap Up Flow Helper')
    public static List<FlowOutputs> invokeThisMethod (List<FlowInputs> request) {
        
        List<FlowOutputs> results;
            if (request[0].methodName == 'getLatestTask') {
                results = getLatestTask(request);
            }
        	if (request[0].methodName == 'getFaultPathError') {
                results = getFaultPathError(request);
            }
        return results;
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public String methodName;
        
        @InvocableVariable
        public String callInteractionId;
        
        @InvocableVariable
        public String callParticipantId;
                
        @InvocableVariable
        public String caseId;
        
        @InvocableVariable
        public String faultMessage;
    }
    
    //output details which goes from apex to flow
    public class FlowOutputs{
        
        @InvocableVariable
        public Task taskRecord;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static List<FlowOutputs> getLatestTask(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowInputs request = requests[0];
        FlowOutputs result = new FlowOutputs();
        Task taskForCall;
        
        List<Task> latestTask = new List<Task> ([
            SELECT Id, CallObject, CallType, WhoId, WhatId, TaskSubtype, TECH_Genesys_Participant_Id__c
            FROM Task 
            WHERE CallObject != null 
            AND CallObject = :request.callInteractionId
            AND TaskSubtype = 'Call'
            AND TECH_Genesys_Participant_Id__c =:request.callParticipantId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]);
        
        List<Case> caseForCall = new List<Case>([SELECT Id, InteractionId__c FROM Case WHERE InteractionId__c = :request.callInteractionId AND InteractionId__c != null ORDER BY CreatedDate DESC LIMIT 1]);
        
        //Get the task for the call
        if (!latestTask.isEmpty()) {
            taskForCall = latestTask.get(0);
        }
        
        //Set the WhatId if case is found
        if (taskForCall != NULL && !caseForCall.isEmpty()) {
            taskForCall.WhatId = caseForCall.get(0).Id;
        }
        
        if(taskForCall != NULL){
            result.taskRecord = taskForCall;
        }
        
        results.add(result);
        return results;
    }

	@AuraEnabled(cacheable=false)
    public static List<FlowOutputs> getFaultPathError(List<FlowInputs> request) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        String ex = request[0].faultMessage;
        Integer exLen = ex.length();
        String exMsg = '';
        
        if(exLen > 131072){
            exMsg = ex.substring(0,131070);
            System.debug('@@@ Debug Exception length exceed : '+ exLen + ' message: '+ exMsg);
        } else if (exLen <= 131072) {
            exMsg = ex;
            System.debug('@@@ Debug Exception below max length: '+ exLen + ' message: '+ exMsg);
        }
        
        QCC_VoiceUtils.insertLogRec('Log Exception Logs Rec Type', 'QCC_WrapUpFlowHelper', 'QCC_WrapUpFlowHelper',
                                'getFaultPathError', '', '', false,'', exMsg);
        
        return results;
    }
}