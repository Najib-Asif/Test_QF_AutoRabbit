/*********************************************************************************
Name         : QCC_LogUtilityHelperTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 October 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_LogUtilityHelper
*********************************************************************************/
@isTest
public class QCC_LogUtilityHelperTest {
    static testmethod void test1(){
        Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(
            'Sample Module',
            'Sample ClassName',
            'Sample MethodName',
            '', '', false, null, null, ''
        );
        
        QCC_LogUtilityHelper.createLogRecord(logRecord);
    }
    
    static testmethod void test2(){
        Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(
            'Sample Module',
            'Sample ClassName',
            'Sample MethodName',
            '', '', false, null, null, ''
        );
        
        List<Log__c> logRecords = new List<Log__c>();
        logRecords.add(logRecord);
        
        QCC_LogUtilityHelper.createLogRecords(logRecords);
    }
}