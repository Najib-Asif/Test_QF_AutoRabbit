/***********************************************************************************************************************************

Description: Apex controller for Portfolio Lightning component

History:
======================================================================================================================
Name                    Jira        Description                                                                Tag
======================================================================================================================
Pushkar Purushothaman   CRM-3075        Apex controller for Portfolio Lightning component                       T01
Pushkar Purushothaman   CRM-3369        Allow health indicator only for contracted accounts                     T02
Pushkar Purushothaman   CRM-3370        Changes for key contact filter and declining accounts for 2 months      T03                                     

Created Date    : 23/04/2018 (DD/MM/YYYY)
Test Class      : PortfolioControllerTest
**********************************************************************************************************************************/
public with sharing class PortfolioController {
    @auraEnabled(cacheable=true)
    public static List<User> fetchRoleUsers(Id userId){
        return RoleUtils.getRoleSubordinates(userId);
    }    
    
    @auraEnabled(cacheable=true)
    public static List<Opportunity> fetchOpps(Id userId,String TeamOrMine,String[] roleIds){
        String qryStr=''; 
        List<Opportunity> oppList =  new List<Opportunity>();
        if(TeamOrMine == 'myPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name FROM Opportunity WHERE OwnerId = \''+userId+'\' AND CloseDate = NEXT_N_DAYS:30 AND Account.Contracted__c = TRUE ORDER BY Name ASC';
            oppList = Database.query(qryStr);
        }else if(TeamOrMine == 'myTeamPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name FROM Opportunity WHERE CloseDate = NEXT_N_DAYS:30 AND OwnerId IN : roleIds AND Account.Contracted__c = TRUE ORDER BY Name ASC';
            oppList = Database.query(qryStr);
            
        }
        return oppList;
        
    }
    
    @auraEnabled(cacheable=true)
    public static String fetchAccountWOKeyContacts(Id userId,String TeamOrMine,String[] roleIds){
        String qryStr='';
        Set<String> custAccIds = new Set<String>();
        List<Account> custAccts = new List<Account>();
        List<Account> accList = new List<Account>();
        List<Account> acckycWOActivities = new List<Account>();
        Map<Id,Account> keyContAccMap = new Map<Id,Account>();
        Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        
        if(TeamOrMine == 'myPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name,(SELECT contact.id, contact.name, Job_Title__c, contact.Tier_loyalty__c, contact.Tier_f__c,contact.Tier_Conga__c, contact.Chairman_lounge_status__c, contact.Customer_Headlines__c, Job_Role__c from AccountContactRelations where contact.Active__c = TRUE and (Key_Contact__c = TRUE or Job_role__c in (\'Chief of the organisation\',\'Chief of Organisation\',\'Chief of Finance\',\'Chief of Procurement\',\'Procurement / supply management\'))) FROM Account WHERE Type=\'Customer Account\' AND OwnerId = \''+userId+'\' AND Contracted__c = TRUE ORDER BY Name ASC';
            for(Account acc : Database.query(qryStr)){
                if(acc.AccountContactRelations.size() == 0){
                    accList.add(acc);
                }
                else{
                    for(AccountContactRelation acr : acc.AccountContactRelations){
                        keyContAccMap.put(acr.contact.id,acc);
                        System.debug(acr.contact.name);
                    }
                }
                custAccIds.add(acc.id);
                custAccts.add(new Account(id=acc.id,Name=acc.Name,Owner=(User)acc.Owner));
            }
            for(Contact cont : [SELECT id,Name,(SELECT id FROM Events WHERE CreatedDate = LAST_N_DAYS:60),(SELECT id FROM Tasks WHERE CreatedDate = LAST_N_DAYS:60) FROM Contact WHERE id IN :keyContAccMap.keySet()  AND RecordTypeId =: ContRecordTypeId ORDER BY Account.Name ASC]){
                if(cont.Events.size() == 0 && cont.Tasks.size() == 0){
                    acckycWOActivities.add(new Account(id=keyContAccMap.get(cont.id).id,Name=keyContAccMap.get(cont.id).Name,Owner=keyContAccMap.get(cont.id).Owner,key_Contact_Office_ID__c=cont.Name,SF_JobID__c = cont.id));
                }
            }
        }
        else if(TeamOrMine == 'myTeamPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name,(SELECT contact.id, contact.name, Job_Title__c, contact.Tier_loyalty__c, contact.Tier_f__c,contact.Tier_Conga__c, contact.Chairman_lounge_status__c, contact.Customer_Headlines__c, Job_Role__c from AccountContactRelations where contact.Active__c = TRUE and (Key_Contact__c = TRUE or Job_role__c in (\'Chief of the organisation\',\'Chief of Organisation\',\'Chief of Finance\',\'Chief of Procurement\',\'Procurement / supply management\'))) FROM Account WHERE Type=\'Customer Account\' AND OwnerId IN : roleIds AND Contracted__c = TRUE ORDER BY Name ASC';
            List<Account> custAccList = Database.query(qryStr);
            for(Account acc : custAccList){
                if(acc.AccountContactRelations.size() == 0){
                    accList.add(acc);
                }
                else{
                    for(AccountContactRelation acr : acc.AccountContactRelations){
                        keyContAccMap.put(acr.contact.id,acc);
                    }
                }
                custAccIds.add(acc.id);
                custAccts.add(new Account(id=acc.id,Name=acc.Name,Owner=(User)acc.Owner));
                
            }
            for(Contact cont : [SELECT id,Name,Account.Name,(SELECT id FROM Events WHERE CreatedDate = LAST_N_DAYS:60),(SELECT id FROM Tasks WHERE CreatedDate = LAST_N_DAYS:60) FROM Contact WHERE id IN :keyContAccMap.keySet() AND RecordTypeId =: ContRecordTypeId ORDER BY Account.Name ASC]){
                if(cont.Events.size() == 0 && cont.Tasks.size() == 0){
                    acckycWOActivities.add(new Account(id=keyContAccMap.get(cont.id).id,Name=keyContAccMap.get(cont.id).Name,Owner=keyContAccMap.get(cont.id).Owner,key_Contact_Office_ID__c=cont.Name,SF_JobID__c = cont.id));
                }
            }
        }
        System.debug('custAccIds'+custAccIds);
        return JSON.serialize(accList)+'*'+JSON.serialize(acckycWOActivities)+'*'+JSON.serialize(custAccIds)+'*'+JSON.serialize(custAccts);
    }
    
    @auraEnabled(cacheable=true)
    public static List<Opportunity> fetchOverdueOpps(Id userId,String TeamOrMine,String[] roleIds){
        String qryStr='';
        
        if(TeamOrMine == 'myPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name FROM Opportunity WHERE OwnerId = \''+userId+'\' AND isClosed = false AND CloseDate < TODAY AND Account.Contracted__c = TRUE ORDER BY Name ASC';
        }else if(TeamOrMine == 'myTeamPf'){
            qryStr = 'SELECT id,Name,OwnerId,Owner.Name FROM Opportunity WHERE isClosed = false AND CloseDate < TODAY AND OwnerId IN : roleIds AND Account.Contracted__c = TRUE ORDER BY Name ASC';
        }
        
        return Database.query(qryStr);
    }
    
    @auraEnabled(cacheable=true)
    public static List<List<Account>> fetchShareDecliningAccounts(Id userId,String TeamOrMine,String[] roleIds){
        List<Account> decAccList = new List<Account>();
        List<Account> decAccNoRiskList = new List<Account>();
        List<List<Account>> accListDecRiskFinal = new List<List<Account>>();
        Set<Id> accIdSetFinal = new Set<Id>();
        Set<Id> accIdRiskSet = new Set<Id>();
        Set<Id> AccIdSet = new Set<Id>();
        Map<String,Snapshot__c> snpShotMap = new Map<String,Snapshot__c>();
        Set<Date> snpDateSet = new Set<Date>();
        Integer n=Integer.valueOf(Label.Account_Declining_Years_Portfolio)+1;
        String qryStr ='';
        if(TeamOrMine == 'myPf'){
            
            qryStr = 'SELECT account__r.id,account__r.Name,account__r.OwnerId,account__r.Owner.Name,Snapshot_Date__c,Total_Market_Share_YTD__c FROM snapshot__c WHERE account__r.type=\'Customer Account\' AND snapshot_date__c>= LAST_N_MONTHS:'+n+' AND account__r.OwnerId= \''+userId+'\' AND Name=\'Account Share Decline Snapshot\' AND account__r.Contracted__c = TRUE ORDER BY snapshot_date__c DESC';
            
        }    
        else if(TeamOrMine == 'myTeamPf'){
            qryStr = 'SELECT account__r.id,account__r.Name,account__r.OwnerId,account__r.Owner.Name,Snapshot_Date__c,Total_Market_Share_YTD__c FROM snapshot__c WHERE account__r.type=\'Customer Account\' AND snapshot_date__c>= LAST_N_MONTHS:'+n+' AND account__r.OwnerId IN : roleIds AND Name=\'Account Share Decline Snapshot\' AND account__r.Contracted__c = TRUE ORDER BY snapshot_date__c DESC';            
        }

        for(Snapshot__c snp : Database.query(qryStr)){
            snpShotMap.put(snp.account__r.id+string.valueof(snp.Snapshot_Date__c),snp);
            if(snp.Total_Market_Share_YTD__c >0.0)
                snpDateSet.add(snp.Snapshot_Date__c);
            AccIdSet.add(snp.account__r.id);
        }
        System.debug('Aggr : '+snpShotMap);
        List<Date> dateLst = new List<Date>(snpDateSet);
        dateLst.sort();
        System.debug('snpDate  : '+ dateLst);
        
        for(Id accId : AccIdSet){
            Integer declineCount = 0;
            for(integer i=dateLst.size()-1; i>=1; i--){
                if(i>0){
                    Decimal val1 = 0; 
                    Decimal val2 = 0; 
                    Boolean inSnpShotMap = true;
                    if(snpShotMap.containsKey(accId+string.valueof(dateLst[i]))){
                        val1 = snpShotMap.get(accId+string.valueof(dateLst[i])).Total_Market_Share_YTD__c;
                    }else{
                        inSnpShotMap = false;
                    }
                    if(snpShotMap.containsKey(accId+string.valueof(dateLst[i-1]))){
                        val2 = snpShotMap.get(accId+string.valueof(dateLst[i-1])).Total_Market_Share_YTD__c;
                    }else{
                        inSnpShotMap = false;
                    }
                    if(val1 < val2 && inSnpShotMap){
                        declineCount++;
                        if(declineCount == Integer.valueOf(Label.Account_Declining_Years_Portfolio)){
                            decAccList.add(new Account(id=accId,Name=snpShotMap.get(accId+string.valueof(dateLst[i])).account__r.Name,OwnerId = snpShotMap.get(accId+string.valueof(dateLst[i])).account__r.OwnerId,Account_Alias__c = snpShotMap.get(accId+string.valueof(dateLst[i])).account__r.Owner.Name));
                            accIdSetFinal.add(accId);
                            System.debug('finallist'+decAccList);
                        }
                        continue;
                    }else{
                        break;
                    }
                }
                
            }
        }
       
        for(Risk__c risk : [SELECT id,Account__r.id,Account__r.Name FROM Risk__c WHERE Account__c IN :accIdSet AND Active__c=true]){
            accIdRiskSet.add(risk.Account__r.id);
        }
        for(Account accInst : decAccList){
            if(!accIdRiskSet.contains(accInst.id)){
                decAccNoRiskList.add(accInst);
            }
        }
        
        accListDecRiskFinal.add(decAccList);
        accListDecRiskFinal.add(decAccNoRiskList);
        return accListDecRiskFinal;
    }
}