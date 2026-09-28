/*==============================================================================================================================
Author:         Navpreet Kaur
Company:        TCS
Purpose:        Test class for Freight_CaseTriggerHandler
Date:           28-Mar-2022
Modified By : Hari B, 27-Mar-2026
              Remediated test class failures. Updated testSetUPMethod() method.
==============================================================================================================================*/
@isTest
public with sharing class Freight_CaseTriggerHandlerTest 
{
    @TestSetup
    static void testSetUPMethod()
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
            List<contact> listConts=new List<contact>();
            Id ContactRTId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            Test.startTest();
            TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
            Test.stopTest();
            
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.name='Green Cord Corp[Freight-SYD-AU]';
            accountRecord.Email__c='greencord@auspost.com.au';
            insert accountRecord;
            
            Account accountRecord1 = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord1.RecordTypeId = accountRecordTypeId;
            accountRecord1.billingcountry='AU';
            accountRecord1.name='Green Cord Corp[Freight-PER-AU]';
            accountRecord1.Email__c='greencord@auspost.com.au';
            insert accountRecord1;
            
            
            Account accountRecord3 = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord3.RecordTypeId = accountRecordTypeId;
            accountRecord3.billingcountry='AU';
            accountRecord3.Email__c='greenavenue@qantas.com.au';
            accountRecord3.name='Green Avenue Corp[Freight-Per-AU]';
            insert accountRecord3;
            
            Account accountRecord2 = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord2.RecordTypeId = accountRecordTypeId;
            accountRecord2.billingcountry='AU';
            accountRecord2.name='Green Trees Corp[Freight-Mel-AU]';
            accountRecord2.Email__c='greenTrees@fedex.com';
            insert accountRecord2;
            
            Contact cont=new Contact();
            cont.firstname='Green';
            cont.lastname='Trees';
            cont.email='greenTrees@fedex.com';
            cont.accountid=accountRecord2.id;
            cont.recordtypeid=ContactRTId;
            listConts.add(cont);
            
            Contact cont2=new Contact();
            cont2.firstname='Yellow';
            cont2.lastname='Trees';
            cont2.email='greenTrees@fedex.com';
            cont2.accountid=accountRecord2.id;
            cont2.recordtypeid=ContactRTId;
            listConts.add(cont2);
            
            Contact cont3=new Contact();
            cont3.firstname='Green';
            cont3.lastname='Garden';
            cont3.email='greenavenue@qantas.com.au';
            cont3.accountid=accountRecord3.id;
            cont3.recordtypeid=ContactRTId;
            listConts.add(cont3);
            
            Contact cont4=new Contact();
            cont4.firstname='Green';
            cont4.lastname='Cord';
            cont4.email='greencord@auspost.com.au';
            cont4.accountid=accountRecord.id;
            cont4.recordtypeid=ContactRTId;
            listConts.add(cont4);
            
            Contact cont5=new Contact();
            cont5.firstname='Green';
            cont5.lastname='Cord';
            cont5.email='greencord@auspost.com.au';
            cont5.accountid=accountRecord1.id;
            cont5.recordtypeid=ContactRTId;
            listConts.add(cont5);
            
            Contact cont6=new Contact();
            cont6.firstname='Green';
            cont6.lastname='Cord';
            cont6.email='greencord@auspost.com.au';
            cont6.accountid=accountRecord.id;
            cont6.recordtypeid=ContactRTId;
            listConts.add(cont6);
            
            Contact cont7=new Contact();
            cont7.firstname='Green';
            cont7.lastname='Cord2';
            cont7.email='greencord@auspost.com.au';
            cont7.accountid=accountRecord1.id;
            cont7.recordtypeid=ContactRTId;
            listConts.add(cont7);   
        
            if(listConts!=null && listConts.size()>0)
            {
                insert listConts;
            }
                
            Airport_Code__c  mdtRec1=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec1);
            Airport_Code__c  mdtRec2=new Airport_Code__c (Name='BHQ',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec2);
            Airport_Code__c  mdtRec3=new Airport_Code__c (Name='ABX',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec3);
            Airport_Code__c  mdtRec4=new Airport_Code__c (Name='ALH',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec4);
            Airport_Code__c  mdtRec5=new Airport_Code__c (Name='ARM',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec5);
            Airport_Code__c  mdtRec6=new Airport_Code__c (Name='ASP',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec6);
            
            
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
            
        
            
            
    }
    /*----------------------------------------------------------------------------------------------      
    Method Name:        testautoAssignCaseToCSUQueue
    Description:        To create cases and based on the ports will be assigned to Freight CSU AU Queue
    Parameter:          
    ----------------------------------------------------------------------------------------------*/  
    static testmethod void testautoAssignCaseToCSUQueue()
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
            List<String> serialCases=new List<String>();
                        
            List<Airport_Code__c> listAirCodes=new List<Airport_Code__c>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
            
            List<case> listOldcase=new List<Case>();
            List<case> listnewcase=new List<Case>();
            
            List<String> serialOldcase=new List<String>();
            List<String> serialnewcase=new List<String>();
            
            Map<id,Case> mapOld=new Map<id,Case>();
         
            Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            accountRecord.billingcountry='AU';
            accountRecord.Email__c='greenavenue@auspost.com.au';
            insert accountRecord;
            
            Account accountRecord3 = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord3.RecordTypeId = accountRecordTypeId;
            accountRecord3.billingcountry='AU';
            accountRecord3.Email__c='greenavenue@qantas.com.au';
            insert accountRecord3;
            
            Account accountRecord2 = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord2.RecordTypeId = accountRecordTypeId;
            accountRecord2.billingcountry='AU';
            accountRecord2.Email__c='greenTrees@fedex.com';
            insert accountRecord2;
                
            Airport_Code__c  mdtRec1=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec1);
            Airport_Code__c  mdtRec2=new Airport_Code__c (Name='BHQ',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec2);
            Airport_Code__c  mdtRec3=new Airport_Code__c (Name='ABX',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec3);
            Airport_Code__c  mdtRec4=new Airport_Code__c (Name='ALH',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec4);
            Airport_Code__c  mdtRec5=new Airport_Code__c (Name='ARM',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec5);
            Airport_Code__c  mdtRec6=new Airport_Code__c (Name='ASP',QF_Freight_Presence__c=true);
            listAirCodes.add(mdtRec6);
            
            
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
            
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            Case newCase6=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase);
            listCases.add(newCase6);
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description='test Case',accountid=accountRecord2.id,Freight_Port__c=mdtRec2.id,Freight_WebToCaseType__c='Freight - General Enquiries',Freight_AWB_Number__c='091-76476477');
            listCases.add(newCase2);
            Case newCase3=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id,Freight_Port__c=mdtRec3.id,Freight_WebToCaseType__c='Freight - Track and trace query');
            listCases.add(newCase3);
            Case newCase4=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description='test Case',accountid=accountRecord2.id,Freight_Port__c=mdtRec4.id,Freight_WebToCaseType__c='Freight - Give us feedback');
            listCases.add(newCase4);
            Case newCase5=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description='test Case',accountid=accountRecord3.id,Freight_Port__c=mdtRec4.id);
            listOldcase.add(newCase5);
            
            
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
                insert listOldcase;
                mapOld.put(newCase5.id,newCase5);
                
            }
            
            newCase5.accountid=accountRecord2.id;
            listnewcase.add(newCase5);
            update listnewcase;
            
            
             test.startTest();
                
                Freight_CaseTriggerHandler.autoAssignCaseToCSUQueue(listnewcase);
                Freight_CaseTriggerHandler.autoAssignPriorityAsPremium(listnewcase);
                Freight_CaseTriggerHandler.autoAssignPriorityAsPremiumManualAccounts(listnewcase,mapOld);
            test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
        
    } 
     /*----------------------------------------------------------------------------------------------      
        Test Method Name:        testassignUrgentPriorityForCasesWithHotWords
        Method Name:             assignUrgentPriorityForCasesWithHotWords   
    ----------------------------------------------------------------------------------------------*/  
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
            List<String> serialCases=new List<String>();
            
            
            List<Airport_Code__c> listAirCodes=new List<Airport_Code__c>();
            List<Id> caseIds=new List<Id>();
            listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
            insert listCustSett;
            List<case> listOldcase=new List<Case>();
            List<case> listnewcase=new List<Case>();
            
            List<String> serialOldcase=new List<String>();
            List<String> serialnewcase=new List<String>();
            
            
            Map<id,Case> mapOld=new Map<id,Case>();
            string strDesc1='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n 5555555555554444 \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc2='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@freight.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc3='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS SYDCSOPS@qantas.com.au \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc4='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS SYDCSOPS@freight.com.au \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc5='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@qantas.com.au> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 Flight Cancellation \n +61 2 9691 1107 \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc6='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@au.com> \n Subject: 53438523 \n Team, \n Agent Code \n 00127540 Disruption \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc7='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@au.com> \n Subject: 53438523 \n Team, \n Agent Code \n Urgent 00127540 \n 5555555555554444  \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
            string strDesc8='From: Trace, Cargo <Cargo.Trace@aa.com> \n Sent: Sunday, 29 August 2021 11:56 PM \n To: Trace, LAXCargo <LAXCargo.Trace@aa.com>; SHR SYD CS OPS <SYDCSOPS@freight.com.au> \n Subject: 53438523 \n Team, \n cred card number 4534 6545 7656 6756 Agent Code \n 00127540 \n Date of Journey \n 13-Aug-2021 \n Shipper \n DHL GLOBAL FORW... \n Consignee';
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
            
            Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description=strDesc1,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase);
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description=strDesc2,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase2);
            Case newCase3=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description=strDesc3,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase3);
            Case newCase4=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='retail booking confirmation', description=strDesc4,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase4);
            Case newCase5=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description=strDesc5,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase5);
            Case newCase6=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description=strDesc6,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase6);
            Case newCase7=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description=strDesc7,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase7);
            Case newCase8=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',subject='Test Case', description=strDesc8,accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(newCase8);
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
               
                
            }
            
            test.starttest();
                Freight_CaseTriggerHandler objCall=new Freight_CaseTriggerHandler();
                
                Freight_CaseTriggerHandler.assignUrgentPriorityForCasesWithHotWords(listCases);
                Freight_CaseTriggerHandler.freightMaskCreditCard(listCases);
            test.stoptest();
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
    }
     /*----------------------------------------------------------------------------------------------      
        Test Method Name:        testfreightAssociateAcctsWeb2Case
        Method Name:             freightAssociateAcctsWeb2Case
    ----------------------------------------------------------------------------------------------*/  
    static testmethod void testfreightAssociateAcctsWeb2Case()
    {
            try
            {
            List<Case> listCases=new List<Case>();
            List<Case> listofCases=new List<Case>();
            List<String> serialCases=new List<String>();
            List<String> serialOfCases=new List<String>();
            
            Id qantas_Freight;
            ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            List<Freight_RecordTypeSeggregation__c> listFreightRts=Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
            Id ContactRTId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            List<ID> caseIds=new List<ID>();
             
            for(Freight_RecordTypeSeggregation__c recType: listFreightRts) 
            {
                 if(recType.name.contains('Qantas_Freight'))
                 {
                     qantas_Freight=recType.RecordTypeId__c ;
                 }
            }
            List<Account> listAccounts=[select id,name from account where recordtypeid=:accountRecordTypeId and name like '%Freight%'];
            List<Contact> listContacts=[select id,name,email,account.id,account.name from contact where recordtypeid=:ContactRTId and account.recordtypeid =:accountRecordTypeId];
            List<Airport_Code__c> listAirCode=[select id,name from Airport_Code__c where name ='NONE' limit 1];
            system.debug('Print list of accounts'+listAccounts);
            system.debug('Print list of contacts'+listContacts);
            system.debug('Print list of airport codes'+listAirCode);
        
            Case newCase1=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenTrees@fedex.com',suppliedcompany='Green Trees Corp');
            Case newCase2=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greencord@auspost.com.au',suppliedcompany='Green Cord Corp');
            Case newCase3=new Case(recordtypeid=qantas_Freight,origin='Web',status='new',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenavenue@qantas.com.au',suppliedcompany='Green Avenue Corp');
            Case newCase4=new Case(recordtypeid=qantas_Freight,origin='Web',status='Closed',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenTrees@fedex.com',suppliedcompany='Green Trees Corp');
            Case newCase5=new Case(recordtypeid=qantas_Freight,origin='Web',status='Closed',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greencord@auspost.com.au',suppliedcompany='Green Cord Corp');
            Case newCase6=new Case(recordtypeid=qantas_Freight,origin='Web',status='Closed',subject='Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenavenue@qantas.com.au',suppliedcompany='Green Avenue Corp');
            Case newCase7=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='Open',subject='Automatic Reply: Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenavenue@qantas.com.au',suppliedcompany='Green Avenue Corp');
            Case newCase8=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='Open',subject='Automatic Reply: Test Case', description='test Case',Freight_Port__c=listAirCode[0].id,suppliedemail='greenavenue@qantas.com.au',suppliedcompany='Green Avenue Corp');
            listCases.add(newCase1);
            listCases.add(newCase2);
            listCases.add(newCase3);
            listCases.add(newCase4);
            listCases.add(newCase5);
            listCases.add(newCase6);
            listofCases.add(newCase7);
            listofCases.add(newCase8);
            
           
            
            test.starttest();
                if(listCases!=null && listCases.size()>0)
                {
                    insert listCases;
                    for(Case getIds:listCases)
                    {
                        caseIds.add(getIds.id);
                        
                    }
                }
                if(listofCases!=null && listofCases.size()>0)
                {
                    insert listofCases;
                    
                }
            List<Case> fetchInsertedCs=[select id,casenumber,suppliedemail,suppliedcompany,recordtypeid,origin,accountid,contactid from case where ID IN :caseIds];
                Freight_CaseTriggerHandler objCall=new Freight_CaseTriggerHandler();
                
                
                
                
                System.debug('fetchInsertedCs====> ' + fetchInsertedCs);
                Freight_CaseTriggerHandler.freightAssociateAcctsWeb2Case(listofCases);  
                Freight_CaseTriggerHandler.autoCloseAuotmaticReplayCases(fetchInsertedCs);  
            test.stoptest(); 
            }
            catch(exception e)
            {
                system.debug('Exception Occurred'+e.getMessage());
            }
    }
}