/*----------------------------------------------------------------------------------------------------------------------
Author:        
Company:       
Date Implemented: 
Description:  CRM5823: This class to check the current time is within Business Hours for Fright Bot
History:
======================================================================================================================
Name                    Jira        			Description                                                 Tag
======================================================================================================================
Lerry Cabanding         CRM-12990   			Code Security Remediation
-------------------------------------------------------------------------------------------------------------------------*/
public with sharing class FreightCheckWithinBusinessHours {
    @InvocableMethod(label = 'Within Business Hours Check')
    public static List<Boolean> makeGetCallout(List<String> Name) {
        String BHName= String.valueOf(+Name[0]);
        // Get Business hours based on name, input from bot
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name= :BHName WITH SYSTEM_MODE];
        // Create Datetime with current date/time in local time zone
        Datetime targetTime = Datetime.now();
        // Find whether the time is within business hours
        Boolean isWithin= BusinessHours.isWithin(bh.id, targetTime);
        return new List<Boolean>{isWithin};
        
	}
}