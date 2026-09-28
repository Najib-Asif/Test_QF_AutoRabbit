/**********************************************************************************************************************************
 
    Created Date: 25/02/2015
 
    Description: Process Opportunity trigger for:
                 1. Assign opportunity team members based on user department after insert.
  
    Versión:
    V1.0 - 25/02/2015 - Initial version [FO]
 
**********************************************************************************************************************************/

trigger OpportunityTeam on Opportunity (after insert, before insert, before update) {
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('OpportunityTeam');
        if(ts.Active__c){
        
            if (Trigger.isInsert) {
                
                /* 
                *Before insert process
                */
              /* if (Trigger.isBefore) { */
                    /* Fetch users based on department and change the opportunity owner if the user is a lead*/
                 /*   for(user teamMember :[SELECT id, Department, Department_Lead__c FROM user WHERE Department = 'Marketing Acquisition & Sales Team' ]){
                        for(Opportunity opp : Trigger.new){
                            if(opp.StageName == 'Identified'){                
                                if(teamMember.Department_Lead__c == true){
                                    opp.OwnerId = teamMember.id;
                                }
                            }
                        }
                    }            
                    
                } */
        
                /*
                *After insert process 
                */
                if (Trigger.isAfter) {
                    
                    /*
                    *Assign opportunity team members based on user department.
                    */
                    
                    List<OpportunityTeamMember> newOpportunityTeamMembers = new List<OpportunityTeamMember>();
                    OpportunityTeamMember oppoTeamMember;
                    /* Fetch parent account details */
                    Map<id, Account> oppoAccounts = new Map<id, Account>([SELECT id, Aquire__c, Account.Type FROM Account WHERE id IN(SELECT AccountId FROM opportunity WHERE id IN:Trigger.newMap.keyset())]);
                   
                    /* Fetch users based on department*/
                    for(user teamMember :[SELECT id, Department, Department_Lead__c FROM user WHERE Department = 'Marketing Acquisition & Sales Team' AND IsActive = true]){
                    
                        /* Create and assign opportunity team members for accounts from Aquire and of type Prospect Account*/
                        for(Opportunity opp : Trigger.new){
                             if(oppoAccounts.get(opp.AccountId).Aquire__c == true && oppoAccounts.get(opp.AccountId).Type == 'Prospect Account' && opp.StageName == 'Identified'){
                                    oppoTeamMember = new OpportunityTeamMember();
                                    oppoTeamMember.OpportunityId = opp.Id;
                                    oppoTeamMember.UserId = teamMember.id;
                                    oppoTeamMember.TeamMemberRole = teamMember.Department;               
                                    newOpportunityTeamMembers.add(oppoTeamMember);
                              }
                              
                         }
                    }
                    
                    /* Save the changes to the system */
                    if(newOpportunityTeamMembers.size() > 0){
                      Database.insert(newOpportunityTeamMembers);
                    }
                }
            }
        }
    }catch(Exception e){
        System.debug('Error Occured From Opportunity Trigger: '+e.getMessage());
    }
}