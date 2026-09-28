@isTest
private class CP_ConPaymentCountHandlerTest{ 
    
    @testsetup
    static void createCPTestData(){
        
        // Custom setting creation
        TestUtilityDataClassContractPayment.enableCPcountTriggers();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
 
    }
    static testMethod void CountNumofConPayments() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        List<Contract_Payments__c> cpList = new  List<Contract_Payments__c>();
        
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        
        //Load CP
        List<Id> ids = new List<Id>();
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();   
        
        for (Proposal__c pr : propList){
                 ids.add(pr.id);
            		break;
        }
        //Update CP
        For (Contract_Payments__c c:cpList )
        {
            c.Amount__c=2000;  
        }
        try{
             CP_ConPaymentCountHandler.CountNumofConPayments(cpList);
			 ProposalApprovalCheck.getProposalId(ids);

           // Database.Update(cpList);
            Database.delete(cpList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        Test.stopTest(); 
    }
    
    static testMethod void testDiscountListHandler1() {
        
         TestUtilityDataClassQantas.enableTriggers();
         List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
       	 List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
         List<Discount_List__c> discList = [SELECT Id, Discount__c from Discount_List__c where Proposal__r.id =: proposalList[0].id];
          List<Fare_Structure__c> faresList = new List<Fare_Structure__c> ();
           Fare_Structure__c fr =   [Select Name,Active__c,Cabin__c,Category__c,Market__c,Qantas_Published_Airfare__c,
                                              ProductCode__c,Segment__c,Network__c from Fare_Structure__c limit 1 ];
    
       
list<Discount_List__c> discList1 = new List <Discount_List__c>();    
         for(Proposal__c prop: proposalList){
          
                Discount_List__c disc = new Discount_List__c(FareStructure__c = fr.Id, Proposal__c = prop.Id, 
                                                             Qantas_Published_Airfare__c = fr.Qantas_Published_Airfare__c, 
                                                             Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fr.Segment__c,
                                                             Category__c = fr.Category__c, Network__c = fr.Network__c, 
                                                             Market__c = fr.Market__c, Cabin__c = fr.Cabin__c, 
                                                             Proposal_Type__c = prop.Type__c, Discount__c = 40,
                                                             Approved_by_NAM__c = false, Approved_by_Pricing__c = false,
                                                             DO_Approved__c = false, TeamLead_Approved__c = false,QL_Tier_1_Offering__c=6
                                                            	
                                                            );
                discList1.add(disc);
            }            
        
       insert discList1;
        
         try{
             for(Proposal__c prop : proposalList){
		        
               
                ProposalApprovalCheck.getProposalId(new List<Id>{discList1[0].id});
             }
             

        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        
        }
    
     static testMethod void testDiscountListHandler2() {
        
         TestUtilityDataClassQantas.enableTriggers();
         List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
       	 List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
         List<Discount_List__c> discList = [SELECT Id, Discount__c from Discount_List__c where Proposal__r.id =: proposalList[0].id];
          List<Fare_Structure__c> faresList = new List<Fare_Structure__c> ();
           Fare_Structure__c fr =   [Select Name,Active__c,Cabin__c,Category__c,Market__c,Qantas_Published_Airfare__c,
                                              ProductCode__c,Segment__c,Network__c from Fare_Structure__c limit 1 ];
     
       
list<Discount_List__c> discList1 = new List <Discount_List__c>();    
         for(Proposal__c prop: proposalList){
          
                Discount_List__c disc = new Discount_List__c(FareStructure__c = fr.Id, Proposal__c = prop.Id, 
                                                             Qantas_Published_Airfare__c = fr.Qantas_Published_Airfare__c, 
                                                             Fare_Combination__c = 'Mainline - H in B deal', Segment__c = fr.Segment__c,
                                                             Category__c = fr.Category__c, Network__c = fr.Network__c, 
                                                             Market__c = fr.Market__c, Cabin__c = fr.Cabin__c, 
                                                             Proposal_Type__c = prop.Type__c, Discount__c = 40,
                                                             Approved_by_NAM__c = false, Approved_by_Pricing__c = false,
                                                             DO_Approved__c = false, TeamLead_Approved__c = false,QL_Tier_1_Offering__c=6
                                                            	
                                                            );
                discList1.add(disc);
            }            
        
       insert discList1;
        
         try{
             for(Proposal__c prop : proposalList){
		        
                ProposalApprovalCheck.getProposalId(new List<Id>{prop.id}); 
               
             }
             

        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        
        }
    
    
}