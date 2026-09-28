//Jira: CRM-5823 & CRM-5916
/*----------------------------------------------------------------------------------------------------------------------
Author:        
Company:       
Date Implemented: 
Description:  CRM-5823: This class to check the current time is within Business Hours for Fright Bot
History:
======================================================================================================================
Name                    Jira        			Description                                                 Tag
======================================================================================================================
Lerry Cabanding         CRM-12990   			Code Security Remediation
-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class FreightCheckWithinBusinessHoursTest {
	@isTest
    public static void test1 () {
        Test.startTest();
        FreightCheckWithinBusinessHours.makeGetCallout(new List<String>{'Qantas Agency Connect Business Hours'});
        test.stopTest();
    }
    
}