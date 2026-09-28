/*Jira-> FCRM-854- US Invoicing - auto create invoice case
Description-> Test Class for batchClass_USInvoicesCases
Developer-> Navpreet Kaur
Creation Date-> Feb 2022
*/
@isTest
public class batchClass_USInvoicesCasesTest 
{
	static testMethod void batchTheUSInvoicesTest()
    {
        try
        {
        List<Airport_Code__c> listAirCodes=new List<Airport_Code__c>();
        List<Contact> listContacts=new List<contact>();
        List<Account> listAccounts=new List<Account>();
        List<AccountContactRelation> listACRs=new List<AccountContactRelation>(); 
        ID accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        string headRow='Origin,Agent Name,Agent code,Air waybill num,Org Total Charges,Org prepaid weight charge,Adj Prepaid weight charge,Comments,Agent Contact Name,Agent Contact Tel,Agent Contact Email \n';
		string rowRec1='ATL,Vikrant Tajane,0110008,08153451403,6927.21,952.24,245.23,Please review the attached with rated booking,Vikrant Tajane,281-233-9444,Vikrant.Tajane@qantas.com.au \n';
		string rowRec2='GRU,Kim Wethmar,0110090,08153451467,5927.21,952.24,245.23,Please review the attached with rated booking,Kim Wethmar,281-233-9444,Kim.Wethmar@qantas.com.au \n';		
		string 	finalstr = headRow+rowRec1+rowRec2;
		blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'FreightInvoicingUS_'+system.today().day()+'_'+system.today().month()+'_'+system.today().year();
       
        Folder fold=[select id from folder where DeveloperName ='Freight_Invoicing_Process_US'];
        List<Trigger_Status__c> getListStatus=new List<Trigger_Status__c>(); 
      	getListStatus.addAll(freightUtilToBypassTrgCustSett.createAccountTriggerSettingFalse());
        getListStatus.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
        insert getListStatus;
            
        Document docFile=new document();
        docFile.Body=csvBlob;
        docFile.DeveloperName=csvname;
        docFile.Name=csvname;
        docFile.FolderId=fold.Id;
        docFile.type='csv';
        docFile.AuthorId=UserInfo.getUserId();
        insert docFile;
        
        Airport_Code__c  mdtRec=new Airport_Code__c (Name='ATL',QF_Freight_Presence__c=true);
        Airport_Code__c  mdtRec2=new Airport_Code__c (Name='GRU',QF_Freight_Presence__c=true);
        listAirCodes.add(mdtRec);
        listAirCodes.add(mdtRec2);
            
        if(listAirCodes!=null && listAirCodes.size()>0)
        {
             insert listAirCodes;
        }   

        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.billingcountry='US';
        accountRecord.Freight_Unique_Identifier__c='0110008';
        accountRecord.Email__c='Vikrant.Tajane@qantas.com.au';    
        listAccounts.add(accountRecord);
        
        Account accountRecord2 = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord2.RecordTypeId = accountRecordTypeId;
        accountRecord2.billingcountry='US';
        accountRecord2.Freight_Unique_Identifier__c='0110090';
        accountRecord.Email__c='Kim.Wethmar@qantas.com.au';  
        listAccounts.add(accountRecord2);
		
        if(listAccounts!=null && listAccounts.size()>0)
        {
            insert listAccounts;
        }

        
        Contact cont=new Contact(recordtypeid=contactRecordTypeId,accountid=accountRecord.id,firstname='Vikrant',lastname='Tajane',email='Vikrant.Tajane@qantas.com.au',Job_Title__c='CEO',Function__c='Other',Business_Types__c='Agency',Job_Role__c='Other');
		Contact cont2=new Contact(recordtypeid=contactRecordTypeId,accountid=accountRecord2.id,firstname='Kim',lastname='Wethmar',email='Kim.Wethmar@qantas.com.au',Job_Title__c='CEO',Function__c='Other',Business_Types__c='Agency',Job_Role__c='Other');
		listContacts.add(cont);
        listContacts.add(cont2);
        
        if(listContacts!=null && listContacts.size()>0)
        {
            insert listContacts;
        }
	
        test.startTest();
        	database.executebatch(new batchClass_USInvoicesCases(),300);
        test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception Occured'+e.getMessage()+' '+e.getCause()+' '+e.getLineNumber());
        }
    }
}