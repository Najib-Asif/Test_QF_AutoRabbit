/*Jira-> FCRM-939- Service - Auto-Close Overridden Cases
Description-> This batch will auto-close the Overridden Cases from FRT Bookings and FRT Cust SErvice
Developer-> Navpreet Kaur
Creation Date-> 10 AUG 2022
*/

global with sharing class batchFreightAutoCloseOverriddenCases implements Database.Batchable<sObject>,schedulable {
   
   global batchFreightAutoCloseOverriddenCases() 
   {
   }
       
   global Database.QueryLocator start(Database.BatchableContext bc)
   {
      ID QantasFreightIT=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
    
      String query='Select id, parentid, status, messagedate,ToAddress,HtmlBody, FromAddress,CcAddress, Subject, TextBody, parent.origin from emailmessage where parentid!=null and parent.status!=\'closed\' and (parent.origin=\'FRT Bookings\' or parent.origin=\'FRT Cust Service\') and parent.recordtypeid=\''+QantasFreightIT+'\'';
      
      return Database.getQueryLocator(query); 
   }
   global void execute(Database.BatchableContext bc, List<EmailMessage> scope) 
   {
      try
      {
          ID QantasFreightIT=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
          List<Id> listParentIds=new List<Id>();
          List<Case> UpdateCases=new List<Case>();
          Set<Id> CloseCaseIds=new Set<Id>();
          List<String> listBookingsKey=new List<String>();
          List<String> listCustServKey=new List<String>();
          List<Freight_Filter_Keywords__mdt> filterKeywords= Freight_Filter_Keywords__mdt.getAll().values();
          List<Freight_Filter_Keywords__mdt> getFRTBookings=new List<Freight_Filter_Keywords__mdt>();
          List<Freight_Filter_Keywords__mdt> getFRTCustServ=new List<Freight_Filter_Keywords__mdt>();
          List<String> onlySubject=new List<String>();
          List<String> SubjBody=new List<String>();
          String str;
          String plainText;
          
          
             if(filterKeywords!=null && filterKeywords.size()>0)
             {
                     for(Freight_Filter_Keywords__mdt getMetaData: filterKeywords)
                     {
                         if(getMetadata.Freight_Mailbox_Name__c=='FRT Bookings')
                         {
                            getFRTBookings.add(getMetaData);      
                         }
                         else if(getMetadata.Freight_Mailbox_Name__c=='FRT Cust Service')
                         {
                             getFRTCustServ.add(getMetadata);
                         }
                     }                     
              }
            
              if(scope!=null && scope.size()>0)  
              {
                  for(EmailMessage getEms: scope)
                  {
                      if(getEms.parent.origin=='FRT Bookings' && getEms.parentid!=null )
                      {
                          for(Freight_Filter_Keywords__mdt getMeta :getFRTBookings)
                          {
                              if(getMeta.Freight_Type__c.contains('Only subject'))
                              {
                               
                                onlySubject.addAll(getMeta.Freight_Subject__c.split(','));
                                
                                if(onlySubject!=null)
                                for(String getStr :onlySubject)
                                {
                                    if(getEms.Subject!=null &&  getEms.Subject.contains(getStr.trim()))
                                    {

                                        CloseCaseIds.add(getEms.ParentId);
                                    }
                                }
                              }
                              
                              if(getMeta.Freight_Type__c.contains('Subject or body'))
                              {
                                  SubjBody.addall(getMeta.Freight_Subject__c.split(','));
                                  for(String getStr: SubjBody)
                                    {
                                        if(getEms.Subject!=null && getEms.TextBody!=null)
                                        if(getEms.Subject.contains(getStr.trim())||getEms.textbody.contains(getStr.trim()))
                                        {
                                            CloseCaseIds.add(getEms.ParentId);
                                        }
                                    }   
                              }
                              if(getMeta.Freight_Type__c.contains('From and Subject'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addAll(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); if(FromAdd.contains('mailto:')){FromAdd=FromAdd.substringBefore('mailto:');}
                                      }
                                  }
                                  if(getEms.FromAddress!=null && FromAdd!=null && getEms.Subject!=null)
                                  if((getEms.FromAddress.contains(getMeta.freight_from__c.trim()) || FromAdd==getMeta.freight_from__c.trim()) && getEms.Subject.contains(getMeta.Freight_Subject__c.trim()))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  }
                              }
                             
                              if(getMeta.Freight_Type__c.contains('CC Address'))
                              {
                                   
                                  
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  List<String> CCAdd=new List<String>();
                                 
                                  
                                  if(getEms.HtmlBody!=null)
                                 // getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                 
                                  
                                    
                                  //str = getEms.HtmlBody.replaceAll('\\<.*?\\>', '').replace('&nbsp;','');
                                  //List<String> spiltStr = str.split('\n');
                                  plainText = getEms.HtmlBody.stripHtmlTags(); 
                                  getEmsBodyList.addall(plainText.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  
                                  
                                  for(String getLine: getEmsBodyList)
                                  {
                                  
                                    if(getLine.contains('Cc:'))
                                    {
                                  
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }

                                  
                                  if(getEmsBodyKeyList!=null)
                                  
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                     /* if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                      CCAdd=getEch.replace('<', '').replace('>','');if(CCAdd.contains('mailto:')){CCAdd=CCAdd.substringBefore('mailto:');}
                                      }
                                      else*/
                                      if(getEch.contains('mailto:'))
                                      {
                                  
                                          CCAdd.add(getEch.substringAfter('mailto:'));
                                      }
                                  }
                                  
                                  
                                  if(CCAdd!=null && CCAdd.size()>0 && getEms.CcAddress!=null)
                                  
                                  
                                  for(String strMeta: CCAdd)
                                  {
                                      if(strMeta.contains(getMeta.Freight_CC_Address__c.trim()) || getEms.CcAddress.contains(getMeta.Freight_CC_Address__c.trim()))
                                      {
                                  
                                              CloseCaseIds.add(getEms.ParentId);
                                      }
                                  }
                                  
                              }
                           }
                      }
                      else if(getEms.parent.origin=='FRT Cust Service' && getEms.parentid!=null && getEms.subject!=null)
                      {
                          for(Freight_Filter_Keywords__mdt getMeta :getFRTCustServ)
                          {
                              if(getMeta.Freight_Type__c.contains('From and Subject'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                          if(FromAdd.contains('mailto:'))
                                          {
                                              FromAdd=FromAdd.substringBefore('mailto:');
                                          }
                                      }
                                  }
                                  
                                  if(getEms.FromAddress!=null && FromAdd!=null && getEms.Subject!=null)
                                  if((getEms.FromAddress==getMeta.freight_from__c.trim() || FromAdd.Equals(getMeta.freight_from__c.trim())) && getEms.Subject.contains(getMeta.Freight_Subject__c.trim()))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  }
                              }
                              
                              if(getMeta.Freight_Type__c.contains('CC Address'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String CCAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('CC:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          CCAdd=getEch.replace('<', '').replace('>','');
                                          if(CCAdd.contains('mailto:'))
                                          {
                                              CCAdd=CCAdd.substringBefore('mailto:');
                                          }
                                      }
                                  }
                                  
                                  if(CCAdd!=null && getEms.CcAddress!=null)
                                  if(CCAdd==getMeta.Freight_CC_Address__c.trim() || getEms.CcAddress.contains(getMeta.Freight_CC_Address__c.trim()))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  }         
                              }
                              if(getMeta.Freight_Type__c.contains('Subject or body with From Address Exception'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                          if(FromAdd.contains('mailto:'))
                                          {
                                              FromAdd=FromAdd.substringBefore('mailto:');
                                          }
                                      }
                                  }
                                  
                                  if(FromAdd!=null && getEms.Subject!=null && getEms.Textbody!=null && getMeta.freight_from__c!=null && getMeta.Freight_Body__c!=null)
                                  if(!FromAdd.Equals(getMeta.freight_from__c.trim()) && (getEms.Subject.contains(getMeta.Freight_Subject__c.trim()) || getEms.Textbody.contains(getMeta.Freight_Body__c.trim())))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  }    
                              }
                              
                              if(getMeta.Freight_Type__c.contains('From Address'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                          if(FromAdd.contains('mailto:'))
                                          {
                                              FromAdd=FromAdd.substringBefore('mailto:');
                                          }
                                      }
                                  }
                                  
                                  if(FromAdd!=null && getEms.FromAddress!=null && getMeta.freight_from__c!=null)
                                  if(FromAdd.Equals(getMeta.freight_from__c.trim()) || getEms.FromAddress.equals(getMeta.Freight_from__c.trim()))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  } 
                              }
                              
                              
                              if(getMeta.Freight_Type__c.contains('To Address'))
                              {
                                List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('To:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                      }
                                  }
                                  
                                  if(FromAdd!=null && getEms.ToAddress!=null)
                                  if(FromAdd.Equals(getMeta.Freight_To_Address__c.trim()) || getEms.ToAddress.contains(getMeta.Freight_To_Address__c.trim()))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  }   
                              }
                              if(getMeta.Freight_Type__c.contains('From Address and Subject or Body'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  
                                  if(getEmsBodyKeyList!=null)
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                          if(FromAdd.contains('mailto:'))
                                          {
                                              FromAdd=FromAdd.substringbefore('mailto:');
                                          }
                                      }
                                      
                                  }
                                  
                                  if(FromAdd!=null && getEms.Subject!=null &&  getEms.Textbody!=null)
                                  if(FromAdd.Equals(getMeta.freight_from__c.trim()) && (getEms.Subject.contains(getMeta.Freight_Subject__c.trim()) || getEms.Textbody.contains(getMeta.Freight_Body__c.trim())))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  } 
                              }
                              
                              
                              if(getMeta.Freight_Type__c.contains('From Address and Body'))
                              {
                                  List<String> getEmsBodyList=new List<String>();
                                  List<String> getEmsBodyKeyList=new List<String>();
                                  String FromAdd='';
                                  
                                  if(getEms.TextBody!=null)
                                  getEmsBodyList.addall(getEms.TextBody.split('\n'));
                                  
                                  if(getEmsBodyList!=null)
                                  for(String getLine: getEmsBodyList)
                                  {
                                    if(getLine.contains('From:'))
                                    {
                                        getEmsBodyKeyList.addAll(getLine.split(' '));
                                    }
                                  }
                                  for(String getEch :getEmsBodyKeyList)
                                  {
                                      if(getEch.contains('<') && getEch.contains('>'))
                                      {
                                          FromAdd=getEch.replace('<', '').replace('>',''); 
                                          if(FromAdd.contains('mailto:'))
                                          {
                                              FromAdd=FromAdd.substringBefore('mailto:');
                                          }
                                      }
                                  }
                                  
                                  if(FromAdd!=null && getEms.FromAddress!=null && getEms.Textbody!=null)
                                  if((FromAdd.Equals(getMeta.freight_from__c.trim()) || getEms.FromAddress.Equals(getMeta.freight_from__c.trim())) && (getEms.Textbody.contains(getMeta.Freight_Body__c.trim())))
                                  {
                                      CloseCaseIds.add(getEms.ParentId);
                                  } 
                              }
                              
                              if(getMeta.Freight_Type__c.contains('Only subject'))
                              {
                                onlySubject.addall(getMeta.Freight_Subject__c.split(','));
                                  
                                if(onlySubject!=null)
                                for(String getStr: onlySubject)
                                {
                                    if(getEms.Subject!=null && getEms.Subject.contains(getStr.trim()))
                                    {
                                        CloseCaseIds.add(getEms.ParentId);
                                    }
                                }
                              } 
                          }
                      }
                  }
              }
          
          if(CloseCaseIds!=null && CloseCaseIds.size()>0)
          {
              List<Case> getCases=[select id,status from case where recordtypeid=:QantasFreightIT and ID IN:CloseCaseIds limit 50000];
              if(getCases!=null && getCases.size()>0)
              for(Case getCase:getCases)
              {
                  getCase.status='Closed';
                  getCase.type='Invalid Case';
                  UpdateCases.add(getCase);
              }
          }
          if(UpdateCases!=null && UpdateCases.size()>0)
          {
              update UpdateCases;
          }
     }
         
      catch(exception e)
      {
         system.debug('Exception has occurred'+e.getmessage()+ e.getLineNumber());
      }
   }
   global void finish(Database.BatchableContext bc) 
   {
            
   }
   global void execute(SchedulableContext sc)
   {
       database.executebatch(new batchFreightAutoCloseOverriddenCases());
      //System.schedule('Scheduled batch 1', '0 0 * * * ?', new batchFreightAutoCloseOverriddenCases());
      //System.schedule('Scheduled batch 2', '0 30 * * * ?', new batchFreightAutoCloseOverriddenCases()); 
      
   }
   global static void start(integer min){
         string jobName = 'Schedule Batch';
         
         jobName = jobName;
         String cron='0 30 * * * ?';
         //string cron = '0' + string.valueof(min) + '* * * *';
         system.schedule(jobName, cron, new batchFreightAutoCloseOverriddenCases());
     
     }
}