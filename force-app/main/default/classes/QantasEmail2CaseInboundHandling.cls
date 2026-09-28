/*----------------------------------------------------------------------------------------------------------------------
Author:        Navpreet Kaur
Company:       TCS
Date Implemented:  7 November 2022
Description:  FCRM - 889 Class that handles the incoming emails after the string-based threading expiration
Test Class:    QantasEmail2CaseInboundHandlingTest
-------------------------------------------------------------------------------------------------------------------------*/
global with sharing class QantasEmail2CaseInboundHandling implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
       Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
       Case caseRec; 
  try 
   { 

    string[] splitEmailSub=new string[]{};
    string casenum='';  
     
    List<Attachment> listAttachments=new List<Attachment>(); 
    List<ContentVersion> listContVer=new List<ContentVersion>(); 
    List<contentDocumentLink> listContDocLink=new List<contentDocumentLink>();   
   
    if(email.subject!=null && email.subject!='')
    {
        splitEmailSub=email.subject.split(' ');
        casenum=splitEmailSub[splitEmailSub.size()-1];    
    }
        if(casenum!=null && casenum!='')
       {
           caseRec=[select id from case where casenumber=:casenum limit 1];    
       }
       
       if(caseRec!=null)
        {
            EmailMessage emmsg=new EmailMessage();
            String toAddres;
               emmsg.ParentId=caseRec.id;
               emmsg.MessageDate=system.now();
               emmsg.Status='0';
               emmsg.FromAddress=email.fromAddress;
               if(email.toAddresses!=null)
               {
                   toAddres=String.valueOf(email.toAddresses);
               }
               emmsg.ToAddress=toAddres;
               emmsg.Subject=email.subject;
               emmsg.TextBody=email.plainTextBody;
               emmsg.HtmlBody=email.htmlBody;

           
           insert emmsg;
        
        
               //Messaging.EmailFileAttachment 
       if(email.binaryAttachments!=null)
       {
           for (Messaging.InboundEmail.binaryAttachment bAttachment : email.binaryAttachments) 
              {
                    Attachment attachment = new Attachment();
                    attachment.Name = bAttachment.fileName;
                    attachment.Body = bAttachment.body;
                    attachment.ParentId = emmsg.Id;
                  
                    insert attachment; //Attachment cannot be listed hence need to be inserted within For
                   
                         
                  
                    ContentVersion contVer=new ContentVersion();
                    contVer.Title=bAttachment.fileName;
                    contVer.PathOnClient=bAttachment.fileName;
                    contVer.VersionData=bAttachment.body;
                    //contVer.FirstPublishLocationId=emmsg.Id;
                    contVer.FirstPublishLocationId=caseRec.id;
                    listContVer.add(contVer);
                  
                  
              }    
       }
       if(listContVer!=null && listContVer.size()>0)
       {
           insert listContVer;
           
                
       }
      }
    }
    catch (Exception e) 
    {
       System.debug('Exception Has Occurred ' + e.getmessage()+e.getLineNumber());
       ID recordtypeid=Schema.SObjectType.log__c.getRecordTypeInfosByName().get('Exception Logs').getRecordTypeId();
       log__c createLog=new Log__c();
       createLog.recordtypeid=recordtypeid;
       createLog.Class_Name__c='QantasEmail2CaseInboundHandling';
       createLog.Error_Message__c=e.getmessage();
       createLog.FailedRecordID__c=caseRec.id;
       createLog.Exception_Type__c=email.subject;
       
       insert createLog;

    }
  
   result.success = true;
   
   // Return the result for the Apex Email Service
   return result;
  }
}