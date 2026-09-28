@isTest
public with sharing class chatTranscriptTriggerHelperTest {
    @testSetup static void createTestData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<QantasConfigData__c> qantasConfigData = new List<QantasConfigData__c>();
        qantasConfigData.add(new QantasConfigData__c(Name='RT_Case_QantasFreight', Config_Value__c ='Qantas_Freight'));
        qantasConfigData.add(new QantasConfigData__c(Name='RT_FreightAccount',  Config_Value__c ='Freight_Account'));
        qantasConfigData.add(new QantasConfigData__c(Name='FullName_AutomatedUser',  Config_Value__c ='Automated Process'));
        insert qantasConfigData;
        
        
    }
    
    @isTest static void testmethodFirst()
    {
        User UID=[select id,name from user where name='Automated Process' limit 1];
        User UID_agent=[select id,name from user where Profile.name='Qantas Freight Service' and userrole.name='QF-Freight-Customer-Service-Unit-Team' limit 1];
        Group groupmember=[select id from Group where type='Queue' and name='Freight Chat'];
        system.runAs(UID)
        {
        List<LiveChatTranscriptEvent> listLiveChatTransEventIns=new List<LiveChatTranscriptEvent>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<LiveChatTranscript> listChatTranscripts=new List<LiveChatTranscript>();
        List<LiveChatTranscript> listUpdateChatTrasns=new List<LiveChatTranscript>();
        system.debug('caseRecordTypeId '+caseRecordTypeId);
        Trigger_Status__c triggerStatus=new Trigger_Status__c();
        triggerStatus.Active__c=true;
        triggerStatus.Name='SubmitForFinalisation';
        insert triggerStatus;
        
        //Create test data for Account object
        ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.billingcountry='AU';
        insert accountRecord;
        system.debug('Account Record Inserted'+accountRecord);
        
        //Create test data for Contact object
        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
            
        system.debug('Contact Record Inserted'+contactRecord);
            
        AccountContactRelation acr = [ SELECT Id FROM AccountContactRelation WHERE AccountId=:accountRecord.Id AND ContactId=:contactRecord.Id ];
        acr.Function__c = 'IT';
        acr.Business_Type__c = 'B&G';
        acr.Job_Role__c ='BDM';                                                         
          
        update acr ; 
            Case caseRec=new Case();
            caseRec.RecordTypeId=caseRecordTypeId;
            caseRec.Origin='Webchat';
            caseRec.OwnerId=UID.id;
            caseRec.AccountId=accountRecord.Id;
            caseRec.ContactId=contactRecord.id;
            caseRec.Description='Please see details of Chat transcript via the feed sub tab.';
            caseRec.Subject='Test Cases';
            caseRec.Status='Open';
            caseRec.Type='Claims';
            insert caseRec;
            
            system.debug('Case Record Inserted'+caseRec);
          
            LiveChatVisitor livechatVis=new LiveChatVisitor();
            insert livechatVis;
            
            system.debug('Live chat visitor ID Insertion'+livechatVis);
        
            LiveChatTranscript chatTransRec=new LiveChatTranscript();
            chatTransRec.AccountId=accountRecord.Id;
            chatTransRec.ContactId=contactRecord.id;
            chatTransRec.OwnerId=UID_agent.id;
            chatTransRec.CaseId=caseRec.Id;
            chatTransRec.LiveChatVisitorId=livechatVis.Id;
            chatTransRec.Freight_Chat_Topic__c='Booking Assistance';
            listChatTranscripts.add(chatTransRec);
        
            if(listChatTranscripts!=null && listChatTranscripts.size()>0)
            {
               insert listChatTranscripts;    
            }
            system.debug('LiveChatTranscript Record Inserted'+listChatTranscripts);
            
            LiveChatTranscriptEvent chatTransRecEvent=new LiveChatTranscriptEvent();
            chatTransRecEvent.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent.AgentId=UID_agent.id;
            chatTransRecEvent.Type='ChatRequest';
            chatTransRecEvent.time=system.now();
            chatTransRecEvent.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent);
            
            LiveChatTranscriptEvent chatTransRecEvent2=new LiveChatTranscriptEvent();
            chatTransRecEvent2.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent2.AgentId=UID_agent.id;
            chatTransRecEvent2.Type='ChatbotEstablished';
            chatTransRecEvent2.time=system.now();
            chatTransRecEvent2.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent2);
        
            LiveChatTranscriptEvent chatTransRecEvent3=new LiveChatTranscriptEvent();
            chatTransRecEvent3.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent3.AgentId=UID_agent.id;
            chatTransRecEvent3.Type='EndVisitor';
            chatTransRecEvent3.time=system.now();
            chatTransRecEvent3.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent3);
        
            LiveChatTranscriptEvent chatTransRecEvent4=new LiveChatTranscriptEvent();
            chatTransRecEvent4.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent4.AgentId=UID_agent.id;
            chatTransRecEvent4.Type='LeaveVisitor';
            chatTransRecEvent4.time=system.now();
            chatTransRecEvent4.Detail='Chat request routed to agent Joanna Eatock.';
           
            listLiveChatTransEventIns.add(chatTransRecEvent4);    
            if(listLiveChatTransEventIns.size()>0 && listLiveChatTransEventIns!=null)
            {
                insert listLiveChatTransEventIns;
            }
        
            system.debug('LiveChatTranscriptEvent Record Inserted'+chatTransRecEvent);
            LiveChatTranscript liveChatQuery=[select id,OwnerId,Status,caseid from LiveChatTranscript where id=:chatTransRec.id];
            system.debug('liveChatQuery Query Result'+liveChatQuery);
            
            liveChatQuery.OwnerId=UID_agent.id;
            liveChatQuery.Status='Completed';
            listUpdateChatTrasns.add(liveChatQuery);
            
            if(listUpdateChatTrasns!=null && listUpdateChatTrasns.size()>0)
            {
                update listUpdateChatTrasns;
            }
          
            system.debug('listUpdateChatTrasns updated values'+listUpdateChatTrasns);        
            test.startTest();
                chatTranscriptTriggerHelper.changeOwnerToCurrentAgent(listUpdateChatTrasns);
                chatTranscriptEventTriggerHelper.autocloseFreightUnhandledCases(listLiveChatTransEventIns);
            test.stopTest();
        }
        
        
    }
    
    @isTest static void testMethodTwo() {
        User UID=[select id,name from user where name='Automated Process' limit 1];
        User UID_agent=[select id,name from user where Profile.name='Qantas Freight Service' and userrole.name='QF-Freight-Customer-Service-Unit-Team' limit 1];
        Group groupmember=[select id from Group where type='Queue' and name='Freight Chat'];
        
        system.runAs(UID)
        {
        List<LiveChatTranscriptEvent> listLiveChatTransEventIns=new List<LiveChatTranscriptEvent>();
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<LiveChatTranscript> listChatTranscripts=new List<LiveChatTranscript>();
        List<LiveChatTranscript> listUpdateChatTrasns=new List<LiveChatTranscript>();
        system.debug('caseRecordTypeId '+caseRecordTypeId);
        Trigger_Status__c triggerStatus=new Trigger_Status__c();
        triggerStatus.Active__c=true;
        triggerStatus.Name='SubmitForFinalisation';
        insert triggerStatus;
        
        //Create test data for Account object
        ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        Account accountRecord = new Account(Name='Retail Customer Webchat');
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.billingcountry='AU';
        insert accountRecord;
        system.debug('Account Record Inserted'+accountRecord);
        
        //Create test data for Contact object
        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
            
        system.debug('Contact Record Inserted'+contactRecord);
            
        AccountContactRelation acr = [ SELECT Id FROM AccountContactRelation WHERE AccountId=:accountRecord.Id AND ContactId=:contactRecord.Id ];
        acr.Function__c = 'IT';
        acr.Business_Type__c = 'B&G';
        acr.Job_Role__c ='BDM';                                                         
          
        update acr ; 
        
        
        
        
        
            Case caseRec=new Case();
            caseRec.RecordTypeId=caseRecordTypeId;
            caseRec.Origin='Web';
            caseRec.OwnerId=UID.id;
            caseRec.AccountId=accountRecord.Id;
            caseRec.ContactId=contactRecord.id;
            caseRec.Description='Please see details of Chat transcript via the feed sub tab.';
            caseRec.Subject='Test Cases';
            caseRec.Status='Open';
            caseRec.Type='Claims';
            insert caseRec;
            
            system.debug('Case Record Inserted'+caseRec);
          
            LiveChatVisitor livechatVis=new LiveChatVisitor();
            insert livechatVis;
            
            system.debug('Live chat visitor ID Insertion'+livechatVis);
        
            LiveChatTranscript chatTransRec=new LiveChatTranscript();
            //chatTransRec.AccountId=accountRecord.Id;
            chatTransRec.ContactId=contactRecord.id;
            chatTransRec.OwnerId=UID_agent.id;
            chatTransRec.CaseId=caseRec.Id;
            chatTransRec.LiveChatVisitorId=livechatVis.Id;
            chatTransRec.Freight_Chat_Topic__c='Booking Assistance';
            listChatTranscripts.add(chatTransRec);
        
            if(listChatTranscripts!=null && listChatTranscripts.size()>0)
            {
               insert listChatTranscripts;    
            }
            system.debug('LiveChatTranscript Record Inserted'+listChatTranscripts);
            
            LiveChatTranscriptEvent chatTransRecEvent=new LiveChatTranscriptEvent();
            chatTransRecEvent.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent.AgentId=UID_agent.id;
            chatTransRecEvent.Type='ChatRequest';
            chatTransRecEvent.time=system.now();
            chatTransRecEvent.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent);
            
            LiveChatTranscriptEvent chatTransRecEvent2=new LiveChatTranscriptEvent();
            chatTransRecEvent2.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent2.AgentId=UID_agent.id;
            chatTransRecEvent2.Type='ChatbotEstablished';
            chatTransRecEvent2.time=system.now();
            chatTransRecEvent2.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent2);
        
            LiveChatTranscriptEvent chatTransRecEvent3=new LiveChatTranscriptEvent();
            chatTransRecEvent3.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent3.AgentId=UID_agent.id;
            chatTransRecEvent3.Type='EndVisitor';
            chatTransRecEvent3.time=system.now();
            chatTransRecEvent3.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent3);
        
            LiveChatTranscriptEvent chatTransRecEvent4=new LiveChatTranscriptEvent();
            chatTransRecEvent4.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent4.AgentId=UID_agent.id;
            chatTransRecEvent4.Type='LeaveVisitor';
            chatTransRecEvent4.time=system.now();
            chatTransRecEvent4.Detail='Chat request routed to agent Joanna Eatock.';
           
            listLiveChatTransEventIns.add(chatTransRecEvent4);    
            if(listLiveChatTransEventIns.size()>0 && listLiveChatTransEventIns!=null)
            {
                insert listLiveChatTransEventIns;
            }
        
            system.debug('LiveChatTranscriptEvent Record Inserted'+chatTransRecEvent);
            LiveChatTranscript liveChatQuery=[select id,OwnerId,Status,caseid from LiveChatTranscript where id=:chatTransRec.id];
            system.debug('liveChatQuery Query Result'+liveChatQuery);
            
            liveChatQuery.OwnerId=UID_agent.id;
            liveChatQuery.Status='Completed';
            listUpdateChatTrasns.add(liveChatQuery);
            
            if(listUpdateChatTrasns!=null && listUpdateChatTrasns.size()>0)
            {
                update listUpdateChatTrasns;
            }
        }
    }
    
    @isTest static void testMethodThree() {
        User UID=[select id,name from user where name='Automated Process' limit 1];
        User UID_agent=[select id,name from user where Profile.name='Qantas Freight Service' and userrole.name='QF-Freight-Customer-Service-Unit-Team' limit 1];
        Group groupmember=[select id from Group where type='Queue' and name='Freight Chat'];
        
        system.runAs(UID)
        {
        List<LiveChatTranscriptEvent> listLiveChatTransEventIns=new List<LiveChatTranscriptEvent>();
        
    
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
        List<LiveChatTranscript> listChatTranscripts=new List<LiveChatTranscript>();
        List<LiveChatTranscript> listUpdateChatTrasns=new List<LiveChatTranscript>();
        system.debug('caseRecordTypeId '+caseRecordTypeId);
        Trigger_Status__c triggerStatus=new Trigger_Status__c();
        triggerStatus.Active__c=true;
        triggerStatus.Name='SubmitForFinalisation';
        insert triggerStatus;
        
        //Create test data for Account object
        ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        Account accountRecord = new Account(Name='Retail Customer Webchat');
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.billingcountry='AU';
        insert accountRecord;
        system.debug('Account Record Inserted'+accountRecord);
        
        //Create test data for Contact object
        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact contactRecord = new Contact(FirstName='Testing Contact', LastName='01', Email='test@qantas.com.au');
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
            
        system.debug('Contact Record Inserted'+contactRecord);
            
        
            Case caseRec=new Case();
            caseRec.RecordTypeId=caseRecordTypeId;
            caseRec.Origin='Web';
            caseRec.OwnerId=UID.id;
            caseRec.AccountId=accountRecord.Id;
            caseRec.ContactId=contactRecord.id;
            caseRec.Description='Please see details of Chat transcript via the feed sub tab.';
            caseRec.Subject='Test Cases';
            caseRec.Status='Open';
            caseRec.Type='Claims';
            insert caseRec;
            
            system.debug('Case Record Inserted'+caseRec);
          
            LiveChatVisitor livechatVis=new LiveChatVisitor();
            insert livechatVis;
            
            system.debug('Live chat visitor ID Insertion'+livechatVis);
        
            LiveChatTranscript chatTransRec=new LiveChatTranscript();
            //chatTransRec.AccountId=accountRecord.Id;
            chatTransRec.ContactId=contactRecord.id;
            chatTransRec.OwnerId=UID_agent.id;
            chatTransRec.CaseId=caseRec.Id;
            chatTransRec.LiveChatVisitorId=livechatVis.Id;
            chatTransRec.Freight_Chat_Topic__c='Booking Assistance';
            listChatTranscripts.add(chatTransRec);
        
            if(listChatTranscripts!=null && listChatTranscripts.size()>0)
            {
               insert listChatTranscripts;    
            }
            system.debug('LiveChatTranscript Record Inserted'+listChatTranscripts);
            
            LiveChatTranscriptEvent chatTransRecEvent=new LiveChatTranscriptEvent();
            chatTransRecEvent.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent.AgentId=UID_agent.id;
            chatTransRecEvent.Type='ChatRequest';
            chatTransRecEvent.time=system.now();
            chatTransRecEvent.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent);
            
            LiveChatTranscriptEvent chatTransRecEvent2=new LiveChatTranscriptEvent();
            chatTransRecEvent2.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent2.AgentId=UID_agent.id;
            chatTransRecEvent2.Type='ChatbotEstablished';
            chatTransRecEvent2.time=system.now();
            chatTransRecEvent2.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent2);
        
            LiveChatTranscriptEvent chatTransRecEvent3=new LiveChatTranscriptEvent();
            chatTransRecEvent3.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent3.AgentId=UID_agent.id;
            chatTransRecEvent3.Type='EndVisitor';
            chatTransRecEvent3.time=system.now();
            chatTransRecEvent3.Detail='Chat request routed to agent Joanna Eatock.';
            listLiveChatTransEventIns.add(chatTransRecEvent3);
        
            LiveChatTranscriptEvent chatTransRecEvent4=new LiveChatTranscriptEvent();
            chatTransRecEvent4.LiveChatTranscriptId=chatTransRec.id;
            chatTransRecEvent4.AgentId=UID_agent.id;
            chatTransRecEvent4.Type='LeaveVisitor';
            chatTransRecEvent4.time=system.now();
            chatTransRecEvent4.Detail='Chat request routed to agent Joanna Eatock.';
           
            listLiveChatTransEventIns.add(chatTransRecEvent4);    
            if(listLiveChatTransEventIns.size()>0 && listLiveChatTransEventIns!=null)
            {
                insert listLiveChatTransEventIns;
            }
        
            system.debug('LiveChatTranscriptEvent Record Inserted'+chatTransRecEvent);
            LiveChatTranscript liveChatQuery=[select id,OwnerId,Status,caseid from LiveChatTranscript where id=:chatTransRec.id];
            system.debug('liveChatQuery Query Result'+liveChatQuery);
            
            liveChatQuery.OwnerId=UID_agent.id;
            liveChatQuery.Status='Completed';
            listUpdateChatTrasns.add(liveChatQuery);
            if(listUpdateChatTrasns!=null && listUpdateChatTrasns.size()>0)
            {
                update listUpdateChatTrasns;
            }
            
        }
    }
    
     @isTest static void testMethodQLChatTranscriptNDC() {
       User UID=[select id,name from user where name='Automated Process' limit 1];
        User UID_agent=[select id,name from user where Profile.name='Qantas Freight Service' and userrole.name='QF-Freight-Customer-Service-Unit-Team' limit 1];
        Group groupmember=[select id from Group where type='Queue' and name='Freight Chat'];
        
        system.runAs(UID)
        {
        List<LiveChatTranscriptEvent> listLiveChatTransEventIns=new List<LiveChatTranscriptEvent>();
        
    
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QAC Contact Us Support').getRecordTypeId();
        List<LiveChatTranscript> listChatTranscripts=new List<LiveChatTranscript>();
        List<LiveChatTranscript> listUpdateChatTrasns=new List<LiveChatTranscript>();
        system.debug('caseRecordTypeId '+caseRecordTypeId);
        Trigger_Status__c triggerStatus=new Trigger_Status__c();
        triggerStatus.Active__c=true;
        triggerStatus.Name='SubmitForFinalisation';
        insert triggerStatus;
        
        //Create test data for Account object
        ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Account accountRecord = new Account(Name='QAC Test Account');
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.billingcountry='AU';
        accountRecord.Qantas_Industry_Centre_ID__c = '0209411';
        insert accountRecord;
        system.debug('Account Record Inserted'+accountRecord);
        
        //Create test data for Contact object
        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Id qacchatRecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByName().get('QAC-NDC Chat').getRecordTypeId();
        Contact contactRecord = new Contact(FirstName='Testing Contact', LastName='01', Email='test@qantas.com.au');
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
            
        system.debug('Contact Record Inserted'+contactRecord);
            
        
            Case caseRec=new Case();
            caseRec.RecordTypeId=caseRecordTypeId;
            caseRec.Origin='Web';
            caseRec.OwnerId=UID.id;
            caseRec.AccountId=accountRecord.Id;
            caseRec.ContactId=contactRecord.id;
            caseRec.Description='Please see details of Chat transcript via the feed sub tab.';
            caseRec.Subject='Test Cases';
            caseRec.Status='Open';
            caseRec.Type='Claims';
            insert caseRec;
            
            system.debug('Case Record Inserted'+caseRec);
          
            LiveChatVisitor livechatVis=new LiveChatVisitor();
            insert livechatVis;
            
            system.debug('Live chat visitor ID Insertion'+livechatVis);
        
            LiveChatTranscript chatTransRec=new LiveChatTranscript();
            //chatTransRec.AccountId=accountRecord.Id;
            chatTransRec.RecordTypeId = qacchatRecordTypeId;
            chatTransRec.ContactId=contactRecord.id;
            chatTransRec.OwnerId=UID_agent.id;
            chatTransRec.CaseId=caseRec.Id;
            chatTransRec.LiveChatVisitorId=livechatVis.Id;
            chatTransRec.Freight_Chat_Topic__c='Booking Assistance';
            chatTransRec.QIC_Number__c = '0209411';
            chatTransRec.PNR__c = '5176PX';
			chatTransRec.Travel_Consultant_Name__c = 'Test';
			chatTransRec.Contact_number__c = '9234567890';
			chatTransRec.Technology_Partner__c = 'Aeronology';
            listChatTranscripts.add(chatTransRec);
        
            if(listChatTranscripts!=null && listChatTranscripts.size()>0)
            {
               insert listChatTranscripts;    
            }
            system.debug('LiveChatTranscript Record Inserted'+listChatTranscripts);
            List<QL_ChatTranscriptNDC.FlowInput_QLChatTranscriptNDC> lstWrap = new List<QL_ChatTranscriptNDC.FlowInput_QLChatTranscriptNDC>();
          	QL_ChatTranscriptNDC.FlowInput_QLChatTranscriptNDC qlNDCwrapClass = new QL_ChatTranscriptNDC.FlowInput_QLChatTranscriptNDC();
            qlNDCwrapClass.operationVar = 'UPDATE';
            qlNDCwrapClass.chatTranscriptVar = listChatTranscripts[0];
            lstWrap.add(qlNDCwrapClass);
            QL_ChatTranscriptNDC.processChatTranscript(lstWrap);
            QL_ChatTranscriptNDC.updateContactFields(listChatTranscripts[0], accountRecord);
            lstWrap[0].operationVar = 'INSERT';
            lstWrap[0].chatTranscriptVar.QIC_Number__c = '';
            QL_ChatTranscriptNDC.processChatTranscript(lstWrap);
            
        }
    }
}