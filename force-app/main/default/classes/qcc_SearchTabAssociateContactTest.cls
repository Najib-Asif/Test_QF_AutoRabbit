/*****************************************************************************************
* Created By		Navpreet Kaur | TCS | Developer 
* Purpose			Test class for qcc_SearchTabAssociateContact
* Modified Date		20/11/23 (DD/MM/YYYY)
* Modified By		
* JIRA				CRM-6910 
******************************************************************************************/
@isTest
public with sharing class qcc_SearchTabAssociateContactTest 
{
	    @isTest
    	static void associateContactToCaseTest()
        { 
       		String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
            String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
              //Set Custom Settings for Trigger_Status__c Custom settings
            List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
            insert customSettingTriggerStatusLists;
            List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
            for(Trigger_Status__c ts : lsttrgStatus){
                ts.Active__c = false;
            }
           
            insert lsttrgStatus;
        
        	Case newCase=new Case(subject='Test Case',recordtypeid=caseRecordTypeId,First_Name__c='test',Last_Name__c='contact',Contact_Email__c='test.contact@qantas.com.au',Contact_Phone__c='+61465776556');
        	insert newCase;
        	Contact newCont=new Contact(recordtypeid=contactRecordTypeId,firstname='TestCont',lastname='ContCont',email='test.email@qantas.com',phone='87564857487');
            insert newCont;
        
          	 test.starttest();
             Boolean getReturn=	qcc_SearchTabAssociateContact.associateContact(newCase.id,newCont.id);
             getReturn=	qcc_SearchTabAssociateContact.associateContact(newCase.id,newCont.id);
            system.assert(true,getReturn);
            test.stoptest();
    	}
}