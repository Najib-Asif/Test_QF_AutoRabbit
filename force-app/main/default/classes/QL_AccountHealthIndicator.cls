/***********************************************************************************************************************************

Description: Apex controller for Account Health Indicator Lightning component

History:
======================================================================================================================
Name                    Jira        Description                                                                Tag
======================================================================================================================
Pushkar Purushothaman   CRM-3075    	Apex controller for Account Health Indicator Lightning component           T01
Pushkar Purushothaman   CRM-3336    	Logic added for freight accounts           								   T02
Pushkar Purushothaman   CRM-3369,3368	Allow health indicator only for contracted accounts;download all		   T03
										account parameters and overall indicator

Created Date    : 23/04/2018 (DD/MM/YYYY)

**********************************************************************************************************************************/

public class QL_AccountHealthIndicator {
    @AuraEnabled
    public static String fetchRecordType(){
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
    }
    
    @AuraEnabled
    public static String computePercentage_Freight(String[] recordIds,String sObjectName,Boolean recordDetail){
        Decimal activeSAP = 0;
        Decimal activeContact = 0;
        Decimal activeEngagement = 0;
        Decimal activeOppty = 0;
        Decimal accHealth = 0;
        String accHealthStr = '';
        
        Id oppFreightRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
        List<Account> accts = [SELECT id,Name,Activity_Created_Last_30_Days__c,
                               (SELECT id FROM Strategic_Account_Plans__r WHERE SAP_Type__c='Other' AND Status__c='Active'),
                               (SELECT contact.id, contact.name, Job_Title__c, contact.Tier_loyalty__c, contact.Tier_f__c,contact.Tier_Conga__c, contact.Chairman_lounge_status__c, contact.Customer_Headlines__c, Job_Role__c FROM AccountContactRelations WHERE contact.Active__c = TRUE AND contact.Business_Types__c = 'Freight' AND Job_role__c in ('Chief Executive Officer','Chief of Finance','Chief of Organisation','Chief of the Organisation','Chief of Business Unit','Owner','Partner')),
                               (SELECT id,Status_Last_Changed__c FROM Opportunities WHERE RecordTypeId=:oppFreightRecTypeId) 
                               FROM Account 
                               WHERE id IN :recordIds 
                               ORDER BY Name ASC];
        
        if(accts.size() > 0){
            for(Account acc : accts){
                for(Strategic_Account_Plan__c sap : acc.Strategic_Account_Plans__r){
                    activeSAP = 1;
                } 
                for(AccountContactRelation acr : acc.AccountContactRelations){
                    activeContact = 1;
                }
                for(Opportunity opp : acc.Opportunities){
                    if(opp.Status_Last_Changed__c != null){
                        if((opp.Status_Last_Changed__c).daysBetween(Date.today()) <= 30)
                            activeOppty = 1;
                    }
                }
                accHealth += ((activeSAP + activeContact + activeOppty + acc.Activity_Created_Last_30_Days__c)/(4*accts.size()));
            }
            accHealthStr = String.valueOf(Math.round(accHealth* 100));
        }
        return accHealthStr+'*'+String.valueOf(activeSAP)+'*'+String.valueOf(activeContact)+'*'+String.valueOf(activeOppty)+'*'+String.valueOf(accts[0].Activity_Created_Last_30_Days__c);
    }
    
