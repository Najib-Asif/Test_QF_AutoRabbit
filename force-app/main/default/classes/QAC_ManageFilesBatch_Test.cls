/*
* Created By  : Jay | TCS | Cloud Developer
* Purpose : To Delete Files for closed service request cases that was closed 90 days ago.
            This test class will cover code for four Main classes.
  Main class Name: QAC_ManageFilesBatch, QAC_ManageFilesBatchScheduler, QAC_MFBCustomIterableExample, QAC_MFBCustomIterable
*/

@isTest
public class QAC_ManageFilesBatch_Test {
    Static Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
    Static Id caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    @testSetup
    static void setup(){
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        TestUtilityDataClassQantas.enableTriggers();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        list<Account> myAccounts = new list<Account>();
        Account acc1 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565369',Email__c='managefile.qac@qantas.com.au',
                                   IATA_Number__c = '0239209');
        myAccounts.add(acc1);
        insert myAccounts;
        
        List<Case> srCaseList = new List<Case>();
        Id conDoc;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        Case casObj = new Case(recordtypeid = caseTypeId,Accountid = acc1.ID, Status = 'Closed', Createddate = system.today()-91, Closeddate = System.today()-90,Service_Fee_Applies__c='No',Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic');
        srCaseList.add(casObj);
        insert  srCaseList;
        
        String base64Data='/9j/4Q0uRXhpZgAATU0AKgAAAAgABwESAAMAAAABAAEAAAEaAAUAAAABAAAAYgEbAAUAAAABAAAAagEoAAMAAAABAAIAAAExAAIAAAAkAAAAcgEyAAIAAAAUAAAAlodpAAQAAAABAAAArAAAANgALcbAAAAnEAAtxsAAACcQQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKE1hY2ludG9zaCkAMjAxNjowODoxMSAxNzo1NDowMAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAdToAMABAAAAAEAAAZRAAAAAAAAAAYBAwADAAAAAQAGAAABGgAFAAAAAQAAASYBGwAFAAAAAQAAAS4BKAADAAAAAQACAAACAQAEAAAAAQAAATYCAgAEAAAAAQAAC/AAAAAAAAAASAAAAAEAAABIAAAAAf/Y/+0ADEFkb2JlX0NNAAH/7gAOQWRvv3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xuve/de697917r3v3Xu+6';
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = 'Test Document';
        cv.PathOnClient = 'Test Document';
        insert cv;
        
        if(cv.Id != null || cv.Id !=''){
        conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        }
        if(casObj.Id != null || casObj.Id !=''){
        Case cid = [SELECT Closed_Case_Age__c FROM Case WHERE Id =:casObj.Id];
        cdlList.add(new ContentDocumentLink( LinkedEntityId =cid.Id, contentDocumentId = conDoc, ShareType = 'V' ));
        }
         
        insert cdlList;    
    }
    
    static testmethod void batchDeleteMethod(){
        test.startTest();
        //QAC_ManageFilesBatch qacMan = new QAC_ManageFilesBatch(caseTypeId,90, True); 
        //Id batchId = Database.executeBatch(qacMan);
        QAC_ManageFilesBatchScheduler qacManSch = new QAC_ManageFilesBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Managefilescheduler', sch, qacManSch);
        test.stopTest(); 
    }
    
}