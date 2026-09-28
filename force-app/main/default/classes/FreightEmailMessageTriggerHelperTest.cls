/*
FCRM - 848 Sprint 155
Developer - Navpreet Kaur
This is a test class created for freightEmailMessageTriggerHelper
*/
@isTest
public with sharing class FreightEmailMessageTriggerHelperTest 
{
    static testmethod void testEmailMessages()
    {
        try
        {
            
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
         
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
                
            Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            insert mdtRec;
            
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                 if(recType.name.contains('Qantas_Freight'))
                 {
                     qantas_Freight=recType.RecordTypeId__c ;
                 }
            }
                
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase);
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='Webchat',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase2);
            Case newCase3=new Case(origin='Web',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase3);
            Case newCase4=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase4);
            Case newCase5=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase5);
            Case newCase6=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase6);
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
                for(Case getC:listCases)
                {
                    caseIds.add(getC.id);
                }
            }
            List<Case> getCases=[select id,casenumber from case where id IN:caseIds];
            
            test.startTest();
            for(Case getCase:getCases)
            {
                EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ' + getCase.casenumber, RelatedToId =getCase.id, status='0');
                EmailMessage emailmsg2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =getCase.id,status='1');
                EmailMessage emailmsg3=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase4.id,status='3');
                EmailMessage emailmsg4=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',ToAddress='freightinvoices@qantas.com.au; freightcustomerservice@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase5.id,status='0');
                EmailMessage emailmsg5=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',ToAddress='freightinvoices@qantas.com.au; freightcustomerservice@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase6.id,status='0');
                listEmailMessages.add(email);
                listEmailMessages.add(emailmsg2);
                listEmailMessages.add(emailmsg3);
                listEmailMessages.add(emailmsg4);
                listEmailMessages.add(emailmsg5);
            }
            
            if(listEmailMessages!=null && listEmailMessages.size()>0)
            {
                insert listEmailMessages;    
            }
            FreightEmailMessageTriggerHelper objEms=new FreightEmailMessageTriggerHelper();
            //CRM-5541: Converted Async method
            Set<Id> emailMessageIDSet = new Set<Id>();
            Map<Id,Emailmessage> emailMap=new Map<Id,EmailMessage>();
            for(EmailMessage email: listEmailMessages){
                emailMessageIDSet.add(email.id);   
                emailMap.put(email.id,email); 
            }
            FreightEmailMessageTriggerHelper.getnewEmailstoRecordComm(emailMessageIDSet);
            FreightEmailMessageTriggerHelper.freightAutoCloseCasesSentToInvoiceAndCustSer(emailMap);
            //objEms.autoResponseEmailInvoices(listEmailMessages);
            test.stopTest();
            
        }
        catch(Exception e)
        {
            system.debug('Exception Thrown '+e.getMessage()+' '+ e.getLineNumber()+' '+e.getCause());
        }
    }
