/*********************************************************************************
Name         : QCC_MemberTierDowngradeBatch
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 20 November 2019
Usages       : This class is used to update Contact Tier
*********************************************************************************/
public class QCC_MemberTierDowngradeBatch implements Database.Batchable<sObject>{
    public String query;
    public Map<String,QCC_Loyalty_Status__e> loyaltyStatusMap; // Map<FFnumber,Loyalty Event>
    public List<String> ffNumberList;
   
    public QCC_MemberTierDowngradeBatch(Map<String,QCC_Loyalty_Status__e> loyaltyStatusMaps){
        loyaltyStatusMap = loyaltyStatusMaps;
        ffNumberList = new List<String>(loyaltyStatusMap.keySet()); // List will be use to query Contact record
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
        query = 'SELECT Id,Frequent_Flyer_Number__c,Frequent_Flyer_Tier__c,QCC_Previous_Frequent_Flyer__c,QCC_Previous_EffectiveTier__c FROM Contact WHERE RecordTypeId =: individualContactRecordTypeId AND Frequent_Flyer_Number__c IN: ffNumberList';
        if(Test.isRunningTest()){
            query = query + ' LIMIT 1'; //Prevent more than one execute batch in test class
        }
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        try{
            system.debug('scope : '+scope);
            List<Contact> contactUpdateList = new List<Contact>();
            for(Contact contactRecord : scope){
                contactRecord.QCC_Effective_Tier__c = loyaltyStatusMap.get(contactRecord.Frequent_Flyer_Number__c).effectiveTier__c; // Tier Effective Tier Accept Tiercode as API name
                contactRecord.Frequent_Flyer_Tier__c = CustomSettingsUtilities.getConfigDataMap(loyaltyStatusMap.get(contactRecord.Frequent_Flyer_Number__c).effectiveTier__c); //Setting to get Tier code description.
                contactRecord.QCC_Previous_Frequent_Flyer__c = loyaltyStatusMap.get(contactRecord.Frequent_Flyer_Number__c).previousTier__c; // Previous Frequent Flyer Tier Accept Tiercode as API name
                contactRecord.QCC_Previous_EffectiveTier__c = loyaltyStatusMap.get(contactRecord.Frequent_Flyer_Number__c).previousTier__c; // QCC_Previous_EffectiveTier__c Accept Tiercode as API name
                contactUpdateList.add(contactRecord);
            }
            
            //Update Contact Record
            update contactUpdateList;
            
        } catch (Exception ex) {
            //TO-DO: Error Handling
            system.debug('ERROR : ' + ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Member Tier Downgrade Batch Job', 'QCC_MemberTierDowngradeBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }     
    public void finish(Database.BatchableContext BC){
        
    }
}