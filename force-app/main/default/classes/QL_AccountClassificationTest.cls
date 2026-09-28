@isTest
public class QL_AccountClassificationTest {
	@isTest
    static void AccountClassificationTileTest()
    {
        Test.startTest();
        List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();
        QL_AccountClassification.AccountClassificationTile(Acclist[0].Id);
        Test.stopTest();
    }
}