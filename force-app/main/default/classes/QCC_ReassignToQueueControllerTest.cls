/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
27-Jan-2026   Tanya-Capgemini     CRM-10408: Test method updated for PSV changes
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_ReassignToQueueControllerTest {

	@TestSetUp
	public static void testSetUp(){
		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
		TestUtilityDataClassQantas.insertQantasConfigData();
		QantasConfigData__c qc = new QantasConfigData__c();
		qc.Name = 'Log Exception Logs Rec Type';
		qc.Config_Value__c = 'Exception Logs';
		qc.Config_Description__c = 'Log Exception Logs Record Type Name';
		insert qc;

		list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
		Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1];

		List<Qantas_API__c> qantasAPIs = TestUtilityDataClassQantas.createQantasAPI();
		insert qantasAPIs;

		List<AirlineCarrierCodes__c> lstAirlineData = new List<AirlineCarrierCodes__c>();
		lstAirlineData.add(TestUtilityDataClassQantas.createAirlineCarrierData('QF','Qantas'));
		insert lstAirlineData;

		List<Airport_Code__c> airportCodes = new List<Airport_Code__c>();
		Airport_Code__c sydney = new Airport_Code__c();
		sydney.Name = 'SYD';
		sydney.Freight_Airport_Country_Name__c = 'Australia';
		sydney.Freight_Station_Name__c = 'SYDNEY';
		airportCodes.add(sydney);
		Airport_Code__c mel = new Airport_Code__c();
		mel.Name = 'MEL';
		mel.Freight_Airport_Country_Name__c = 'Australia';
		mel.Freight_Station_Name__c = 'MELBOURNE';
		airportCodes.add(mel);
		insert airportCodes;

		Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
		User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com',
		                   Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
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
				                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Silver',Frequent_Flyer_Number__c = '12345');
				con.CAP_ID__c = '71000000001'+ (i+7);
				contacts.add(con);
			}
			insert contacts;
		}

		System.runAs(u1) {
			String type = 'Insurance Letter';
			String recordType = 'CCC Insurance Letter Case';
			contacts = [SELECT Id FROM Contact];
			List<Case> cases = new List<Case>();
			for(Contact con: contacts) {
				Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
				cs.Origin = 'Qantas.com';
				cs.Booking_PNR__c = 'K5F5ZE';
				cs.Flight_Number__c = 'QF0401';
				cs.ContactId = con.Id;
				cs.Airline__c = 'Qantas';
				cs.Suburb__c = 'NSW';
				cs.Street__c = 'Jackson';
				cs.State__c = 'Mascot';
				cs.Post_Code__c = '20020';
				cs.Country__c = 'Australia';
				cs.Last_Queue_Owner__c = g.id;
				cs.Last_Queue_Owner_Name__c = g.Name;
				cs.Cabin_Class__c = 'Business';
				cases.add(cs);
			}
			insert cases;
		}
	}

	@isTest
	public static void getlistQueuesTest(){
		List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
		System.assertNotEquals(listQueue.size(), 0);
		System.assert (!listQueue[0].endsWithIgnoreCase('SLA'));
		System.assert (!listQueue[0].endsWithIgnoreCase('Low'));
		System.assert (!listQueue[0].endsWithIgnoreCase('Medium'));
		System.assert (!listQueue[0].endsWithIgnoreCase('High'));
	}

	@isTest
	public static void reassignToQueueTestNoPriority(){
       	try{
		Test.startTest();
		List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
		String queueName = listQueue[0];
		if (listQueue.contains('CCC Baggage Tracing Queue')) {
			queueName = 'CCC Baggage Tracing Queue';
		}
		Case c = [select id, Cabin_Class__c from Case limit 1];
		c.Cabin_Class__c = '';
		update c;

		String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(c.Id, queueName);
		System.debug([Select id, OwnerId from Case where isClosed = false]);
		Test.stopTest();
		System.debug(LoggingLevel.ERROR, selectedQueue);
		//System.assert (selectedQueue.equalsIgnoreCase('CCC Baggage Tracing Queue'));
        }catch(Exception e){
            
        }
	}
	//Method added to support Code Security Remediation changes
    @isTest
	public static void reassignToQueueTestNoPriorityExcp(){
        
        Profile p = [Select Id from Profile where Name= 'Standard User' LIMIT 1];
        User u= new User(Alias = 'stduser',Email = 'stduser@example.com',EmailEncodingKey = 'UTF-8',
            			  LastName = 'User', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                         TimeZoneSidKey='America/Los_Angeles',Username='stduser'+System.currentTimeMillis()+'@example.com',ProfileId =p.Id);
       	Test.startTest();
        try{
		
        System.runAs(u){
            String caseId = '500000000000001AAA';
            String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(caseId, 'Unknownqueue');
           //System.assert(false,'Excepted QueryException was not thrown');
            }
		
        }catch(Exception e){
        	//System.assert(e.getMessage().contains('Exception Occured in SOQL query'),'Exception Occured in SOQL query');    
        }
        Test.stopTest();
	}
	//Method added to support Code Security Remediation changes
    @isTest
    public static void calculatePrioirtyExcp(){
    	Profile p = [Select Id from Profile where Name= 'Standard User' LIMIT 1];
        User u= new User(Alias = 'stduser',Email = 'stduser@example.com',EmailEncodingKey = 'UTF-8',
            			  LastName = 'User', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',Username='stduser'+System.currentTimeMillis()+'@example.com',ProfileId =p.Id);
       	try{ 
            Test.startTest();
            System.runAs(u){
             List<String> idlist = new List<String>();
             idlist.add('500000000000001AAA');
             Map<String,String> pmap= new Map<String,String>();
             pmap =QCC_ReassignToQueueController.calculateCasesPriority(idlist);
                
            }    
        }catch(Exception e){
        	
        }
    }
	/*This is no longer needed (User Story: QSFR-23)
	   @isTest
	     public static void reassignToQueueTestLow(){
	     Test.startTest();
	             List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
	     String queueName = listQueue[0];
	     Case c = [select id, Cabin_Class__c from Case limit 1];
	     c.Cabin_Class__c = '';
	     update c;

	     String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(c.Id, queueName);
	     System.debug([Select id, OwnerId from Case where isClosed = false]);
	     Test.stopTest();
	     System.debug(LoggingLevel.ERROR, selectedQueue);
	     System.assert(selectedQueue.endsWithIgnoreCase('Low'));
	     }
	 */

	@isTest
	public static void reassignToQueueTestSLA(){
		Test.startTest();
		List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
		String queueName = listQueue[0];
		Case c = [select id, Cabin_Class__c from Case limit 1];
		c.Due_Date__c = System.today().adddays(-1);
		update c;

		String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(c.Id, queueName);
		Test.stopTest();
		System.debug(LoggingLevel.ERROR, selectedQueue);
		//System.assert(selectedQueue.endsWithIgnoreCase('SLA'));
	}

	@isTest
	public static void reassignToQueueTestMedium(){
		Test.startTest();
		List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
		String queueName = listQueue[0];
		Case c = [select id, Cabin_Class__c from Case limit 1];
		c.cabin_class__c = 'Business';
		update c;

		String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(c.Id, queueName);
		Test.stopTest();
		System.debug(LoggingLevel.ERROR, selectedQueue);
		//System.assert(selectedQueue.endsWithIgnoreCase('Medium'));
	}

	@isTest
	public static void reassignToQueueTestHigh(){
		Test.startTest();
		List<String> listQueue = QCC_ReassignToQueueController.getlistQueues();
		String queueName = listQueue[0];
		Case c = [select id, Cabin_Class__c from Case limit 1];
		c.cabin_class__c = 'First';
		update c;
		String selectedQueue = QCC_ReassignToQueueController.reassignToQueue(c.Id, queueName);
		Test.stopTest();
		System.debug(LoggingLevel.ERROR, selectedQueue);
		//System.assert(selectedQueue.endsWithIgnoreCase('High'));
	}
}