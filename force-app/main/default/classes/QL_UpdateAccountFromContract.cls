/**
 * @desc:this class is being created to separate the Account fields update after contract generation to reduce SOQL consumption
 * @author: Navpreet Kaur
 * @test Class: QL_UpdateAccountFromContractTest
 * @jira ticket: CRM-9795
 * @log
 * 		created date: 23/06/2025 Navpreet Kaur
 */
public class QL_UpdateAccountFromContract implements Queueable{
List<Account> accountToUpdate=new List<Account>();
public QL_UpdateAccountFromContract(List<account> getAcctsToUpdate)
{
    if(getAcctsToUpdate!=null)
    this.accountToUpdate.addall(getAcctsToUpdate);
	system.debug('here is the size of accountstoupdate'+accountToUpdate.size());
}
public void execute(QueueableContext context) {
    try{
        if(accountToUpdate!=null && accountToUpdate.size()>0)
        {
            update accountToUpdate;
        }
    }
    catch(exception e)
    {
        system.debug('Exception occurred while updating accounts'+e.getmessage());
		CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QL_UpdateAccountFromContract', 'QL_UpdateAccountFromContract', 
                                    'execute', String.valueOf(''), String.valueOf(''),false,'', e);
    }
    }
}