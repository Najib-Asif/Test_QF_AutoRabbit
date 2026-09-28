/*Last Modified By   : Vinoth Balasubramanian (Added the comments in the line where the changes are done)
                 JIRA : CRM - 2017 */
                 
public class RiskReportExport {
   
    public List<RiskReportWrapper> getRiskWrapperList(){
        Set<Id> accIds = new Set<Id>();
        
        /*List<Risk__c> allRisks = [SELECT Account_Manager__c, Amount_Risk__c, Account__r.Name, Amount_At_Risk__c, Risk_Level__c, Risk_Indicator__c, At_Risk_Since__c, Reason_At_Risk__c, 
                    (SELECT Id, Subject, Owner.Name, ActivityDate, Subtype__c, Task_type__c, Description FROM ActivityHistories ORDER BY ActivityDate DESC LIMIT 1000),
                    (SELECT Id, Subject, Owner.Name, ActivityDate, Subtype__c, Task_type__c, Description FROM Tasks WHERE Subtype__c != 'Action Taken'ORDER BY ActivityDate DESC nulls last LIMIT 10000)
                FROM Risk__c WHERE Active__c = true ORDER BY Risk_Level_Sort__c ASC LIMIT 1000];*/
                
        //CRM-2017 - Changed order of Actions Taken/Next Steps to show oldest action first, only include the most recent 3 Actions Taken / Next Steps, Added the Risk Description, QF International Market share and QF Domestic Market share fields in below query (Commented the above query and added the below one)
                
        List<Risk__c> allRisks = [SELECT Account_Manager__c, Amount_Risk__c, Account__r.Name, Amount_At_Risk__c, Risk_Level__c, Risk_Indicator__c, At_Risk_Since__c, Reason_At_Risk__c, Risk_Description__c,Account__r.QF_International_Market_Share__c,Account__r.QF_Domestic_Market_Share__c,
                    (SELECT Id, Subject, Owner.Name, ActivityDate, Subtype__c, Task_type__c, Description FROM ActivityHistories ORDER BY ActivityDate DESC LIMIT 3),
                    (SELECT Id, Subject, Owner.Name, ActivityDate, Subtype__c, Task_type__c, Description FROM Tasks WHERE Subtype__c != 'Action Taken'ORDER BY ActivityDate DESC nulls last LIMIT 3)
                FROM Risk__c WHERE Active__c = true ORDER BY Risk_Level_Sort__c ASC LIMIT 1000];
        
        for(Risk__c rr : allRisks){
            accIds.add(rr.Account__c);
        }    
        
        List<Account_Relation__c> allRelations = [SELECT Id, Primary_Account__c, Primary_Account__r.Name, Related_Account__c, Relationship__c 
                                                  FROM Account_Relation__c 
                                                  WHERE Relationship__c='Travel Manager Of' AND Related_Account__c IN :accIds AND Active__c = true];
        Map<Id, Account_Relation__c> accRlships = new Map<Id, Account_Relation__c>();
        
        for(Account_Relation__c ar : allRelations){
            if(!accRlships.containsKey(ar.Related_Account__c)) accRlships.put(ar.Related_Account__c, ar);            
        }        
        
        List<RiskReportWrapper> wrapperList = new List<RiskReportWrapper>();
        
        for(Risk__c r : allRisks){           
           RiskReportWrapper rr = new RiskReportWrapper(r, accRlships.get(r.Account__c));
           wrapperList.add(rr);       
        }
        
        return wrapperList;
    }
    
    public class RiskReportWrapper{
        public Account_Relation__c acc {get; set;}
        public Risk__c risk {get; set;}
        public RiskReportWrapper(Risk__c r, Account_Relation__c ac){
            acc = new Account_Relation__c();
            risk = new Risk__c();
            acc = ac;
            risk = r;
        }
    }
    
    public PageReference exportExcel(){
        return new PageReference('/apex/RiskDetailReportsExport');
    }

}