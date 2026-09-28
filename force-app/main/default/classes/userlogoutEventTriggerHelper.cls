//Test class: QAC_CaseReassignmentScheduler_Test
public class userlogoutEventTriggerHelper {
	
    public static void QACCaseReassignOwner(List<LogoutEventStream> LogoutEventStreamList){
        
        //get the NDC Support queue Id
        String queueName = 'NDC Support';
        Id queueId = [select id, name from group where name =:queueName].id;
        
        for(LogoutEventStream event:LogoutEventStreamList){
        try{
			List<Case> casesToReassign = [Select Id, OwnerId,description from Case where RecordType.name = 'QAC Contact Us Support' and Type='NDC' and OwnerId =:event.UserId and status !='Resolved'];
            
            for(case c:casesToReassign){
                c.OwnerId = queueId;
                //c.description = 'Case Reassigned back to queue as the owner logged out';
            }
            if(!casesToReassign.isEmpty()){
                update casesToReassign;
            } 
        }
        catch(Exception ex){
            system.debug('Unexpected Exception'+ex.getMessage());
        }
    }
    }
}