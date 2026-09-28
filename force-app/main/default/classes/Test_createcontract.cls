/*==============================================================================================================================
Modified By : Venkata Suresh Kumar (TCS Team), 02-Mar-2026
Desc : Remediated test class failures. Added testSetUPMethod() method.
**************************************************************************
15-Jul-2026 Jonathan-Capgemini			RBAC SND
==============================================================================================================================*/

@isTest(seealldata=false)
public class Test_createcontract{
    //Added by Suresh
    @testSetup static void setupTestData(){
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();        
        Test.stopTest();
    }
    public static testMethod void myTest(){
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'Sales and Distribution-Sales'];//RBAC SND - Profile Update
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
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('SND_Base_Permissions,SND_Non_GSA_Permission,SND_Sales_Account_Manager_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u.Id,permissionSetIds);
        }
        Test.startTest();
        
        //system.runAs(u){ 
        
        String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                  RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today().addDays(7) 
                                 );
        insert acc;
        
        Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
        
        insert con;
        
        Opportunity opp = new Opportunity(  Name = 'Opp'+acc.Name , AccountId = acc.Id,
                                          Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                          StageName = 'Qualify',Forecast_MCA_Revenue__c = 500000);
        
        insert opp;
        
        Opportunity opp1 = new Opportunity(  Name = 'Opp1'+acc.Name , AccountId = acc.Id,
                                           Amount = 600000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                           StageName = 'Qualify',Forecast_MCA_Revenue__c = 500000);
        
        insert opp1;
        
        String proposalRecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();
        
        Proposal__c prop = new Proposal__c(Name = 'Proposal '+opp.Name , Account__c = opp.AccountId, Opportunity__c = opp.Id,
                                           Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                           Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                           MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                           Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                           NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                           DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false, 
                                           RecordTypeId = proposalRecordTypeId, Approval_Required_Others__c = false,QL_Discount_Model__c = 'Tiered',
                                           Forecast_MCA_Revenue__c = 500000
                                           
                                          );
        insert prop;

        String contractRecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();
        
        Contract__c contr = new Contract__c(Name = 'Contract '+opp.Name , Account__c = prop.Account__c, Opportunity__c = prop.Opportunity__c, Proposal__c = prop.Id,
                                            Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                            Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', 
                                            MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today().addDays(7) , RecordTypeId = contractRecordTypeId,
                                            Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer', QL_Effective_Tier__c = 'Tier 1', QL_Discount_Model__c ='Tiered'                                            
                                           );
        
        insert contr;
        Test.stopTest();
    }
}