/*
Test Method Name:        testassignUrgentPriorityForCasesWithHotWords
Method Name:             assignUrgentPriorityForCasesWithHotWords
*/
    static testmethod void testassignUrgentPriorityForCasesWithHotWords()
    {
        try
        {
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            List<Airport_Code__c> listAirCodes=new List<Airport_Code__c>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
            List<case> listOldcase=new List<Case>();
            List<case> listnewcase=new List<Case>();
            Map<id,Case> mapOld=new Map<id,Case>();
            string strDesc1='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc2='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@freight.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc3='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS SYDCSOPS@qantas.com.au \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc4='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS SYDCSOPS@freight.com.au \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc5='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 Flight Cancellation \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc6='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@au.com> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 Disruption \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc7='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@au.com> \n Subject: 53438523 \n Team, \n Agent Code \n Urgent 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
            List<QCC_Hotword_Queue_Routing__c> listHotWords=new List<QCC_Hotword_Queue_Routing__c>();
            Id QCCHotWords_RTID= Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
            
            QCC_Hotword_Queue_Routing__c obj1=new QCC_Hotword_Queue_Routing__c(RecordTypeId=QCCHotWords_RTID,Hot_words__c='Disruption,flight cancellation,Urgent',freight_Type__c='Hot Word',Priority__c='Urgent');
            QCC_Hotword_Queue_Routing__c obj2=new QCC_Hotword_Queue_Routing__c(RecordTypeId=QCCHotWords_RTID,Hot_words__c='noreply@freight.com.au',freight_Type__c='Mail Address',Priority__c='Urgent');
            QCC_Hotword_Queue_Routing__c obj3=new QCC_Hotword_Queue_Routing__c(RecordTypeId=QCCHotWords_RTID,Hot_words__c='@qantas.com.au,@freight.com.au',freight_Type__c='Mail Suffix',Priority__c='Urgent');
            listHotWords.add(obj1);
            listHotWords.add(obj2);
            listHotWords.add(obj3);
            
            if(listHotWords!=null && listHotWords.size()>0)
            {
                insert listHotWords;
            }
                
            Airport_Code__c  mdtRec1=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec1);
              if(listAirCodes!=null && listAirCodes.size()>0)
            {
                insert listAirCodes;
            }
           
            
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                 if(recType.name.contains('Qantas_Freight'))
                 {
                     qantas_Freight=recType.RecordTypeId__c ;
                 }
            }
            
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',priority='Low',subject='Test Case', description='test case',accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase);
           
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
            }
            
             EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc1,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ' , RelatedToId =newCase.id);
             EmailMessage email2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc2,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email3=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc3,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email4=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc4,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email5=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc5,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email6=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc6,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email7=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc7,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email8=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc1,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email9=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc2,MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id);
             EmailMessage email10=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc3,MessageDate=system.now(),ParentId=newCase.id,subject='retail booking confirmation', RelatedToId =newCase.id);
             EmailMessage email11=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',Textbody=strDesc4,MessageDate=system.now(),ParentId=newCase.id,subject='retail booking confirmation', RelatedToId =newCase.id);
             listEmailMessages.add(email);
             listEmailMessages.add(email2);
             listEmailMessages.add(email3);
             listEmailMessages.add(email4);
             listEmailMessages.add(email5);
             listEmailMessages.add(email6);
             listEmailMessages.add(email7);
             listEmailMessages.add(email8);
             listEmailMessages.add(email9);
             listEmailMessages.add(email10);
             listEmailMessages.add(email11);
             
             if(listEmailMessages!=null && listEmailMessages.size()>0)
             {
                 insert listEmailMessages;
             }
            //CRM-5541: Converted Async method
            Set<Id> emailMessageIDSet = new Set<Id>();
            for(EmailMessage em:listEmailMessages){
                emailMessageIDSet.add(em.id);    
            }
            test.starttest();
                FreightEmailMessageTriggerHelper.assignUrgentPriorityForCasesWithHotWords(emailMessageIDSet);
            test.stoptest();
            
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
    }
