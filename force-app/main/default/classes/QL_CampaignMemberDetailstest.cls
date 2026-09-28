/***********************************************************************************************************************************

Description: Test Class for Campaign Member List component

History:
======================================================================================================================
Name                    Jira        Description                                                          Tag
======================================================================================================================
Pushkar Purushothaman   CRM-3081    Test Class for Campaign Member List component                    T01

Created Date    : 28/04/2018 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method. Formatted code

**********************************************************************************************************************************/
@isTest
public class QL_CampaignMemberDetailstest 
{
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest static void Testmethod1()
    {
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; /*'testuser@test123456789.com';*/
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; /*'testuser@test123456789.com';*/
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        system.runAs(u)
        {           
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            
            Account acc = new Account(Name = 'Sample Acc ', Active__c = true, Aquire__c = true, Type = 'Customer Account', 
                                      RecordTypeId = RecordTypeId, Qantas_Corporate_Identifier__c = 'ABC', 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', AMEX__c = True, ABN_Tax_Reference__c = '1234567890');
            insert acc;            
            
            List<Contact> contactlist = new List<Contact>();
            for(Integer i=0;i<5;i++)
            {
                Contact con = new Contact(FirstName = 'FirstContact'+i,LastName='ContTest', Email='test1contact@duptest.com', AccountId = acc.Id,
                                          MailingCity = 'Sydney', MailingState = 'NSW', MailingPostalCode = '2000', MailingCountry = 'AU',  MailingStreet = 'Hill Road', Phone = '0444444444',
                                          Job_Role__c = 'Manager',Job_Title__c = 'MR');
                contactlist.add(con);
            }     
            insert contactlist;
            
            Campaign camp = new Campaign();
            camp.Name = 'Test campaign';
            camp.LookupAccount__c = acc.id;
            insert camp;            
            
            List<CampaignMember> cmember = new List<CampaignMember>();        
            for(Contact c : contactlist)
            {
                CampaignMember Newmember = new CampaignMember();
                Newmember.ContactId = c.id;
                Newmember.CampaignId = camp.Id;
                Newmember.Status = 'Planned';  
                Newmember.Assigned_to_User__c = u.Id; 
                Newmember.Related_Account__c = acc.Id;
                cmember.add(Newmember);                
            }
            
            Test.startTest();
            insert cmember;        
            QL_CampaignMemberDetails.fetchCampMembers(u.Id, 2, 1, camp.Id);
            Test.stopTest();
        }
    }
}