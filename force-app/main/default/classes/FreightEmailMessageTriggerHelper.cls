/*----------------------------------------------------------------------------------------------------------------------
Author:        Navpreet Kaur
Company:       TCS
Date Implemented:  15 March 2022
Description:   Class to be invoked from Email Message Trigger, all Logics has been restricted for Freight RecordTypes
Test Class:    freightEmailMessageTriggerHelperTest
-------------------------------------------------------------------------------------------------------------------------*/

global with sharing class FreightEmailMessageTriggerHelper 
{
    Map<String, String> freight_rectypeMap = new Map<String, String>();
    public static Boolean DuplicateExecuted=false;
    public static Boolean priorityPremCustExecuted=false;
    public static Boolean updateCaseAccountexecuted=false;
    public freightEmailMessageTriggerHelper (){
        
        Map<String, Schema.RecordTypeInfo> caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        
        for(String recType: caseRT.keySet()) 
        {
            if(caseRT.get(recType).getDeveloperName().contains('Freight'))
            {
                freight_rectypeMap.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
            }   
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        getnewEmailstoRecordComm
TestMethod:         testEmailMessages
Description:        This method get the latest email message's date time and update on the respective case fields
Parameter:          EmailMessage New List 
Jira Story:         FCRM-848 
Date Implemented:   1 March 2022
Sprint:             155
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    @future //CRM-5541: Converted Asyn method
    public static void getnewEmailstoRecordComm(Set<Id> emailMessageIds)
    {
        List<string> listSubjects=new List<string>();
        set<string> setCasesIds=new set<string>();
        List<case> updateCases=new List<case>();
        Map<string,EmailMessage> mapMailsDateTime=new Map<string,EmailMessage>();
        try
        {
            //CRM-5541: Converted Asyn method
            List<EmailMessage> emailObject = new List<EmailMessage>([SELECT id,MessageDate,Incoming,subject,FromAddress,status,parentid,ToAddress,To_Address__c,HtmlBody,QCC_Tech_Is_Internal_Email__c FROM EmailMessage WHERE Id IN: emailMessageIds]);
            if(emailObject!=null && emailObject.size()>0)
            {
                for(Emailmessage emails:emailObject)
                {
                    if(emails.parentid!=null )
                    {
                        String str='';
                        
                        string[] splitSub=new string[]{};
                            splitSub=emails.subject.split(' ');
                        str=splitSub[splitSub.size()-1];
                        
                        if(emails.parentid!=null)
                        {
                            setCasesIds.add(emails.parentid);
                            mapMailsDateTime.put(emails.parentid,emails);
                        }
                        
                    }
                }
                Map<Id,Case> getCasesMap=new Map<Id,Case>([select id,casenumber,freight_Last_Comm_ID__c,FreightLastCommDate__c,Freight_lastcomstype__c from case where ID IN:setCasesIds and recordtype.name='Qantas Freight' and origin='Web']); 
                
                if(getCasesMap.isEmpty()==false && mapMailsDateTime.isEmpty()==false)
                {
                    for(Case getCase: getCasesMap.values())
                    {
                        if(mapMailsDateTime.containskey(getCase.id))
                        {
                            getCase.FreightLastCommDate__c=mapMailsDateTime.get(getCase.id).MessageDate;
                            getCase.Freight_lastcomstype__c='Email';
                            getCase.freight_Last_Comm_ID__c=mapMailsDateTime.get(getCase.id).Id; 
                            updateCases.add(getCase);
                        }
                        
                    }
                }
                if(updateCases!=null && updateCases.size()>0)
                {
                    
                    update updateCases;
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getMessage());
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        assignUrgentPriorityForCasesWithHotWords
TestMehtod:         testassignUrgentPriorityForCasesWithHotWords
Description:        This method automates the case Priority to be Urgent based on the Hot words
Parameter:          EmailMessage New List 
Jira Story:         FCRM-894
Date Implemented:   28 March 2022
Sprint Freight      156
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    @future    //CRM-5541: Converted Asyn method
    public static void assignUrgentPriorityForCasesWithHotWords(Set<Id> emailMessageIds)
    {
        
        List<ID> listParentIds=new List<ID>();
        List<string> listDesc=new List<string>();
        List<string> listSubj=new List<string>();
        List<string> listDescEmail=new List<string>();
        List<string> listSubjEmail=new List<string>();
        List<string> strHotEmails=new List<string>();
        List<string> strHotWrds=new List<string>();
        Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        Id QCCHotWords_RTID= Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<QCC_Hotword_Queue_Routing__c> listHotWords=new List<QCC_Hotword_Queue_Routing__c>();
        Map<string,List<String>> mapHotWords=new Map<string,List<String>>();
        Map<Id,string> listUpdateCases=new Map<Id,string>();
        String constStrIgnore='Retail '+'Booking '+'Confirmation';
        List<case> updateCaseList=new List<Case>(); 
        
        try
        {
            //CRM-5541: Converted Asyn method
            List<EmailMessage> emailsNewList = new List<EmailMessage>([SELECT id,Incoming,subject,FromAddress,status,parentid,TextBody,
                                                                       ToAddress,To_Address__c,HtmlBody,QCC_Tech_Is_Internal_Email__c FROM EmailMessage WHERE Id IN: emailMessageIds]);
            listHotWords =[select id,name,Hot_words__c,Priority__c,freight_Type__c from QCC_Hotword_Queue_Routing__c where RecordTypeId=: QCCHotWords_RTID];
            
            if(listHotWords!=null && listHotWords.size()>0)
            {   
                for(QCC_Hotword_Queue_Routing__c getHotWrds :listHotWords)
                {    
                    //Code is being commented as part of Jira FCRM - 943
                    /*if(getHotWrds.freight_Type__c.contains('Hot Word'))
{
strHotWrds.addAll(getHotWrds.Hot_words__c.split(',')); 
}
else
{
strHotEmails.addAll(getHotWrds.Hot_words__c.split(',')); 
}*/
                    if(getHotWrds.freight_Type__c.contains('Mail Suffix'))
                    {
                        strHotEmails.addAll(getHotWrds.Hot_words__c.split(','));
                    }
                    
                }    
            }
            if(emailsNewList!=null && emailsNewList.size()>0)
            {
                for(EmailMessage em: emailsNewList)
                {
                    if(em.parentid!=null)
                    {
                        listParentIds.add(em.ParentId);    
                    }
                    
                }
            }
            Map<Id,Case> mapFrtCases=new Map<Id,Case>([select id,casenumber,origin,priority from Case where Id IN :listParentIds and recordtypeID = :CaseRT_ID]);
            
            if(emailsNewList!=null && emailsNewList.size()>0)
            {
                for(EmailMessage emsg: emailsNewList)
                {
                    if((mapFrtCases.keySet()!=null && mapFrtCases.values()!=null) && mapFrtCases.containsKey(emsg.parentid) && (mapFrtCases.get(emsg.parentid).origin=='FRT Bookings'|| mapFrtCases.get(emsg.parentid).origin=='FRT Cust Service') && emsg.TextBody!=null)
                    {
                        String FromEmdomain;
                        
                        if(emsg.fromaddress!=null && emsg.fromaddress.contains('@'))
                        {
                            FromEmdomain='@'+emsg.fromaddress.substringAfter('@').trim();
                        }
                        
                        
                        listDesc=emsg.TextBody.split('\n');
                        for(String strSplit: listDesc)
                        {
                            if(strSplit.contains('From:'))
                            {
                                listDescEmail.addAll(strSplit.split(' '));    
                            }
                            
                            // Code is being commented as part of Jira FCRM - 943
                            /* else
{
for(string strHwrds :strHotWrds)
{
if(strSplit.containsIgnoreCase(strHwrds) && !emsg.Subject.containsIgnoreCase(constStrIgnore))
{
listUpdateCases.put(mapFrtCases.get(emsg.parentid).Id,'Urgent');

} 
}
}*/
                        }
                        if((listDescEmail!=null && listDescEmail.size()>0) || emsg.fromAddress!=null)
                        {
                            integer index=1;
                            String fltCan='';
                            
                            for(string strHEms :strHotEmails)
                            {
                                
                                if(FromEmdomain.containsIgnoreCase(strHEms))
                                {
                                    listUpdateCases.put(mapFrtCases.get(emsg.parentid).Id,'Urgent');
                                }
                            }
                            
                            for(String getEach :listDescEmail)
                            {
                                if( getEach.contains('<') && getEach.contains('>'))
                                {
                                    getEach=getEach.replace('<','').replace('>','');
                                    if(getEach.contains('mailto:'))
                                    {
                                        getEach=getEach.substringBefore('mailto:');
                                    }
                                    if(getEach.contains('@'))
                                    {
                                        getEach='@'+getEach.substringAfter('@').trim();
                                    }
                                    for(string strHEms :strHotEmails)
                                    {
                                        if(getEach.containsIgnoreCase(strHEms))
                                        {
                                            
                                            listUpdateCases.put(mapFrtCases.get(emsg.parentid).Id,'Urgent');
                                            
                                        }
                                    }
                                }
                                
                            }
                        } 
                    }
                    //Code is being commented as part of Jira FCRM - 943
                    /* if((mapFrtCases.keySet()!=null && mapFrtCases.values()!=null) && mapFrtCases.containsKey(emsg.parentid) && (mapFrtCases.get(emsg.parentid).origin=='FRT Bookings'|| mapFrtCases.get(emsg.parentid).origin=='FRT Cust Service') && emsg.subject!=null)
{
listSubj=emsg.Subject.split(' ');
if(listSubj!=null && listSubj.size()>0)
{
integer index=1;
String fltCan='';

for(string getSub :listSubj)
{
if(index<listSubj.size())
{
fltCan=listSubj[index-1]+' '+listSubj[index];    
} 
for(string strHwrds :strHotWrds)
{
if((getSub.containsIgnoreCase(strHwrds) || fltCan.containsIgnoreCase(strHwrds)) && !emsg.Subject.containsIgnoreCase(constStrIgnore))
{
listUpdateCases.put(mapFrtCases.get(emsg.parentid).Id,'Urgent');
}

}
index++;
}     
}
} */
                }
            }
            if(listUpdateCases.keyset()!=null && listUpdateCases.values()!=null)
            {
                for(Case getCs :mapFrtCases.values())
                {
                    if(listUpdateCases.containskey(getCs.id) && getCs.priority!='Premium')
                    {
                        getCs.priority='Urgent';
                        updateCaseList.add(getCs);
                    } 
                }
                if(updateCaseList!=null && updateCaseList.size()>0)
                {
                    update updateCaseList;
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
        
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        autoResponseEmailInvoices
Description:        This method sends an auto-response for Invoice Cases to Group Email
Parameter:          EmailMessage New List  
Jira Story:         FCRM-903
Date Implemented:   6 April 2022
Sprint Freight      156
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    //@InvocableMethod(label='Get case ID' Description='')
    public static list<ID> autoResponseEmailInvoices(list<ID> NewList)
    {
        list<emailmessage> listEmailMsg=new list<emailmessage>();
        List<id> CaseIds=new List<Id>();
        try
        {
            // List<id> CaseIds=new List<Id>();
            
            Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            /* if(NewList!=null && NewList.size()>0)
{
for(EmailMessage em: NewList)
{
CaseIds.add(em.parentid); 
}

} */
            
            Map<id,Case> CaseMap=new Map<id,Case>([select id,type,Sub_Type_1__c,Sub_Type_2__c from case where id IN :CaseIds and recordtypeid =:CaseRT_ID and origin='Web' and Type='Customer Query']); 
            
            /* if(NewList!=null && NewList.size()>0 && CaseMap.keyset()!=null && CaseMap.values()!=null)
{
for(EmailMessage em: NewList)
{
if(CaseMap.containskey(em.parentid) && ((CaseMap.get(em.parentid).Sub_Type_1__c=='Accounts' && CaseMap.get(em.parentid).Sub_Type_2__c =='Invoice') || CaseMap.get(em.parentid).Sub_Type_1__c=='Terminal Service Fee') && em.status.contains('3'))
{
em.ccAddress='freightinvoices@qantas.com.au';
}

}
} */
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage());
        }  
        return CaseIds;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightMaskCreditCard
TestMehtod:         testfreightMaskCreditCard
Description:        This method checks the credit card details in the Email-to-Case and Mask them
Parameter:          EmailMessage New List  
Jira Story:         FCRM-902
Date Implemented:   11 April 2022
Sprint Freight      157
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    public void freightMaskCreditCard(List<EmailMessage> emails)
    {
        try
        {
            Boolean hasCardInfo;
            List<ID> caseIds=new List<ID>();
            Boolean isUpdate = false;
            Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            if(emails!=null && emails.size()>0)
            {
                for(Emailmessage ems:emails)
                {
                    if(ems.parentid!=null && ems.textbody!=null)
                    {
                        CaseIds.add(ems.parentid);
                    }
                }
                
            }
            
            Map<Id,Case> mapGetFrtCases=new Map<Id,Case>([Select id from Case where recordtypeid = :CaseRT_ID and (Origin='FRT Bookings' or Origin='FRT Cust Service') and id IN :CaseIds]);
            
            for(EmailMessage em :emails){
                hasCardInfo = false;
                
                if(em != null){
                    
                    
                    if(em.textbody!=null && mapGetFrtCases.keyset()!=null && mapGetFrtCases.containskey(em.parentid)){ 
                        String str = em.textbody;
                        str= str.replace('\n',' ');
                        if( em.textbody.contains('-XXXX-XXXX-XXXX')){
                            hasCardInfo = true;
                        }
                        List<String> spiltStr = str.split(' ');
                        for(String s : spiltStr){
                            String s1 = s;
                            
                            s= s.replace('\n','');
                            
                            s=s.replace('\r','');
                            
                            s =  s.trim();
                            
                            Boolean isAusPhoneNumberWithplus = s.startsWith('+61')||s.startsWith('0')||s.startsWith('61')||s.startsWith('+');
                            Boolean isPhoneNumber;
                            
                            if(isAusPhoneNumberWithplus){
                                
                                isPhoneNumber =  true;
                                continue;
                            }
                            
                            if(s.contains('http')) {    //skip the masking logic for urls
                                continue;
                            }
                            s = s.replaceAll('\\D','');
                            Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11}|(?:2131|1800|35*\\d{3})*\\d{15})$');
                            Matcher m = p.matcher(s);
                            if(m.matches()){
                                
                                hasCardInfo = true;
                                integer i =s.length();
                                String s2 = s.substring(2, i);
                                String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                                String strChanged = str.replace(s1, s3);
                                em.textbody = strChanged;
                                isUpdate= true;
                                
                            }
                        }
                        
                        //Jira CRM-5358
                        Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
                        for (String mskdStr : maskedStrMap.keySet())
                        {
                            em.TextBody = em.TextBody.replace(mskdStr, maskedStrMap.get(mskdStr));
                        }
                        
                    }
                    if(em.HtmlBody!=null && mapGetFrtCases.keyset()!=null && mapGetFrtCases.containskey(em.parentid))
                    {
                        String str = em.HtmlBody;
                        str = str.replaceAll('\\<.*?\\>', ' ');
                        str= str.replace('\n',' ');
                        str= str.replace('&nbsp;',' ');
                        if( em.HtmlBody.contains('-XXXX-XXXX-XXXX'))
                        {
                            hasCardInfo = true;
                        }
                        List<String> spiltStr = str.split(' ');
                        for(String s : spiltStr){
                            String s1 = s;
                            
                            s= s.replace('\n','');
                            
                            s=s.replace('\r','');
                            
                            s =  s.trim();
                            
                            Boolean isAusPhoneNumberWithplus = s.startsWith('+61')||s.startsWith('0')||s.startsWith('61')||s.startsWith('+');
                            Boolean isPhoneNumber;
                            
                            if(isAusPhoneNumberWithplus){
                                
                                isPhoneNumber =  true;
                                continue;
                            }
                            
                            if(s.contains('http')) {    //skip the masking logic for urls
                                continue;
                            }
                            
                            
                            Pattern alpha=Pattern.compile('^.*[a-zA-Z0-9]+.*$'); //skip the masking logic for NON-Credit Card Strings FCRM - 957
                            Matcher mAlpha = alpha.matcher(s);
                            if(mAlpha.matches() || s.contains('.'))
                            {
                                continue;
                            }
                            
                            
                            s = s.replaceAll('\\D','');
                            Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11}|(?:2131|1800|35*\\d{3})*\\d{15})$');
                            Matcher m = p.matcher(s);
                            if(m.matches()){
                                
                                hasCardInfo = true;
                                integer i =s.length();
                                String s2 = s.substring(2, i);
                                String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                                String strChanged = str.replace(s1, s3);
                                
                                em.HtmlBody = em.HtmlBody.replace(s1, s3);
                                
                                //em.HtmlBody = strChanged;
                                isUpdate= true;
                                
                            }
                        }
                        //Jira CRM-5358
                        Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
                        for (String mskdStr : maskedStrMap.keySet())
                        {
                            em.HtmlBody = em.HtmlBody.replace(mskdStr, maskedStrMap.get(mskdStr));
                        }
                    }
                }
                
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage());
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightLevelUpCasePriority
TestMehtod:         testfreightLevelUpCasePriority
Description:        This method checks new emailMessage on Case and upgrade the case priority and change status from on-hold to in progress
Parameter:          EmailMessage New List  
Jira Story:         FCRM-899
Date Implemented:   13 April 2022
Sprint Freight      157
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    @future   //CRM-5541: Converted Asyn method
    public static void freightLevelUpCasePriority(Set<Id> emailMessageIds) 
    {
        try
        {
            List<Id> caseIds=new List<Id>();
            //CRM-5541: Converted Asyn method
            List<EmailMessage> emails = new List<EmailMessage>([SELECT id,Incoming,subject,FromAddress,status,parentid,ToAddress,To_Address__c,HtmlBody,QCC_Tech_Is_Internal_Email__c
                                                                FROM EmailMessage WHERE Id IN: emailMessageIds]);
            Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            List<Case> listUpdateCases=new List<Case>();
            if(emails!=null && emails.size()>0)
            {
                for(EmailMessage ems:emails)
                {
                    if(ems.parentid!=null)
                    {
                        caseIds.add(ems.parentid);
                    }
                }
            }
            
            Map<Id,Case> mapFrtCases=new Map<Id,Case>([Select id,origin, priority, status from Case where ID IN:caseIds and recordtypeID =:CaseRT_ID and status ='On Hold']);
            
            if(mapFrtCases.keyset()!=null)
            {
                for(EmailMessage emNew:emails)
                {
                    if(mapFrtCases.containskey(emNew.parentid) && (emNew.status.contains('0') || emNew.status.contains('1')))
                    {
                        for(Case cs:mapFrtCases.values())
                        {
                            if(cs.status.containsIgnoreCase('On Hold') && (cs.origin=='FRT Bookings' || cs.origin=='FRT Cust Service'))
                            {
                                if(!cs.priority.containsIgnoreCase('Urgent') && !cs.priority.containsIgnoreCase('Premium'))
                                {
                                    
                                    String CasePriority=cs.priority;
                                    switch on CasePriority
                                    {
                                        when 'Low'
                                        {
                                            cs.status='In Progress';
                                            cs.priority='Medium';
                                            listUpdateCases.add(cs);
                                        }
                                        when 'Medium'
                                        {
                                            cs.status='In Progress';
                                            cs.priority='High';
                                            listUpdateCases.add(cs); 
                                        }
                                        when else
                                        {
                                            cs.status='In Progress';
                                            cs.priority='Urgent';
                                            listUpdateCases.add(cs); 
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            if(listUpdateCases!=null && listUpdateCases.size()>0)
            {
                update listUpdateCases;
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightChildCaseCreationForClosedParent
TestMehtod:         testfreightChildCaseCreationForClosedParent
Description:        This method checks new emailMessage on Closed Case and create a new child case, and associate it to the Closed parent
Parameter:          EmailMessage New List  
Jira Story:         FCRM-906
Date Implemented:   29 April 2022
Sprint Freight      158
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    public void freightChildCaseCreationForClosedParent(List<EmailMessage> emails)
    {
        try
        {
            system.debug('inside freightChildCaseCreationForClosedParent'+emails);
            List<Id> caseIds=new List<Id>();
            List<Case> listChildCase=new List<Case>();
            
            Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            List<Case> listUpdateCases=new List<Case>();
            Map<Id, Case> ChildCases=new Map<Id,Case>();
            Map<Id, Case> ChildOpenCases=new Map<Id,Case>();
            List<EmailMessage> listUpdateEmls=new List<EmailMessage>();
            Id csuQ;
            Id ClaimsQ;   
            
            List<Group> getQueue=[select id,name,DeveloperName from group where type='queue' and (DeveloperName='Freight_CSU_AU_Queue' or DeveloperName='Freight_Claims_Queue')];
            
            if(getQueue!=null && getQueue.size()>0)
            {
                if(getQueue[0].DeveloperName.equals('Freight_CSU_AU_Queue'))
                {
                    csuQ=getQueue[0].id;
                    ClaimsQ=getQueue[1].id;
                }
                else if(getQueue[1].DeveloperName.equals('Freight_CSU_AU_Queue'))
                {
                    csuQ=getQueue[1].id;
                    ClaimsQ=getQueue[0].id;
                }
            }
            system.debug('emails.size()'+emails.size());
            
            if(emails!=null && emails.size()>0)
            {
                for(EmailMessage ems:emails)
                {
                    system.debug('ParentId'+ems.parentid);
                    if(ems.parentid!=null && ems.FromAddress != System.label.FRT_NoReply_Email && ems.Incoming == True)//jira CRM-6749
                    {
                        caseIds.add(ems.parentid);
                    }
                }
            }
            system.debug('caseIds'+caseIds);
            system.debug('CaseRT_ID'+CaseRT_ID);
            Map<Id,Case> mapFrtCases=new Map<Id,Case>([Select id,origin,ownerid,recordtypeid,accountid,contactid,type,Sub_Type_1__c,Sub_Type_2__c,subject,description,Freight_AWB_Number__c,Freight_Port__c, priority, status from Case where ID IN:caseIds and recordtypeID =:CaseRT_ID and Status='Closed' and (Origin='FRT Bookings' or Origin='FRT Cust Service' or Origin='FRT Phone' or Origin='FRT Export Spl Moves' or Origin='FRT Spl Moves' or Origin='Webchat' or Origin='FRT Claims'or Origin='Web')]);// Added FRT claims Origin CRM-6589
            
            /* for(Case putMapChild: [Select id,parentid, status from Case where parentid IN:caseIds and recordtypeID =:CaseRT_ID and Status!='Closed' and (Origin='FRT Bookings' or Origin='FRT Cust Service')])
{
ChildOpenCases.put(putMapChild.parentid,putMapChild);
} */
            system.debug('mapFrtCases'+mapFrtCases);
            system.debug('mapFrtCases2'+mapFrtCases.isEmpty());
            system.debug('mapFrtCases3'+mapFrtCases.values().isEmpty());
            if(mapFrtCases.isEmpty()==False && mapFrtCases.values().isEmpty()==false)
            {
                system.debug('inside mapFrtCases');
                
                for(Case getParent: mapFrtCases.values())
                {
                    if(getParent.status=='closed' )
                    {
                        
                        getParent.status=System.Label.Freight_Child_Case_Status;
                        if(getParent.origin =='FRT Claims')//Queue assignment on reply received excluding FRT claims -Jira CRM-6758
                        {
                            getParent.ownerid=ClaimsQ; 
                        }else{
                            getParent.ownerid=csuQ;// Queues assigned on Case Creation [Email to Case]
                        }
                        
                        listChildCase.add(getParent);
                        
                    }
                    
                    
                }
            } 
            
            system.debug('listChildCase'+listChildCase.size());
            system.debug('listChildCase'+listChildCase);
            if(listChildCase!=null && listChildCase.size()>0)
            {             
                update listChildCase;
                
                
                /*if(listChildCase!=null && listChildCase.size()>0)
for(Case putMap: listChildCase)
{

ChildCases.put(putMap.parentid,putMap);
}*/
            }
            
            
            /*if(emails!=null && emails.size()>0)
{
for(EmailMessage emls:emails)
{

if(ChildOpenCases.isEmpty()==true && mapFrtCases.isEmpty()==false && ChildCases.isEmpty()==false && mapFrtCases.containsKey(emls.parentid) && ChildCases.containskey(emls.parentid))
{

emls.parentid=ChildCases.get(emls.parentid).id;
}

if(ChildOpenCases.isEmpty()==false && ChildOpenCases.containskey(emls.parentid))
{
emls.parentid=ChildOpenCases.get(emls.parentid).id;
}

}
}*/
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage());
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightCloseDuplicateCases
TestMehtod:         testfreightCloseDuplicateCases
Description:        This method matches the subjects of all emails received for Freight cases and close the duplicate cases 
Parameter:          EmailMessage New List  
Jira Story:         FCRM-932
Date Implemented:   14 July 2022
Sprint Freight      163
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/    
    public void freightCloseDuplicateCases(List<EmailMessage> emails)
    {
        system.debug('inside freightCloseDuplicateCases'+emails);
        DuplicateExecuted=true; //Set the global static variable to true to block recurrsive calling
        Map<ID,string> MapEmailSubjects=new Map<ID,string>(); 
        List<Case> getExistingCases=new List<Case>();
        List<Case> updateCases=new List<Case>();
        List<Case> updateParentCases=new List<Case>();
        List<ID> getEmailParentIDs=new List<ID>();
        Map<Id,Case> getMatchedOldCases=new Map<Id,Case>();
        Map<ID,EmailMessage> mapEmailMsgs=new Map<ID,EmailMessage>();
        Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        ID parentCaseID;
        try
        {
            
            if(emails!=null && emails.size()>0)
                for(EmailMessage getNewEmails:emails)
            {
                
                if(getNewEmails.subject!=null && (getNewEmails.subject.contains('FW:') || getNewEmails.subject.contains('RE:') ||getNewEmails.subject.contains(':') ))
                {
                    system.debug('inside if subject contains :');
                    MapEmailSubjects.put(getNewEmails.parentid,getNewEmails.subject.substringAfter(':'));
                    
                }
                else if(getNewEmails.subject!=null && getNewEmails.subject.containsNone(':'))
                {
                    system.debug('inside else if subject not contains :');
                    MapEmailSubjects.put(getNewEmails.parentid,getNewEmails.subject);
                    
                }
                system.debug('MapEmailSubjects'+MapEmailSubjects);
                mapEmailMsgs.put(getNewEmails.parentid,getNewEmails);
                system.debug('mapEmailMsgs'+mapEmailMsgs);
                
            }
            
            getExistingCases=[select id,subject,casenumber,origin,status,createddate from case where (Origin='FRT Bookings' OR Origin='FRT Cust Service') and recordtypeId=:CaseRT_ID and status!='Closed'];
            system.debug('getExistingCases'+getExistingCases);
            
            if(MapEmailSubjects!=null && MapEmailSubjects.isEmpty()==false && getExistingCases!=null && getExistingCases.size()>0)
            {
                
                for(String newSubject :MapEmailSubjects.values())
                {
                    
                    for(Case existingCase :getExistingCases)
                    {
                        
                        String newSub=newSubject.trim();
                        String colonLessSub='';
                        //Added Not null check for Bug Jira FCRM-944
                        if(existingCase.subject!=null && existingCase.subject!='' && existingCase.subject.contains(':'))
                        {
                            colonLessSub=existingCase.subject.substringAfter(':').trim();    
                        }
                        else if(existingCase.subject!=null && existingCase.subject!='' && existingCase.subject.containsNone(':')) //Added Not null check for Jira FCRM-5876
                        {
                            colonLessSub=existingCase.subject.trim();
                        }
                        
                        system.debug('colonLessSub'+colonLessSub);  
                        if((existingCase.origin=='FRT Bookings' || existingCase.origin=='FRT Cust Service') && /*!MapEmailSubjects.containsKey(existingCase.id) &&*/ (colonLessSub !='' && colonLessSub.equals(newSub))) //Added Not blank check for Jira FCRM-5876
                        {
                            getMatchedOldCases.put(existingCase.id,existingCase);
                        }  
                    }
                } 
            }
            
            List<Case> getCasesSortedbyDate;
            if(getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false)
            {
                getCasesSortedbyDate=[select id,createddate,subject,casenumber,origin,status,Freight_Resolve_Reason__c,Resolved_Reasons_Sub_Type__c from case where ID IN:getMatchedOldCases.keyset() order by createddate asc];
            }
            
            system.debug('*getCasesSortedbyDate'+getCasesSortedbyDate);
            system.debug('*getMatchedOldCases'+getMatchedOldCases);    
            
            if(getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false && getCasesSortedbyDate!=null && getCasesSortedbyDate.size()>0)
            {
                //Additional check to open FRT Booking Cases if both FRT Bookings and FRT Cust Service cases created at same time Jira 5753
                system.debug('*****before if'+getCasesSortedbyDate.size());
                if(getCasesSortedbyDate.size()>1 && getCasesSortedbyDate[0].origin== 'FRT Cust Service' && getCasesSortedbyDate[1].origin== 'FRT Bookings' ){
                    system.debug('*****inside if'+getCasesSortedbyDate[1].origin);
                    parentCaseID=getCasesSortedbyDate[1].id;
                }else if(getCasesSortedbyDate.size()>1 && getCasesSortedbyDate[0].origin== 'FRT Bookings' && getCasesSortedbyDate[1].origin== 'FRT Cust Service' ){//Fix for CRM 5898
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
                    
                    if(!getCase.id.equals(ParentCaseID) && (getCase.origin=='FRT Bookings' ||getCase.origin=='FRT Cust Service'))
                    { 
                        system.debug('inside if logic for closing cases');
                        //getCase.parentid=parentCaseID;
                        getCase.status='Closed';
                        getCase.Freight_Resolve_Reason__c='Duplicate Case';
                        getCase.Resolved_Reasons_Sub_Type__c='Customer Follow Up';
                        updateCases.add(getCase);
                        getEmailParentIDs.add(getCase.id);
                        
                    }
                }
            }
            
            system.debug('updateCases'+updateCases);
            system.debug('updateCases.size()'+updateCases.size());
            if(updateCases!=null && updateCases.size()>0)
            {
                update updateCases;
            }
            
            for(Case getCase: updateCases)
            {
                if(getCase.Status == 'Closed')
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
                update updateParentCases;
            }
            system.debug('aft updateParentCases'+updateParentCases);
            
            /*List<EmailMessage> getAllEmails=[select id,parentid from EmailMessage where parent.origin='FRT Bookings' and parent.recordtypeid =:CaseRT_ID and parentid IN:getEmailParentIDs and parent.status='Closed'];
if(getAllEmails!=null && getAllEmails.size()>0)
{
mapEmailMsgs.putall(getAllEmails);
}*/
            
            // List<EmailMessage> getOnlyFRT=[select id from emailmessage where parent.recordtypeid=:CaseRT_ID and (parent.origin='FRT Bookings' or parent.origin='FRT Cust Service') and ];
            system.debug('mapEmailMsgs******'+mapEmailMsgs);
            system.debug('getMatchedOldCases******'+getMatchedOldCases);
            if(mapEmailMsgs!=null && mapEmailMsgs.isEmpty()==false && getMatchedOldCases!=null && getMatchedOldCases.isEmpty()==false)
            {
                system.debug('mapEmailMsgs'+mapEmailMsgs.values());
                for(EmailMessage getEms: mapEmailMsgs.values())
                {
                    if(getMatchedOldCases.containskey(getEms.parentid))
                    {
                        getEms.parentid=parentCaseID;
                        system.debug('getEms.parentid'+getEms.parentid);
                    }
                }
            }
        }
        catch(Exception e)    
        {
            system.debug('Exception Occurred'+e.getMessage());
        }
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightSendEmailAlertForBouncedEmails
TestMehtod:         testfreightChildCaseCreationForClosedParent
Description:        This method sends email alerts to the sender of bounced emails
Parameter:          EmailMessage New List  
Jira Story:         FCRM-937
Date Implemented:   8 Aug 2022
Sprint Freight      165
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/  
    
    @future  //CRM-5541: Converted Asyn method
    public static void freightSendEmailAlertForBouncedEmails(Set<Id> emailMsgsIds)
    {
        List<EmailMessage> EmailMsgIds=new List<EmailMessage>();
        List<Messaging.Email> emailList=new List<Messaging.Email>();
        Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<Id> TargetObjectIds=new List<Id>();
        
        
        try
        {
            
            List<EmailMessage> emails = new List<EmailMessage>([SELECT id,Incoming,subject,FromAddress,parentid,ToAddress,To_Address__c,
                                                                HtmlBody,status,createdby.email,QCC_Tech_Is_Internal_Email__c,parent.casenumber, isBounced, createdbyId FROM EmailMessage WHERE Id IN: emailMsgsIds and parent.recordtypeid=:CaseRT_ID]);
            
            if(emails!=null && emails.size()>0)
            {
                for(EmailMessage ems:emails)
                {
                    if(ems.parentid!=null && ems.isBounced==true)
                    {
                        EmailMsgIds.add(ems);
                        TargetObjectIds.add(ems.createdbyId);
                    }
                }  
                
            }
            
            //List<EmailMessage> FRTEmails=[select id,status,createdby.email,createdbyid,toaddress,fromaddress,isBounced,parentid,parent.casenumber from emailmessage where parent.recordtypeid=:CaseRT_ID and ID IN:EmailMsgIds];
            
            
            Map<Id,User> Conts=new Map<Id,User>([select id,name from User where Id IN:TargetObjectIds]);
            
            
            string iconSRCUrl = QCC_UtilityHelper.getDyanamicUrl();
            if(EmailMsgIds!=null && EmailMsgIds.size()>0)
            {
                for(EmailMessage FRTEms: EmailMsgIds)
                {
                    
                    IF(FRTEms.isBounced==true && FRTEms.status=='3')
                    {
                        
                        Messaging.SingleEmailMessage emailMsg= new Messaging.SingleEmailMessage();
                        String[] toAddress=new String[]{FRTEms.createdby.email};
                            emailMsg.setToAddresses(toAddress); 
                        String subject='Qantas Freight Bounced Email – Ref No '+FRTEms.parent.casenumber;
                        emailMsg.setSubject(subject);
                        emailMsg.setSaveAsActivity(false);
                        emailMsg.setUseSignature(false);
                        /*String emailBody='Dear '+ Conts.get(FRTEms.createdbyId).name +',<br/><br/>'+'The email intended for '+ FRTEms.ToAddress+
' has been bounced back for the case number '+ FRTEms.Parent.Casenumber +'.<br/><br/><br/> Thanks <br/> <br/><br/>' +
'<footer><img src="https://qantas--c.ap15.content.force.com/servlet/servlet.ImageServer?id=0159000000FHvlL&oid=00D900000010OOK&lastMod=1521233610000" alt="Freight Logo" /></footer>'; */
                        
                        
                        String emailBody='Dear '+ Conts.get(FRTEms.createdbyId).name +',<br/><br/>'+'The email intended for '+ FRTEms.ToAddress+
                            ' has been bounced back for the case number '+ FRTEms.Parent.Casenumber +'.<br/><br/><br/> Thanks <br/> <br/><br/>' +
                            '<footer><img src= '+iconSRCUrl+' alt="Freight Logo" /></footer>';
                        
                        emailMsg.setHTMLBody(emailBody);
                        
                        emailList.add(emailMsg);
                        
                    }
                }
            }
            
            if(emailList!=null && emailList.size()>0)
            {
                
                Messaging.sendEmail(emailList);
            }
            
            
            
        }
        catch(Exception e)
        {
            system.debug('Exception has Occurred'+e.getmessage());
        }
    }
    
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getEmailCaseRecordTypeIds
Description:        This method will return the email case record type Ids
Parameter:          caseIds 
Jira Story:         CRM-5541
Date Implemented:   03 Oct 2022
Sprint Freight      169
Developer's Name:   Mallikarjuna
--------------------------------------------------------------------------------------*/
    public static Map<Id,Id> getEmailCaseRecordTypeIds(List<Id> caseIds)
    {
        Map<Id,Id> caseRecTypeIdMap = new Map<Id,Id>();
        List<case> cases = [select Id, RecordTypeId from case where ID IN: caseIds];
        for(case cs: cases)
        {
            caseRecTypeIdMap.put(cs.Id, cs.RecordTypeId);
        }
        return caseRecTypeIdMap;
    } 
    /*--------------------------------------------------------------------------------------      
Method Name:        freightChangePriorityForPremiumCustomers
TestMehtod:         testfreightChangePriorityForPremiumCustomers
Description:        This method changes parent case's priority to Premium  
Parameter:          EmailMessage Ids 
Jira Story:         FCRM-961
Date Implemented:   14 OCT 2022
Sprint Freight      170
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/    
    public void freightChangePriorityForPremiumCustomers(List<emailmessage> emails)
    {
        priorityPremCustExecuted=true;
        try
        {
            Set<ID> emsParentId=new Set<Id>();
            list<String> descLines=new list<String>();
            List<String> listDesc=new List<String>();
            Map<string,Freight_Premium_Account__mdt> MapCompName=new Map<string,Freight_Premium_Account__mdt>();
            Id CaseRT_ID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            List<Case> updateCaseList=new List<Case>();
            List<EmailMessage> ListemailMsgs;
            List<Case> listCases;
            
            
            Map<string,Freight_Premium_Account__mdt> mapAccounts=Freight_Premium_Account__mdt.getAll();
            if(mapAccounts.isEmpty()==false)
            {
                for(Freight_Premium_Account__mdt mapValues :mapAccounts.values())
                {
                    MapCompName.put(mapValues.Premium_Accounts__c,mapValues);
                    System.debug('MapCompName'+ MapCompName);
                }
            }                                                     
            
            if(emails!=null && emails.size()>0)
                for(Emailmessage getRec :emails)
            {
                if(getRec.parentid!=null)
                {
                    emsParentId.add(getRec.parentid);
                    System.debug('Inside emsParentID'+ emsParentId);
                }
            }
            
            if(emsParentId!=null && emsParentId.size()>0)
            {
                listCases=[select id,priority,origin from case where recordtypeid=:CaseRT_ID and ID IN :emsParentId];   
                System.debug('ListCases Query'+ listCases);
            }
            
            
            if(listCases!=null && listCases.size()>0 && emails!=null && emails.size()>0)
            {
                for(Case getCs: listCases)
                {
                    for(EmailMessage ems: emails)
                    {
                        //if(ems.parentid.Equals(getCs.Id) && (getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service') && ems.fromaddress!=null)
                        if(ems.parentid.Equals(getCs.Id) && (getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service'||getCs.origin=='FRT Claims'|| getCs.origin == 'FRT Spl Moves') && ems.fromaddress!=null)//jira CRM-6589, CRM-6662
                        {
                            if(ems.fromaddress.contains('@'))
                            {
                                if(MapCompName.containskey(ems.fromaddress.split('@').get(1).trim()))
                                {
                                    getCs.priority='Premium';
                                    updateCaseList.add(getCs);
                                    System.debug('Updatecaselist'+updateCaseList);
                                }
                            }
                            
                        }
                        
                        //if((getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service') && ems.TextBody!=null)
                        if((getCs.origin=='FRT Bookings' || getCs.origin=='FRT Cust Service'||getCs.origin=='FRT Claims'|| getCs.origin == 'FRT Spl Moves') && ems.TextBody!=null)//jira CRM-6589, CRM-6662
                        {
                            
                            descLines=ems.TextBody.split('\n');
                            
                            if(descLines!=null && descLines.size()>0)
                            {
                                for (String strSplit: descLines)
                                {
                                    if(strSplit.contains('From:'))
                                    {
                                        listDesc.addAll(strSplit.split(' '));
                                    }   
                                } 
                            }
                            
                            if(listDesc!=null && listDesc.size()>0)
                            {
                                for(String strDesc :listDesc)
                                {
                                    if(strDesc.contains('<') && strDEsc.contains('>'))
                                    {
                                        strDesc=strDesc.replace('<','').replace('>','');
                                        strDesc=strDesc.split('@').get(1).trim();
                                        
                                        
                                        if(MapCompName.containskey(strDesc))
                                        {
                                            getCs.priority='Premium';
                                            updateCaseList.add(getCs);
                                            System.debug('Updatecaselist******'+updateCaseList);
                                        }
                                    }
                                }
                            }
                        } 
                    }
                    
                }
            }  
            
            if(updateCaseList!=null && updateCaseList.size()>0)
            {
                update updateCaseList;
                System.debug('Updatecaselist$$$'+updateCaseList);
            }
        }
        catch(Exception e)
        {
            system.debug('Exception has occured'+e.getmessage());
        } 
        
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightAutoCloseCasesSentToInvoiceAndCustSer
Description:        This method auto-closes the Emails sent to Invoice and Cust service address
Parameter:          EmailMessage Ids 
Jira Story:         CRM-6123
Date Implemented:   11 MAY 2023
Sprint Freight      181
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/    
    public static void freightAutoCloseCasesSentToInvoiceAndCustSer(Map<Id,EmailMessage> emails)
    {
        set<ID> caseIds=new set<ID>();
        String[] emailAdd=new String[]{};
            emailAdd=system.label.FreightAutoClosureEmailAddresses.split(';');
        List<Case> updateCases=new List<Case>();
        
        
        
        if(emails!=null && emails.isEmpty()==false)
        {
            for(EmailMessage getEms: emails.values())
            {
                
                if(getEms.parentid!=null && getEms.toAddress.containsIgnoreCase(emailAdd[0]) && getEms.toAddress.containsIgnoreCase(emailAdd[1]))
                {
                    caseIds.add(getEms.parentid);
                }
            }
        }
        
        // Cases are already filtered by Record Type Checks in the EmailMessageTrigger
        List<Case> getCases=[select id,status,type from case where id IN:caseIds and (origin='FRT Bookings' or origin='FRT Cust Service')]; 
        
        
        if(getCases!=null && getCases.size()>0)
        {
            for(Case getC: getCases)
            {
                getC.type='Invalid Case';
                getC.Status='Auto-closed';
                updateCases.add(getC);
            }
        }
        
        if(updateCases!=null && updateCases.size()>0)
        {
            update updateCases;
        }
    }
    
    /*--------------------------------------------------------------------------------------------------------------------
Method Name:        freightUpdateCaseAccountFromEmail
Description:        This method will update the account name by fetching the domain name from the sender's email.
Parameter:          EmailMessage Ids
Jira #:             6361
----------------------------------------------------------------------------------------------------------------------*/
    public void freightUpdateCaseAccountFromEmail(List<emailmessage> emails)
    {
        set<string> setCasesIds=new set<string>();
        List<case> updateCases=new List<case>();
        updateCaseAccountexecuted=true;

        Map<Id,EmailMessage> mapEmail=new Map<Id,EmailMessage>();
        String domainName, SplitName ;
        try
        {
           if(emails!=null && emails.size()>0)
            {
                for(Emailmessage eml:emails)
                {
                    if(eml.parentid!=null)
                    {
                        system.debug('Emp parentid'+eml.parentid);
                        setCasesIds.add(eml.parentid);
                        mapEmail.put(eml.parentid,eml);
                    }							   
                }
                //Map<Id,Case> getCasesMap=new Map<Id,Case>([select id,AccountId,origin from case where  ID IN:setCasesIds and recordtype.name='Qantas Freight' and (origin='FRT Bookings' OR origin='FRT Cust Service')]); 
                Map<Id,Case> getCasesMap=new Map<Id,Case>([select id,AccountId,origin from case where  ID IN:setCasesIds and recordtype.name='Qantas Freight' and (origin='FRT Bookings' OR origin='FRT Cust Service'or origin = 'FRT Claims' or origin = 'FRT Spl Moves')]); //jira CRM-6589, CRM-6662
                
                if(getCasesMap!=null && getCasesMap.size()>0 && emails!=null && emails.size()>0)
                {
                    for(EmailMessage ems: emails)
                    {
                        if(ems.fromaddress!=null)
                        {
                            if(ems.fromaddress.contains('@'))
                            {
                                domainName = ems.fromaddress.split('@').get(1).trim();
                                System.debug('domainName'+ domainName);
                                
                            }               
                        }
                    }              
                }  
                List<Account> updateAccount = new List<Account>([select Id, Name,BillingCountryCode from Account where Email__c LIKE :('%'+domainName) AND RecordType.Name ='Freight Account' AND Type = 'Freight-Country'ORDER BY Name ASC  ]);
                System.debug('updateAccount'+updateAccount);
                if(getCasesMap.isEmpty()==false && mapEmail.isEmpty()==false)
                {
                    for(Case getCase: getCasesMap.values())
                    {
                        if(updateAccount.size()==1)
                        {
                            getCase.AccountId = updateAccount[0].Id;	
                            System.debug('AccountId***'+getCase.AccountId);
                        }
                        else if(updateAccount.size() >1)
                        {
                            for(Account acc: updateAccount)
                            {
                                if(acc.BillingCountryCode == 'AU')
                                {
                                    getCase.AccountId = acc.Id;
                                    system.debug('AccountId****'+acc.Id);
                                    break;
                                }                               
                            }
                        }
                        else
                        {
                            getCase.AccountId = '';
                            system.debug('AccountId*****'+getCase.AccountId);
                        }
                        updateCases.add(getCase);
                    }
                }      
                System.debug('updateCases'+updateCases);
                if(updateCases!=null && updateCases.size()>0)
                {
                    
                    update updateCases;
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getMessage());
        }
    }
    
    
    
   
}