/*
Test Method Name:        testfreightMaskCreditCard
Method Name:             freightMaskCreditCard
*/
     static testmethod void testfreightMaskCreditCard()
     {
         try
         {
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
         
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
                
            Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            insert mdtRec;
            
            string strTextBdy1='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n 5555555555554444 \n P. +61 2 9691 1107 (ext. 21107) \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strTextBdy2='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@freight.com.au> \n Subject: 53438523 \n Team, \n P. +61 2 9691 1107 (ext. 21107) \n 00127540 \n 5555555555554444\n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            
            string strTextBdy3='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n 4534 6754 7689 8767 \n P. +61 2 9691 1107 (ext. 21107) \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strTextBdy4='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@freight.com.au> \n Subject: 53438523 \n Team, \n P. +61 2 9691 1107 (ext. 21107) \n 00127540 \n 4534 6754 7689 8767 \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                 if(recType.name.contains('Qantas_Freight'))
                 {
                     qantas_Freight=recType.RecordTypeId__c ;
                 }
            }
                
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase);
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase2);
            Case newCase3=new Case(origin='FRT Bookings',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase3);
            Case newCase4=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',type='Customer query',Sub_Type_1__c='Accounts',Sub_Type_2__c='Invoice',subject='Test Case', description='test Case',accountid=accountRecord.id);
            listCases.add(newCase4);
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
                for(Case getC:listCases)
                {
                    caseIds.add(getC.id);
                }
            }
            List<Case> getCases=[select id,casenumber from case where id IN:caseIds];
            
            test.startTest();
            for(Case getCase:getCases)
            {
                EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy1,HtmlBody=strTextBdy1,MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ' + getCase.casenumber, RelatedToId =getCase.id, status='0');
                EmailMessage emailmsg2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy2,HtmlBody=strTextBdy2,MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =getCase.id,status='1');
                EmailMessage emailmsg3=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy1,HtmlBody=strTextBdy1,MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase4.id,status='3');
                
                EmailMessage emailmsg4=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy3,HtmlBody=strTextBdy3,MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ' + getCase.casenumber, RelatedToId =getCase.id, status='0');
                EmailMessage emailmsg5=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy4,HtmlBody=strTextBdy4,MessageDate=system.now(),ParentId=getCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =getCase.id,status='1');
                EmailMessage emailmsg6=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody=strTextBdy3,HtmlBody=strTextBdy3,MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase4.id,status='3');
                
                listEmailMessages.add(email);
                listEmailMessages.add(emailmsg2);
                listEmailMessages.add(emailmsg3);
                listEmailMessages.add(emailmsg4);
                listEmailMessages.add(emailmsg5);
                listEmailMessages.add(emailmsg6);
            }
            
            if(listEmailMessages!=null && listEmailMessages.size()>0)
            {
                insert listEmailMessages;    
            }
            FreightEmailMessageTriggerHelper objEms=new FreightEmailMessageTriggerHelper();
            
            objEms.freightMaskCreditCard(listEmailMessages);
            test.stopTest();
         }
         catch(Exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
/*
Test Method Name:        testfreightLevelUpCasePriority
Method Name:             freightLevelUpCasePriority
*/
    static testmethod void testfreightLevelUpCasePriority()
    {
        try
        {
            Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            ID qantas_Freight;
            List<EmailMessage> listEmailMessages=new List<EmailMessage>();
            List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
            List<Case> listCases=new List<Case>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
         
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
                
            Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            insert mdtRec;
            
            
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                 if(recType.name.contains('Qantas_Freight'))
                 {
                     qantas_Freight=recType.RecordTypeId__c ;
                 }
            }
                
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',Priority='Medium',status='On hold',subject='Test Case', description='test Case',accountid=accountRecord.id,On_hold_Reason__c='Awaiting Response');
            listCases.add(newCase);
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='On hold',Priority='High',subject='Test Case', description='test Case',accountid=accountRecord.id,On_hold_Reason__c='Awaiting Response');
            listCases.add(newCase2);
            
             if(listCases!=null && listCases.size()>0)
             {
                insert listCases;
             
             }
             
             
            test.startTest();
               
                    EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email1',MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id, status='0');
                    EmailMessage emailmsg2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email2',MessageDate=system.now(),ParentId=newCase2.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase2.id,status='1');

                    listEmailMessages.add(email);
                    listEmailMessages.add(emailmsg2);

               
                if(listEmailMessages!=null && listEmailMessages.size()>0)
                {
                    insert listEmailMessages;    
                }
                //CRM-5541: Converted Asyn method
                Set<Id> emailMessageIDSet = new Set<Id>();
                for(EmailMessage em: listEmailMessages){
                    emailMessageIDSet.add(em.id);    
                }
                FreightEmailMessageTriggerHelper.freightLevelUpCasePriority(emailMessageIDSet);
            test.stopTest();
          }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e.getmessage()); 
        }
    }
