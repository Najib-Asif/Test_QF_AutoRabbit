/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QAC_localPNRCases
*/
@isTest
public class QAC_localPNRCases_Test 
{
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
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
        for(Integer i=0;i<3;i++){
            Case caseWoPay = new Case(External_System_Reference_Id__c = 'C-002001001001',Origin = 'QAC Website',RecordTypeId = caseRTId,Status = 'Open',
                                      Type = 'Commercial Waiver (BART)',Problem_Type__c = 'Name Correction',Waiver_Sub_Type__c = 'Ticketed - Qantas Operated and Marketed',
                                      Reason_for_Waiver__c = 'Typing Error in FirstName',Request_Reason_Sub_Type__c='Correction more than three characters',
                                      Subject = 'test'+i,Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                      AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                      PNR_number__c = 'TAMSI7',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'Domestic'); 
            
            allCases.add(caseWoPay);
        }
        insert allCases;
    }
    @isTest
    public static void localCases()
    {
        Set<String> eachCaseNums = new Set<String>();
        for(Case eachCase : [Select Id,CaseNumber from Case]){
            eachCaseNums.add(eachCase.CaseNumber);
        }
        
        Test.startTest();
            QAC_localPNRCases.getAllPNRCases('TAMSI7',((new list<String>(eachCaseNums))[0]));
            QAC_PNRSearch_Controller.getLocalSearchCases('TAMSI7');
        Test.stopTest();
    }
}