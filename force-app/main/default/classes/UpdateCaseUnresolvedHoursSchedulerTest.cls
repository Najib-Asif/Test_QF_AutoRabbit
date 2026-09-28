/*==================================================================================================================================
Author:         Raghavendra Chakali
Purpose:        Test Class for UpdateCaseUnresolvedHoursScheduler Class
Date:           31/05/23 (DD/MM/YYYY)
JIRA:           CRM - 6089

==================================================================================================================================*/
@isTest(SeeAllData = false)
public class UpdateCaseUnresolvedHoursSchedulerTest {
     static testmethod void run()
    {
        try
        {
            
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            TriggerSwitchHelper.caseTriggerRunFlag = false;
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
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
            
            if(rtMap.containsKey('Qantas Freight'))
            {
                qantas_Freight = rtMap.get('Qantas Freight').getRecordTypeId();
            }
            
            Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            insert mdtRec;
            
            /*for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                if(recType.name.contains('Qantas_Freight'))
                {
                    qantas_Freight=recType.RecordTypeId__c ;
                }
            }*/
            
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase);
            
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
                
            }
            Test.StartTest();
                String everyHourExp = '0 0 * * * ?';
                String jobId = System.schedule('Update Case Unresolved Hours Batch Test', everyHourExp, new UpdateCaseUnresolvedHoursScheduler());
                // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same
            System.assertEquals(everyHourExp, 
                                ct.CronExpression);
            Test.StopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception Thrown '+e.getMessage()+' '+ e.getLineNumber()+' '+e.getCause());
        }
    }
    
}