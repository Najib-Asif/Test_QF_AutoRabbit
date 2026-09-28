/*
JIRA -6089  Sprint 182
Developer - Raghavendra Chakali
This is a test class created for UpdateCaseUnresolvedHoursBatch
*/
@isTest
public class UpdateCaseUnresolvedHoursBatchTest {
    static testmethod void testEmailMessages()
    {
        try
        {
            
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
            
            List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;Person Account'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type','Aquire Registration'));
            insert lstConfigData;
            
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
            
            Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            insert mdtRec;
            
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                if(recType.name.contains('Qantas_Freight'))
                {
                    qantas_Freight=recType.RecordTypeId__c ;
                }
            }
            
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase);
            
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
                
            }
            Test.StartTest();
                UpdateCaseUnresolvedHoursBatch ucuh = new UpdateCaseUnresolvedHoursBatch();
                ID batchprocessid = Database.executeBatch(ucuh);
            Test.StopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception Thrown '+e.getMessage()+' '+ e.getLineNumber()+' '+e.getCause());
        }
    }
}