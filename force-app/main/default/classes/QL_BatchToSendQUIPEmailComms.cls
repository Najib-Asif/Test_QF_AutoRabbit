/*
Author: Navpreet Kaur
Batch Description: This batch sends email comms to Qantas Sales SME customers with an attachment of QUIP PDF on a monthly basis, after the interval of one week from PDF document generation
Date: AUG 2023
EPIC CRM-5831
*/

global with sharing class QL_BatchToSendQUIPEmailComms implements Database.Batchable<sObject>,Database.Stateful, schedulable 
{
   List<Id> acctListIds=new List<Id>();
   List<QL_QuipScheduledJob__c> batchStatus=new List<QL_QuipScheduledJob__c>();
   Map<Id,String> getRemovableEmails=new Map<Id,String>();
   Map<Id,String> getRemovableACREmails=new Map<Id,String>();
   List<Contact> listConts=new List<Contact>();
   List<Id> eligibleAcctListIds=new List<Id>();
   
   public QL_BatchToSendQUIPEmailComms()
   {
       
   }
   public QL_BatchToSendQUIPEmailComms(List<Id> acctIds)
   {
       this.acctListIds=acctIds;
   }
   public QL_BatchToSendQUIPEmailComms(List<Id> acctIds,List<QL_QuipScheduledJob__c> getbatchStatus) 
   {
       system.debug('The value of acctIds'+acctIds);
       system.debug('The value of getbatchStatus'+getbatchStatus);
        this.acctListIds=acctIds;
        this.batchStatus.addall(getbatchStatus);
        system.debug('The value of batchStatus'+batchStatus);
    } 
   global Database.QueryLocator start(Database.BatchableContext bc)
   {
       system.debug('The value of acctIds'+acctListIds);
     
      
        String query='Select id,name, firstname,email, accountid,account.Legal_Name__c, account.owner.title, account.owner.firstname,account.owner.name, account.owner.lastname,account.owner.email, account.Active__c,account.Latest_Period_Date__c, account.Contracted__c, account.Account_Owner_Role__c,(select id,Related_Email__c,accountid,contact.firstname,contact.email, AQ_First_Name__c,contactid,account.owner.title,Performance_Update__c,account.owner.firstname,account.owner.lastname,IsActive,account.owner.name,account.owner.email from accountcontactrelations where IsActive=true) from contact where accountid IN :acctListIds and account.QL_Ineligible_for_QUIP__c=false'; 
      return Database.getQueryLocator(query); 
        
   }
   global void execute(Database.BatchableContext bc, List<contact> scope) 
   {
       
       Map<Id,AccountContactRelation> mapACR=new Map<Id,AccountContactRelation>();
       List<ContentDocumentLink> listContentDocList=new List<ContentDocumentLink>();
       List<Id> contDocIdList=new List<Id>();
       List<ContentDocument> listContentDoc=new List<ContentDocument>();    
       List<ContentVersion> listContentVer=new List<ContentVersion>();
       List<String> listFileTitles=new List<String>();  
       Map<Id,List<AccountContactRelation>> mapACRWithAcct;
       Map<Id,ContentDocument> mapAcctContDoc=new Map<Id,ContentDocument>();
       Map<Id,ContentVersion> mapAcctContVer=new Map<Id,ContentVersion>();  
       List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
       List<Attachment> listAttachments=new List<Attachment>();
       
       List<Task> listTasks=new List<Task>();
       Boolean DiffEmailflag=false;
        
       system.debug('The value of acctListIds'+this.acctListIds);
       
       try
       {
       EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='DO NOT USE - Monthly Sales Report email - INITIAL' limit 1];
       OrgWideEmailAddress[] getOrgWideAdd=[select id,Address from OrgWideEmailAddress where DisplayName =:'Corp Sales Aus' limit 1];          
    
       if(scope!=null && scope.size()>0)
       {
           for(Contact getCont: scope)
           {  
               eligibleAcctListIds.add(getCont.accountid);  
               if(getCont.accountcontactrelations.size()>0)
               {
                   for(AccountContactRelation acr: getCont.accountcontactrelations)
                   {
                       if(acr.AccountId!=null && acr.Related_Email__c!=null && getCont.account.Legal_Name__c!=null && acr.Performance_Update__c=='Subscribed' && acr.IsActive==true)
                       {
                         
                           mapACR.put(acr.AccountId, acr);
                           listFileTitles.add('Monthly Performance -%');
                           if(getCont.email!= acr.Related_Email__c)
                           {
                               getRemovableEmails.put(acr.contactid,getCont.email+','+acr.Related_Email__c);
                               getRemovableACREmails.put(acr.id,getCont.email+','+acr.Related_Email__c);
                           }
                           if(mapACRWithAcct==null && getCont.accountid.equals(acr.AccountId))
                           {
                               mapACRWithAcct=new Map<Id,List<AccountContactRelation>>();
                               mapACRWithAcct.put(acr.AccountId,new List<AccountContactRelation>());
                           }
                           if(mapACRWithAcct!=null && getCont.accountid.equals(acr.AccountId) && mapACRWithAcct.get(acr.AccountId)!=null)
                           {
                               mapACRWithAcct.get(acr.AccountId).add(acr);
                           }
                           if(mapACRWithAcct!=null && getCont.accountid.equals(acr.AccountId)  && !mapACRWithAcct.containsKey(acr.AccountId))
                           {
                               mapACRWithAcct.put(acr.AccountId,new List<AccountContactRelation>());
                               mapACRWithAcct.get(acr.AccountId).add(acr);
                           }
                       }
                   }    
               }
               
           }
               if(getRemovableEmails.isEmpty()==false)
               {
                   for(contact getCont: scope)
                   {
                       if(getRemovableEmails.containskey(getCont.id))
                       {
                          getCont.email=getRemovableEmails.get(getCont.id).substringafter(',');
                          listConts.add(getCont); 
                       }
                   }
                   if(listConts!=null && listConts.size()>0)
                   {
                       update listConts;
                   }
               }  
       }
       
       system.debug('the value of listFileTitles'+listFileTitles);  
       system.debug('The value of mapACRWithAcct'+mapACRWithAcct);
       if(mapACRWithAcct!=null && mapACRWithAcct.isEmpty()==false)
       {
           listContentDocList=[select id, contentdocumentid,linkedEntityId from contentdocumentlink where linkedEntityid IN:mapACRWithAcct.keyset()];
       }
       
       system.debug(' the value of listContentDocList'+listContentDocList);
       if(listContentDocList!=null && listContentDocList.size()>0)
       {
           for(ContentDocumentLink contLink: listContentDocList)
           {
               contDocIdList.add(contLink.ContentDocumentId);
           }   
       }
       
       system.debug('the value of contDocIdList'+contDocIdList);
       if(contDocIdList!=null && contDocIdList.size()>0)
       {
           listContentVer=[select id, fileextension,title,filetype,versiondata,TextPreview,ContentDocumentid from ContentVersion where contentdocumentid IN:contDocIdList and filetype='PDF' and title like :listFileTitles];
       }
       
       
       system.debug('the value of listContentVer'+listContentVer);
       if(listContentVer!=null && listContentVer.size()>0 && listContentDocList!=null && listContentDocList.size()>0)
       {
           for(ContentDocumentLink contLi: listContentDocList)
               {
                   for(ContentVersion contVer: listContentVer)
                   {
                       system.debug('the value of mapACRWithAcct.containsKey(contli.LinkedEntityId'+mapACRWithAcct.keyset());
                       system.debug('the value of contli.LinkedEntityId'+contli.LinkedEntityId);
                       system.debug('the value of  contLi.ContentDocumentId'+ contLi.ContentDocumentId);                 
                        if(mapACRWithAcct.containsKey(contli.LinkedEntityId) && contLi.ContentDocumentId.equals(contVer.ContentDocumentid))
                        {
                            mapAcctContVer.put(contLi.LinkedEntityId, contVer);
                        }
                   }
              }
       }
       
      
       system.debug('the value of mapAcctContVer'+mapAcctContVer);
       if(mapACRWithAcct!=null && mapACRWithAcct.isEmpty()==false && mapAcctContVer!=null && mapAcctContVer.size()>0)
       {
           for(Id getAcct: mapAcctContVer.keyset())
           {
               system.debug('The execution of outer for loop');
               for(AccountContactRelation getAcr: mapACRWithAcct.get(getAcct))
               {
                   Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    system.debug('The execution of inner for loop');
                    Blob fileData;
                    if(mapAcctContVer.get(getAcr.accountid)!=null)
                    {
                        fileData = mapAcctContVer.get(getAcr.accountid).VersionData; // <= This step converts the version data into a blob for the attachment
                        system.debug('the value of fileData'+fileData);
                    }
            
                   /* Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                    emlAtt.setFilename(mapAcctContVer.get(getAcr.accountid).title+'.' + mapAcctContVer.get(getAcr.accountid).filetype);
                    emlAtt.setContentType('application/pdf');
                    emlAtt.setBody(fileData); */
    
                    message.setTargetObjectId(getAcr.contactid);
                    
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(true);
                    
                    //message.setWhatId(getAcr.contactid);
    
                   //Get templete id for set the templete.
                   String EmTempHrml=emailTemplate.HtmlValue;
                   
                   system.debug('the value of getAcr.contact.firstname'+getAcr.contact.firstname);
                   system.debug('the value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   if(getAcr.contact.firstname!=null && getAcr.contact.firstname!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_FirstName,getAcr.contact.firstname);
                       system.debug('The value of getAcr.contact.firstname'+getAcr.contact.firstname);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue); 
                       
                   }
                   system.debug('the value of getAcr.account.owner.firstname'+getAcr.account.owner.firstname);
                   if(getAcr.account.owner.firstname!=null && getAcr.account.owner.firstname!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_SenderFirstName,getAcr.account.owner.firstname); 
                       system.debug('The value of getAcr.account.owner.firstname'+getAcr.account.owner.firstname);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.lastname'+getAcr.account.owner.lastname);
                   if(getAcr.account.owner.lastname!=null && getAcr.account.owner.lastname!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_LastName,getAcr.account.owner.lastname); 
                       system.debug('The value of getAcr.account.owner.lastname'+getAcr.account.owner.lastname);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.title'+getAcr.account.owner.title);
                   if(getAcr.account.owner.title!=null && getAcr.account.owner.title!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_Title,getAcr.account.owner.title); 
                       system.debug('The value of getAcr.account.owner.title'+getAcr.account.owner.title);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.email'+getAcr.account.owner.email);
                   if(getAcr.account.owner.email!=null && getAcr.account.owner.email!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_Email,getAcr.account.owner.email); 
                       system.debug('The value of getAcr.account.owner.email'+getAcr.account.owner.email);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.name'+getAcr.account.owner.name);
                   if(getAcr.account.owner.name!=null && getAcr.account.owner.name!='')
                   {
                       EmTempHrml=EmTempHrml.replace(system.label.QL_SenderName,getAcr.account.owner.name); 
                       system.debug('The value of getAcr.account.owner.name'+getAcr.account.owner.name);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                          
                   message.setTemplateID(emailTemplate.Id);
                   if(getOrgWideAdd.get(0).id!=null)
                   {
                        message.setOrgWideEmailAddressId(getOrgWideAdd.get(0).id);                           
                   }
                   
                   
                   message.setHtmlBody(EmTempHrml);
                   
                   message.setSubject(emailTemplate.Subject); 
                   message.setEntityAttachments(new List<String>{mapAcctContVer.get(getAcr.accountid).id}); 
                   system.debug('the vlaue of getAcr.Related_Email__c'+getAcr.Related_Email__c);
                   
                   system.debug('>>> the value of message.toaddress before assignment'+message.toAddresses);
                   if(getAcr.Related_Email__c!=null)
                   {
                       //message.setWhatId(finalContactMap.get(getAcct.id).id); //This is important for the merge fields in template to work
                       //message.settoAddress=getAcr.Related_Email__c;
                        message.toAddresses = new String[] {getAcr.Related_Email__c}; 
                   }
                   system.debug('>>> the value of message.toaddress after assignment'+message.toAddresses);
                   /*message.inreplyto= 'noreply@salesforce.com';
                   message.setReplyTo('noreply@salesforce.com');
                   message.setSenderDisplayName('Salesforce No Reply');
                   message.setInReplyTo('noreply@salesforce.com');*/
                   
                   message.setFileAttachments(new Messaging.EmailFileAttachment[] {});
                    system.debug('the value of message'+message);
                   
                   
                   messages.add(message);
                    system.debug('the value of messages'+messages); 
                    //Task newTask=new Task(Subject = emailTemplate.Subject, WhoId = getAcr.contactid, TaskSubtype = 'Email', ActivityDate = Date.today());
                    //listTasks.add(newTask);
               }
           }
       }
       
       if(messages!=null && messages.size()>0 && mapAcctContVer!=null && mapAcctContVer.isEmpty()==false)
       { 

          Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages,false);  
          
          
          if(results.size()>0)
          {
               for(Messaging.SendEmailResult getR: results)
               {     
                         
                    system.debug('The value of results'+ getR.isSuccess());    
                    system.debug('Get Errors of emails'+ getR.getErrors());  
                    system.debug('The value of getT.success'+getR.success);
                
                
               }
               
          }
         
         
             
       }
      }
       catch(Exception e)
       {
           system.debug('Exception has occurred'+e.getMessage());
       }   
           
           
           
   }
   global void finish(Database.BatchableContext bc)  
   {
          List<Contact> updateContList=new List<Contact>();
          List<AccountContactRelation> updateACRs=new List<AccountContactRelation>();
          Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;    
          if(getRemovableEmails.isEmpty()==false)
          {
              for(contact getContact: listConts)
              {
                  if(getRemovableEmails.containskey(getContact.id))
                  {
                      getContact.email=getRemovableEmails.get(getContact.id).substringbefore(',');
                      
                      updateContList.add(getContact);
                      system.debug('>>> the value of getcontact var'+getContact.email);
                      system.debug('>>> the value of updateContList var'+updateContList);
                  }
              }
              if(updateContList!=null && updateContList.size()>0)
              {
                  database.update(updateContList,dml);
                  system.debug('>>> the list has been updated'+updateContList);
              }
              for(AccountContactRelation getACRel:[select id,contactid,accountid,Related_Email__c from accountcontactrelation where id in :getRemovableACREmails.keyset()])
              {
                  if(getRemovableEmails.containskey(getACRel.contactid))
                  {
                      getACRel.Related_Email__c=getRemovableACREmails.get(getACRel.id).substringafter(',');
                      updateACRs.add(getACRel);
                      system.debug('>>> the getACRel.Related_Email__c'+getACRel.Related_Email__c);
                      system.debug('>>> the value of updateACRs'+updateACRs);
                  }
              }
              if(updateACRs!=null && updateACRs.size()>0)
              {
                  database.update(updateACRs,dml);
                  system.debug('>>> the updated value of updateACRs'+updateACRs);
              }
          }
           
         //Update the completed batch jobs details on Scheduled jobs object   
         QL_QuipBatchesStatusUpdator.updateStatusRecord(eligibleAcctListIds,bc.getjobId());
         
         // Update the next scheduled details on scheuled jobs object
         QL_QuipBatchesStatusUpdator.updateBatchScheduleTime(eligibleAcctListIds,null,null);
         
   } 
   global void execute(SchedulableContext sc) 
   {
      Database.executeBatch(new QL_BatchToSendQUIPEmailComms(acctListIds,batchStatus),200);
   } 
   
}