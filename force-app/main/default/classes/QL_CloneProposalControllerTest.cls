/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the cloning the Proposal functionality
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam                 CRM-2969   LEx-Custom Clone Proposal                                   T01
Ajay					AE - 82		to add Record Type on Contract Payments & Payments object
Created Date    : 02/02/18 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated createTestData() method. Formatted code
**********************************************************************************************************************************/
@isTest
public class QL_CloneProposalControllerTest {
    
    // Ajay : added for JIRA : AE - 82
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
    // Ajay : ended
    
    @testsetup
    static void createTestData(){
        // Custom setting creation
        QL_TestUtilityData.enableCPTriggers();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    static testMethod void validateTestDataActiveProposal() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();         
        List<Contract__c> conList = new  List<Contract__c>();
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        // Load Opportunities
        oppList = QL_TestUtilityData.getOpportunities(accList);
        
        // Load Proposals
        // propList = QL_TestUtilityData.getProposal(oppList);
        // propList = QL_TestUtilityData.getProposal(oppList);
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                                Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',Leadership_Rejected__c=false,QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000
                                               );
        insert validProp;
        Fare_Structure__c fss = new Fare_Structure__c(Name = 'J1', Active__c = true, Cabin__c = 'Business', 
                                                      Category__c = 'Mainline', Market__c = 'Australia', 
                                                      ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                      Segment__c = 'Domestic'
                                                     );
        insert fss;
        // create a disc list
        List<Discount_List__c> discList = new List<Discount_List__c>();
        for(Integer i=1;i<4;i++){
            Discount_List__c disc = new Discount_List__c(FareStructure__c = fss.Id, Proposal__c = validProp.Id, 
                                                         Qantas_Published_Airfare__c = fss.Qantas_Published_Airfare__c, 
                                                         Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fss.Segment__c,
                                                         Category__c = fss.Category__c, Network__c = fss.Network__c, 
                                                         Market__c = fss.Market__c, Cabin__c = fss.Cabin__c, 
                                                         Proposal_Type__c = validProp.Type__c, Discount__c = 40,
                                                         Approval_Comment_NAM__c = 'test', Approval_Comment_Pricing__c = 'test2',
                                                         Comment__c = 'test', Discount_Threshold_AM__c = 5,Discount_Threshold_NAM__c = 10,QL_Tier_1_Offering__c = 6
                                                        );
            discList.add(disc);
        }
        if(!discList.isEmpty())
            insert discList;
        
        // create a CP List
        List<Contract_Payments__c> cpList = new List<Contract_Payments__c>();
        
        // create a CFI List
        List<Charter_Flight_Information__c> cfiList = new List<Charter_Flight_Information__c>();
        
        for(Integer i=1;i<4;i++){
            Contract_Payments__c cp = new Contract_Payments__c(Proposal__c = validProp.Id, RecordTypeId = cpRTId); // Ajay : added record type for JIRA:AE-82
            cpList.add(cp);
            Charter_Flight_Information__c cf = new Charter_Flight_Information__c(Proposal__c = validProp.Id,ETD__c='test',Flight_Date__c=date.today(),Flight_Number__c='123',Seating_Space__c=45,Sector__c='test');
            cfiList.add(cf);
        }
        if(!cpList.isEmpty())
            insert cpList;
        
        if(!cfiList.isEmpty())
            insert cfiList;
        
        //Contract TMC test coverage starts here
        List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
        List<Agency_Info__c> TMCList = TestUtilityDataClassQantas.getTMC();
        Integer i= 1;
        for(Agency_Info__c tmc : TMCList){
            QEC_ContractTMCInfo__c contractTMC = new QEC_ContractTMCInfo__c(Proposal__c = validProp.Id, 
                                                                            TMC_Info__c = tmc.Id);
            i++;
            contractTMCList.add(contractTMC);
        }
        if(!contractTMCList.isEmpty()){
            insert contractTMCList;
        }
        //Contract TMC test coverage ends here
        
        List<Business_Case__c> createBs = new List<Business_Case__c>();
        
