/*----------------------------------------------------------------------------------------------------------------------
*******************************************************************
History
15-Jul-2026 Jonathan-Capgemini          RBAC SND
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QAC_CaseReassignmentScheduler_Test {

     @testSetup
    public static void setup() {
       
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'Qantas Agency Connect and Agency Sales'];//RBAC SND - Profile Update
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; 
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; 
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        //RBAC SND - Permission Set Update
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Agency_Connect_Support_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u.Id,permissionSetIds);
        }
        
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QAC Contact Us Support').getRecordTypeId();
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        TestUtilityDataClassQantas.enableTriggers();
        
        Account testacc = new Account(Name='Test Tcs Account',Active__c = true,Type = 'Freight-Country',RecordTypeId = accRTId);
        insert testacc;
        
        Contact testcon = new Contact(FirstName='Bob1',LastName='Test2',AccountId=testacc.id,Function__c = 'IT',Business_Types__c = 'Freight',Email = 'abc@test.com',RecordTypeId =conRTId);
        insert testcon;
        system.debug('Before case create');
        
        List<Case> caseList = new List<Case>();
        
        Case newCase = new Case(AccountId = testacc.id, RecordTypeId = caseRTId,Status = 'Open',ContactId=testcon.id,Subject = 'Test01FRT',Description = 'some desc',
                                 Type = 'NDC',Group__c = 'NDC Portal', Category__c = 'Qantas NDC offers support', Sub_Category__c = 'Unable to view commission offer',
                                ownerId = u.Id
                               ); 
        insert newCase;
        	
            
        }
    
    
    @isTest 
    public static void executeTest()
    {
        Test.startTest();
        	Case c = [Select id,ownerId from case limit 1];
        	c.ownerId = UserInfo.getUserId();
            update c;
            System.schedule('QAC_CaseReassignmentSchedulerTest','0 0 * * * ?',new QAC_CaseReassignmentScheduler());
        Test.stopTest();
    }
    
    
    @isTest 
    public static void userLogoutTest()
    {
       Test.startTest();
       User u1 = [SELECT Id, UserName FROM User WHERE FirstName = 'Test' limit 1];
        Case c = [Select id,ownerId from case limit 1];
        	c.ownerId = u1.Id;
            update c;
       LogoutEventStream event = new LogoutEventStream();
       event.UserName = u1.UserName;
       event.UserId = u1.Id;
       EventBus.publish(event);
       Test.stopTest(); 
    }
}