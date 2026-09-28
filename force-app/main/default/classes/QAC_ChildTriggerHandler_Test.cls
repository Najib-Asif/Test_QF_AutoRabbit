/* 
Created By      : Ajay Bharathan | TCS | Cloud Developer 
Main Class      : QAC_ChildTriggerHandler
Modified Date   : 29/10/2025 (DD/MM/YYYY)
Modified By     : Gokulakannan Perumal
JIRA            : CRM-9259
*/
@isTest
public class QAC_ChildTriggerHandler_Test {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String spRTId = Schema.SObjectType.Service_Payment__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woliRTId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String passengerRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
        insert myAccount;
        
        // inserting Case
        Case newCase1 = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = '01290000001IINOAA4',
                                 Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Open',
                                 Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Not Applicable',
                                 AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                 PNR_number__c = '454545',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
        insert newCase1;
        
		//	Start - CRM-9259: NDC/Freight Web Chat code 
        case newCase2 = new Case (Origin ='Web',Type='NDC',Group__c = 'NDC chat',Category__c='Web Chat', Description = 'Test',
                                  Sub_Category__c ='General',RecordTypeId = '012Mo000001qBJlIAM');
        insert newCase2;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Consultant').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
                          );
        insert u1;
        
        Id msgEndUserId;
		/* CRM-11408 QUERY EXISTING MESSAGING CHANNEL CREATION */
        MessagingChannel messagingChannel = [SELECT Id, MessagingPlatformKey  FROM MessagingChannel WHERE DeveloperName = 'QAC_Messaging_Web_Chat'];
       
        system.runAs(u1){
            
            /*CRM-11408 BYPASSING MESSAGING CHANNEL CREATION
            MessagingChannel messagingChannel = new MessagingChannel();
            messagingChannel.MasterLabel = 'Test Channel';
            messagingChannel.DeveloperName = 'Test_Channel';
            messagingChannel.IsActive = true;
            messagingChannel.MessageType = 'Text'; 
            messagingChannel.MessagingPlatformKey = '71823b51-1111-2222-3333-211e1143ce85';
            insert messagingChannel;**/
            
            MessagingEndUser user = new MessagingEndUser();
            user.Name = 'Messaging User';
            user.MessagingChannelId = messagingChannel.id;
            user.MessageType = 'Text'; 
            //user.MessagingPlatformKey = 'v2/iamessage/UNAUTH/NA/uid:cf9bf7db-1111-2222-3333-49af3c5a037b'; //CRM-11408 Commented
            user.MessagingPlatformKey = messagingChannel.MessagingPlatformKey; //CRM-11408 Added
            insert user;
            msgEndUserId=user.id;
            
        }
        
		//CRM-11408 Added - Added static resource file CSVConversationMock to load below
        List<SObject> convList = Test.loadData(Conversation.SObjectType, 'CSVConversationMock');
        Conversation conv = (Conversation) convList[0];

        //MessagingChannel channel = [SELECT Id FROM MessagingChannel WHERE DeveloperName = 'Test_Channel']; //CRM-11408 Commented
        MessagingSession session = new MessagingSession();
        session.MessagingEndUserId = msgEndUserId;
        session.MessagingChannelId = messagingChannel.Id;
        session.Status = 'New';
        session.CaseId = newCase2.id;
		session.ConversationId = conv.Id; //CRM-11408 Added
        insert session;
        
        //	End - CRM-9259: NDC/Freight Web Chat code 
           
        list<Flight__c> flightlist = new list<Flight__c>();
        for(Integer i=0;i<4;i++){
            Flight__c newTA = new Flight__c();
            newTA.RecordTypeId = flightRTId;
            newTA.Case__c = newCase1.Id;
            flightList.add(newTA);            
        }
        insert flightList;
        
        list<Affected_Passenger__c> pslist = new list<Affected_Passenger__c>();
        for(Integer i=0;i<4;i++){
            Affected_Passenger__c newPassenger = new Affected_Passenger__c();
            newPassenger.RecordTypeId = passengerRTId;
            newPassenger.Case__c = newCase1.Id;
            pslist.add(newPassenger);
        }
        insert pslist;
        
        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        waiverTypes.add(newCase1.Problem_Type__c);
        waiverSubTypes.add(newCase1.Waiver_Sub_Type__c);
        
        list<CaseComment> cclist = new list<CaseComment>();
        for(Integer i=0;i<4;i++){
            CaseComment newComment = new CaseComment();
            newComment.CommentBody = 'hellloo1';
            newComment.ParentId = newCase1.Id;
            cclist.add(newComment);
        }
        insert cclist;
        
        // insert Product
        Product2 NameChangeProd = new Product2(Name = 'Name Correction',ProductCode = 'Name_Corr_AU',QuantityUnitOfMeasure = 'Ticket',
                                               IsActive = TRUE, RFIC_code__c='AFPT');
        insert NameChangeProd;
        
        // insert Pricebook
        Pricebook2 customPB1 = new Pricebook2(Name='QAC AU Online', isActive=true, Description='Pricebook for AU Agents that Register via Website');
        Pricebook2 customPB2 = new Pricebook2(Name='QAC EU Call', isActive=true, Description='Pricebook for AU Agents that Register via Calls');
        insert customPB1;        
        insert customPB2;        
        
        // Standard PB ID
        Id StdPricebookId = Test.getStandardPricebookId();
        
        // Insert PriceBookEntry - Std PB entry Mandatory for PB and Product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = StdPricebookId, Product2Id = NameChangeProd.Id,UnitPrice = 100, IsActive = true);
        insert standardPrice;        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB1.Id, Product2Id = NameChangeProd.Id,UnitPrice = 70, IsActive = true);
        insert customPrice1;        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = NameChangeProd.Id,UnitPrice = 80, IsActive = true);
        insert customPrice2;        
        
        list<QAC_Waiver_Default__mdt> WDmdt = [SELECT MasterLabel,DeveloperName,Approve__c,Condition_Met__c,
                                               Cost_of_Sale__c,Paid_Service__c,Waiver_Sub_Type__c,Waiver_Type__c
                                               from QAC_Waiver_Default__mdt 
                                               where Waiver_Type__c IN: waiverTypes AND Waiver_Sub_Type__c IN: waiverSubTypes];
        system.debug('WD mdt**'+WDmdt);
        
        // create Work Order & Service Payment record for invalidCase
        WorkOrder newWO = new WorkOrder();
        newWO.CaseId = newCase1.Id;
        newWO.RecordTypeId = woRTId;
        newWO.StartDate = newCase1.CreatedDate;
        newWO.Travel_Type__c = newCase1.Travel_Type__c;
        newWO.Pricebook2Id = customPB1.Id;
        newWO.Status = 'New';
        insert newWO;
        
        WorkOrderLineItem newWOLI = new WorkOrderLineItem();
        newWOLI.WorkOrderId = newWO.Id;
        newWOLI.RecordTypeId = woliRTId;
        newWOLI.PricebookEntryId = customPrice1.Id ;
        newWOLI.Quantity = 2;
        insert newWOLI;
        system.debug('newWOLI:'+newWOLI);
        
        Service_Payment__c newSPay = new Service_Payment__c();
        newSPay.Case__c = newCase1.Id;
        newSPay.RecordTypeId = spRTId;
        newSPay.Payment_Due_Date__c = Date.today().addDays(-3);
        newSPay.Payment_Status__c = 'Pending';      
        newSPay.Payment_Type__c = 'Card';
        newSpay.EMD_Number__c = '0818209981826';
        insert newSPay;
        
        
    }
    
    @isTest
    public static void testdeleteFlight() 
    {
        list<Flight__c> flightlist = new list<Flight__c>();
        for(Flight__c eachflight : [Select Id from Flight__c])
            flightlist.add(eachflight);
        
        Test.startTest();
        delete flightList[0];
        delete flightList[1];
        Test.stopTest();
    }
    
    @isTest
    public static void testdeleteSP() 
    {
        list<Service_Payment__c> paylist = new list<Service_Payment__c>();
        for(Service_Payment__c eachSP : [Select Id from Service_Payment__c])
            paylist.add(eachSP);
        
        Test.startTest();
        delete paylist;
        Test.stopTest();
    }
    
    @isTest
    public static void testdeleteWO() 
    {        
        list<WorkOrder> wolist = new list<WorkOrder>();
        for(WorkOrder eachwo : [Select Id from WorkOrder])
            wolist.add(eachwo);
        
        Test.startTest();
        delete wolist;
        Test.stopTest();
    }
    
    @isTest
    public static void testdeletePAX() 
    {
        list<Affected_Passenger__c> pslist = new list<Affected_Passenger__c>();
        for(Affected_Passenger__c eachPAX : [Select Id from Affected_Passenger__c])
            pslist.add(eachPAX);
        
        Test.startTest();
        delete pslist[0];
        delete pslist[1];
        Test.stopTest();
    }
    
    @isTest
    public static void testdeleteCaseComment() 
    {
        list<CaseComment> cclist = new list<CaseComment>();
        for(CaseComment eachCC : [Select Id from CaseComment])
            cclist.add(eachCC);
        
        Test.startTest();
        delete cclist[0];
        delete cclist[1];
        Test.stopTest();
    }
    
    @isTest
    public static void testFileCreation() 
    {
        list<Case> allCases = new list<Case>();
        for(Case eachCase : [Select Id from Case])
            allCases.add(eachCase);
        
        Test.startTest();
        String myJson = 'this is a sample file';
        ContentVersion myVersion = new ContentVersion();
        myVersion.ContentLocation = 'S';
        myVersion.PathOnClient = 'Agency Registration Information.txt';
        myVersion.Title = 'Agency Registration Information';
        myVersion.VersionData = Blob.valueOf(myJson);
        insert myVersion;   
        
        Id ContentDocId = [Select ContentDocumentId from ContentVersion where Id =: myVersion.Id].ContentDocumentId;
        
        List<MessagingSession> session = [Select id, MessagingEndUserId, Status,MessagingChannelId,caseId from MessagingSession limit 1];
        
        ContentDocumentLink myDocument = new ContentDocumentLink();
        myDocument.ContentDocumentId = ContentDocId;
        myDocument.LinkedEntityId = allCases[0].Id; 
        myDocument.LinkedEntityId = session[0].Id; 
        myDocument.ShareType = 'I'; 
        insert myDocument;
        
        //	Start - CRM-9259: NDC/Freight Web Chat code 
        List<ContentDocumentLink> cdl = [Select id,LinkedEntityId from  ContentDocumentLink where LinkedEntityId =:session[0].Id];
        QAC_ChildTriggerHandler.contentDocumentToCase(cdl);
        //	End - CRM-9259: NDC/Freight Web Chat code 
        
        Test.stopTest();
        
    }
    
    
}