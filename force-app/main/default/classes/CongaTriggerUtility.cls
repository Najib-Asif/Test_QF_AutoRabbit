/**
 * @description       : Conga Trigger approach document generation
 * @author            : Gandla Mallikarjuna
 * @group             : 
 * @last modified on  : 01-09-2025
 * @last modified by  : Gandla Mallikarjuna
**/
public without sharing class CongaTriggerUtility {


    public static Id getIntegrationUserId() {
        User usr;
        try {
            usr = [select id, name, Username from user where Name =: CustomSettingsUtilities.getConfigDataMap('CongaTriggerIntegrationUser') and IsActive = true Limit 1];

        }  catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CongaTriggerUtility', 
                'getIntegrationUserId', String.valueOf(''), String.valueOf(''), false, '', ex);

        }
        return usr.Id;
    }


    
    @AuraEnabled
    public static Object getLatestAttachment(Id recordlId, String fileName, Id fileOwnerId) {
        ContentDocumentLink cdl;
        try {
            system.debug('before fileName=======> ' +fileName);
            fileName = fileName.replace(':', '_');
            system.debug('after fileName=======> ' +fileName);
            if (!test.isrunningtest()) {
                cdl = [SELECT ContentDocument.Title, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:recordlId  and ContentDocument.Title LIKE :(fileName+'%') and ContentDocument.CreatedById =: getIntegrationUserId() ORDER BY ContentDocument.CreatedDate  DESC LIMIT 1];
            } else {
                    cdl = [SELECT ContentDocument.Title, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:recordlId  and ContentDocument.Title LIKE :(fileName+'%') ORDER BY ContentDocument.CreatedDate  DESC LIMIT 1];
            }
            if (cdl != null) {
                deleteOldAttachments(recordlId, fileName,  cdl.ContentDocument.FileType);
                ContentDocument cd = new ContentDocument(Id= cdl.ContentDocumentId);
                cd.OwnerId = fileOwnerId;
                update cd;
            } 
        	    
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CongaTriggerUtility', 
                'getLatestAttachment', String.valueOf(''), String.valueOf(''), false, '', ex);
            
        }
        return cdl;
    }

    @AuraEnabled
    public static Boolean deleteOldAttachments(Id recordlId, String fileName, string fileType) {
        Boolean isdeleted = false;
        try {
            
            List<String> fileNameWithoutDate = fileName.split(' - ');
            fileNameWithoutDate.remove(fileNameWithoutDate.size()-1);
                        
            String fileNameWithoutDateValue;
            for (String file : fileNameWithoutDate) {

                fileNameWithoutDateValue = fileNameWithoutDateValue != null ? (fileNameWithoutDateValue + ' - ' + file ) : file;

            }
            List<ContentDocumentLink> contentDocLinks;
            if (!test.isrunningtest()) {
                contentDocLinks = [SELECT ContentDocument.Title, ContentDocumentId, ContentDocument.FileType, ContentDocument.LatestPublishedVersionId,  ContentDocument.Owner.name, ContentDocument.OwnerId FROM ContentDocumentLink WHERE LinkedEntityId =: recordlId and ContentDocument.Title  LIKE :(fileNameWithoutDateValue+'%') and ContentDocument.FileType =:fileType and ContentDocument.CreatedById =: getIntegrationUserId() ORDER BY ContentDocument.CreatedDate  DESC offset 1];
            } else {
                    contentDocLinks = [SELECT ContentDocument.Title, ContentDocumentId, ContentDocument.FileType, ContentDocument.LatestPublishedVersionId,  ContentDocument.Owner.name, ContentDocument.OwnerId FROM ContentDocumentLink WHERE LinkedEntityId =: recordlId and ContentDocument.Title  LIKE :(fileNameWithoutDateValue+'%') and ContentDocument.FileType =:fileType ORDER BY ContentDocument.CreatedDate  DESC offset 1];
            }
            List<ContentDocument> contentDocIdstoDel = new List<ContentDocument>();
            for (ContentDocumentLink cdl : contentDocLinks) {
                    ContentDocument cd = new ContentDocument(id = cdl.ContentDocumentId);
                    contentDocIdstoDel.add(cd);
            }
            if (!contentDocIdstoDel.isEmpty()) {
                delete contentDocIdstoDel;
                isdeleted = true;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CongaTriggerUtility', 
                'deleteOldAttachments', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return isdeleted;

    }

}