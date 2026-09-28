@isTest
public class Test_ProposalTriggerHandler {
    
    public static testMethod void myTest(){
        
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
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
        u.Level__c='P3;FF1(B&G)';
        insert u;
        
        Trigger_Status__c ProposalTrigger = new Trigger_Status__c();
        ProposalTrigger.Name = 'ProposalTrigger';
        ProposalTrigger.Active__c = true;
        insert ProposalTrigger;
        
        system.runAs(u) {
            // Custom setting creation
            TestUtilityDataClassQantas.enableTriggers();
            
            // Load Accounts
            accList = TestUtilityDataClassQantas.getAccounts();
            
            // Load Opportunities
            oppList = TestUtilityDataClassQantas.getOpportunities(accList);
            
            // Load Proposals
            propList = TestUtilityDataClassQantas.getProposal(oppList);
            Test.startTest();
            // Update Proposals
            for(Proposal__c prop : propList){
                prop.NAM_Approved__c = true;
                prop.Pricing_Approved__c = true;
                prop.DO_Approved__c = true;
                prop.TeamLead_Approved__c = true;
                prop.TL_Approved__c = true;
                prop.Approved_by_SBD__c = true;
                prop.SBD_Approved__c = true;
                prop.Qantas_Annual_Expenditure__c = 600000;
                prop.Forecast_MCA_Revenue__c = 500000;
            }
            
            try{
                Database.Update(propList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            
            // Update Proposals
            for(Proposal__c prop : propList){
                prop.NAM_Rejected__c = true;
                prop.Pricing_Rejected__c = true;
                prop.DO_Rejected__c = true;
                prop.TeamLead_Rejected__c = true;
                prop.TL_Rejected__c = true;
                prop.SBD_Rejected__c = true;
                prop.Rejected_by_SBD__c = true;
                prop.Approval_Required_Others__c = true;
                prop.Domestic_Annual_Share__c = 78;
                prop.International_Annual_Share__c = 78;
                prop.MCA_Routes_Annual_Share__c = 78;
                prop.Status__c = 'Rejected - Internal';              
            }
            
            try{
                Database.Update(propList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            
            // Update Discount List
            for(Proposal__c prop : propList){
                for(Discount_List__c dl : prop.Fare_Structure_Lists__r)
                {
                    discList.add(dl); 
                }
            }
            
            for(Discount_List__c dl : discList){
                dl.Discount__c = 45;    
            }
            
            try{
                Database.Update(discList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            
            // Update Proposals
            for(Proposal__c prop : propList){
                prop.Qantas_Annual_Expenditure__c = 5000000;  
                
            }
            
            try{
                Database.Update(propList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            
            for(Proposal__c prop : propList){
                prop.Forecast_MCA_Revenue__c = 4000000;  
                
            }
            
            try{
                Database.Update(propList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            
            //Added for Recalled
            Proposal__c prop = propList[0];
            prop.Approval_Recalled__c='Recalled';
            try{
                Database.Update(prop);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
            Test.stopTest(); 
        }              
    }
    
}