/*
Test Method Name:        testfreightChildCaseCreationForClosedParent
Method Name:             freightChildCaseCreationForClosedParent
*/
        static testmethod void testfreightChildCaseCreationForClosedParent()
        {
            try
            {
                Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
                List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
                ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
                ID qantas_Freight;
                QueuesObject q1=new QueuesObject();
                
                Group grp=new Group();
                grp.name='Freight CSU AU Queue';
                grp.Type='Queue';
                grp.DeveloperName='Freight_CSU_AU_Grp';
                insert grp;
                
                System.runAs(new User(Id=UserInfo.getUserId()))
                {
                      q1.QueueID = grp.id;
                      q1.SobjectType = 'Case';
                      insert q1;
    
                }
                
                List<EmailMessage> listEmailMessages=new List<EmailMessage>();
                List<EmailMessage> listEmailMessages2=new List<EmailMessage>();
                List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
                List<Case> listCases=new List<Case>();
                List<Id> caseIds=new List<Id>();
                listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
                insert listCustSett;
                
                Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
                accountRecord.RecordTypeId = accountRecordTypeId;
                accountRecord.billingcountry='AU';
                accountRecord.Email__c='greenavenue@auspost.com.au';
                insert accountRecord;
                    
                Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
                insert mdtRec;
                
                Contact cont=new Contact();
                cont.firstname='Test';
                cont.lastname='Contact';
                cont.accountid=accountRecord.id;
                cont.Email='freight_Emails@qantas.com.au';
                insert cont;
            
                for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
                {
                     if(recType.name.contains('Qantas_Freight'))
                     {
                         qantas_Freight=recType.RecordTypeId__c ;
                     }
                }
                
                Case newCase=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Cust Service',ownerid=grp.id,Priority='Medium',status='Closed',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Test Case', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                listCases.add(newCase);
                Case newCase1=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Cust Service',ownerid=grp.id,Priority='Medium',status='Closed',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Test Case', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                listCases.add(newCase1);
                Case newCase2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='Open',parentid=newCase1.id,Priority='High',subject='Test Case', description='test Case',accountid=accountRecord.id);
                listCases.add(newCase2);
                
                 if(listCases!=null && listCases.size()>0)
                 {
                    insert listCases;
                 
                 }
                
                test.starttest();
                    EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email1',MessageDate=system.now(),ParentId=newCase.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase.id, incoming=true);
                    EmailMessage emailmsg2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email2',MessageDate=system.now(),ParentId=newCase2.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase1.id,incoming=true);
                    EmailMessage emailmsg3=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email2',MessageDate=system.now(),ParentId=newCase2.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase2.id,incoming=true);

                    listEmailMessages.add(email);
                    listEmailMessages.add(emailmsg2);
                    listEmailMessages.add(emailmsg3);
                if(listEmailMessages!=null && listEmailMessages.size()>0)
                {
                    insert listEmailMessages;    
                }
                EmailMessage emailmsg4=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au', isBounced=true,To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email2',MessageDate=system.now(),ParentId=newCase2.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase2.id,incoming=true);
                FreightEmailMessageTriggerHelper objEms=new FreightEmailMessageTriggerHelper();
            
                listEmailMessages2.add(emailmsg4);
                  
                if(listEmailMessages2!=null && listEmailMessages2.size()>0)
                {
                    insert listEmailMessages2;    
                }    
                
                
                objEms.freightChildCaseCreationForClosedParent(listEmailMessages);
                //CRM-5541: Converted Asyn method
                Set<Id> emailMessageIDSet = new Set<Id>();
                for(EmailMessage em: listEmailMessages2){
                    emailMessageIDSet.add(em.id);    
                }

                FreightEmailMessageTriggerHelper.freightSendEmailAlertForBouncedEmails(emailMessageIDSet)  ;
                     
                test.stoptest();
                
            }
            catch(Exception e)
            {
                system.debug('Exception Occurred '+e.getmessage());
            }
        }  
