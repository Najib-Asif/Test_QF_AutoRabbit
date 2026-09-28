@isTest
public class QCC_SpecialLogicUtilityHelperTest {
    static testMethod void QCC_SpecialLogicUtilityHelperTest(){
        String moduleName = 'Quarterly Health Check Call';
        QCC_SOQL_Setting__mdt soqlSetting;
        
        soqlSetting = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c
                FROM QCC_SOQL_Setting__mdt 
                WHERE Module_Name__c =: moduleName
                LIMIT 1];
         
        //String modulePortswithCurfew =''
        test.startTest();
        QCC_SpecialLogicUtilityHelper.generateAdditionalFilterForDynamicSOQL(soqlSetting.Module_Name__c, soqlSetting.Query_String__c);
        QCC_SpecialLogicUtilityHelper.generateFilterForDynamicSOQL(soqlSetting.Module_Name__c, soqlSetting.Query_String__c);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic(soqlSetting.Module_Name__c, soqlSetting.Query_String__c, null , null);
        QCC_SpecialLogicUtilityHelper.replaceCommaWithSemicolon('Quarterly Health Check Call');
        QCC_SpecialLogicUtilityHelper.getQantasConfigValue('Quarterly Health Check Call');
        //QCC_SpecialLogicUtilityHelper.removeLeadingZero('String');
        QCC_SpecialLogicUtilityHelper.getCaseRecordTypeIDByDeveloperName('QCC_Specific_Needs');
        QCC_SpecialLogicUtilityHelper.addDaysToToday('1');
		QCC_SpecialLogicUtilityHelper.generateFilterWhenModuleIsQantasHostReportDisruption('Event__r.ScheduledDepDate__c', '1');
        QCC_SpecialLogicUtilityHelper.convertDateToDateTimeString('2019-11-12');
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('effectiveTierToFrequentFlyerTier', 'Frequent_Flyer_Tier__c', 'Platinum One', null);

        String moduleName2 = 'Qantas Host Report Disruption';
        QCC_SOQL_Setting__mdt soqlSetting2;

        soqlSetting2 = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c
                FROM QCC_SOQL_Setting__mdt
                WHERE Module_Name__c =: moduleName2
                LIMIT 1];

        QCC_SpecialLogicUtilityHelper.generateFilterForDynamicSOQL(soqlSetting2.Module_Name__c, soqlSetting2.Query_String__c);

        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('removeCurrentValue', 'Frequent_Flyer_Tier__c', 'Platinum One', null);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('replaceCommaWithSemicolon', 'Frequent_Flyer_Tier__c', 'Platinum One', null);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('removeLeadingZero', 'Frequent_Flyer_Tier__c', 'Platinum One', null);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('convertDateToDateTimeString', 'QCC_Recent_Activity_Date__c', '2019-11-12', null);

 		Map<String, List<sObject>> otherRefDataNameMapping = new Map<String, List<sObject>>();

        List<QCC_Curfew_Port__c> curfewPortRecords = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Curfew_Port__c', 'QCC_TestDataCurfewPort');
        insert curfewPortRecords;

        for (QCC_Curfew_Port__c referenceRec : curfewPortRecords) {
            String keyName = String.valueOf(referenceRec.get('Name'));
            List<sObject> referenceList_Temp = (otherRefDataNameMapping.containskey(keyName)) ? otherRefDataNameMapping.get(keyName) : new List<sObject>();
            referenceList_Temp.add(referenceRec);
            otherRefDataNameMapping.put(keyName,referenceList_Temp);
        }

        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('checkPortsWithCurfew', 'QCC_TECH_Port_Departure_Time__c', 'SYD-12:00', otherRefDataNameMapping);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('assignCaseToQueue','QCC_TECH_Port_Departure_Time__c', 'SYD-12:00', otherRefDataNameMapping);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('getQantasConfigValue','QCC_TECH_Port_Departure_Time__c', 'SYD-12:00', otherRefDataNameMapping);
        QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic('getContactByFrequentFlyerNumber','QCC_TECH_Port_Departure_Time__c', 'SYD-12:00', otherRefDataNameMapping);
        QCC_SpecialLogicUtilityHelper.getCaseRecordTypeIDByDeveloperName('QCC_Disruption');

        test.stopTest();
                                                                  
    }
}