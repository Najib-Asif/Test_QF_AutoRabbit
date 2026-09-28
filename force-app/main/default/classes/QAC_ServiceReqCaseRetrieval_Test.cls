/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QAC_ServiceReqCaseRetrieval
  ************************************************************************************************
  2-Feb-2026      Tanya-Capgemini               CRM-10423: Test method updated for PSV changes   
  15-Jul-2025     Jonathan-Capgemini            RBAC SND
  ************************************************************************************************
  */
@isTest
public class QAC_ServiceReqCaseRetrieval_Test {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String paxRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        System.debug('paxRTId-->'+paxRTId);
        String woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woliRTId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String spRTId = Schema.SObjectType.Service_Payment__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();

        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentTriggerSetting());
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
        list<Case> allCases = new list<Case>();
        Case caseWoPay = new Case(External_System_Reference_Id__c = 'C-002001001001',Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',
                                  Type = 'Commercial Waiver (BART)',Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                  Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                  Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                  AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                  PNR_number__c = '454522',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
        allCases.add(caseWoPay);
        
        Case caseWPay = new Case(Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',Type = 'Commercial Waiver (BART)',
                                 Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                 Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                 Subject = 'validCase',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                 AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                 PNR_number__c = '454523',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Paid_Service__c = true,
                                 QAC_Request_Country__c = 'AU', Travel_Type__c = 'Domestic');
        allCases.add(caseWPay);
        insert allCases;
        
        list<Flight__c> flightlist = new list<Flight__c>();
        for(Integer i=0;i<2;i++){
            Flight__c newTA = new Flight__c();
            newTA.RecordTypeId = flightRTId;
            newTA.Case__c = allCases[1].Id;
            flightList.add(newTA);            
        }
        insert flightList;
       
        list<Affected_Passenger__c> pslist = new list<Affected_Passenger__c>();
        for(Integer i=0;i<2;i++){
            Affected_Passenger__c newPassenger = new Affected_Passenger__c();
            newPassenger.RecordTypeId = paxRTId;
            newPassenger.Case__c = allCases[1].Id;
			newPassenger.Passenger_Sequence__c = Decimal.valueOf(i);
            pslist.add(newPassenger);
        }
        System.debug('pslist--'+pslist);
        insert pslist;
        
       
        list<CaseComment> cclist = new list<CaseComment>();
        for(Integer i=0;i<2;i++){
            CaseComment newComment = new CaseComment();
            newComment.CommentBody = 'hellloo1';
            newComment.ParentId = allCases[1].Id;
            cclist.add(newComment);
        }
        insert cclist;
        
        String myJson = 'this is a sample file';
        ContentVersion myVersion = new ContentVersion();
        myVersion.ContentLocation = 'S';
        myVersion.PathOnClient = 'Agency Registration Information.txt';
        myVersion.Title = 'Agency Registration Information';
        myVersion.VersionData = Blob.valueOf(myJson);
        insert myVersion;
        
        Id ContentDocId = [Select ContentDocumentId from ContentVersion where Id =: myVersion.Id].ContentDocumentId;
        
        ContentDocumentLink myDocument = new ContentDocumentLink();
        myDocument.ContentDocumentId = ContentDocId;
        myDocument.LinkedEntityId = allCases[1].Id; 
        myDocument.ShareType = 'I'; 
        insert myDocument;
        
        waiverTypes.add(allCases[1].Problem_Type__c);
        waiverSubTypes.add(allCases[1].Waiver_Sub_Type__c);
        
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
		newWO.CaseId = allCases[1].Id;
		newWO.RecordTypeId = woRTId;
		newWO.StartDate = allCases[1].CreatedDate;
		newWO.Travel_Type__c = allCases[1].Travel_Type__c;
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
		
		WorkOrder createdWO = QAC_PaymentsProcess.fetchWorkOrder(newWO.Id);
		Service_Payment__c newSPay = new Service_Payment__c();
		newSPay.Case__c = allCases[1].Id;
		newSPay.RecordTypeId = spRTId;
		newSPay.Payment_Due_Date__c = Date.today().addDays(-3);
		newSPay.Work_Order__c = createdWO.Id;
		newSPay.Payment_Currency__c = createdWO.CurrencyIsoCode;
		newSPay.Total_Amount__c = createdWO.TotalPrice;
		newSPay.RFIC_code__c = NameChangeProd.RFIC_code__c;
		newSPay.Quantity_UOM__c = NameChangeProd.QuantityUnitOfMeasure;
		newSPay.Payment_Status__c = 'Pending';          
		insert newSPay;
		system.debug('newSPay:'+newSPay);
    }
    
    @isTest
    public static void CaseRetrieval()
    {
        Set<Id> eachIds = new Set<Id>();
        Set<String> eachCaseNums = new Set<String>();
        for(Case eachCase : [Select Id,CaseNumber from Case]){
            eachIds.add(eachCase.Id);
            eachCaseNums.add(eachCase.CaseNumber);
        }
        System.debug('eachIds**'+eachIds);
        List<Affected_Passenger__c> pasgnrlist = new List<Affected_Passenger__c>();
        pasgnrlist= [Select id from Affected_Passenger__c where Case__c in: eachIds ];
         System.debug('pasgnrlist**'+pasgnrlist);
        
		String json = '{'+
		'\"caseRetrieval\" : {'+
		'\"sfCaseId\":[\"'+((new list<Id>(eachIds))[0])+'\",\"'+((new list<Id>(eachIds))[1])+'\",\"5009200000bjUpVAAU\"],'+
		'\"sfCaseNumber\":[\"'+((new list<String>(eachCaseNums))[0])+'\",\"'+((new list<String>(eachCaseNums))[1])+'\",\"0123456\"]'+
		'}'+
		'}';
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        user newuser1 = new user(FirstName = 'User1',
                                 LastName = 'Manager',
                                 Email = 'user1M@yopmail.com',
                                 CompanyName = 'test.com',
                                 Title = 'User1 Manager',
                                 Username = 'user1M@yopmail.com',
                                 Alias = 'user1',
                                 ProfileId = profMap.get('Sales and Distribution-Sales').Id,//RBAC SND
                                 Location__c = 'Manila',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_AU',
                                 TimeZoneSidKey = 'Australia/Sydney');
        insert newuser1;
		//RBAC SND - Permission Set Update
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Sales_Account_Manager_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(newuser1.Id,permissionSetIds);
        }
        System.debug('newuser1--'+newuser1);
        QAC_ServiceReqCaseRetrievalAPI myApi = QAC_ServiceReqCaseRetrievalAPI.parse(json);
         System.debug('myApi--'+myApi);
        QAC_ServiceReqCaseRetrieval_Test.restLogic(myApi,null);
        
		
        Test.startTest();
        QAC_ServiceReqCaseRetrieval.doCaseRetrieval();
        //System.runAs(newuser1){
        QAC_ServiceReqCaseRetrieval.doCaseRetrieval();
        //}
        Test.stopTest();
        }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
            QAC_ServiceReqCaseRetrieval_Test.restLogic(null,myExcepJson);
            
            Test.startTest();
            QAC_ServiceReqCaseRetrieval.doCaseRetrieval();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void restLogic(QAC_ServiceReqCaseRetrievalAPI theApi, String theExcepJson){
        System.debug('theApi--'+theApi);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QAC_ServReqCaseRetrieval/';  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}