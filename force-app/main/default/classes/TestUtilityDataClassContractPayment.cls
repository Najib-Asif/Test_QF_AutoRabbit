/*
* MOdified By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to add Record Type on Contract Payments & Payments object for Qantas Payments
*/

@isTest
public class TestUtilityDataClassContractPayment 
{
    public static String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
    public static Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();

    // Get Account records
    public static List < Account > getAccounts() {
        //  createQantasConfigDataAccRecType();
        List < Account > accList = new List < Account > ();
        
        for (Integer i = 1; i < 4; i++) {
            Account acc = new Account(Name = 'Sample' + i, Active__c = true, Aquire__c = true, Type = 'Prospect Account',
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false,
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N'
                                     );
            accList.add(acc);
        }
        
        try {
            Database.Insert(accList);
        } catch (Exception e) {
            System.debug('Error Occured: ' + e.getMessage());
        }
        return accList;
    }

    // Get Opportunities to the given Accounts
    public static List < Opportunity > getOpportunities(List < Account > accList) {
        List < Opportunity > oppList = new List < Opportunity > ();
        
        for (Account acc: accList) {
            Opportunity opp = new Opportunity(Name = 'Opp' + acc.Name, AccountId = acc.Id,
                                              Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                              StageName = 'Qualify',Forecast_MCA_Revenue__c=20000
                                             );
            oppList.add(opp);
        }
        
        try {
            Database.Insert(oppList);
        } catch (Exception e) {
            System.debug('Exception Occured: ' + e.getMessage());
        }
        return oppList;
    }
    
    // Get Proposal & Discount List to the given Opportunity
    public static List < Proposal__c > getProposal(List < Opportunity > oppList) {
        List < Proposal__c > propList = new List < Proposal__c > ();
        List < Discount_List__c > discList = new List < Discount_List__c > ();
        List < Fare_Structure__c > faresList = new List < Fare_Structure__c > ();
        List < Standard_Discount_Guidelines__c > stdgList = new List < Standard_Discount_Guidelines__c > ();
        
        for (Opportunity opp: oppList) {
            Proposal__c prop = new Proposal__c(Name = 'Proposal ' + oppList[0].Name, Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                               Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                               Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                               MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                               Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                               NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                               DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                               Approval_Required_Others__c = false
                                              );
            propList.add(prop);
        }
        
        try {
            Database.Insert(propList);
        } catch (Exception e) {
            System.debug('Exception Occured: ' + e.getMessage());
        }
        
        // Fares
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business',
                                                     Category__c = 'Mainline', Market__c = 'Australia',
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                    );
        faresList.add(fs);
        try {
            Database.Insert(faresList);
        } catch (Exception e) {
            System.debug('Error Occured: ' + e.getMessage());
        }
        return propList;
    }

    // Get Contract
    public static List < Contract__c > getContract(List < Proposal__c > propList) {
        List < Contract__c > conList = new List < Contract__c > ();
        
        for (Proposal__c prop: propList) {
            Contract__c contr = new Contract__c(Name = 'Contract ' + prop.Name, Account__c = prop.Account__c, Opportunity__c = prop.Opportunity__c, Proposal__c = prop.Id,
                                                Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = true,
                                                MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today().addmonths(12),
     Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer', General__c ='New Deal',
     Domestic_Amendment__c ='Penalties', International_Amendment__c='All Discounts', Amendments__c='All Discounts'
                                               );
            conList.add(contr);
        }
        
        try {
            Database.Insert(conList);
        } catch (Exception e) {
            System.debug('Exception Occured: ' + e.getMessage());
        }
        return conList;
    }

    //Get the Contract Payment for theProposal
    public static List < Contract_Payments__c > getCP(List < Proposal__c > propList) {
        List < Contract_Payments__c > cpList = new List < Contract_Payments__c > ();
        for (Proposal__c p: propList) {
            Contract_Payments__c cp1 = new Contract_Payments__c(Proposal__c = p.Id,RecordTypeId = cpRTId, Amount__c = 100.50, Type__c = 'Performance Bonus', Payment_Frequency__c = 'Yearly', Payment_Criteria__c = 'Test');
            Contract_Payments__c cp2 = new Contract_Payments__c(Proposal__c = p.Id,RecordTypeId = cpRTId, Amount__c = 100.50, Type__c = 'Performance Bonus', Payment_Frequency__c = 'Quarterly', Payment_Criteria__c = 'Test');
            Contract_Payments__c cp3 = new Contract_Payments__c(Proposal__c = p.Id,RecordTypeId = cpRTId, Amount__c = 100.50, Type__c = 'Performance Bonus', Payment_Frequency__c = 'Half-Yearly', Payment_Criteria__c = 'Test');
            cpList.add(cp1);
            cpList.add(cp2);
            cpList.add(cp3);
        }
        
        try {
            Database.Insert(cpList);
        } catch (Exception e) {
            System.debug('Exception Occured: ' + e.getMessage());
        }
        return cpList;
    }

    // Get Trigger Status Custom setting
    public static List < Trigger_Status__c > enableCPTriggers() {
        List < Trigger_Status__c > tsList = new List < Trigger_Status__c > ();
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'RollupTravelFundSum';
        ts.Active__c = true;
        
        tsList.add(ts);
        
        try {
            Database.Insert(tsList);
        }
        Catch(Exception e) {
            System.debug('Error Occured: ' + e.getMessage());
        }
        return tsList;
    }
    
    // Get Trigger Status of Contract payment count Custom setting
    public static List < Trigger_Status__c > enableCPcountTriggers() {
        List < Trigger_Status__c > tsList = new List < Trigger_Status__c > ();
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ConPaymentCount';
        ts.Active__c = true;
        
        tsList.add(ts);
        
        try {
            Database.Insert(tsList);
        }
        Catch(Exception e) {
            System.debug('Error Occured: ' + e.getMessage());
        }
        return tsList;
    }
}