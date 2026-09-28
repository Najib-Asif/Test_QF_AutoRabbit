/*----------------------------------------------------------------------------------------------------------------------
Author:        Gnanavelu
Description:   Test class for QL_AquireAmexsection
************************************************************************************************
History
************************************************************************************************
19-July-2018      Gnanavelu               Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QL_AquireAmexsectionTest 
{
	@isTest
    static void AquireAmexSectionTest()
    {
        Test.startTest();
        List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();
        QL_AquireAmexsection.AquireAmexSection(Acclist[0].Id);
        Test.stopTest();
    }
}