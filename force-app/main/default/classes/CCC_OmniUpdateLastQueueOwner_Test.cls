/*------------------------------------------------------------
   Company:        Salesforce
   Description:    Test for CCC_OmniUpdateLastQueueOwner

   History
   Date            Author                  Comments
   -------------------------------------------------------------
   06-04-2021      Salesforce              Initial Version
   -------------------------------------------------------------*/
@isTest
public class CCC_OmniUpdateLastQueueOwner_Test {

	@TestSetup
	static void testSetup(){
		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
		TestUtilityDataClassQantas.insertQantasConfigData();

		Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
		User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com',
		                   Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id, 
		                   EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
		                   TimeZoneSidKey = 'Australia/Sydney', City='Manila', Location__c = 'Manila'
		                   );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }

		List<Contact> contacts = new List<Contact>();

		System.runAs(u1) {

			for(Integer i = 0; i < 1; i++) {
				Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager',
				                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd',
				                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249',
				                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Silver', Frequent_Flyer_Number__c = '12345');
				con.CAP_ID__c = '71000000001'+ (i+7);
				contacts.add(con);
			}
			insert contacts;
		}
	}

	@isTest
	public static void omniUpdateLastQueueOwnerTest() {
		String type = 'Query';
		String recordType = 'CCC Query';
		Contact con = [SELECT Id, Name FROM Contact Limit 1];
		Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
		cs.ContactId = con.id;
		insert cs;

		list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
		Id queueId = listQO[0].QueueId;

		CCC_OmniUpdateLastQueueOwner.Input singleInput = new CCC_OmniUpdateLastQueueOwner.Input();
		singleInput.originalGroupId = queueId;
		singleInput.workItemId = cs.id;
		List<CCC_OmniUpdateLastQueueOwner.Input> inputs = new  List<CCC_OmniUpdateLastQueueOwner.Input>();
		inputs.add(singleInput);

		Test.startTest();
		CCC_OmniUpdateLastQueueOwner.updateLastQueueOwner(inputs);
		Case objCase = [Select id, Last_Queue_Owner__c from Case where Id = :cs.Id];
		Test.stopTest();
		System.assertEquals(objCase.Last_Queue_Owner__c, Id.valueOf(queueId), 'Last Queue Owner is Not Updated.');
	}
}