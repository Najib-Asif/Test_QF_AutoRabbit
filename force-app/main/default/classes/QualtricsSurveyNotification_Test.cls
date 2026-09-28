/***********************************************************************************************************************************

Description: Test class for Qualtrics Survey notification to the end customer. 

History:
======================================================================================================================
Name                          Description                                           Tag
======================================================================================================================
Yuvaraj MV                    Qualtrics Survey notification to the end customer     T01
Created Date    : 29/04/19 (DD/MM/YYYY)

MainClass       : QualtricsSurveyNotification
**********************************************************************************************************************************/
@isTest
public class QualtricsSurveyNotification_Test 
{
    /*----------------------------------------------------------------------------------------------      
    Method Name:        dataSetup
    Description:        Datasetup for QantasConfigdata
    ----------------------------------------------------------------------------------------------*/
    @testsetup
    public static void dataSetup()
    {   
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd;
        
      /*  Trigger_Status__c caseQualtricsSurvey = new Trigger_Status__c();
        caseQualtricsSurvey.Name = 'QualtricsSurvey';
        caseQualtricsSurvey.Active__c = true;
        insert caseQualtricsSurvey; */
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
        
        insert lstConfigData;

    }
    //Insert caserecord
    public static testmethod void testQualtricsSurvey()
    {  
        id cccComplaint = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
        
        Trigger_Status__c  tgrStatus = new Trigger_Status__c();
        tgrStatus.Name = 'QualtricsSurvey';
        tgrStatus.Active__c = true;
        insert tgrStatus;
        
        List<case> caseList = new List<case>();
        
        case caseExcl = new case();
        caseExcl.RecordTypeId = cccComplaint;
        caseExcl.Group__c = 'Lounges';
        caseExcl.Category__c = 'Facilities/Signage';
        caseExcl.Sub_Category__c = 'Specific Needs';
        caseExcl.Type = 'Complaint';
        caseExcl.Status = 'Received';
        caseExcl.Origin = 'Email';
        caseExcl.Received_Date__c = datetime.now();
        caseExcl.Description = 'Testing Qualtrics';
        caseExcl.First_Name__c = 'Qualtricsname1';
        caseExcl.Last_Name__c = 'lastname1';
        caseExcl.Contact_Email__c = 'axbc1@cmgc.com';
        caseList.add(caseExcl);
        
        case caseIncl = new case();
        caseIncl.RecordTypeId = cccComplaint;
        caseIncl.Group__c = 'Lounges';
        caseIncl.Category__c = 'Staff Assistance';
        caseIncl.Sub_Category__c = 'Wait times';
        caseIncl.Type = 'Complaint';
        caseIncl.Status = 'Received';
        caseIncl.Origin = 'Email';
        caseIncl.Received_Date__c = datetime.now();
        caseIncl.Description = 'Testing Qualtrics';
        caseIncl.First_Name__c = 'Qualtricsname2';
        caseIncl.Last_Name__c = 'lastname2';
        caseIncl.Contact_Email__c = 'axbc2@cmgc.com';
        caseList.add(caseIncl);
        
        Test.startTest();
        try{
        insert caseList;
        }
        catch(Exception ex){
          system.assert(ex.getTypeName() == 'System.DmlException', 'Exception Occured');   
        }
        Test.stopTest();
        system.assert(caseList[0].Id != Null, 'Case is not Inserted');
    }
    
    //ExceptionHandling
    public static testmethod void testException()
    {   
        id cccMedical = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Medical').getRecordTypeId(); 

            
            List<case> caseList = new List<case>();
            
            case caseExcl = new case();
            caseExcl.RecordTypeId = cccMedical;
            caseExcl.Group__c = 'Lounges';
            caseExcl.Category__c = 'Facilities/Signage';
            caseExcl.Sub_Category__c = 'Specific Needs';
            caseExcl.Type = 'Complaint';
            caseExcl.Status = 'Received';
            caseExcl.Origin = 'Email';
            caseExcl.Received_Date__c = datetime.now();
            caseExcl.Description = 'Testing Qualtrics';
            caseExcl.First_Name__c = 'Qualtricsname1';
            caseExcl.Last_Name__c = 'lastname1';
            caseExcl.Contact_Email__c = 'axbc1@cmgc.com';
            
            caseList.add(caseExcl); 
            Test.startTest();
            try{
                insert caseList;
            }
            catch(Exception ex){
               system.assert(ex.getTypeName() == 'System.DmlException', 'Exception Occured');
            }
            Test.stopTest();

    }
}