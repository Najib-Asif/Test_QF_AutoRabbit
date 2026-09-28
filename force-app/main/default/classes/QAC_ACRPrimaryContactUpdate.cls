/********************************************************************************************************************************
* Author: TCS
* Description: To Update PrimaryContact field in ACR and make sure only one ACR is having PrimaryContact checked
* JIRA       :TS-4880
* ******************************************************************************************************************************/
public class QAC_ACRPrimaryContactUpdate{
    Public static boolean acrUpdated=false;
    public static void updateACR(List<AccountContactRelation> newList)
    {
        Set<String> agencyId = new Set<String>();
        Set<String> acrId = new Set<String>();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        List<AccountContactRelation> updateOldACR = new List<AccountContactRelation>();
        Map<String,AccountContactRelation> acrMap = new map<String,AccountContactRelation>();
        try{
            for(AccountContactRelation acr:newList)
            {
                if(acr.primary_contact__c)
                {
                    if(!acrMap.containskey(acr.AccountId)){
                        acrMap.put(acr.accountId,acr);
                    }
                    else{
                        System.debug('More than one ACR is Primary for ACcount');
                        acr.addError('More than one ACR has PrimaryContact Checked in the input Under Account, Please Make one ACR as Primary'+acr.accountId);
                    }
                    
                }
                if(acr.id!=null)
                    acrId.add(acr.id);
                
            }
            
            for(AccountContactRelation acr:[Select Id,AccountId,ContactId,Primary_Contact__c from AccountContactRelation where
                                            AccountId in:acrMap.keyset() and account.recordtypeId=:accRTId and Primary_Contact__c=true
                                            and id not in:acrid])
            {
                System.debug('ACR Update to false');
                AccountContactRelation acrUpdt = new AccountContactRelation();
                acrUpdt.Primary_Contact__c=false;
                acrUpdt.id=acr.id;
                updateOldACR.add(acrUpdt);
            }
            if(!updateOldACR.isempty())
            {
                acrUpdated=true;
                update updateOldACR;
                
            }
        }Catch(Exception e){}
    }
    
    public static void afterupdateACR(List<AccountContactRelation> newList,map<Id,AccountContactRelation> oldMap){
        List<AccountContactRelation> updatedList = new List<AccountContactRelation>();
        Map<String, boolean> accMap = new Map<String, boolean>();
        Map<String, AccountContactRelation> acrrecType = new Map<String,AccountContactRelation>();
        Set<String> accid = new Set<String>();
        for(AccountContactRelation acr: newList){
            if(oldMap.get(acr.id).primary_contact__c!=acr.Primary_Contact__c && acr.Primary_Contact__c )
                updatedList.add(acr);
            if(!acr.Primary_Contact__c)
                accid.add(acr.AccountId);
        }
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        for(AccountContactRelation acr : [Select Id,AccountId,ContactId,Primary_Contact__c,account.recordtypeId,account.Iata_Number__c from AccountContactRelation where
                                          AccountId in:accid ])
        {
            System.debug('Updated ACRsRecType'+acr.account.recordtypeId); 
            acrrecType.put(acr.id,acr);
            if(acr.Primary_Contact__c)
                accMap.put(acr.AccountId,true);
        }
        System.debug('Updated ACRs'+acrrecType);
        for(AccountContactRelation acr:newList)
        {
            
            if( acrrecType.containskey(acr.Id) && acrrecType.get(acr.Id).account.recordtypeid==accRTId&&!accMap.containskey(acr.AccountId)&& !acr.Primary_Contact__c)
                acr.Primary_contact__c.adderror('Atleast One Primary Contact Should be there for IATA:'+' '+acrrecType.get(acr.id).account.IATA_NUMBER__C);
        }
        if(!updatedList.isEmpty())
            updateACR(updatedList);
        
    }
    
}