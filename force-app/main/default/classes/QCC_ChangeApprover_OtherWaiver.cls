/*********************************************************************************
Name         : QCC_ChangeApprover_OtherWaiver
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 August 2019
Usages       : Assign approver to Team Leader queue after 12 hours if approval record has not yet been approved
*********************************************************************************/
public without sharing class QCC_ChangeApprover_OtherWaiver {
    //@Purpose: This method gets the Approval request record and automatically assign the Approval to the Team Leaders queue.
    //@input parameter:
    //	1. recordIds - the record ID of the created Other Waiver record which we get from the Process Builder (QCC Approval Process Reassign for Other Waiver)
    
    @InvocableMethod
    public static void changeApprover(List<Id> recordIds){
        
        //Gets the ID of the Team Leader queue from Custom Label
        Group teamLeaderQueue;
        try {
            teamLeaderQueue = [SELECT Id, Name, Type FROM Group WHERE Type = : Label.QCC_Group_Queue AND Name = : Label.QCC_TeamLeaderQueue];            
            System.debug('##teamLeaderQueueId ' + teamLeaderQueue);        
            
            //Method starts only when the Queue Group is found
            if (teamLeaderQueue != null){
                
                //Get the IDs of the approval request based from the recordIds passed by the parameter from the Process Builder.
                List <ProcessInstance> processInstanceLists= [SELECT Id, TargetObjectId, Status FROM ProcessInstance 
                                                              WHERE TargetObjectId IN: recordIds AND Status = 'Pending'];  
                List<Id> processInstanceIds = new List<Id>();
                //Get the ID of the Approval record request to be used to query the Approval Steps.
                for(ProcessInstance processInstanceId: processInstanceLists) {
                    processInstanceIds.add(processInstanceId.Id);
                }
                System.debug('##processInstanceLists ' + processInstanceLists);        
                
                //Get the Approval Step and Status of the queried ProcessInstance where the Approval Step is Level 1 and the Status is Pending
                List <ProcessInstanceNode> processInstanceNodeLists = [SELECT Id, ProcessInstanceId, NodeStatus, ProcessNodeName FROM ProcessInstanceNode
                                                                       WHERE ProcessInstanceId IN: processInstanceIds
                                                                       AND NodeStatus = 'Pending' AND ProcessNodeName = 'Level 1 Approval'];  
                List<Id> processInstanceNodeInstanceIds = new List<Id>();
                //Get the IDs of the approval request based from queried ProcessInstanceNode.
                for(ProcessInstanceNode processInstanceNodeRecord: processInstanceNodeLists) {
                    processInstanceNodeInstanceIds.add(processInstanceNodeRecord.ProcessInstanceId);
                }
                System.debug('##processInstanceNodeInstanceIds ' + processInstanceNodeInstanceIds); 
                
                //Get the Ids of all WorkItems related to the TargerObjectIds from the ProcessInstance where the ActorId is not the TL Queue
                List <ProcessInstanceWorkItem> processInstanceWorkItemLists = [SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkItem 
                                                                               WHERE ProcessInstanceId IN: processInstanceNodeInstanceIds AND (NOT ActorId =: teamLeaderQueue.Id)];  
                System.debug('##processInstanceWorkItemLists ' + processInstanceWorkItemLists); 
                
                //Update the Approver to Team Leader Queue
                for(ProcessInstanceWorkItem processInstanceWorkItemList: processInstanceWorkItemLists ) {
                    processInstanceWorkItemList.ActorId = teamLeaderQueue.Id;
                    System.debug('##processInstanceWorkItemList.ActorId ' + processInstanceWorkItemList.ActorId); 
                }                
                
                if(processInstanceWorkItemLists.size() > 0){
                    //Update processInstanceWorkItemList;
                    Database.SaveResult[] saveResultList = Database.update(processInstanceWorkItemLists, false);
                    //Create the log record for those save result that fails
                    QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC - Change Approver Other Waiver', 'QCC_ChangeApprover_OtherWaiver', '');
                }
                System.debug('##processInstanceWorkItemLists ' + processInstanceWorkItemLists); 
            }
        }
        catch(Exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Change Approver Other Waiver', 'QCC_ChangeApprover_OtherWaiver', 'changeApprover', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}