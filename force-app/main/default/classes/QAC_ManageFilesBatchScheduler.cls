/*
 * Created By  : Ajay | TCS | Cloud Developer 
 * Modified By : Jay (Purpose: Test class has been written for this Scheduler class, code coverage:100%)
 * Modified By : Yuvaraj| TCS | Developer
 * Purpose : To Schedule the Batch Class
 * Dependent Batch Class : QAC_ManageFilesBatch
 * Test Class Name : QAC_ManageFilesBatch_Test.
*/
global class QAC_ManageFilesBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
        Map<String,QAC_Manage_File__mdt> allMFmap = new Map<String,QAC_Manage_File__mdt>();
       // String rtName = 'Service Request';
        String rtServiceRequestName = 'Service Request';
        String rtQacContactUsSupportName = 'QAC Contact Us Support';
        Id recTypeServiceRequestId = GenericUtils.getObjectRecordTypeId('Case', rtServiceRequestName);
        Id recTypeQacContactUsSupportId = GenericUtils.getObjectRecordTypeId('Case', rtQacContactUsSupportName);      

        for(QAC_Manage_File__mdt eachFileData : [SELECT MasterLabel,No_of_Days_from_Closed_Date__c,Case_Record_Type__c,Case_Closed__c,DeveloperName
                                                 FROM QAC_Manage_File__mdt])
        {
            if(eachFileData != null){
                allMFmap.put(eachFileData.Case_Record_Type__c,eachFileData);
            }
        }
        //system.debug('allMFmap:'+allMFmap);
       // String rtId = QAC_PaymentsProcess.fetchRecordTypeId('Case',allMFmap.get(rtName).Case_Record_Type__c);
        //system.debug('rtId:'+rtId+' allMFmap.get(rtName).No_of_Days_from_Closed_Date__c:'+allMFmap.get(rtName).No_of_Days_from_Closed_Date__c+' allMFmap.get(rtName).Case_Closed__c:'+allMFmap.get(rtName).Case_Closed__c);
        Database.executeBatch(new QAC_ManageFilesBatch(recTypeServiceRequestId,
                                                       allMFmap.get(rtServiceRequestName).No_of_Days_from_Closed_Date__c,
                                                       allMFmap.get(rtServiceRequestName).Case_Closed__c));
        
              Database.executeBatch(new QAC_ManageFilesBatch(recTypeQacContactUsSupportId,
                                                       allMFmap.get(rtQacContactUsSupportName).No_of_Days_from_Closed_Date__c,
                                                       allMFmap.get(rtQacContactUsSupportName).Case_Closed__c));
    }
}