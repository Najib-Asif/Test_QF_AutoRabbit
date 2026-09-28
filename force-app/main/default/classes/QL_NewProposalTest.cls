/*----------------------------------------------------------------------------------------------------------------------
Author:        Gnanavelu
Description:   Test class for QL_NewProposal
************************************************************************************************
History
************************************************************************************************
12-July-2018      Gnanavelu               Initial Design

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QL_NewProposalTest 
{
    @testSetup 
    static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
            
    @isTest
    static void NewproposalTest()
    {        
        Account acc = new Account(Name = 'Test Customer Account', Estimated_Total_Annual_Revenue__c = 123456, QF_Revenue__c = 456789, Estimated_MCA_Revenue__c = 2034, Type = 'Customer Account', 
                                  Estimated_QF_Dom_Market_Share__c = 54, Domestic_Air_Travel_Spend__c = 56321,
                                  QF_Domestic_Revenue__c = 85744, Estimated_Int_Market_Share__c = 10, International_Air_Travel_Spend__c = 112,
                                  QF_International_Revenue__c = 2351, Estimated_Int_MCA_Market_Share__c = 12, ABN_Tax_Reference__c = '1234567890');                                                                                                   
        
        insert acc;
        
        List<Opportunity> Opplist = new List<Opportunity>();
        
        //Corporate Airfares
        Opportunity Oppinsert1 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert1.Forecast_MCA_Revenue__c=20000;
        Opplist.add(Oppinsert1);        
        //Qantas Business Savings
        Opportunity Oppinsert2 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert2.Category__c = 'Qantas Business Savings';
        Oppinsert2.Forecast_MCA_Revenue__c=20000;
        Opplist.add(Oppinsert2);
        //Adhoc
        Opportunity Oppinsert3 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert3.Category__c = 'Adhoc';
        Oppinsert3.Forecast_MCA_Revenue__c=20000;
        Opplist.add(Oppinsert3);
        //Sheduled
        Opportunity Oppinsert4 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert4.Category__c = 'Scheduled';
        Oppinsert4.Forecast_MCA_Revenue__c=20000;
        Opplist.add(Oppinsert4);
        //FIFO Scheduled
        Opportunity Oppinsert5 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert5.Category__c = 'FIFO Scheduled';
        Oppinsert5.Forecast_MCA_Revenue__c=20000;
        Opplist.add(Oppinsert5);
        //stage closed
        Opportunity Oppinsert6 = QL_NewProposalTest.CreateOpportunity(acc.Id);
        Oppinsert6.Forecast_MCA_Revenue__c=20000;
        insert Oppinsert6;
        //Network
        Opportunity closedopp = [Select Id, StageName, Closed_Reasons__c from Opportunity where Id=:Oppinsert6.Id];
        closedopp.StageName = 'Closed - Not Accepted';
        closedopp.Closed_Reasons__c = 'Network';
        closedopp.Other_reasons__c = 'Network';
        update closedopp;
        Test.startTest();
        
        insert Opplist;
        
        QL_NewProposal.Newproposal(Opplist[0].Id);
        QL_NewProposal.Newproposal(Opplist[1].Id);
        QL_NewProposal.Newproposal(Opplist[2].Id);
        QL_NewProposal.Newproposal(Opplist[3].Id);
        QL_NewProposal.Newproposal(Opplist[4].Id);
        QL_NewProposal.Newproposal(closedopp.Id);
        Test.stopTest();
    }
    
    static Opportunity CreateOpportunity(Id AccId)
    {
        Opportunity Opp = new Opportunity(Name='Opportunity Test',StageName='Qualify', Category__c='Corporate Airfares  ', Type='Business and Government', 
                                          Sub_Type_Level_1__c='Currently In Contract', Sub_Type_Level_2__c = 'Variation', CloseDate=Date.newInstance(2018, 07, 05),
                                          Sub_Type_Level_3__c='Single POS', Proposed_Revenue_Amount__c=326542, Proposed_Market_Share__c=90,
                                          Proposed_International_Market_Share__c=70, Proposed_MCA_Routes_Market_Share__c=70, AccountId=AccId);
        return Opp;
    }
}