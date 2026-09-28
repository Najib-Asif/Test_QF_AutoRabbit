global class Account_Ownership_Update_Daily_Batch implements Database.Batchable<sObject> {
    
    String query = 'SELECT Id, OwnerId, Name, (SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE  Estimated_Total_Air_Travel_Spend__c >= 300000 AND Estimated_Total_Air_Travel_Spend__c < 1000000 AND (RecordType.Name=\'Prospect Account\' OR RecordType.Name=\'Customer Account\') ORDER BY Name';
    Map<String, Account_Owner__c> accOwnerMap = new Map<String, Account_Owner__c>();    
    List<Account_Owner__c> allAO;
    
    global Account_Ownership_Update_Daily_Batch(){
        allAO = [SELECT Id, Name,Update_Required_AM__c,Update_Required_BDR__c,Account_Manager__c,Business_Development_Rep__c,Old_Account_Manager__c,Old_BDR__c
                 FROM Account_Owner__c
                 Where Update_Required_AM__c = true OR Update_Required_BDR__c = true];         
        
        for(Account_Owner__c ao : allAO){
            accOwnerMap.put(ao.Name, ao);
        }    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<Account> filteredAccnts){    
                         
        List<Account> updateAccounts = new List<Account>();
        List<AccountTeamMember> deleteATMList = new List<AccountTeamMember>();
        List<AccountTeamMember> insertATMList = new List<AccountTeamMember>();
        
        for(Account acc : filteredAccnts){
            
            if(accOwnerMap.get(acc.Name.subString(0,1)) != null){
                Account_Owner__c accountOwner = accOwnerMap.get(acc.Name.subString(0,1));
                
                for(AccountTeamMember atm : acc.AccountTeamMembers){                    
                    // Deleting Account Manager, Adding new Account Manager to team & replacing the Account Owner with new AM
                    if(accountOwner.Update_Required_AM__c && (acc.OwnerId == accountOwner.Old_Account_Manager__c || atm.UserId == accountOwner.Old_Account_Manager__c) && atm.TeamMemberRole == 'Account Manager'){
                        deleteATMList.add(atm);
                       
                        AccountTeamMember member = new AccountTeamMember();
                        member.AccountId = acc.Id;
                        member.UserId = accountOwner.Account_Manager__c;
                        member.TeamMemberRole = 'Account Manager';
                        insertATMList.add(member);
                        if(acc.OwnerId == accountOwner.Old_Account_Manager__c){ 
                            acc.OwnerId = accountOwner.Account_Manager__c;
                            updateAccounts.add(acc);
                        }                      
                    }
                    // Deleting Business Development Rep, Adding new BDR to team
                    if(accountOwner.Update_Required_BDR__c && atm.UserId == accountOwner.Old_BDR__c && atm.TeamMemberRole == 'Business Development Rep'){
                        deleteATMList.add(atm);
                       
                        AccountTeamMember member1 = new AccountTeamMember();
                        member1.AccountId = acc.Id;
                        member1.UserId = accountOwner.Business_Development_Rep__c;
                        member1.TeamMemberRole = 'Business Development Rep';
                        
                        insertATMList.add(member1);                      
                    }
                                              
                }                             
            }
        }      
        
        try{
           Database.Delete(deleteATMList);
           Database.Insert(insertATMList);           
           Database.Update(updateAccounts);           
        }catch(Exception e){
           System.debug('Exception Occured: '+e.getMessage());   
        }
    }
    
    global void finish(Database.BatchableContext ctx){
    
        for(Account_Owner__c ao : allAO){
            ao.Update_Required_AM__c = false;
            ao.Update_Required_BDR__c = false;
            ao.Old_Account_Manager__c = null;
            ao.Old_BDR__c = null;
        }
        
        try{
            Database.Update(allAO);
        }catch(Exception e){
            System.debug('Exception Occured : '+e.getMessage());
        }
    
    }   

}