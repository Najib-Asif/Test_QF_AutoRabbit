/********
    * Created By : Flo De Los Reyes | ACN | Developer 
    * Purpose : test class for Indicator_Service/Indicator Controller
    * Purpose : Apex controler Class for IndicatorBadge Aura Component
    * REST API : No Rest API Needed
    
    Modified Date   : 27/01/23 (DD/MM/YYYY)
    Modified By     : Flo De Los Reyes
    JIRA            : ADT-21
    Version         : 1.1 -Initial Development | Flo - 27/01/23
    Version         : 1.2 - added new test method | Flo - 13/17/23
*/
@isTest
public class IndicatorServiceTest {
    

    /***************************
    *   Purpose				: create test record to use in methods
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: 
	*/
    @testSetup 
    static void setup(){
        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        

        update statToUpdate;
        
        Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'QCC_SetNonFFContactOnCase';
        triggerStatus.Active__c = false;
        insert triggerStatus;
        
        Account accountObj = TestUtilityDataClassQantas.createAccount();
        insert accountObj;
        
        Contact contactObj = TestUtilityDataClassQantas.createContact(accountObj.Id);
        insert contactObj;
        
        Id caseVoicecRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
        
        Case caseObj = TestUtilityDataClassQantas.CreateCase(accountObj.Id);
        caseObj.recordtypeId = caseVoicecRecordTypeId;
        caseObj.ContactId = contactObj.Id;
        insert caseObj;
    }
	/***************************
    *   Purpose				: Test for getFieldsToQueryForObject method on INDICATOR_Service class
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: There should fields to be return when called the method getFieldsToQueryForObject
	*/
    
    static testmethod void getFieldsToQueryForObjectTest(){
        test.startTest();
            String objName = 'Contact';
            List<String> lstObjectFields = IndicatorService.getFieldsToQueryForObject(objName);
            system.assertEquals(lstObjectFields.isEmpty(),false,'No Record is return');
        test.stopTest();
        
    }
    
    /***************************
    *   Purpose				: Test for getIndicatorBadgesForObject method on INDICATOR_Controller class for Contact
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: There should be meta data record return
	*/
    
    static testmethod void getIndicatorBadgesForObjectContactTest(){
        test.startTest();
            Contact newContact = new Contact();
            newContact.LastName = 'Test';
            insert newContact;
            String objName = 'Contact';
            List<IndicatorService.Indicator> lstObjectFields = IndicatorController.getIndicators(newContact.id, objName);
            system.assertEquals(lstObjectFields.isEmpty(),false,'No Record is return');
        test.stopTest();
        
    }
    
     /***************************
    *   Purpose				: Test for getIndicatorBadgesForObject method on INDICATOR_Controller class for Case
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: There should be meta data record return
	*/
    
    static testmethod void getIndicatorBadgesForObjectCaseTest(){
        test.startTest();
            List<Case> lstCase = [SELECT id, ContactId FROM Case];
        String objName = 'Case';
        if(lstCase[0].ContactId != null )
        {
            Contact con = new Contact();
            con.Id = lstCase[0].ContactId;
            con.Birthdate = Date.Today();
            update con;
            
        }
        List<IndicatorService.Indicator> lstObjectFields = IndicatorController.getIndicators(lstCase[0].id, objName);
            system.assertEquals(lstObjectFields.isEmpty(),false,'No Record is return');
        test.stopTest();
    }
    
    /***************************
    *   Purpose				: Test for getIndicatorBadgesForObject method on INDICATOR_Controller class for null id
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: There should be meta data record return
	*/
    
    static testmethod void getIndicatorBadgesForObjectTestNull(){
		test.startTest();
            String objName = 'Case';
            List<IndicatorService.Indicator> lstObjectFields = IndicatorController.getIndicators('', objName);
            system.assertEquals(lstObjectFields==null,true,'there should be no Record to return');
        test.stopTest();
    }
    
    /***************************
    *   Purpose				: Test for getSObjectLabel method
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: 
	*/
    
    static testmethod void getSObjectLabelTest(){
        test.startTest();
            IndicatorService.Indicator res = new IndicatorService.Indicator('test','red','test');
            String label = '';
            Indicator_Badge__mdt indicatorBadge = [SELECT Object__c FROM Indicator_Badge__mdt LIMIT 1];
            label = IndicatorController.getSObjectLabel(indicatorBadge.Object__c);
            system.assertEquals(label != '',true);
        test.stopTest();
    }
    
    /***************************
    *   Purpose				: Test for getContactId method 
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: the return id is same with the contact id 
	*/
    
    static testmethod void getContactIdTest(){
        test.startTest();
            List<Case> lstCase = [SELECT id, ContactId FROM Case];
            Contact curContact = [SELECT id FROM Contact LIMIT 1];
            id idContact = IndicatorController.getContactId(lstCase[0].Id);
            system.assertEquals(curContact.id , idContact , 'Incorrect contact id' );
        test.stopTest();
    }
    
     /***************************
    *   Purpose				: Test for getContactId method 
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: there should be null return as the id pass is empty
	*/
    
     static testmethod void getContactIdEmptyTest(){
        test.startTest();
            
            Contact curContact = [SELECT id FROM Contact LIMIT 1];
            id idCase = IndicatorController.getContactId('');
            system.assertEquals(null , idCase , 'Incorrect contact id' );
        test.stopTest();
    }
    
     /***************************
    *   Purpose				: Test for getContactId method 
    * 	Parameters			: 
    * 	Returns				: 
    * 
    * 	Throws
    * 	Expectations		: there should be null return as the id pass is incorrect
	*/
    static testmethod void getContactIdIncorrectTest(){
        test.startTest();
            List<Case> lstCase = [SELECT id, ContactId FROM Case];
            Contact curContact = [SELECT id FROM Contact LIMIT 1];
            id idCase = IndicatorController.getContactId(curContact.id);
            system.assertEquals(null , idCase , 'Incorrect contact id' );
        test.stopTest();
    }
}