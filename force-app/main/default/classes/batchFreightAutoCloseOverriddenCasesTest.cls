/*Jira-> FCRM-939- Service - Auto-Close Overridden Cases
Description-> Test Class for batch that auto-closes the Overridden Cases from FRT Bookings and FRT Cust SErvice
Developer-> Navpreet Kaur
Creation Date-> 10 AUG 2022
*/
@istest
public class batchFreightAutoCloseOverriddenCasesTest 
{
	static testmethod void testautoCaseClosure()
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
            
            String[] sub=new String[]{'Export Flight Report','has been disrupted and is being re booked','7 west','NZ FREIGHTER','COOL ROOM PRE-ALERTS','has reached overbooking capacity limit',
						'ATLAS DELAYS','TRUCKING PRE ALERT','TRUCKING PRE ALERT','TRUCKING PRE ALERT'};
			
            String[] sub2=new String[]{'[Vaccine Pre-Alert]','LAO','MAP','MAPPING','majed','pca','Roy Hill - New Job Request Created','Missing','msca','41499161'};
            
            
            for(integer i=0; i<10; i++)
            {
                Case cs=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',priority='Low',subject=sub[i], description='test case',accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
                listCases.add(cs);
            }
           
            Case cs2=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',priority='Low',subject='Retail Booking Confirmation', description='From: noreplyfreight@qantas.com.au', accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(cs2);
            
            
            Case cs3=new Case(recordtypeid=qantas_Freight,origin='FRT Bookings',status='new',priority='Low',subject='Retail Booking Confirmation', description='Cc: aufreightbookings@qantas.com.au', accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(cs3);
            
            

			for(integer i=0;i<10;i++)
            {
                Case cs4=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',priority='Low',subject=sub2[i], description='Cc: aufreightbookings@qantas.com.au', accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            	listCases.add(cs4);
            }
            
            Case cs5=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',priority='Low',subject='Retail Booking Confirmation', description='From: noreplyfreight@qantas.com.au', accountid=accountRecord.id,Freight_Port__c=mdtRec1.id);
            listCases.add(cs5);
            
            if(listCases!=null && listCases.size()>0)
            {
                insert listCases;
            }
            
			for(integer i=0;i<10;i++)
            {
                EmailMessage ems=new EmailMessage(parentid=listCases[i].id, subject=sub[i], incoming=true, textbody='test case');
                listEmailMessages.add(ems);
            }
             
           EmailMessage ems2=new EmailMessage(parentid=listCases[10].id, subject='Retail Booking Confirmation', incoming=true, textbody='From: noreplyfreight@qantas.com.au');
                listEmailMessages.add(ems2);
            
            EmailMessage ems3=new EmailMessage(parentid=listCases[11].id, subject='Retail Booking Confirmation', incoming=true, textbody='Cc: aufreightbookings@qantas.com.au');
                listEmailMessages.add(ems3);
            
            
            
            for(integer i=0;i<10;i++)
            {
                EmailMessage ems4=new EmailMessage(parentid=listCases[i+12].id, subject=sub2[i], incoming=true, textbody='test case');
                listEmailMessages.add(ems4);
            }
            
           EmailMessage ems5=new EmailMessage(parentid=listCases[22].id, subject='Retail Booking Confirmation', incoming=true, textbody='From: noreplyfreight@qantas.com.au');
           listEmailMessages.add(ems5);
            
             if(listEmailMessages!=null && listEmailMessages.size()>0)
             {
                 insert listEmailMessages;
             }
            
            test.starttest();
                database.executeBatch(new batchFreightAutoCloseOverriddenCases(),200);
            	String sch = '0 0 2 * * ?'; 
				system.schedule('Test Territory Check', sch, new batchFreightAutoCloseOverriddenCases());
            test.stoptest();
            
        }
        catch(Exception e)
        {
            system.debug('Exception Occurred'+e);
        }
    }
}