        Business_Case__c businessValue = new Business_Case__c(Proposal__c = validProp.Id,
                                                              // Aligned_with_EK_sales__c = 'test',
                                                              Cost_of_sale_Incremental_opportunity__c = 'test',
                                                              Current_performance_in_the_route_s__c = 'tets',
                                                              What_else_have_you_considered__c = 'test',
                                                              How_did_you_arrive_with_this_proposal__c = 'test record for the active proposal',
                                                              Is_there_competitive_MI__c = 'test',
                                                              Market__c = 'India',
                                                              Requested_routes__c = 'test',               
                                                              What_is_the_current_booking_mix__c = 'test', Supplementary_Materials_Sharepoint_Link__c='www.url.com');         
        
        createBs.add(businessValue);                
        if(!createBs.isEmpty())
            insert createBs;    
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com';/*'testuser@test123456789.com';*/
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
        u.CountryCode='AU';
        insert u;
        system.runAs(u) {
            Test.startTest();               
            try{
                //  Database.Update(conList);
                //Invoke the controller Method
                QL_CloneProposalController.getClonedProposal(validProp.Id);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }
    
    static testMethod void validateTestDataInActiveProposal() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        List<Contract__c> conList = new  List<Contract__c>();
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        // Load Opportunities
        oppList = QL_TestUtilityData.getOpportunities(accList);
        
        // Load Proposals
        propList = QL_TestUtilityData.getProposal(oppList);
        // propList = QL_TestUtilityData.getProposal(oppList);
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                                Active__c = false, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000
                                               );
        insert validProp;
        
        //Contract TMC test coverage starts here
        List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
        List<Agency_Info__c> TMCList = TestUtilityDataClassQantas.getTMC();
        Integer i= 1;
        for(Agency_Info__c tmc : TMCList){
            QEC_ContractTMCInfo__c contractTMC = new QEC_ContractTMCInfo__c(Proposal__c = validProp.Id, 
                                                                            TMC_Info__c = tmc.Id);
            i++;
            contractTMCList.add(contractTMC);
        }
        if(!contractTMCList.isEmpty()){
            insert contractTMCList;
        }
        //Contract TMC test coverage ends here
        
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
        u.CountryCode='AU';
        insert u;
        system.runAs(u) {
            Test.startTest();               
            try{
                //  Database.Update(conList);
                //Invoke the controller Method
                QL_CloneProposalController.getClonedProposal(validProp.Id);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }
    
    static testMethod void validateTestDataAdhocProposal() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();         
        List<Contract__c> conList = new  List<Contract__c>();
        
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        // Load Opportunities
        oppList = QL_TestUtilityData.getOpportunities(accList);
        
        // Load Proposals
        // propList = QL_TestUtilityData.getProposal(oppList);
        // propList = QL_TestUtilityData.getProposal(oppList);
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                                Active__c = true, Type__c = 'Adhoc', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',Leadership_Rejected__c=false,QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000
                                               );
        insert validProp;
        Fare_Structure__c fss = new Fare_Structure__c(Name = 'J1', Active__c = true, Cabin__c = 'Business', 
                                                      Category__c = 'Mainline', Market__c = 'Australia', 
                                                      ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                      Segment__c = 'Domestic'
                                                     );
        insert fss;
        // create a disc list
        List<Discount_List__c> discList = new List<Discount_List__c>();
        for(Integer i=1;i<4;i++){
            Discount_List__c disc = new Discount_List__c(FareStructure__c = fss.Id, Proposal__c = validProp.Id, 
                                                         Qantas_Published_Airfare__c = fss.Qantas_Published_Airfare__c, 
                                                         Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fss.Segment__c,
                                                         Category__c = fss.Category__c, Network__c = fss.Network__c, 
                                                         Market__c = fss.Market__c, Cabin__c = fss.Cabin__c, 
                                                         Proposal_Type__c = validProp.Type__c, Discount__c = 40,
                                                         Approval_Comment_NAM__c = 'test', Approval_Comment_Pricing__c = 'test2',
                                                         Comment__c = 'test', Discount_Threshold_AM__c = 5,Discount_Threshold_NAM__c = 10,QL_Tier_1_Offering__c = 6
                                                        );
            discList.add(disc);
        }
        if(!discList.isEmpty())
            insert discList;
        
