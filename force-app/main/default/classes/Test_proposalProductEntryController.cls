/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
27-Jan-2026   Mark-Capgemini               CRM-10405: Test method updated for PSV changes  
15-Jul-2026   Jonathan-Capgemini           RBAC SND    
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class Test_proposalProductEntryController{

    @istest static void myTest(){
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
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

        system.runAs(u) {
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        
        //Accounts
        accList = TestUtilityDataClassQantas.getAccounts();
        
        // Load Opportunities
         oppList = TestUtilityDataClassQantas.getOpportunities(accList);
         
        // Load Proposals
        propList = TestUtilityDataClassQantas.getProposal(oppList);
        
        

        // Create Fare Structure
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                     );
        try{
            Database.Insert(fs);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        // Create Discount_List__c 
        Discount_List__c disc = new Discount_List__c(FareStructure__c = fs.Id, Proposal__c = propList[0].Id);
         try{
            Database.Insert(disc);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        // Proposal Main Logic Test
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(propList[0]);
        
        proposalProductEntryController pCon = new proposalProductEntryController(stdController);
        proposalProductEntryController.ProductWrapper pw = new proposalProductEntryController.ProductWrapper(fs);
        pCon.overLimit = false;
        pCon.toUnselect = '';
        pCon.Total = 10;
        pCon.errorMsg = false;
        pCon.toSelect = fs.Id;
        pCon.updateAvailableList();
        pCon.addToShoppingCart();
        pCon.onSelectAll();
        pCon.onSave();
        pCon.onSaveMore();
        pCon.onCancel();        
        //pCon.onSelect();
        pCon.pgntionProducts();
        pCon.getFareCombinations();
        pCon.getBookingClassIds('Mainline - H in B deal');
        pCon.fareCombinationChange();
        pCon.next();
        pCon.previous();
        pCon.getPreviousDisplay();
        pCon.getNextDisplay();     
        
        // Update Proposal
        Proposal__c pr = propList[0];
        pr.Type__c = 'Qantas Business Savings';
        update pr;
        
        
        try{
            Database.Update(pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        System.debug('*** Proposal Is: '+pr);        
        
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(pr);
        
        proposalProductEntryController pCon1 = new proposalProductEntryController(stdController1);
        pCon1.selectedPicklistValue = 'All';
       // pCon1.onSelect();
        pCon1.onSelectAll();
        pCon1.fareCombinationChange();
            
        // Update Proposal
        Proposal__c pr1 = propList[0];
        pr1.Type__c = 'Corporate Airfares';
        update pr1;
        pCon1.onSelect();
        Test.stopTest();      
        
    }
    }
    @isTest static void myTest1(){
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
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

        system.runAs(u) {
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        
        //Accounts
        accList = TestUtilityDataClassQantas.getAccounts();
        
        // Load Opportunities
         oppList = TestUtilityDataClassQantas.getOpportunities(accList);
         
        // Load Proposals
        propList = TestUtilityDataClassQantas.getProposal(oppList);

        // Create Fare Structure
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                     );
        try{
            Database.Insert(fs);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        // Create Discount_List__c 
        Discount_List__c disc = new Discount_List__c(FareStructure__c = fs.Id, Proposal__c = propList[0].Id);
         try{
            Database.Insert(disc);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        // Proposal Main Logic Test
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(propList[0]);
        
        proposalProductEntryController pCon = new proposalProductEntryController(stdController);
        proposalProductEntryController.ProductWrapper pw = new proposalProductEntryController.ProductWrapper(fs);
        pCon.overLimit = false;
        pCon.toUnselect = '';
        pCon.Total = 10;
        pCon.errorMsg = false;
        pCon.toSelect = fs.Id;
        pCon.updateAvailableList();
        pCon.addToShoppingCart();
        pCon.onSelectAll();
        pCon.onSave();
        pCon.onSaveMore();
        pCon.onCancel();        
        //pCon.onSelect();
        pCon.pgntionProducts();
        pCon.getFareCombinations();
        pCon.getBookingClassIds('Mainline - H in B deal');
        pCon.fareCombinationChange();
        pCon.next();
        pCon.previous();
        pCon.getPreviousDisplay();
        pCon.getNextDisplay();     
        
        // Update Proposal
        Proposal__c pr = propList[0];
        pr.Type__c = 'Qantas Business Savings';
        pr.Forecast_MCA_Revenue__c = 100001;
        update pr;
        
        
        try{
            Database.Update(pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        System.debug('*** Proposal Is: '+pr);        
        
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(pr);
        
        proposalProductEntryController pCon1 = new proposalProductEntryController(stdController1);
        pCon1.selectedPicklistValue = 'All';
       // pCon1.onSelect();
        pCon1.onSelectAll();
        pCon1.fareCombinationChange();
            
        // Update Proposal
        Proposal__c pr1 = propList[0];
        pr1.Type__c = 'Corporate Airfares';
        update pr1;
        pCon1.onSelect();
        Test.stopTest();      
        
    }
    }
}