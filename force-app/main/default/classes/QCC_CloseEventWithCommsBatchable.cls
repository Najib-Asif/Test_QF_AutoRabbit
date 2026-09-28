global class QCC_CloseEventWithCommsBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {
    String query;
    Set<Id> setEventId;
    
    /*--------------------------------------------------------------------------------------       
    Method Name:        QCC_CloseEventWithCommsBatchable
    Description:        submit recovery for specific event
    Parameter:          set Id of Event
    --------------------------------------------------------------------------------------*/
    global QCC_CloseEventWithCommsBatchable(set<Id> setEventId, String query) {
        this.setEventId = setEventId;
        this.query = query; 
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query += 'IN :setEventId'
            + 	' AND' 
            +  	' Affected__c = true'
            + 	' AND'
            + 	' EventCommunication__c != Null';
        system.debug('query####'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Affected_Passenger__c> lstPassenger) {
        for(Affected_Passenger__c objPass: lstPassenger){
            objPass.SendEmail__c = true;
        }
        system.debug('after Send email update to true ');
        try{
        	update lstPassenger;
        }catch(Exception ex)
        {
           System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Affected Passenger Trigger', 'AffectedPassengerTriggerHelper', 
                                    'isAffectedPassenger', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob aJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        String messageResult;
        if(aJob.Status == 'Completed'){
            messageResult = CustomSettingsUtilities.getConfigDataMap('QCC_EmailCommsSuccess');
            system.debug('Completed Message Result:'+messageResult);
        }
        if(aJob.Status == 'Failed'){
            messageResult = CustomSettingsUtilities.getConfigDataMap('QCC_EmailCommsFailed');
            system.debug('Failed Message Result:'+messageResult);
        }
        if(!Test.isRunningTest() ){
            Id chatterGroupId = [select Id from CollaborationGroup WHERE CollaborationType='Public' and Name = 'CC Events Group'].Id;
            system.debug('chatterGroupId'+chatterGroupId);
            FeedItem post = new FeedItem();
            post.ParentId = chatterGroupId;
            post.Body = messageResult;
            insert post;
		}
    }
}