        // create a CP List
        List<Contract_Payments__c> cpList = new List<Contract_Payments__c>();
        
        // create a CFI List
        List<Charter_Flight_Information__c> cfiList = new List<Charter_Flight_Information__c>();
        
        for(Integer i=1;i<4;i++){
            Contract_Payments__c cp = new Contract_Payments__c(Proposal__c = validProp.Id,RecordTypeId = cpRTId); // Ajay : added record type for JIRA:AE-82
            cpList.add(cp);
            Charter_Flight_Information__c cf = new Charter_Flight_Information__c(Proposal__c = validProp.Id,ETD__c='test',Flight_Date__c=date.today(),Flight_Number__c='123',Seating_Space__c=45,Sector__c='test');
            cfiList.add(cf);
        }
        if(!cpList.isEmpty())
            insert cpList;
        
        if(!cfiList.isEmpty())
            insert cfiList;
        
        //Contract TMC test coverage starts here
        List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
        List<Agency_Info__c> TMCList = TestUtilityDataClassQantas.getTMC();
        Integer i= 1;
        for(Agency_Info__c tmc : TMCList){
            QEC_ContractTMCInfo__c contractTMC = new QEC_ContractTMCInfo__c(Proposal__c = validProp.Id, 
                                                                            TMC_Info__c = tmc.Id);
            i++;
            contractTMCList.add(contractTMC);
        }
        if(!contractTMCList.isEmpty()){
            insert contractTMCList;
        }
        //Contract TMC test coverage ends here
        
        List<Business_Case__c> createBs = new List<Business_Case__c>();
        
        Business_Case__c businessValue = new Business_Case__c(Proposal__c = validProp.Id,
                                                              Aligned_with_EK_sales__c = 'test',
                                                              Cost_of_sale_Incremental_opportunity__c = 'test',
                                                              Current_performance_in_the_route_s__c = 'tets',
                                                              What_else_have_you_considered__c = 'test',
                                                              How_did_you_arrive_with_this_proposal__c = 'test record for the active proposal',
                                                              Is_there_competitive_MI__c = 'test',
                                                              Market__c = 'India',
                                                              Requested_routes__c = 'test',               
                                                              What_is_the_current_booking_mix__c = 'test', Supplementary_Materials_Sharepoint_Link__c='www.url.com');         
        
        createBs.add(businessValue);                
        if(!createBs.isEmpty())
            insert createBs;    
        
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
        u.CountryCode='AU';
        insert u;
        system.runAs(u) {
            Test.startTest();               
            try{
                //  Database.Update(conList);
                //Invoke the controller Method
                QL_CloneProposalController.getClonedProposal(validProp.Id);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }
    
    static testMethod void validateTestDataScheduledProposal() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();         
        List<Contract__c> conList = new  List<Contract__c>();
        
        
        // Load Accounts
        accList = QL_TestUtilityData.getAccounts();
        
        // Load Opportunities
        oppList = QL_TestUtilityData.getOpportunities(accList);
        
        // Load Proposals
        // propList = QL_TestUtilityData.getProposal(oppList);
        // propList = QL_TestUtilityData.getProposal(oppList);
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                                Active__c = true, Type__c = 'Scheduled', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',Leadership_Rejected__c=false,QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000
                                               );
        insert validProp;
        Fare_Structure__c fss = new Fare_Structure__c(Name = 'J1', Active__c = true, Cabin__c = 'Business', 
                                                      Category__c = 'Mainline', Market__c = 'Australia', 
                                                      ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                      Segment__c = 'Domestic'
                                                     );
        insert fss;
        // create a disc list
        List<Discount_List__c> discList = new List<Discount_List__c>();
        for(Integer i=1;i<4;i++){
            Discount_List__c disc = new Discount_List__c(FareStructure__c = fss.Id, Proposal__c = validProp.Id, 
                                                         Qantas_Published_Airfare__c = fss.Qantas_Published_Airfare__c, 
                                                         Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fss.Segment__c,
                                                         Category__c = fss.Category__c, Network__c = fss.Network__c, 
                                                         Market__c = fss.Market__c, Cabin__c = fss.Cabin__c, 
                                                         Proposal_Type__c = validProp.Type__c, Discount__c = 40,
                                                         Approval_Comment_NAM__c = 'test', Approval_Comment_Pricing__c = 'test2',
                                                         Comment__c = 'test', Discount_Threshold_AM__c = 5,Discount_Threshold_NAM__c = 10,QL_Tier_1_Offering__c = 6
                                                        );
            discList.add(disc);
        }
        if(!discList.isEmpty())
            insert discList;
        
