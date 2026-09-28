//Jira: CRM-7264: Test class for FreightCompareBotVariables
@isTest
public with sharing class FreightCompareBotVariablesTest 
{
  public static testmethod void testGetCounts()
    {
        List<Integer> listcount=new List<Integer>();
        Integer count=0;
        listcount.add(count);
        
        test.starttest();
          FreightCompareBotVariables.GetCounts(listcount);
        test.stoptest();
    }
}