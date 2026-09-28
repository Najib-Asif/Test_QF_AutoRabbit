/*********************************************************************************
Name         : QCC_SendQantasReportToSPSchedulableTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : January 2, 2020
Usages       : This will handle the test class and code coverage of apex class below
                - QCC_SendQantasReportToSPSchedulable
*********************************************************************************/
@isTest
public class QCC_SendQantasReportToSPSchedulableTest {

    @isTest
    static void test(){
        Test.startTest();
        
        String jobName = 'QCC_SendQantasReportToSPSchedulable Test';
        String cronExp = '0 0 0 ? * * 2020/1'; 
        String moduleName = 'Send Qantas Host Report';
        QCC_SendQantasReportToSPSchedulable schedulable = new QCC_SendQantasReportToSPSchedulable(moduleName);
		
        
        System.schedule(jobName, cronExp, schedulable);
        
        Test.stopTest();
    }
    
    @isTest
    static void exceptionCheck(){
        Test.startTest();
        
        String jobName = 'QCC_SendQantasReportToSPSchedulable Test';
        String cronExp = '0 0 0 ? * * 2020/1'; 
        String moduleName = 'Send Qantas Host Reprt';
        QCC_SendQantasReportToSPSchedulable schedulable = new QCC_SendQantasReportToSPSchedulable(moduleName);
		
        
        System.schedule(jobName, cronExp, schedulable);
        
        Test.stopTest();
    }


}