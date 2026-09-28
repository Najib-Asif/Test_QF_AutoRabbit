/**********************************************************************************************************************************
 
    Created Date: 23/05/17
 
    Description: Roll up of CL contacts of an account.
  
    Versión:
    V1.0 - 23/05/17 - Initial version [FO]
 
**********************************************************************************************************************************/

public class RollupofCLcontactsHandler {

        public static void CountNumofContacts(List < Contact > newList) {
            Set<ID> acctIds = new Set<ID>();
            Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
  try {
       // get list of accounts

    for (Contact con : newList) {
            acctIds.add(con.AccountId);
    }
   
  /*  Map<ID, Contact> contactsForAccounts = new Map<ID, Contact>([select Id
                                                            ,AccountId
                                                            from Contact
                                                            where AccountId in :acctIds and Profile_CL_Flag__c=TRUE]);*/
                                                            

   /* Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id
                                                                 ,Chairmans_Lounge__c
                                                                  from Account
                                                                  where Id in :acctIds]);*/
                                                                  
                                                                  
        list<Account> acctsToUpdate = [select Id
                                                ,Chairmans_Lounge__c
                                                ,(select Id from Contacts where Profile_CL_Flag__c=TRUE AND RecordTypeId = :ContRecordTypeId )
                                                from Account
                                                where Id in :acctIds];                                                        
                                                                
    for (Account acct : acctsToUpdate) {
        /*Set<ID> conIds = new Set<ID>();
        for (Contact con : contactsForAccounts.values()) {
            if (con.AccountId == acct.Id)
                conIds.add(con.Id);
        }*/
        list<Contact> Allcons  = new list<Contact>();
        Allcons = acct.Contacts;
        if (acct.Chairmans_Lounge__c != Allcons.size())
            acct.Chairmans_Lounge__c = Allcons.size();
    }
    If(acctsToUpdate.size()>0)
    update acctsToUpdate;

  }
  
  catch(Exception e){
        System.debug('Error Occured From RollupofCLcontacts  Handler: '+e.getMessage());
    }
}
}