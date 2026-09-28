/***********************************************************************************************************************************

History:
======================================================================================================================
Name                          Description                                           Tag
======================================================================================================================
Yuvaraj MV           Test Class for clsCaseFieldUpdatesHelper                       T01

Created Date    : 09/08/18 (DD/MM/YYYY)

TestClass       :TestclsCaseFieldUpdatesHelper
**********************************************************************************************************************************/


@isTest
public class TestclsCaseFieldUpdatesHelper{

    @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
         TestUtilityDataClassQantas.enableTriggers();

        /*Integration_User_Tradesite__c testSetting = new Integration_User_Tradesite__c();
        testSetting.name = 'tradeSiteUser';
        testSetting.Username__c = 'sf1';
        testSetting.Password__c = 'pas';
        testSetting.Endpoint__c = 'endpo';
        testSetting.NameChangeStartNumber__c = 1;
        testSetting.NameChangeEndNumber__c = 9;
        testSetting.NameChangeLastNumber__c = 0;
        testSetting.ApprovedText__c = 'Appr';
        testSetting.RejectedText__c = 'Reje';
        insert testSetting;*/
        
         QIC_AutoNumber__c qicInfo = new QIC_AutoNumber__c();
        
        qicInfo.Name='Fee Waiver Request';
        qicInfo.CaseType__c='Blanket Waiver';
        qicInfo.LastNumber__c=799998;
        qicInfo.StartNumber__c=400000;
        qicInfo.EndNumber__c=799999;
        qicInfo.ClosedStatus__c='Closed - Approved';
        qicInfo.Blanket_Waiver__c='Master Operational Waiver';
        qicInfo.Record_Type__c='Service Request';
        insert qicInfo;
        
        ID agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Account myAccount   = new Account(Name = 'Test Account111', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566453',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9999998');
        insert myAccount;
       
        Account myAccount1  = new Account(Name = 'Test Account112', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566454',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9999999');
        
        insert myAccount1;
        
        
        String blanketWaiverType = 'Blanket Waiver';
        ID QICRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        ID blanketWaiverRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master Operational Waiver').getRecordTypeId();
        ID caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();  
        
       
        Case newCase = new Case(RecordTypeId = blanketWaiverRecordTypeId,Type = 'Operational Waiver',Status = 'Open',
                                Subject = 'to be decided',Description = 'some desc',Blanket_Waiver_Type__c = 'OP-Change Fee/ADCOL',
                                AccountId = myAccount.Id,Authority_Number__c=null,Authority_Status__c = 'Auto Approved',
                                PNR_number__c = '999998',Old_PNR_Number__c = '121512',Passenger_Name__c = 'TestUser',Regions__c = 'Africa',
                                Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic');   
        insert newCase;
        
        Case newCase2 = new Case(RecordTypeId = QICRecordTypeId,Consultant_Email__c = 'test@test1.com',Consultant_Phone__c = '28213812',
                                Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Credit',Status = 'Open',
                                Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                AccountId = myAccount1.Id,Consultants_Name__c = 'abcd',Agency_Code__c='4364557',
                                PNR_number__c = '999999',Old_PNR_Number__c = '121513',Passenger_Name__c = 'TestUser',Regions__c = 'DOM',
                                Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic');   
        insert newCase2;
        
        insert new Trigger_Status__c(name = 'AccountTeam',Active__c = true); 
        insert new Trigger_Status__c(name = 'trgCaseFieldUpdates',Active__c = true);
        insert new Trigger_Status__c(name = 'trgTradeSiteResponses',Active__c = false);
          
    }
    
    public static testMethod void testAuthorityNumberforblanketWaiverRecordTypeId()
    {   
                Test.startTest();

        Account accObj =  [Select Id,IATA_Number__c from Account where IATA_Number__c = '9999998'];
        
        QIC_AutoNumber__c qicInfo = QIC_AutoNumber__c.getValues('Fee Waiver Request'); 
        
        Case case1 = [select RecordTypeId,Type,Status,Authority_Number__c,Authority_Status__c,Regions__c From Case 
                          where accountid=:accObj.id];
          
            list<case> cases = new list<Case>();
            cases.add(case1);
        
            clsCaseFieldUpdatesHelper.generateAuthorityNumberNew(cases);
            Test.stopTest();
            
            //To satisfy line - 59, 69 in clsCaseFieldUpdatesHelper
            qicInfo.LastNumber__c=Decimal.valueOf(case1.Authority_Number__c);
            qicInfo.EndNumber__c=Decimal.valueOf(case1.Authority_Number__c)+1;
            update qicInfo;        
    }
    public static testMethod void testAuthorityNumberforQICRecordTypeId()
    {
                    Test.startTest();

         Account accObj1 =  [Select Id,IATA_Number__c from Account where IATA_Number__c = '9999999'];
         Case case2 = [select RecordTypeId,Type,Status,Authority_Number__c,Authority_Status__c,Regions__c From Case 
                          where accountid=:accObj1.id];
            
            list<case> cases1 = new list<Case>();
            cases1.add(case2);
               
            clsCaseFieldUpdatesHelper.generateAuthorityNumberNew(cases1);
            Test.stopTest();
    }
    
    public static Testmethod void testUpdateAccountRequestPending()
    {
            Test.startTest();

        string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        TestUtilityDataClassQantas.enableTriggers();
        
         Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557', QAC_Request_Pending__c=false);
        
        insert acc;
        insert new Trigger_Status__c(name = 'trgTradeSiteResponses',Active__c = true);

        Case objCase=new Case();

        
        List<Case> caseList = new List<Case>();
        Case toInsertAccountMaintCase  = new Case();
        
        toInsertAccountMaintCase.Subject = 'Agency (' + acc.IATA_Number__c + ') - Primary Details Update';
        toInsertAccountMaintCase.AccountId = acc.Id;
        toInsertAccountMaintCase.RecordTypeId = caseRecordTypeId;
        toInsertAccountMaintCase.Description  = 'ABN - ' + '\r\n Old Value - ' + acc.ABN_Tax_Reference__c + '\r\n New Value - ';
        toInsertAccountMaintCase.Origin    = 'QAC Website';
        toInsertAccountMaintCase.Type    = 'Agency Account';
        toInsertAccountMaintCase.Sub_Type_1__c = 'Account Update'; 
        
        caseList.add(toInsertAccountMaintCase);
        insert caseList;
        
                
        List<Case> lstCases = new List<Case>();
       for(Case eachCase : caseList)
        {
            objCase.id = eachCase.id;
            objCase.Status = 'Closed';
            lstCases.add(objCase);
        }
        update lstCases;
        
        
        
        Test.stopTest();
        
    }
}