/*
Test Method Name:        testfreightCloseDuplicateCases
Method Name:             freightCloseDuplicateCases
*/
        static testmethod void testfreightCloseDuplicateCases()
        {
            try
            {
                test.starttest();
                
                Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
                List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
                ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
                ID qantas_Freight;
                QueuesObject q1=new QueuesObject();
                
                Group grp=new Group();
                grp.name='Freight CSU AU Queue';
                grp.Type='Queue';
                grp.DeveloperName='Freight_CSU_AU_Grp';
                insert grp;
                
                System.runAs(new User(Id=UserInfo.getUserId()))
                {
                      q1.QueueID = grp.id;
                      q1.SobjectType = 'Case';
                      insert q1;
    
                }
                
                List<EmailMessage> listEmailMessages=new List<EmailMessage>();
                List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
                List<Case> listCases=new List<Case>();
                List<Id> caseIds=new List<Id>();
                listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
                insert listCustSett;
                
                Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
                accountRecord.RecordTypeId = accountRecordTypeId;
                accountRecord.billingcountry='AU';
                accountRecord.Email__c='greenavenue@auspost.com.au';
                insert accountRecord;
                    
                Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
                insert mdtRec;
                
                Contact cont=new Contact();
                cont.firstname='Test';
                cont.lastname='Contact';
                cont.accountid=accountRecord.id;
                cont.Email='freight_Emails@qantas.com.au';
                insert cont;
            
                for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
                {
                     if(recType.name.contains('Qantas_Freight'))
                     {
                         qantas_Freight=recType.RecordTypeId__c ;
                     }
                }
                
                Case newCase=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Bookings',ownerid=grp.id,Priority='Medium',status='Open',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Qantas Freight Customer Support – Ref No', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                Case newCase2=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Bookings',ownerid=grp.id,Priority='Medium',status='Open',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Re:Qantas Freight Customer Support – Ref No', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                Case newCase3=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Bookings',ownerid=grp.id,Priority='Medium',status='Open',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Re:Qantas Freight Customer Support – Ref No', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                Case newCase4=new Case(recordtypeid=qantas_Freight,Freight_Port__c=mdtRec.id,type='Claims',Sub_Type_1__c='Accounts',Sub_Type_2__c='Rates',Freight_AWB_Number__c='081-76763768',origin='FRT Bookings',ownerid=grp.id,Priority='Medium',status='Open',Freight_Resolve_Reason__c='Website',Resolved_Reasons_Sub_Type__c='Info not available',subject='Re:Qantas Freight Customer Support – Ref No', description='test Case',accountid=accountRecord.id,contactid=cont.id);
                listCases.add(newCase);
                listCases.add(newCase2);
                listCases.add(newCase3);
                listCases.add(newCase4);

                if(listCases!=null && listCases.size()>0)
                 {
                    insert listCases;
                 }
                

                    EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email1',MessageDate=system.now(),ParentId=newCase2.id,subject='Re:Qantas Freight Customer Support – Ref No ', RelatedToId =newCase2.id, incoming=true);
                

                    
                    EmailMessage emailmsg2=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email1',MessageDate=system.now(),ParentId=newCase3.id,subject='Re:Qantas Freight Customer Support – Ref No ', RelatedToId =newCase3.id,incoming=true);
                    EmailMessage emailmsg3=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',Textbody='Test Case Email1',MessageDate=system.now(),ParentId=newCase4.id,subject='Qantas Freight Customer Support – Ref No ', RelatedToId =newCase4.id,incoming=true);
                    
                    listEmailMessages.add(emailmsg2);
                    listEmailMessages.add(emailmsg3);

                if(listEmailMessages!=null && listEmailMessages.size()>0)
                {
                    insert listEmailMessages;    
                }
                
                FreightEmailMessageTriggerHelper objEms=new FreightEmailMessageTriggerHelper();
                objEms.freightCloseDuplicateCases(listEmailMessages);
               
                  
                    
                test.stoptest();
                         
            }
            catch(Exception e)
            {
                system.debug('Exception Occurred');
            }
        }

}