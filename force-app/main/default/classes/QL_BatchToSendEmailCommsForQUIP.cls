/*
Author: Navpreet Kaur
Batch Description: This batch sends email comms to Qantas Sales SME customers with an attachment of QUIP PDF on a monthly basis, after the interval of one week from PDF document generation
Date: 20 March 2023
Sprint: Sprint 178
Jira: CRM-5832
*/

global with sharing class QL_BatchToSendEmailCommsForQUIP implements Database.Batchable<sObject>,Database.Stateful, schedulable 
{
   List<Id> acctListIds=new List<Id>();
 
   public QL_BatchToSendEmailCommsForQUIP()
   {
       
   }
   public QL_BatchToSendEmailCommsForQUIP(List<Id> acctIds) 
   {
       system.debug('The value of acctIds'+acctIds);
        this.acctListIds=acctIds;
    } 
   global Database.QueryLocator start(Database.BatchableContext bc)
   {
       system.debug('The value of acctIds'+acctListIds);
      //ID QantasSalesAcct=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      //String accountOwnerRole='%R&G%';
      //String query='Select id,name, accountid,email, account.owner.title, account.owner.firstname, account.owner.lastname, account.Active__c,account.Latest_Period_Date__c, account.Contracted__c, account.Account_Owner_Role__c,(select id,Related_Email__c,accountid, AQ_First_Name__c,contactid,account.owner.title,account.owner.firstname,account.owner.lastname from accountcontactrelations) from contact where account.Contracted__c=true and account.Active__c=true and account.recordtypeid=:QantasSalesAcct and account.Account_Owner_Role__c LIKE :accountOwnerRole and account.Quip__c!=null';     
      
	String query='Select id,name, accountid,email, account.owner.title, account.owner.firstname, account.owner.lastname, account.Active__c,account.Latest_Period_Date__c, account.Contracted__c, account.Account_Owner_Role__c,(select id,Related_Email__c,accountid, AQ_First_Name__c,contactid,account.owner.title,Performance_Update__c,account.owner.firstname,account.owner.lastname from accountcontactrelations) from contact where accountid IN :acctListIds'; 
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

      /* system.debug('the value of getAccts before in mains'+getAccts);
	   List<Contact> scope=[Select id,name, accountid,email, account.owner.title, account.owner.firstname, account.owner.lastname, account.Active__c,account.Latest_Period_Date__c, account.Contracted__c, account.Account_Owner_Role__c,(select id,Related_Email__c,accountid, AQ_First_Name__c,contactid,account.owner.title,account.owner.firstname,account.owner.lastname from accountcontactrelations) from contact where accountid IN :getAccts];     	
	   system.debug('the value of getAccts afterwards in mains'+getAccts);   */     

       system.debug('The value of acctListIds'+this.acctListIds);
       
       
       try
       {
       EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='DO NOT USE - Monthly Sales Report email - INITIAL' limit 1];
	   OrgWideEmailAddress getOrgWideAdd=[select id,Address from OrgWideEmailAddress where DisplayName =:'Corp Sales Aus' limit 1];	       
    
       if(scope!=null && scope.size()>0)
       {
           for(Contact getCont: scope)
           {    
               if(getCont.accountcontactrelations.size()>0)
               {
                   for(AccountContactRelation acr: getCont.accountcontactrelations)
                   {
                       if(acr.AccountId!=null && acr.Related_Email__c!=null && getCont.account.Latest_Period_Date__c!=null && acr.Performance_Update__c=='Subscribed')
                       {
                           mapACR.put(acr.AccountId, acr);
                           listFileTitles.add('Monthly Performance - '+getCont.account.Latest_Period_Date__c);
                           
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
           listContentVer=[select id, fileextension,title,filetype,versiondata,TextPreview,ContentDocumentid from ContentVersion where contentdocumentid IN:contDocIdList and filetype='PDF' and title IN :listFileTitles];
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
    
                   //Get templete id for set the templete.
                   String EmTempHrml='';
                   system.debug('the value of getAcr.AQ_First_Name__c'+getAcr.AQ_First_Name__c);
                   if(getAcr.AQ_First_Name__c!=null && getAcr.AQ_First_Name__c!='')
                   {
                       EmTempHrml=emailTemplate.HtmlValue.replace('{{{AccountContactRelation.FirstName}}}',getAcr.AQ_First_Name__c);
                       system.debug('The value of getAcr.AQ_First_Name__c'+getAcr.AQ_First_Name__c);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue); 
                       
                   }
                   system.debug('the value of getAcr.account.owner.firstname'+getAcr.account.owner.firstname);
                   if(getAcr.account.owner.firstname!=null && getAcr.account.owner.firstname!='')
                   {
                       EmTempHrml=EmTempHrml.replace('{{{Sender.FirstName}}}',getAcr.account.owner.firstname); 
                       system.debug('The value of getAcr.account.owner.firstname'+getAcr.account.owner.firstname);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.lastname'+getAcr.account.owner.lastname);
                   if(getAcr.account.owner.lastname!=null && getAcr.account.owner.lastname!='')
                   {
                       EmTempHrml=EmTempHrml.replace('{{{Sender.LastName}}}',getAcr.account.owner.lastname); 
                       system.debug('The value of getAcr.account.owner.lastname'+getAcr.account.owner.lastname);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                   system.debug('the value of getAcr.account.owner.title'+getAcr.account.owner.title);
                   if(getAcr.account.owner.title!=null && getAcr.account.owner.title!='')
                   {
                       EmTempHrml=EmTempHrml.replace('{{{Sender.Title}}}',getAcr.account.owner.title); 
                       system.debug('The value of getAcr.account.owner.title'+getAcr.account.owner.title);
                       system.debug('The value of emailTemplate.HtmlValue'+emailTemplate.HtmlValue);
                   }
                          
                   message.setTemplateID(emailTemplate.Id);
                  /* if(getOrgWideAdd!=null)
                   {
                   		message.setOrgWideEmailAddressId(getOrgWideAdd.id);                   		 
                   }*/
                   
                   message.setHtmlBody(EmTempHrml);
                   message.setSubject(emailTemplate.Subject); 
                   message.setEntityAttachments(new List<String>{mapAcctContVer.get(getAcr.accountid).id});	
                   system.debug('the vlaue of getAcr.Related_Email__c'+getAcr.Related_Email__c);
                   if(getAcr.Related_Email__c!=null)
                   {
                       //message.setWhatId(finalContactMap.get(getAcct.id).id); //This is important for the merge fields in template to work
                        message.toAddresses = new String[] {getAcr.Related_Email__c}; 
                   }
                  
                   message.setFileAttachments(new Messaging.EmailFileAttachment[] {});
                    system.debug('the value of message'+message);
				   
                   messages.add(message);
                    system.debug('the value of messages'+messages); 
               }
           }
       }
       
       if(messages!=null && messages.size()>0 && mapAcctContVer!=null && mapAcctContVer.isEmpty()==false)
       { 
          Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages,false);  
          for(Messaging.SendEmailResult getR: results)
          {              
                system.debug('The value of results'+ getR.isSuccess());    
                system.debug('Get Errors of emails'+ getR.getErrors());  
                system.debug('The value of getT.success'+getR.success);
          }
          /*for(Messaging.SingleEmailMessage getMail:messages)
          {
              Attachment attIns = new Attachment();
              List<Messaging.EmailFileAttachment> emailAttList=new List<Messaging.EmailFileAttachment>();
			   emailAttList=getMail.getFileAttachments();
			
				attIns.name=emailAttList[0].getFilename();
				attIns.body=emailAttList[0].getBody();
				attIns.parentid=getMail.
				getMail.se
              	listAttachments.add(getMail);
          } */
			 
       }
      }
       catch(Exception e)
       {
           system.debug('Exception has occurred'+e.getMessage());
       }   
	       
   }
   global void finish(Database.BatchableContext bc)  
   {
            
   } 
   global void execute(SchedulableContext sc) 
   {
      Database.executeBatch(new QL_BatchToSendEmailCommsForQUIP(acctListIds),200);
   } 
}