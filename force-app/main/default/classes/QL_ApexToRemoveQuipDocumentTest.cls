@isTest
public with sharing class QL_ApexToRemoveQuipDocumentTest
{
 
 
      
    @isTest
    private static void testremoveQuipDocuments(){
    
        try
        {
            
             Test.startTest();
              List<Trigger_Status__c> lisTriggerStatus=new List<Trigger_Status__c>();
              
             Trigger_Status__c statusAccountEligibility=new Trigger_Status__c(name='AccountEligibilityLogTrigger',Active__c=true);          
              lisTriggerStatus.add(statusAccountEligibility);
             Trigger_Status__c AccountUpdateAccountDetail=new Trigger_Status__c(name='AccountUpdateAccountDetail',Active__c=true);
             lisTriggerStatus.add(AccountUpdateAccountDetail);
            Trigger_Status__c AccountTeam=new Trigger_Status__c(name='AccountTeam',Active__c=true);
             lisTriggerStatus.add(AccountTeam);
            Trigger_Status__c ACRPrimaryContact=new Trigger_Status__c(name='ACRPrimaryContact',Active__c=true);
             lisTriggerStatus.add(ACRPrimaryContact);
            Trigger_Status__c ContentDocLinkTriggerCheck=new Trigger_Status__c(name='ContentDocLinkTriggerCheck',Active__c=true);
            lisTriggerStatus.add(ContentDocLinkTriggerCheck);
            
            if(lisTriggerStatus!=null && lisTriggerStatus.size()>0)
            {
                insert lisTriggerStatus;
            }
            
            List<Id> listAcct=new List<Id>();
            List<date> listdate=new list<date>();
            Date getdate=system.today().addDays(-5);
            listdate.add(getdate);
            String batchname='QL_batchClassToRemoveQuipDocs'+system.now();
            
            ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account createAcct=new Account(Name='Test Accounr',recordtypeid=accountId,Quip__c='https://qantasairwaysptyltd.quip.com/0bZHAWaLGFH1');
            insert createAcct;
            listAcct.add(createAcct.id);
       
        
            List<List<ID>> listAccountsList=new List<List<Id>>();
            listAccountsList.add(listAcct);
            List<QL_ApexToRemoveQuipDocument.FlowInputs> getrequests=new List<QL_ApexToRemoveQuipDocument.FlowInputs>();
            
            QL_ApexToRemoveQuipDocument.FlowInputs getrequest=new  QL_ApexToRemoveQuipDocument.FlowInputs();
            getrequest.getAccountIds=listAcct;
            getrequest.currentBatchNameRandom=batchname;
            getrequests.add(getrequest);
            

            QL_ApexToRemoveQuipDocument.removeQuipDocuments(getrequests);
        
            Test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception has ocurred');
        }
   
        
   }
  
  
   
}