/***********************************************************************************************************************************

Description: Test class for the apex class iDealPageRedirectExtn

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2828    Test class for the apex class iDealPageRedirectExtn                  T01
                                    
Created Date    : 11/06/17 (DD/MM/YYYY)
Modified By : Hari B, 27-Mar-2026
              Remediated test class failures. Added setupTestData(), and updated TestIDealPageL() method.                                       
**********************************************************************************************************************************/

@isTest
public class iDealPageRedirectExtntest {
     @testSetup static void setupTestData() {
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        Test.stopTest();
        Account testAccount = new Account(Name='Test Company Name123');
        insert testAccount;
     }

    @isTest
    public static  void TestIDealPageL(){        
        TEST.startTest();
        PageReference pageRef = Page.iDealPageRedirect;
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',testAccount.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        integer count=0;
        iDealPageRedirectExtn testExtn = new iDealPageRedirectExtn(sc);
        
        TEST.stopTest();
    }
}