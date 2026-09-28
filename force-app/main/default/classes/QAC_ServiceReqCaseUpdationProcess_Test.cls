/* 
    * Created By : Ajay Bharathan | TCS | Cloud Developer 
    * Main Class : QAC_ServiceReqCaseUpdationProcess
    ************************************************************************************************
    History
    ************************************************************************************************
    25-Jun-2019      Jay               QAC Agency Credits related Changes.
--------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QAC_ServiceReqCaseUpdationProcess_Test {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String spRTId = Schema.SObjectType.Service_Payment__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String woliRTId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
		Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        List<Trigger_Status__c> lsttrgStatus1 = TestUtilityDataClassQantas.createAssetTriggerSetting();
        insert lsttrgStatus1;
        
        //Inserting Account
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557',Billingcountry='AU', rcti__c = true, Tradesite__c = True);
        insert myAccount;
        
        // inserting Case
        list<Case> myCases = new list<Case>();
        Case newCase1 = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                 Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Open',
                                 Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Not Applicable',
                                 AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                 PNR_number__c = '454545',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
        
        Case newCase2 = new Case(External_System_Reference_Id__c = 'C-002002002003',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                 Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Credit',Status = 'Open',
                                 Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Not Applicable',
                                 AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test2@test.com',Consultant_Phone__c = '28213813',
                                 PNR_number__c = '454547',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic');   
        myCases.add(newCase1);
        myCases.add(newCase2);
        insert myCases;

        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        list<CaseComment> cclist = new list<CaseComment>();
        for(Integer i=0;i<2;i++){
            CaseComment newComment = new CaseComment();
            newComment.CommentBody = 'hellloo1';
            newComment.ParentId = newCase1.Id;
            cclist.add(newComment);
        }
        for(Integer i=0;i<2;i++){
            CaseComment newComment = new CaseComment();
            newComment.CommentBody = 'hellloo2';
            newComment.ParentId = newCase2.Id;
            cclist.add(newComment);
        }
        insert cclist;
        
        Case_Fulfilment__c cf1 = new Case_Fulfilment__c();
        cf1.Category__c = 'Remark';
        cf1.Message__c = 'Created successfully';
        cf1.Case__c = newCase1.Id;
        cf1.Status__c = 'Started';
        insert cf1;
        
        waiverTypes.add(newCase1.Problem_Type__c);
        waiverSubTypes.add(newCase1.Waiver_Sub_Type__c);
        
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
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB1.Id, Product2Id = NameChangeProd.Id,UnitPrice = 70, IsActive = true, Product_Credit_Value__c = 100);
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
        newWOLI.Product_Credit_Value__c = 100;
		insert newWOLI;
		system.debug('newWOLI:'+newWOLI);
        
		Service_Payment__c newSPay = new Service_Payment__c();
		newSPay.Case__c = newCase1.Id;
		newSPay.RecordTypeId = spRTId;
		newSPay.Payment_Due_Date__c = Date.today().addDays(-3);
		newSPay.Payment_Status__c = 'Pending';      
        newSPay.Payment_Type__c = '';
        newSpay.EMD_Number__c = '';
        newSpay.Total_Payable_credits__c = 100;
        newSpay.Work_Order__c = newWO.Id;
		insert newSPay;
		
		List<Asset> listAssets = new List<Asset>();
        Asset ass1 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId, AccountId = myAccount.Id, Active__c = True, Total_Acquired_Credits__c = 1000, Total_Consumed_Credits__c = 0 ); 
        listAssets.add(ass1);
        insert listAssets;
    }
    
    @isTest
    public static void CaseUpdation()
    {
        Set<String> eachCaseNums = new Set<String>();
        Set<String> eachSPNums = new Set<String>();
        Set<Id> eachIds = new Set<Id>();
        
        for(Case eachCase : [Select Id,CaseNumber from Case]){
            system.debug('each case no:**'+eachCase.CaseNumber);
            eachCaseNums.add(eachCase.CaseNumber);
            eachIds.add(eachCase.Id);
        }
        for(Service_Payment__c eachSP : [Select Id,Name,Case__c from Service_Payment__c]){
            eachSPNums.add(eachSP.Name);
        }
        system.debug('case nums**'+eachCaseNums);
        
        String json = '{'+
            '   \"serviceRequestUpdate\":['+
            '      {'+
            '         \"requestId\":\"12345abc\",'+
            '         \"requestNumber\":\"1234500\",'+
            '         \"correlationId\":\"C-001001001003\",'+
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Arun Rajendran\",'+
            '            \"agentPhone\":\"+61-423559795\",'+
            '            \"agentEmail\":\"arunrajendran@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"servicePayment\":{'+
            '            \"paymentId\":\"a28p00000003zxzAAA\",'+
            '            \"workOrderId\":\"0WOp00000004a3ZGAQ\",'+
            '            \"paymentType\":\"Card\",'+
            '            \"paymentStatus\":\"Paid\",'+
            '            \"paymentRemarks\":\"Payment Done successfully\",'+
            '            \"paymentReferenceNumber\":\"\",'+
            '            \"emdNumber\":\"0818209981826\",'+
            '            \"emdIssueDate\":\"2018-09-12\",'+
            '            \"emdIssueIata\":\"0239498\",'+
            '            \"receiptEmail\":\"rana.dhiraj@qantas.com.au\",'+
            '            \"paymentNumber\":\"INV-00000476\",'+
            '            \"paymentTimestamp\":\"2018-10-23 12:28:51\"'+
            '         },'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      },'+
            '      {'+
            '         \"requestId\":\"'+((new list<Id>(eachIds))[0])+'\",'+
            '         \"requestNumber\":\"'+((new list<String>(eachCaseNums))[0])+'\",'+
            '         \"correlationId\":\"C-001001001003\",'+
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Arun Rajendran\",'+
            '            \"agentPhone\":\"+61-423559795\",'+
            '            \"agentEmail\":\"arunrajendran@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"servicePayment\":{'+
            '            \"paymentId\":\"a28p00000003zxzAAA\",'+
            '            \"workOrderId\":\"0WOp00000004a3ZGAQ\",'+
            '            \"paymentType\":\"Card\",'+
            '            \"paymentStatus\":\"Paid\",'+
            '            \"paymentRemarks\":\"Payment Done successfully\",'+
            '            \"paymentReferenceNumber\":\"\",'+
            '            \"emdNumber\":\"0818209981826\",'+
            '            \"emdIssueDate\":\"2018-09-12\",'+
            '            \"emdIssueIata\":\"0239498\",'+
            '            \"receiptEmail\":\"rana.dhiraj@qantas.com.au\",'+
            '            \"paymentNumber\":\"'+((new list<String>(eachSPNums))[0])+'\",'+
            '            \"paymentTimestamp\":\"2018-10-23 12:28:51\"'+
            '         },'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      },'+
            '      {'+
            '         \"requestId\":\"'+((new list<Id>(eachIds))[1])+'\",'+
            '         \"requestNumber\":\"'+((new list<String>(eachCaseNums))[1])+'\",'+
            '         \"correlationId\":\"C-001001001002\",'+
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Ajay Bharathan\",'+
            '            \"agentPhone\":\"+61-469017227\",'+
            '            \"agentEmail\":\"ajay.bharathan@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      }'+
            '   ]'+
            '}';        
        
        QAC_ServiceReqCaseUpdationAPI myApi = QAC_ServiceReqCaseUpdationAPI.parse(json);
        system.debug(' @@ myapi @@ ' + myApi);
        QAC_ServiceReqCaseUpdationProcess_Test.restLogic(myApi,null);
        
        Test.startTest();
        QAC_ServiceReqCaseUpdationProcess.doServReqCaseUpdation();
        Test.stopTest();
    }
	
     @isTest	
	 public static void CaseUpdationForCredit()
    {
        Set<String> eachCaseNums = new Set<String>();
        Set<String> eachSPNums = new Set<String>();
		Set<String> eachSPIds = new Set<String>();
		Set<String> eachAsstNums = new Set<String>();
		Set<String> eachWOIds = new Set<String>();
        Set<Id> eachIds = new Set<Id>();
        Set<String> eachCorrIds = new Set<String>();
        
        for(Case eachCase : [Select Id,CaseNumber,External_System_Reference_Id__c from Case]){
            system.debug('each case no:**'+eachCase.CaseNumber);
            eachCaseNums.add(eachCase.CaseNumber);
            eachIds.add(eachCase.Id);
            eachCorrIds.add(eachCase.External_System_Reference_Id__c);
        }
        for(Service_Payment__c eachSP : [Select Id,Name,Case__c from Service_Payment__c]){
            eachSPNums.add(eachSP.Name);
            eachSPIds.add(eachSP.Id);
            
        }
        system.debug('case nums**'+eachCaseNums);
		
		for(WorkOrder eachWO : [Select Id from WorkOrder]){
         eachWOIds.add(eachWO.Id);			
		}
		
        String json = '{'+
            '   \"serviceRequestUpdate\":['+
            '      {'+
            '         \"requestId\":\"'+((new list<Id>(eachIds))[0])+'\",'+
            '         \"requestNumber\":\"'+((new list<String>(eachCaseNums))[0])+'\",'+
            '         \"correlationId\":\"'+((new list<String>(eachCorrIds))[0])+'\",'+  
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Arun Rajendran\",'+
            '            \"agentPhone\":\"+61-423559795\",'+
            '            \"agentEmail\":\"arunrajendran@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"servicePayment\":{'+
            '            \"paymentId\":\"'+((new list<String>(eachSPIds))[0])+'\",'+ 
            '            \"workOrderId\":\"'+((new list<String>(eachWOIds))[0])+'\",'+
            '            \"paymentType\":\"Credit\",'+
            '            \"paymentStatus\":\"Paid\",'+
            '            \"paymentRemarks\":\"Payment Done successfully\",'+
            '            \"paymentReferenceNumber\":\"\",'+
            '            \"emdNumber\":\"\",'+
            '            \"emdIssueDate\":\"2018-09-12\",'+
            '            \"emdIssueIata\":\"0239498\",'+
            '            \"receiptEmail\":\"rana.dhiraj@qantas.com.au\",'+
            '            \"paymentNumber\":\"'+((new list<String>(eachSPNums))[0])+'\",'+
            '            \"paymentTimestamp\":\"2018-10-23 12:28:51\"'+
            '         },'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      }'+
            '   ]'+
            '}';        
        
        QAC_ServiceReqCaseUpdationAPI myApi = QAC_ServiceReqCaseUpdationAPI.parse(json);
        system.debug(' @@ myapi @@ ' + myApi);
        QAC_ServiceReqCaseUpdationProcess_Test.restLogic(myApi,null);
        
        Test.startTest();
        QAC_ServiceReqCaseUpdationProcess.doServReqCaseUpdation();
        Test.stopTest();
    }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
            QAC_ServiceReqCaseUpdationProcess_Test.restLogic(null,myExcepJson);
            
            Test.startTest();
            QAC_ServiceReqCaseUpdationProcess.doServReqCaseUpdation();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void restLogic(QAC_ServiceReqCaseUpdationAPI theApi, String theExcepJson){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QAC_ServReqCaseUpdation/';  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}