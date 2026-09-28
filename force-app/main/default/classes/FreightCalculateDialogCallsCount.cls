/*************************************************************************************************
Author: Navpreet Kaur
Last Modified By: Gokulakannan Peroumal
Description: This class calculates and returns the count of chat transfer dialog calls 
Test Class:  FreightCalculateDialogCallsCountTest 

History:
CRM-7264 - Class created by Navpreet
CRM-9778 - Class updated due to summer'25 release update
*************************************************************************************************/
public with sharing class FreightCalculateDialogCallsCount 
{
    @InvocableMethod(label = 'Count dialog calls')
    public static List<Integer> GetCounts(List<Integer> getInitCount) 
    {
        Integer dialogCounts;
        
        if(getInitCount == null || getInitCount[0]==null )
        {
            dialogCounts=0;      
        }
        else
        {
            dialogCounts= getInitCount[0];           
        }
        
        dialogCounts=dialogCounts+1;
        //CRM-9778
        getInitCount[0] =dialogCounts;
        
        return getInitCount ;
    }
}