public with sharing class ViewAllFilesController 
{
    @AuraEnabled
    public static List<FilesWrapper> getRelatedDocs(String caseId)
    {
        List<ContentDocument> contentDocs = new List<ContentDocument>();
        List<FilesWrapper> data = new List<FilesWrapper>();
        Map<Id, Id> cdIdentityIdMap = new Map<Id, Id>();
        Map<Id, String> entityIdNameMap = new Map<Id, String>();
        Boolean isParentCase= false;
        List<Id> childCaseIds = new List<Id>();//Can it be a set?
        List<Id> entityIds = new List<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, String> emailMsgIdSubjectMap = new Map<Id, String>();
        
        if(caseId ==null)
            return null;
        /*entityIds.add(caseId);//Add caseId to the entityIds
        List<Case> caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId];
        if(caseRec!=null && caseRec.size()>0)
        {
            entityIdNameMap.put(caseRec[0].Id, caseRec[0].CaseNumber);
        }
        //List<Id> ids = getEmailMsgIds(new List<Id>{caseId});
        emailMsgIdSubjectMap  = getEmailMsgIds(new List<Id>{caseId});
        if(emailMsgIdSubjectMap!=null && emailMsgIdSubjectMap.size()>0 && emailMsgIdSubjectMap.keySet().size()>0)
        {
            entityIds.addAll(emailMsgIdSubjectMap.keySet());//Add Ids of EmailMessage with Attachment to the entityIds
            entityIdNameMap.putAll(emailMsgIdSubjectMap);
        }*/
        //Check if child cases exist for the caseId
        for( Case caseRecord : [SELECT Id, CaseNumber FROM Case WHERE ParentId =: caseId or Id =: caseId] )
        {
            childCaseIds.add(caseRecord.Id);
            entityIdNameMap.put(caseRecord.Id, caseRecord.CaseNumber);
        }
        if(childCaseIds !=null && childCaseIds.size()>0)
        {
            entityIds.addAll(childCaseIds);
            Map<Id, String> childCaseEmailMsgIds = new Map<Id, String> ();
            childCaseEmailMsgIds = getEmailMsgIds(childCaseIds);
            if(childCaseEmailMsgIds!=null && childCaseEmailMsgIds.size()>0 && childCaseEmailMsgIds.keySet().size()>0)
            {
                entityIds.addAll(childCaseEmailMsgIds.keySet());
                entityIdNameMap.putAll(childCaseEmailMsgIds);
            }         
        }
        //ContentDocumentLink is the junction that links the ContentDocument(file or attachment) to a LinkedEntityId(case or user record) 
        //So query ContentDocumentLink and store ContentDocumentIds
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN : entityIds] )
        {
            contentDocumentIds.add(cdl.ContentDocumentId);
            cdIdentityIdMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        System.debug('++ cdIdentityIdMap is '+cdIdentityIdMap);
        if(contentDocumentIds!=null && contentDocumentIds.size()>0)
        {
            contentDocs = [Select Title, Owner.Name, FileExtension, LastModifiedBy.Name, LastModifiedDate, ContentSize 
                    from ContentDocument Where ID In :contentDocumentIds order by LastModifiedDate desc];
            for(ContentDocument contentDoc : contentDocs)
            {
                System.debug('==>> '+contentDoc);
                FilesWrapper fw = new FilesWrapper();
                fw.entityId = cdIdentityIdMap.get(contentDoc.Id);
                fw.isCase = false;
                if(fw!=null && fw.entityId.getSObjectType().getDescribe().getKeyPrefix() == '500')
                {
                    fw.isCase = true;
                }
                fw.label = entityIdNameMap.get(fw.entityId);
                fw.lastModifiedDate = (contentDoc.LastModifiedDate.format('d/MM/yyyy h:mm a')).toLowerCase();
                fw.fileSize = getFileSize(contentDoc.ContentSize);
                /*if(contentDoc.title.contains('.'))
                {
                    fw.docType = 'doctype:'+contentDoc.title.substring(  contentDoc.title.lastIndexOf('.')+1, contentDoc.title.length());
                }
                else
                {
                    fw.docType = 'doctype:image';
                }*/
                if(contentDoc.FileExtension != null && (contentDoc.FileExtension.equalsIgnoreCase('jpg') || contentDoc.FileExtension.equalsIgnoreCase('jpeg') 
                // || contentDoc.FileExtension == 'png' || contentDoc.FileExtension == 'tif')
                    || contentDoc.FileExtension.equalsIgnoreCase('gif') || contentDoc.FileExtension.equalsIgnoreCase('png') || contentDoc.FileExtension.equalsIgnoreCase('tif'))) 
                {
                    fw.docType = 'doctype:image';
                }
                else
                {
                    fw.docType = 'doctype:'+contentDoc.FileExtension;
                }  
                
                fw.cd = contentDoc;
                data.add(fw);
            }
        }
        System.debug('==>> '+contentDocs);        
        for(FilesWrapper f : data)
        {
            System.debug('**** '+f.entityId);
            System.debug('**** '+f.cd.Id);
        }        
        return data;
        //return contentDocs;
    }
    
    public static String getFileSize(Integer size)
    {
        String fileSize;
        Decimal d;
        if(size>0)
        {
            d = ((Decimal)size)/1024;
            if(d>1000.00)
            {
                fileSize = (d/1024.00).setscale(1)+'MB';
            }
            else
            {
                fileSize = d.setscale(0)+'KB'; 
                
            }
        }
        return fileSize;        
    }
    
    @AuraEnabled
    public static string getDocURL(Id docId)
    {
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docId AND IsLatest = true];
        String cvDownloadURL = URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id;
        return cvDownloadURL;
    }
     
    @AuraEnabled
    public static Boolean deleteDoc(Id docId)
    {
        Boolean isDeleted = false;
        ContentDocument conDoc = new ContentDocument(Id = docId);
        Database.DeleteResult dr = Database.delete(conDoc, false);                
        if (dr.isSuccess()) 
        {
            isDeleted = true;
    	}
        else 
        {
            isDeleted = false;
            // Operation failed, so get all errors                
            for(Database.Error err : dr.getErrors()) 
            {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
        }
        return isDeleted;
    }
            
    public static Map<Id, String> getEmailMsgIds(List<Id> caseIds)
    {
        Map<Id, String> emailMsgIds = new Map<Id, String>();
        /*List<EmailMessage> caseEmailMsgs = [SELECT Id, Subject, ParentId, HasAttachment FROM EmailMessage 
                                            WHERE ParentId IN : caseIds AND HasAttachment=true ];*/
        for( EmailMessage caseEmailMsg : [SELECT Id, Subject, ParentId, HasAttachment FROM EmailMessage 
                                            WHERE ParentId IN : caseIds AND HasAttachment=true ] )
        {
            emailMsgIds.put(caseEmailMsg.Id, caseEmailMsg.Subject);
        }
                                            
        return emailMsgIds;
    }
    
    // Wrapper class
    public class FilesWrapper
    {
        @AuraEnabled
        public Id entityId{get;set;}
        
        @AuraEnabled
        public Boolean isCase{get;set;}
        
        @AuraEnabled
        public String label{get;set;}
        
        @AuraEnabled
        public String lastModifiedDate{get;set;}
        
        @AuraEnabled
        public String fileSize{get;set;}

        @AuraEnabled
        public String docType{get;set;}        
        
        @AuraEnabled
        public ContentDocument cd{get;set;}
    }
    
    @AuraEnabled
    public static Boolean removeRecord(String docId)
    {    
    	Boolean flag = false;
        List<ContentDocumentLink> cdlListToDelete = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId  from ContentDocumentLink WHERE ContentDocumentId=:docId ];        
        if(cdlList!=null && cdlList.size()>0)
        {
            for(ContentDocumentLink cdl : cdlList)
            {
                String s1 = String.valueof(cdl.Id);
				if(!s1.startsWith('005'))
                {
                    cdlListToDelete.add(cdl);
                    break;
                }
            }            
        }
        if( cdlListToDelete.size()>0 )
        {            
            Database.DeleteResult[] drList = Database.delete(cdlListToDelete, false);
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted CDL with ID: ' + dr.getId());
                    flag = true;
                }
                else {
                    flag = false;
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('CDL fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        return flag;
    }
}