    //method to compute the percentage for account health and return the concatenated string of resultant percentage along with details for legend
    @AuraEnabled
    public static String computePercentage(String[] recordIds,String sObjectName,Boolean recordDetail){
        System.debug('recordDetail'+recordDetail);
        String accHealthStr = '';
        String accOwner='';
        Decimal accHealth = 0;
        Decimal activeSAP = 0;
        Decimal updatedSAP = 0;
        Decimal noOverdueOpp = 0;
        Decimal contractSigned = 0;
        Decimal activityLast90Days = 0;
        Decimal accReview = 0;
        DateTime closeDateReview = null;
        
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> ownerNameSet = new Set<String>();
        Set<Account> activeSAPAccIdSet = new Set<Account>();
        Set<Account> updatedSAPAccIdSet = new Set<Account>();
        Set<Account> reviewAccIdSet = new Set<Account>();
        Set<Account> activityAccIdSet = new Set<Account>();
        Set<Account> overdueOppAccIdSet = new Set<Account>();
        Set<Account> contractUnSignedAccIdSet = new Set<Account>();
        List<accountHealthWrapper> accHealthWrapList = new List<accountHealthWrapper>();
        
        List<Account> accts = [SELECT id,Name,Owner.Name,Account_Review_Completed_Last_90_Days__c,Last_Completed_Account_Review__c,No_of_Days_Since_Last_Created_Activity__c,Total_QF_Revenue_TY__c,Total_Air_Travel_Spend__c,QF_Domestic_Revenue__c,QF_Domestic_Market_Share__c,Intl_QF_EK_Revenue_TY__c,QF_International_Market_Share__c,
                               (SELECT id,SAP_Active_and_Update_Last_3_Months__c FROM Strategic_Account_Plans__r WHERE SAP_Type__c='B&G' AND Status__c='Active'),
                               (SELECT id,Overdue_Opportunity__c FROM Opportunities WHERE Type='Business and Government'),
                               (SELECT id,ClosedDate FROM Cases WHERE Type='Account Review' and isClosed=true ORDER BY ClosedDate DESC LIMIT 1)
                               FROM Account 
                               WHERE id IN :recordIds AND Contracted__c = TRUE ORDER BY Name ASC];
        if(accts.size() > 0){
            for(Account acc : accts){
                
                activeSAP = 0;
                updatedSAP = 0;
                noOverdueOpp = 0;
                contractSigned = 0;
                activityLast90Days = 0;
                accReview = 0;
                
                for(Strategic_Account_Plan__c sap : acc.Strategic_Account_Plans__r){
                    activeSAP = 1;
                    activeSAPAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    if(sap.SAP_Active_and_Update_Last_3_Months__c == 1){
                        updatedSAP = 1;
                        updatedSAPAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                    
                }
                    
                if(acc.Cases.size() > 0){
                    for(Case cs : acc.Cases){
                    	closeDateReview = cs.ClosedDate;
                    }
                	
                }
                if(acc.Last_Completed_Account_Review__c != null){
                if(acc.Last_Completed_Account_Review__c > closeDateReview || closeDateReview == null){
                    if(Integer.valueOf((Datetime.now().getTime() - acc.Last_Completed_Account_Review__c.getTime())/(1000*60*60*24)) <= 90){
                        accReview = 1;
                        reviewAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                    
                }else if(acc.Last_Completed_Account_Review__c < closeDateReview){
                    if(Integer.valueOf((Datetime.now().getTime() - closeDateReview.getTime())/(1000*60*60*24)) <= 90){
                        accReview = 1;
                        reviewAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                }
                }
                
                if(acc.No_of_Days_Since_Last_Created_Activity__c <= 90){
                    System.debug('Activity True');
                    activityLast90Days = 1;
                    activityAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                }
                if(acc.Opportunities.size() > 0){
                    for(Opportunity opp : acc.Opportunities){
                        if(opp.Overdue_opportunity__c == 0){
                            noOverdueOpp = 1;
                        }   
                        else{
                            noOverdueOpp = 0;
                            overdueOppAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                            break;
                        }           
                    }
                }else{
                    noOverdueOpp = 1;
                    System.debug('Iam not there');
                }
                for(Opportunity opp : acc.Opportunities){
                    oppIdSet.add(opp.Id);
                    
                }
                ownerNameSet.add(acc.Owner.Name);
                accountHealthWrapper AHW = new accountHealthWrapper();
                AHW.AcntId=acc.Id;
                AHW.AcntName=acc.Name;
                AHW.accDomRev=acc.QF_Domestic_Revenue__c;
                AHW.accDomShare=(acc.QF_Domestic_Market_Share__c != null)?(acc.QF_Domestic_Market_Share__c):0;
                AHW.accIntRev=acc.Intl_QF_EK_Revenue_TY__c;
                AHW.accIntShare=(acc.QF_International_Market_Share__c != null)?(acc.QF_International_Market_Share__c):0;
                AHW.activeSAP=activeSAP;
                AHW.updatedSAP=updatedSAP;
                AHW.accReviewed=accReview;
                AHW.actCreated=activityLast90Days;
                AHW.noOverdueOpp=noOverdueOpp;
                AHW.noUnsignedContracts=1;
                accHealthWrapList.add(AHW);
                accHealth += ((accReview + activityLast90Days + activeSAP + updatedSAP + noOverdueOpp)/(6 * accts.size()));
                System.debug('accHealth***'+accHealth );            
            }
            System.debug('accHealthTotal***'+accHealth );
            
            List<Contract__c> contractLst = [SELECT Id,Contract_Not_Signed__c,Account__c,Account__r.Name FROM Contract__c WHERE Opportunity__c IN : oppIdSet];
            if(contractLst.size() > 0){
                for(Contract__c cntrct : contractLst){
                    if(cntrct.Contract_Not_Signed__c == 0){   
                        contractSigned = 1;  
                    }   
                    else{
                        
                        contractSigned = 0;
                        for(accountHealthWrapper ahw : accHealthWrapList){
                            if(ahw.AcntId == cntrct.Account__c){
                                ahw.noUnsignedContracts = 0;
                            }
                            
                        }
                        contractUnSignedAccIdSet.add(new Account(id=cntrct.Account__c,Name=cntrct.Account__r.Name));                    
                    }          
                }
            }else{
                contractSigned = 1;
            }
            if(ownerNameSet.size() == 1){
                for(String str : ownerNameSet){
                    accOwner = str;
                    break;
                }
            }
            
            Decimal contractSignedNum = (contractUnSignedAccIdSet.size() > 0 || contractSigned == 1)?(accts.size()-contractUnSignedAccIdSet.size()): accts.size();
            Decimal div = 6 * accts.size();
                accHealth += (contractSignedNum/div);
            accHealthStr = String.valueOf(Math.round(accHealth* 100));
        }
        
        if(recordDetail)
            return accHealthStr+'*'+String.valueOf(activeSAP)+'*'+String.valueOf(updatedSAP)+'*'+String.valueOf(accReview)+'*'+String.valueOf(activityLast90Days)+'*'+String.valueOf(noOverdueOpp)+'*'+String.valueOf(contractSigned);
        else
            return accHealthStr+'*'+JSON.serialize(activeSAPAccIdSet)+'*'+JSON.serialize(updatedSAPAccIdSet)+'*'+JSON.serialize(reviewAccIdSet)+'*'+JSON.serialize(activityAccIdSet)+'*'+JSON.serialize(overdueOppAccIdSet)+'*'+JSON.serialize(contractUnSignedAccIdSet)+'*'+JSON.serialize(accHealthWrapList);
    }
    
     //method to compute the percentage for account health and return the concatenated string of resultant percentage along with details for legend
    @AuraEnabled
    public static String computePercentageNonContractedQBR(String[] recordIds,String sObjectName,Boolean recordDetail){
        System.debug('recordDetail'+recordDetail);
        String accHealthStr = '';
        String accOwner='';
        Decimal accHealth = 0;
        Decimal activeSAP = 0;
        Decimal updatedSAP = 0;
        Decimal noOverdueOpp = 0;
        Decimal contractSigned = 0;
        Decimal activityLast90Days = 0;
        Decimal accReview = 0;
        Decimal activeB2BContact = 0;
        Decimal industry = 0;
        DateTime closeDateReview = null;
        
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> ownerNameSet = new Set<String>();
        Set<Account> activeSAPAccIdSet = new Set<Account>();
        Set<Account> updatedSAPAccIdSet = new Set<Account>();
        Set<Account> reviewAccIdSet = new Set<Account>();
        Set<Account> activityAccIdSet = new Set<Account>();
        Set<Account> activeB2BAccIdSet = new Set<Account>();
        Set<Account> industryAccIdSet = new Set<Account>();
        List<accountHealthWrapper> accHealthWrapList = new List<accountHealthWrapper>();
        
        List<Account> accts = [SELECT id,Name,Industry,Aquire_System__c,Owner.Name,Account_Review_Completed_Last_90_Days__c,Last_Completed_Account_Review__c,No_of_Days_Since_Last_Created_Activity__c,Total_QF_Revenue_TY__c,Total_Air_Travel_Spend__c,QF_Domestic_Revenue__c,QF_Domestic_Market_Share__c,Intl_QF_EK_Revenue_TY__c,QF_International_Market_Share__c,
                               (SELECT id,SAP_Active_and_Update_Last_3_Months__c FROM Strategic_Account_Plans__r WHERE SAP_Type__c='B&G' AND Status__c='Active'),
                               (SELECT id,Key_Contact__c FROM AccountContactRelations WHERE contact.Active__c = TRUE AND Key_Contact__c = TRUE),
                               (SELECT id,ClosedDate FROM Cases WHERE Type='Account Review' and isClosed=true ORDER BY ClosedDate DESC LIMIT 1)
                               FROM Account 
                               WHERE id IN :recordIds AND Contracted__c != TRUE ORDER BY Name ASC];
        if(accts.size() > 0){
            for(Account acc : accts){
                
                activeSAP = 0;
                updatedSAP = 0;
                activityLast90Days = 0;
                accReview = 0;
                activeB2BContact = 0;
                industry = 0;
                    if(acc.Industry != null)
                    industry = 1;
                    industryAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
               for(AccountContactRelation acr : acc.AccountContactRelations){
                    activeB2BContact = 1;
                    activeB2BAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                }               
                for(Strategic_Account_Plan__c sap : acc.Strategic_Account_Plans__r){
                    activeSAP = 1;
                    activeSAPAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    if(sap.SAP_Active_and_Update_Last_3_Months__c == 1){
                        updatedSAP = 1;
                        updatedSAPAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                    
                }
                    
                if(acc.Cases.size() > 0){
                    for(Case cs : acc.Cases){
                    	closeDateReview = cs.ClosedDate;
                    }
                	
                }
                if(acc.Last_Completed_Account_Review__c != null){
                if(acc.Last_Completed_Account_Review__c > closeDateReview || closeDateReview == null){
                    if(Integer.valueOf((Datetime.now().getTime() - acc.Last_Completed_Account_Review__c.getTime())/(1000*60*60*24)) <= 90){
                        accReview = 1;
                        reviewAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                    
                }else if(acc.Last_Completed_Account_Review__c < closeDateReview){
                    if(Integer.valueOf((Datetime.now().getTime() - closeDateReview.getTime())/(1000*60*60*24)) <= 90){
                        accReview = 1;
                        reviewAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                    }
                }
                }
                
                if(acc.No_of_Days_Since_Last_Created_Activity__c <= 90){
                    System.debug('Activity True');
                    activityLast90Days = 1;
                    activityAccIdSet.add(new Account(id=acc.id,Name=acc.Name));
                }

                ownerNameSet.add(acc.Owner.Name);
                accountHealthWrapper AHW = new accountHealthWrapper();
                AHW.AcntId=acc.Id;
                AHW.AcntName=acc.Name;
                AHW.accDomRev=acc.QF_Domestic_Revenue__c;
                AHW.accDomShare=(acc.QF_Domestic_Market_Share__c != null)?(acc.QF_Domestic_Market_Share__c):0;
                AHW.accIntRev=acc.Intl_QF_EK_Revenue_TY__c;
                AHW.accIntShare=(acc.QF_International_Market_Share__c != null)?(acc.QF_International_Market_Share__c):0;
                AHW.activeSAP=activeSAP;
                AHW.updatedSAP=updatedSAP;
                AHW.accReviewed=accReview;
                AHW.actCreated=activityLast90Days;
                AHW.industry = industry;
                AHW.activeB2BContact = activeB2BContact;
                accHealthWrapList.add(AHW);
                accHealth += ((accReview + activityLast90Days + activeSAP + updatedSAP + industry + activeB2BContact)/(6 * accts.size()));
                System.debug('accHealth***'+accHealth );            
            }
            System.debug('accHealthTotal***'+accHealth );

            if(ownerNameSet.size() == 1){
                for(String str : ownerNameSet){
                    accOwner = str;
                    break;
                }
            }
            accHealthStr = String.valueOf(Math.round(accHealth* 100));
        }
        
        if(recordDetail)
            return accHealthStr+'*'+String.valueOf(activeSAP)+'*'+String.valueOf(updatedSAP)+'*'+String.valueOf(accReview)+'*'+String.valueOf(activityLast90Days)+'*'+String.valueOf(industry)+'*'+String.valueOf(activeB2BContact);
        else
          return accHealthStr+'*'+JSON.serialize(activeSAPAccIdSet)+'*'+JSON.serialize(updatedSAPAccIdSet)+'*'+JSON.serialize(reviewAccIdSet)+'*'+JSON.serialize(activityAccIdSet)+'*'+JSON.serialize(industryAccIdSet)+'*'+JSON.serialize(activeB2BAccIdSet)+'*'+JSON.serialize(accHealthWrapList);
    }
    
    public class accountHealthWrapper{
        @AuraEnabled public String AcntId = '';
        @AuraEnabled public String AcntName = '';
        @AuraEnabled public Decimal accDomRev = 0;
        @AuraEnabled public Decimal accDomShare = 0;
        @AuraEnabled public Decimal accIntRev = 0;
        @AuraEnabled public Decimal accIntShare = 0;
        @AuraEnabled public Decimal activeSAP = 0;
        @AuraEnabled public Decimal updatedSAP = 0;
        @AuraEnabled public Decimal accReviewed = 0;
        @AuraEnabled public Decimal actCreated = 0;
        @AuraEnabled public Decimal noOverdueOpp = 0;
        @AuraEnabled public Decimal noUnsignedContracts = 0;
        @AuraEnabled public Decimal industry = 0;
        @AuraEnabled public Decimal activeB2BContact = 0;
        
    }
    
}