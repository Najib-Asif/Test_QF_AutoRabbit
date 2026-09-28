/*
Desc: Test class for QL_FlowHelperToScheduleBatch

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
*/
@isTest
public class QL_FlowHelperToScheduleBatchTest 
{
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    public testmethod static void testdecideForBatchCall()
    {
        test.startTest();
        
        List<Id> listAcct=new List<Id>();
        List<date> listdate=new list<date>();
        Date getdate=system.today().addDays(-5);
        listdate.add(getdate);
        
        Account createAcct=new Account(Name='Test Accounr',Quip__c='http:\\www.quip.com',recordtypeid='01290000001IIN9');
        insert createAcct;
        listAcct.add(createAcct.id);
        
        //QL_FlowHelperToScheduleBatch.decideForBatchCall(listAcct);
        test.stopTest();
    }
}