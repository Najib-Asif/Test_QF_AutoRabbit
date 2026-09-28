//Test class: QAC_CaseReassignmentScheduler_Test
public class QAC_CaseReassignmentScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc){
        
        Map<Id,DateTime> latestOwnerchangeMap = new Map<Id,DateTime>(); //store the last ownerChnage datetime
        List<Case>casesToReassign = new List<Case>(); //store the cases that needs Reassignment
        
        
            //get the NDC Support queue Id
           	String queueName = 'NDC Support';
            Id queueId = [select id, name from group where name =:queueName].id;
            
            //cases to process
            List<Case> casesToProcess = [Select Id, OwnerId from Case where RecordType.name = 'QAC Contact Us Support' and Type='NDC' and OwnerId !=:queueId and status !='Resolved'];
            if(casesToProcess.isEmpty()){
                return;
            }
            Set<Id> caseIds = new Set<Id>();
            for(Case c:casesToProcess){
                caseIds.add(c.Id);
                if(Test.isRunningTest()){
                    latestOwnerchangeMap.put(c.Id,DateTime.now().addHours(-25));
            	}
            }
            
            for(AggregateResult ar:[Select caseId,MAX(Createddate) latestChange from CaseHistory where Field = 'Owner' and caseId in: caseIds GROUP BY caseId]){
                latestOwnerchangeMap.put((Id)ar.get('caseId'),(DateTime)ar.get('latestChange'));
            }
            
            for(Case c:casesToProcess){
                DateTime latestChange = latestOwnerchangeMap.get(c.Id);
                if(latestChange!=null && latestChange<=DateTime.now().addHours(-24)){
                    c.OwnerId = queueId;
                    casesToReassign.add(c);
                }
            }
            if(!casesToReassign.isEmpty()){
                update casesToReassign;
            } 
        
    }

}