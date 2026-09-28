/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated acrPrimary() method.
-----------------------------------------------------------------------------------------------------------------------*/
@IsTest
public class QAC_ACRPrimaryContactUpdateTest {
    
    @testSetup
    public static void acrPrimary(){
        //TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
		String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.name='ACRPrimaryContact';
        ts.Active__c=true;
        insert ts;
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(RecordTypeId=accRTId,Name='Agency Account1');
        Account acc2 = new Account(RecordTypeId=accRTId,Name='Agency Account2');
        accList.add(acc1);
        accList.add(acc2);
        
        insert accList;
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact(FirstName='Fname1', LastName='testxby',Email='testxby@gmail.com',MobilePhone='9999256123',verification_number__c='1234567890',QAC_Contact__c='Yes',
                                  accountid=accList[0].Id,RecordTypeId = conRTId);
        Contact con2 = new Contact(FirstName='Fname2', LastName='Lname2',Email='testxby@gmail.com',MobilePhone='9999256123',verification_number__c='1234567788',QAC_Contact__c='Yes',
                                  accountid=accList[1].Id,RecordTypeId = conRTId);
        conList.add(con1);
        conList.add(con2);
        insert conList;
        
    }
    @isTest
    Public static void acrCreate(){
        
        String conId =[Select id from Contact where FirstName='Fname2'].id;
        String accId =[Select id from Account where name='Agency Account1'].id;
        String acrId=[Select id from AccountContactRelation where accountid=:accId][0].Id;
        AccountContactRelation acr = new AccountContactRelation();
        acr.id=acrId;
        acr.Primary_Contact__c=true;
        update acr;
        AccountContactRelation acrInsert = new AccountContactRelation();
        acrInsert.contactId=conId;
        acrInsert.accountId=accId;
        acrInsert.Primary_Contact__c=true;
        try{
        insert acrInsert;
        }Catch(Exception e){}
    }

}