        // create a CP List
        List<Contract_Payments__c> cpList = new List<Contract_Payments__c>();
        
        // create a CFI List
        List<Charter_Flight_Information__c> cfiList = new List<Charter_Flight_Information__c>();
        
        for(Integer i=1;i<4;i++){
            Contract_Payments__c cp = new Contract_Payments__c(Proposal__c = validProp.Id,RecordTypeId = cpRTId); // Ajay : added record type for JIRA:AE-82
            cpList.add(cp);
            Charter_Flight_Information__c cf = new Charter_Flight_Information__c(Proposal__c = validProp.Id,ETD__c='test',Flight_Date__c=date.today(),Flight_Number__c='123',Seating_Space__c=45,Sector__c='test');
            cfiList.add(cf);
        }
        if(!cpList.isEmpty())
            insert cpList;
        
        if(!cfiList.isEmpty())
            insert cfiList;
        
        //Call custom settings to invoke trigger
        TestUtilityDataClassQantas.enableTriggers();
        //Special condition test coverage starts
        List<QEC_Special_Condition__c> splconditionList = TestUtilityDataClassQantas.getSpecialConditions();
        for(QEC_Special_Condition__C condition : splconditionList){
            condition.Proposal__c = validProp.id;
        }
        if(!splconditionList.isEmpty()){
            insert splconditionList;
        }
        //Special condition test coverage ends
        
        //Contract TMC test coverage starts here
        List<QEC_ContractTMCInfo__c> contractTMCList = new List<QEC_ContractTMCInfo__c>();
        List<Agency_Info__c> TMCList = TestUtilityDataClassQantas.getTMC();
        Integer i= 1;
        for(Agency_Info__c tmc : TMCList){
            QEC_ContractTMCInfo__c contractTMC = new QEC_ContractTMCInfo__c(Proposal__c = validProp.Id, 
                                                                            TMC_Info__c = tmc.Id);
            i++;
            contractTMCList.add(contractTMC);
        }
        if(!contractTMCList.isEmpty()){
            insert contractTMCList;
        }
        //Contract TMC test coverage ends here
        
        List<Business_Case__c> createBs = new List<Business_Case__c>();
        
        Business_Case__c businessValue = new Business_Case__c(Proposal__c = validProp.Id,
                                                              Aligned_with_EK_sales__c = 'test',
                                                              Cost_of_sale_Incremental_opportunity__c = 'test',
                                                              Current_performance_in_the_route_s__c = 'tets',
                                                              What_else_have_you_considered__c = 'test',
                                                              How_did_you_arrive_with_this_proposal__c = 'test record for the active proposal',
                                                              Is_there_competitive_MI__c = 'test',
                                                              Market__c = 'India',
                                                              Requested_routes__c = 'test',               
                                                              What_is_the_current_booking_mix__c = 'test', Supplementary_Materials_Sharepoint_Link__c='www.url.com');         
        
        createBs.add(businessValue);                
        if(!createBs.isEmpty())
            insert createBs;    
        
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
        u.CountryCode='AU';
        insert u;
        system.runAs(u) {
            Test.startTest();               
            try{
                //  Database.Update(conList);
                //Invoke the controller Method
                QL_CloneProposalController.getClonedProposal(validProp.Id);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }
}