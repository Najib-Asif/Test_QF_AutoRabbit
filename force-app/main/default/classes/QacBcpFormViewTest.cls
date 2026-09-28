/*
Main Class: QacBcpFormView
Author: Navpreet Kaur
Jira Ticket: CRM-7937
Description: 
 */
@isTest
private class QacBcpFormViewTest {
    @TestSetup
    static void myUnitTestDataSetup(){

        ID bcpCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QAC 3.0').getRecordTypeId();
        String myString = 'StringToBlob.snote';
        Blob myBlob = Blob.valueof(myString);
        Group getGrp=[select id from group where DeveloperName=:'BCP_Portal_Support' and type =:'Queue' limit 1];
        

        Trigger_Status__c contentDocLink = new Trigger_Status__c();
        contentDocLink.Name = 'ContentDocLinkTriggerCheck';
        contentDocLink.Active__c = true;
        insert contentDocLink;
        
        contentDocLink = new Trigger_Status__c();
        contentDocLink.Name = 'ContDocTriggerEligiblityCheckContDel';
        contentDocLink.Active__c = true;
        insert contentDocLink;

        test.startTest();
        Case newCase=new Case(recordtypeid=bcpCaseRecordTypeId,type='Existing booking',Sub_Type_1__c='Schedule Change',Sub_Type_2__c='Rebook flight',origin='QF Internal',ownerid=getGrp.id,Priority='Medium',status='Open',subject='Existing booking', description='BCP Case Request');
        insert newCase;

        

        ContentVersion createDoc=new ContentVersion(versionData=myBlob,FirstPublishLocationId=newCase.id,Title='QacRequestFile',PathOnClient='QacRequestFile.snote');
        insert createDoc;
        
        ContentVersion createBackupDoc=new ContentVersion(versionData=myBlob,FirstPublishLocationId=newCase.id,Title='QacBackupFile',PathOnClient='QacBackupFile.snote');
        insert createBackupDoc;

        test.stopTest();
    }

    
    static testmethod void myUnitTest() {

        try {
        
        test.startTest();
            
        Id CaseRecordId=[select id from case limit 1].id;    
            
        List<ContentDocumentLink> getContentDocumentLinks=[select id, ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData from ContentDocumentLink where LinkedEntityId =:CaseRecordId and ContentDocument.LatestPublishedVersion.PathOnClient = 'QacRequestFile.snote' 
        order by ContentDocument.CreatedDate desc limit 1];
        QacBcpFormView createObj=new QacBcpFormView();
        Object returnedData = QacBcpFormView.getJsonData(CaseRecordId);    
        Map<String, Object> returnedDataInMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnedData));
         
        
        system.assertEquals(returnedDataInMap.containsKey('fileData'), true ,'Map Contains the File Data as a Key');
        system.assertEquals(returnedDataInMap.containsKey('fileName'), true ,'Map Contains the File Name as a Key');
        system.assertEquals(returnedDataInMap.get('fileName'), getContentDocumentLinks[0].ContentDocument.Title ,'File Title Did Not Match!');
        

        test.stopTest();    
           
        
        } catch (Exception e) {
            system.debug('Exceoption occured'+e.getMessage());
        }
        


    }
    
    static testmethod void myUnitTest1() {

        try {
        
        test.startTest();
            
        Id CaseRecordId=[select id from case limit 1].id;    
            
        List<ContentDocumentLink> getContentDocumentLinks=[select id, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData from ContentDocumentLink where LinkedEntityId =:CaseRecordId and ContentDocument.LatestPublishedVersion.PathOnClient = 'QacRequestFile.snote' 
        order by ContentDocument.CreatedDate desc limit 1];
        ContentDocument cd = new ContentDocument(Id=getContentDocumentLinks[0].ContentDocumentId);
        delete cd;
            
        
        QacBcpFormView createObj=new QacBcpFormView();
        Object returnedData = QacBcpFormView.getJsonData(CaseRecordId);    
        Map<String, Object> returnedDataInMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnedData));
         
        
        system.assertEquals(returnedDataInMap.containsKey('fileData'), true ,'Map Contains the File Data as a Key');
        system.assertEquals(returnedDataInMap.containsKey('fileName'), true ,'Map Contains the File Name as a Key');
        system.assertEquals(returnedDataInMap.get('fileName'), 'QacBackupFile' ,'File Title Did Not Match!');
        

        test.stopTest();    
           
        
        } catch (Exception e) {
            system.debug('Exceoption occured'+e.getMessage());
        }
        


    }
}