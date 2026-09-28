@isTest
public class QAC_caseFulfilmentHandler_Test {
    
    @IsTest
    public static void caseFulfilmentCreation() {
        
        system.debug('inside ff test**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;
        
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
        list<Case> newCases = new list<Case>();
        Case newCase0 = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                 Type = 'Commercial Waiver (BART)',Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                 Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                 Status = 'Open',Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                 AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                 PNR_number__c = '454545',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
        
        Case newCase1 = new Case(External_System_Reference_Id__c = 'C-002002002003',ParentId = newCase0.Id,Origin = 'QAC Website',
                                 Type = 'Operational Waiver Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Reissue',
                                 Status = 'Open',RecordTypeId = caseRTId,Subject = 'to be decided',Description = 'some desc',
                                 Justification__c = 'must give',Authority_Status__c = 'Approved',AccountId = myAccount.Id,Consultants_Name__c = 'abcd',
                                 Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',PNR_number__c = '454546',Old_PNR_Number__c = '1021512',
                                 Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic');   
        
        waiverTypes.add(newCase0.Problem_Type__c);
        waiverTypes.add(newCase1.Problem_Type__c);
        waiverSubTypes.add(newCase0.Waiver_Sub_Type__c);
        waiverSubTypes.add(newCase1.Waiver_Sub_Type__c);
        newCases.add(newCase0);
        newCases.add(newCase1);
        system.debug('newCases**'+newCases);
        
        list<QAC_Fulfillment_Status__mdt> FFmdt = [SELECT MasterLabel,DeveloperName,Fulfillment_Message__c,Fulfillment_Status__c,
                                                   Sequence_1__c,Sequence_2__c,Sequence_3__c,Sequence_4__c,
                                                   Sequence_5__c,Sequence_6__c,Sequence_7__c,Sequence_8__c 
                                                   from QAC_Fulfillment_Status__mdt 
                                                   where Waiver_Type__c IN: waiverTypes AND Waiver_Sub_Type__c IN: waiverSubTypes];
        system.debug('ff mdt**'+FFmdt);
        
        Test.startTest();
        insert newCases;
        //QAC_caseFulfilmentHandler.autoCreateFulfillmentRecords(newCases);
        Test.stopTest();
    }
}