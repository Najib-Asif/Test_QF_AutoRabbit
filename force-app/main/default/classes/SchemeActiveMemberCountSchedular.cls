/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir
Company:       Capgemini
Description:   Https callout to fetch the Scheme Active Member Count received from LSL
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
25-AUG-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/


global class SchemeActiveMemberCountSchedular implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        FetchSchemeMemberCountAPI.getActiveMemberCount();
    }
}