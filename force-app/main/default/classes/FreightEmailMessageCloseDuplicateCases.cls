/*----------------------------------------------------------------------------------------------------------------------
Author:        Gandla Mallikarjuna
Company:       TCS
Description:   FreightEmailMessageCloseDuplicateCases
Test Class:    FreightEmailMsgCloseDuplicateCasesTest

************************************************************************************************
History
************************************************************************************************
29-Jan-2026   Mark-Capgemini      CRM-10427 Code Security Remediation, PSV changes for System and User Mode for SOQL    
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class FreightEmailMessageCloseDuplicateCases { //CRM-10427 added without sharing for Code Security Remediation

    private static final String ORIGIN_FRTBOOKINGS_CASE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTBookings');
    private static final String CASEORIGIN_FRTCUSTSERVICE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTCustService');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    //private static final String CUST_FOLLOWUP_ISSUE_ROOT_CAUSE = CustomSettingsUtilities.getConfigDataMap('CustFollowUpIssueRootCause');
    //private static final String DUPLICATE_CASE_ISSUE_TYPE = CustomSettingsUtilities.getConfigDataMap('DuplicateCaseIssueType');
    private static final String REPLIED_EMAIL_PREFIX = CustomSettingsUtilities.getConfigDataMap('RepliedEmailPrefix');
    private static final String FORWARDED_EMAIL_PREFIX = CustomSettingsUtilities.getConfigDataMap('ForwardedEmailPrefix');
    private static final String COLON_SYMBOL = CustomSettingsUtilities.getConfigDataMap('ColonSymbol');
    private static final String CASE_TYPE_INVALID = CustomSettingsUtilities.getConfigDataMap('Type_InvalidCase');

    /*--------------------------------------------------------------------------------------      
    Method Name:        freightCloseDuplicateCases
    TestMehtod:         testfreightCloseDuplicateCases
    Description:        This method matches the subjects of all emails received for Freight cases and close the duplicate cases 
    Parameter:          EmailMessage New List  
    --------------------------------------------------------------------------------------*/ 
    @InvocableMethod(label='freight Close Duplicate Cases' description='')
    public static void freightCloseDuplicateCases(List<EmailMessage> emails)
    {
        system.debug('inside freightCloseDuplicateCases'+emails);
        //DuplicateExecuted=true; //Set the global static variable to true to block recurrsive calling
        Map<ID,string> MapEmailSubjects=new Map<ID,string>(); 
        List<Case> getExistingCases=new List<Case>();
        List<Case> updateCases=new List<Case>();
        List<Case> updateParentCases=new List<Case>();
        List<ID> getEmailParentIDs=new List<ID>();
        Map<Id,Case> getMatchedOldCases=new Map<Id,Case>();
        Map<ID,EmailMessage> mapEmailMsgs=new Map<ID,EmailMessage>();
        Map<Id,EmailMessage> emailMsgIds=new Map<Id,EmailMessage>();
        
        List<contentdocumentLink> getContentDocumentLink=new List<contentdocumentLink>();
        List<contentdocumentLink> updateContentDocumentLink=new List<contentdocumentLink>();
        Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        ID parentCaseID;
        try
        {
            
            if(emails!=null && emails.size()>0)
                for(EmailMessage getNewEmails:emails)
            {
                
                if(getNewEmails.subject!=null && (getNewEmails.subject.contains(FORWARDED_EMAIL_PREFIX) || getNewEmails.subject.contains(REPLIED_EMAIL_PREFIX) /*||getNewEmails.subject.contains(COLON_SYMBOL)*/ ))
                {
                    system.debug('inside if subject contains :');
                    MapEmailSubjects.put(getNewEmails.parentid,getNewEmails.subject.substringAfter(COLON_SYMBOL));
                    system.debug('emailSubject'+MapEmailSubjects);
                    
                }
                else if(getNewEmails.subject!=null /*&& getNewEmails.subject.containsNone(COLON_SYMBOL)*/)
                {
                    system.debug('inside else if subject not contains :');
                    MapEmailSubjects.put(getNewEmails.parentid,getNewEmails.subject);
                    system.debug('emailSubject'+MapEmailSubjects);
                    
                }
                if(getNewEmails.hasAttachment==true)
                {
                    emailMsgIds.put(getNewEmails.id,getNewEmails);
                }
                system.debug('MapEmailSubjects'+MapEmailSubjects);
                mapEmailMsgs.put(getNewEmails.parentid,getNewEmails);
                system.debug('mapEmailMsgs'+mapEmailMsgs);
                
            }
            if(emailMsgIds!=null && emailMsgIds.size()>0)
            {
                getContentDocumentLink=[select id,contentdocumentid, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:emailMsgIds.keyset() WITH SYSTEM_MODE]; //CRM-10427 added WITH SYSTEM_MODE for Code Security Remediation
            }
            //Calling SOQL with negative expressions causes performance issues. Hence replace status equals closed with isclosed = true
            //getExistingCases = [select id,subject,casenumber,origin,status,createddate,recordtypeid from case where (Origin=:ORIGIN_FRTBOOKINGS_CASE OR Origin =:CASEORIGIN_FRTCUSTSERVICE) and recordtypeId=:CaseRT_ID and status !=:CASE_CLOSED_STATUS];
            getExistingCases = [select id,subject,casenumber,origin,status,createddate,recordtypeid from case where (Origin=:ORIGIN_FRTBOOKINGS_CASE OR Origin =:CASEORIGIN_FRTCUSTSERVICE) and recordtypeId=:CaseRT_ID AND IsClosed = false WITH SYSTEM_MODE];//CRM-10427 added WITH SYSTEM_MODE for Code Security Remediation

            system.debug('getExistingCases'+getExistingCases);
            
            if(MapEmailSubjects!=null && MapEmailSubjects.isEmpty()==false && getExistingCases!=null && getExistingCases.size()>0)
            {
                
                for(String newSubject :MapEmailSubjects.values())
                {
                    
                    for(Case existingCase :getExistingCases)
                    {
                        
                        String newSub=newSubject.trim();
                        system.debug('newSub***'+newSub);
                        String colonLessSub='';
                        //Added Not null check for Bug Jira FCRM-944
                        if(existingCase.subject!=null && existingCase.subject!='' && /*existingCase.subject.contains(':')*/(existingCase.subject.contains(FORWARDED_EMAIL_PREFIX) || existingCase.subject.contains(REPLIED_EMAIL_PREFIX)))
                        {
                            colonLessSub=existingCase.subject.contains(FORWARDED_EMAIL_PREFIX) ? existingCase.subject.substringAfter(FORWARDED_EMAIL_PREFIX).trim():existingCase.subject.substringAfter(REPLIED_EMAIL_PREFIX).trim();
                            //string colonLessRWSub =existingCase.subject.substringAfter(REPLIED_EMAIL_PREFIX).trim();  
                            system.debug('colonLessSub if'+colonLessSub);
                        }
                        else if(existingCase.subject!=null && existingCase.subject!='' /*&& existingCase.subject.containsNone(':')*/) //Added Not null check for Jira FCRM-5876
                        {
                            colonLessSub=existingCase.subject.trim();
                            system.debug('colonLessSub else if '+colonLessSub);
                        }
                        
                        system.debug('colonLessSub'+colonLessSub);  
                        if((existingCase.origin == ORIGIN_FRTBOOKINGS_CASE || existingCase.origin == CASEORIGIN_FRTCUSTSERVICE) && /*!MapEmailSubjects.containsKey(existingCase.id) &&*/ (colonLessSub !='' && colonLessSub.equals(newSub))) //Added Not blank check for Jira FCRM-5876
                        {
                            getMatchedOldCases.put(existingCase.id,existingCase);
                        }  
                    }
                } 
            }
            
            List<Case> getCasesSortedbyDate;
            if(getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false)
            {
                getCasesSortedbyDate=[select id,createddate,Type,subject,casenumber,origin,status,Freight_Resolve_Reason__c,Resolved_Reasons_Sub_Type__c from case where ID IN:getMatchedOldCases.keyset() WITH SYSTEM_MODE order by createddate asc];
            System.debug('getMatchedOldCases.keyset()'+getMatchedOldCases.keyset());
            }
            
            system.debug('*getCasesSortedbyDate'+getCasesSortedbyDate);
            system.debug('*getMatchedOldCases'+getMatchedOldCases);    
            
            if(getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false && getCasesSortedbyDate!=null && getCasesSortedbyDate.size()>0)
            {
                //Additional check to open FRT Booking Cases if both FRT Bookings and FRT Cust Service cases created at same time Jira 5753
                system.debug('*****before if'+getCasesSortedbyDate.size());
                if(getCasesSortedbyDate.size()>1 && getCasesSortedbyDate[0].origin == CASEORIGIN_FRTCUSTSERVICE && getCasesSortedbyDate[1].origin == ORIGIN_FRTBOOKINGS_CASE ){
                    system.debug('*****inside if'+getCasesSortedbyDate[1].origin);
                    parentCaseID=getCasesSortedbyDate[1].id;
                }else if(getCasesSortedbyDate.size()>1 && getCasesSortedbyDate[0].origin == ORIGIN_FRTBOOKINGS_CASE && getCasesSortedbyDate[1].origin == CASEORIGIN_FRTCUSTSERVICE ){//Fix for CRM 5898
                    system.debug('*****inside elseif'+getCasesSortedbyDate[0].origin);
                    parentCaseID=getCasesSortedbyDate[0].id;
                }
                else{
                    system.debug('*****inside else');
                    parentCaseID=getCasesSortedbyDate[0].id;
                }
                // End of Jira 5753
                for(Case getCase: getCasesSortedbyDate)
                {
                    
                    if(!getCase.id.equals(ParentCaseID) && (getCase.origin == ORIGIN_FRTBOOKINGS_CASE ||getCase.origin == CASEORIGIN_FRTCUSTSERVICE))
                    { 
                        system.debug('inside if logic for closing cases');
                        //getCase.parentid=parentCaseID;
                        getCase.status = CASE_CLOSED_STATUS;
                        getCase.Type = CASE_TYPE_INVALID;
                        updateCases.add(getCase);
                        getEmailParentIDs.add(getCase.id);
                        
                    }
                }
            }
            
            system.debug('updateCases'+updateCases);
            system.debug('updateCases.size()'+updateCases.size());
            if(updateCases!=null && updateCases.size()>0)
            {
                UPDATE as system updateCases; //CRM-10427 CRUD check before DML 
            }
            
            for(Case getCase: updateCases)
            {
                if(getCase.Status == CASE_CLOSED_STATUS)
                {
                    system.debug('getCase.parentid'+getCase.Id);
                    system.debug('getCase.parentid'+parentCaseID);
                    getCase.parentid=parentCaseID; 
                    updateParentCases.add(getCase); 
                }
            }
            system.debug('updateParentCases'+updateParentCases.isEmpty());
            system.debug('updateParentCasessize'+updateParentCases.size());
            if( !updateParentCases.isEmpty() && updateParentCases.size()>0) // Fix for Duplicate cases- CRM 6417
            {
                update as system updateParentCases; //CRM-10427 CRUD check before DML 
            }
            system.debug('aft updateParentCases'+updateParentCases);
            
            system.debug('mapEmailMsgs******'+mapEmailMsgs);
            system.debug('getMatchedOldCases******'+getMatchedOldCases);
            if(mapEmailMsgs!=null && mapEmailMsgs.isEmpty()==false && getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false)
            {
                List<EmailMessage> emailsToClone = new List<EmailMessage>();
                List<EmailMessage> emailsToRemove = new List<EmailMessage>();
                system.debug('mapEmailMsgs'+mapEmailMsgs.values());
                for(EmailMessage getEms: mapEmailMsgs.values())
                {
                    if(getMatchedOldCases.containskey(getEms.parentid))
                    {
                        EmailMessage emailToClone = getEms.clone(false, true, true, true);
                        emailToClone.parentid = parentCaseID;
                        emailToClone.IsAsyncLogic__c = true;
                        emailsToClone.add(emailToClone);
                        emailsToRemove.add(getEms);
                        system.debug('getEms.parentid'+getEms.parentid);
                    }
                }
                if (emailsToClone.size() > 0) {
                    INSERT as system emailsToClone; //CRM-10427 CRUD check before DML //From USER to SYSTEM
                }
                //Fix for Freight Email Attachments relinking to cloned emails INC2472978
                if(getContentDocumentLink!=null && getContentDocumentLink.size()>0 && emailsToClone!=null && emailsToClone.size()>0)
                {
                    for(contentDocumentLink getLinks: getContentDocumentLink)
                    {
                        if(emailMsgIds.containskey(getLinks.LinkedEntityId))
                        {
                            for(EmailMessage getMsg:emailsToClone)
                            {
                                    getLinks.LinkedEntityId=getMsg.id;
                                    updateContentDocumentLink.add(getLinks);
                                
                            }
                        }
                    }
                }
                
                if(updateContentDocumentLink!=null && updateContentDocumentLink.size()>0)
                {
                    UPDATE as user updateContentDocumentLink; //CRM-10427 CRUD check before DML
                }
                if (emailsToRemove.size() > 0) {
                    DELETE as user emailsToRemove; //CRM-10427 CRUD check before DML
                }
            }
        } catch (QueryException e) { //CRM-10427 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'FreightEmailMessageCloseDuplicateCases', 
                                    'freightCloseDuplicateCases', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
        } catch(Exception ex)    
        {
            system.debug('Exception Occurred' + ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'FreightEmailMessageCloseDuplicateCases', 
                                    'freightCloseDuplicateCases', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
}