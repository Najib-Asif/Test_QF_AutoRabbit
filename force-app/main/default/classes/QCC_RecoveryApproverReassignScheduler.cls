global class QCC_RecoveryApproverReassignScheduler implements Schedulable { 
    
    global void execute(SchedulableContext sc) {
        try{
            QCC_RecoveryApprovalSLA__mdt raSLA = [Select id, Scheduler_Frequency__c,SLA_Time__c 
                                                  FROM QCC_RecoveryApprovalSLA__mdt 
                                                  WHERE MasterLabel='QCC_RecoveryApproverReassignScheduler' limit 1];
            Set<String> setUser = new Set<String>();
            
            //get Recovery Prefix
            Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get('Recovery__c');
            Schema.DescribeSObjectResult r = s.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            
            Group omQueue = [SELECT id, name FROM Group WHERE Type='Queue' AND Name = 'CCC OM Recovery Approval Queue' Order By Name ASC limit 1];
            //Added by Bharath to get the Dean Id for the last escalated level
             String finalrecoveryapproval=System.Label.QCC_RecoveryApproval;
            User theDean = [Select Id, ManagerId from User Where name=:finalrecoveryapproval limit 1];
            system.debug('theDean'+theDean);
            if(Test.isRunningTest()){ 
                theDean = [Select Id, ManagerId from User Where firstname='User5' AND Lastname ='Manager' AND Email='user5M@yopmail.com' limit 1];
            }
            String theDeanId = theDean.Id;
            
            //Select all the Processinstances which are Approval and In Pending Status
            Map<ID,Processinstance> mapPendingApprovals = new Map<ID,Processinstance>( [SELECT CompletedDate, CreatedById, CreatedDate,
                                                                                        Id, LastActorId, LastModifiedById, LastModifiedDate,
                                                                                        ProcessDefinitionId, Status, SystemModstamp,
                                                                                        TargetObjectId, SubmittedById 
                                                                                        FROM ProcessInstance 
                                                                                        WHERE ProcessDefinition.Type = 'Approval' 
                                                                                        AND status = 'Pending'] );
            
            //filter to get only Recovery Approval by check in TargetObjectId prefix
            for(ID i : mapPendingApprovals.keySet()){
                if(!String.ValueOf(mapPendingApprovals.get(i).TargetObjectId).startsWith(keyPrefix)){
                    mapPendingApprovals.remove(i);
                }
            }
            
            //Select all the ProcessinstancesWorkItem 
            List<ProcessInstanceWorkItem> listWorkItem = [SELECT ActorId,CreatedById,CreatedDate,Id,
                                                          OriginalActorId,ProcessInstanceId,SystemModstamp 
                                                          FROM ProcessInstanceWorkitem
                                                          WHERE ProcessInstanceId IN :mapPendingApprovals.keySet()];
            
            List<ProcessInstanceWorkItem> updateWorkItem = new List<ProcessInstanceWorkItem>();
            DateTime currentTime = System.now();
            for(ProcessInstanceWorkItem item : listWorkItem){
                if(String.valueOf(item.ActorId).startsWith('005')){
                    setUser.add(item.ActorId);
                }
                setUser.add(item.OriginalActorId);
            }
            Map<String, infoWrapper> mapUserInfo = getActorInfoMap(new List<String>(setUser));
            
            infoWrapper iw = new infoWrapper();
            iw.actorId = omQueue.id;
            iw.escalatedQueue = theDeanId;
            
            mapUserInfo.put(omQueue.id, iw);
            System.debug(LoggingLevel.Error, theDeanId);
            
            for(ProcessInstanceWorkItem workItem : listWorkItem){
                infoWrapper iwItem = mapUserInfo.get(workItem.OriginalActorId);
                String bhId = iwItem.businessHourIds;
                if(String.isBlank(bhId)){
                    //not change anything 
                }else{
                    if((String.valueOf(workItem.ActorId).startsWith('005') || workItem.ActorId == omQueue.id) 
                       && (workItem.ActorId != theDeanId) ){ // stop at the Dean
                        if( (BusinessHours.diff(bhId, workItem.SystemModstamp, currentTime)/(1000*60*60) > raSLA.SLA_Time__c) //correct time should be 1000*60*60
                           || Test.isRunningTest()){ //incase of running unit Test
                               String escalatedActor = mapUserInfo.get(workItem.ActorId).escalatedQueue;
                               workItem.ActorId = escalatedActor;
                               System.debug(LoggingLevel.Error, escalatedActor);
                               
                               updateWorkItem.add(workItem);
                           }
                    }
                }
                
            } 
            
            if(updateWorkItem.size()>0){
                List<Database.SaveResult> srList = Database.update(updateWorkItem, false);
                
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        //
                    }else{
                        System.debug(sr);
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err);
                        }
                    }
                }
            }
            
        }Catch(exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            System.debug(LoggingLevel.Error, ex.getStackTraceString());
        }
        
        reScheduleNextRun();
    }
    
    
    private Map<String, infoWrapper> getActorInfoMap(List<String> listUserIds){
        Map<String, infoWrapper> output = new Map<String, infoWrapper>();
        if(listUserIds.isEmpty()){
            return output;
        }
        
        List<User> listUsers = [SELECT LocaleSidKey,ManagerId,Name,ProfileId,TimeZoneSidKey,Username,
                                UserRoleId,UserRole.Name,UserType,Location__c, profile.name
                                FROM User WHERE Id IN :listUserIds ];
        
        Group omQueue = [SELECT id, name FROM Group WHERE Type='Queue' AND Name = 'CCC OM Recovery Approval Queue' Order By Name ASC limit 1];
        
        List<Group> listQueues = [Select id, name from Group 
                                  where Type='Queue' AND Name like 'CCC % Recovery Approval Queue' Order By Name ASC];
        List<BusinessHours> listBH = [SELECT Id,IsActive,IsDefault,Name,TimeZoneSidKey FROM BusinessHours];
        
        List<QCC_Recovery_Approval_Queue__mdt>  listApprovalQueue = [Select Location__c, Location_TL_Queue__c From QCC_Recovery_Approval_Queue__mdt];
        
        for(User u : listUsers){
            infoWrapper iw = new InfoWrapper();
            iw.actorId = u.Id;
            iw.Location = u.Location__c;
            
            if(!String.isBlank(u.Location__c)){
                for(BusinessHours bh : listBH){
                    if(bh.Name.startsWith(u.Location__c)){
                        iw.businessHourIds = bh.id;
                        break;
                    }
                }
            }
            
            
            // CRM-11911 - Add QCC Operational Manager in if statement
            if(u.Profile.Name == 'Qantas CC Operational Manager' || u.Profile.Name == 'QCC Operational Manager' ){
                iw.escalatedQueue = omQueue.id;
            }else{
                //CRM-11628 Adding QCC Contact Center Agent with all Qantas CC Consultant and Qantas CC Team Lead Profiles
                if((u.Profile.Name == 'Qantas CC Consultant')||(u.Profile.Name == 'Qantas CC Team Lead') || (u.Profile.Name.contains('QCC Contact Center Agent')) ){
                    for(QCC_Recovery_Approval_Queue__mdt q : listApprovalQueue){
                        if(u.Location__c == q.Location__c){
                            for(Group g : listQueues){
                                if(g.Name == q.Location_TL_Queue__c){
                                    iw.escalatedQueue = g.id;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }
            System.debug(LoggingLevel.Error, iw); 
            output.put(u.id, iw);
        }        
        
        return output;
    }
    
    private void reScheduleNextRun(){
        Try{
            QCC_RecoveryApprovalSLA__mdt raSLA = [Select id, Scheduler_Frequency__c,SLA_Time__c 
                                                  FROM QCC_RecoveryApprovalSLA__mdt 
                                                  WHERE MasterLabel='QCC_RecoveryApproverReassignScheduler' limit 1];
            
            List<CronTrigger> lstJobs = [Select id FROM CronTrigger Where CronJobDetail.Name = 'QCC_RecoveryApproverReassignScheduler'];
            
            for(CronTrigger ct : lstJobs){
                System.abortJob(ct.id);
            }
            
            QCC_RecoveryApproverReassignScheduler pa= new QCC_RecoveryApproverReassignScheduler();
            integer interval = Integer.valueOf(raSLA.Scheduler_Frequency__c); 
            DateTime nowSchedule = System.Now().addMinutes(interval);
            String day = string.valueOf(nowSchedule.day());
            String month = string.valueOf(nowSchedule.month());
            String hour = string.valueOf(nowSchedule.hour());
            String minute = string.valueOf(nowSchedule.minute());
            String second = string.valueOf(nowSchedule.second());
            String year = string.valueOf(nowSchedule.year());
            
            String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            System.schedule('QCC_RecoveryApproverReassignScheduler', strSchedule, pa);
        }catch(exception ex){
        }
    }
    
    
    public class infoWrapper{
        public String businessHourIds{get;set;}
        public String escalatedQueue{get;set;}
        public String Location{get;set;}
        public String actorId{get;set;}
    } 
}