//Jira: CRM-7264: Test class for FreightCalculateDialogCallsCount
@isTest
public with sharing class FreightCalculateDialogCallsCountTest 
{
  public static testmethod void testGetCounts()
    {
        List<Integer> listcount=new List<Integer>();
        Integer count=0;
        listcount.add(count);
        
        test.starttest();
          FreightCalculateDialogCallsCount.GetCounts(listcount);
        test.stoptest();
    }
}