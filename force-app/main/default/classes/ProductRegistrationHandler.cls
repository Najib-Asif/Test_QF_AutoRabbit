/**********************************************************************************************************************************

Created Date: 18/03/2015

Description: Process Product Registration trigger for:
1. processing AMEX Eligibility on accounts.
2. Opportunity creation based on travel frequency. (Disabling the creation through the JIRA CRM-1902)

Version:
V1.0 - 18/03/2015 - Initial version [FO]
Membership_Expiry_Date__c replaces Aquire_membership_end_date__c CRM-1093  13/06/2015
Removed QBD Account references 
CRM-1573 (PR2810494) Recurring Amex requests need logic to run again.
CRM-1902 - Remove auto-create opp for Aquire
        - Fix for duplicate record in account update list

    Modified Date   : 29/01/19 (DD/MM/YYYY)
    Added By        : Vinothkumar Balasubramanian
    JIRA            : CRM - 3494
    Version         : V2.0 - Commented the unused lines after discussing with Nijo to increase test class coverage
**********************************************************************************************************************************/
public class ProductRegistrationHandler {
    
    /*
    Purpose:  Create opportunity based on travel frequency, Change account type
    Parameters: trigger.new list of product Registrations.
    Return: none. 
    */
    public static boolean hasRunProcessAMEXEligibilityUpdate = false;
    public void processAccountAndOpportunity(List<Product_Registration__c> newList){
        String aquireRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('Aquire Registration').getRecordTypeId();
        String amexRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('AEQCC Registration').getRecordTypeId();
        
        set<Id> aquireAccounts = new set<Id>();
        //set<Id> amexAccounts = new set<Id>();
        
        map<Id,account> accToUpdate = new map<Id,account>();
        
        for(Product_Registration__c pr:newList){
            if(pr.RecordTypeId == aquireRecordTypeId){
                aquireAccounts.add(pr.Account__c);
            }/*else if(pr.RecordTypeId == amexRecordTypeId){
                amexAccounts.add(pr.Account__c);
            }*/
        }
        
        /*Create oppertunities */
        
        //CRM-1902 - Commented the below lines to disable the auto Opportunity creation
        
        /*List<Opportunity> oppoList = new List<Opportunity>();
        Account_Travel_Frequency__c atf = Account_Travel_Frequency__c.getValues('Travel Frequency');*/
        
        for(Product_Registration__c pr:[SELECT id, Account__c, Annual_Domestic_Flights__c, Annual_International_Flights__c, Account__r.Name, Account__r.OwnerId,
                                        Account__r.CreatedDate, Account__r.Manual_Revenue_Update__c, Stage_Status__c, Estimated_Total_Annual_Revenue__c, Aq_Business_Domestic_annual_spend__c, Aq_Business_international_annual_spend__c 
                                        FROM Product_Registration__c 
                                        WHERE id IN:(Trigger.newMap.keySet()) AND Account__c IN:(aquireAccounts)])
        {    
            Account tempAcc = new Account(id = pr.Account__c, Aquire__c = true);        //All Aquire Accounts
            if(pr.Account__r.Manual_Revenue_Update__c != true){
                if(pr.Aq_Business_Domestic_annual_spend__c == null && pr.Aq_Business_international_annual_spend__c == null){
                    tempAcc.Estimated_Total_Air_Travel_Spend__c  = null;
                }else {
                    Decimal a=0, b=0;
                    //CRM-2618  commenting the logic starts here
                   /* if(pr.Aq_Business_Domestic_annual_spend__c != null && pr.Aq_Business_Domestic_annual_spend__c != '') a =  Decimal.valueOf(rectifySpendAmount(pr.Aq_Business_Domestic_annual_spend__c));
                    if(pr.Aq_Business_international_annual_spend__c != null && pr.Aq_Business_international_annual_spend__c != '') b =  Decimal.valueOf(rectifySpendAmount(pr.Aq_Business_international_annual_spend__c));*/
                    //CRM-2618  commenting the logic end here
                    //CRM-2618 new datatype change logic
                    if(pr.Aq_Business_Domestic_annual_spend__c != null)a =  pr.Aq_Business_Domestic_annual_spend__c;
                    if(pr.Aq_Business_international_annual_spend__c != null) b =  pr.Aq_Business_international_annual_spend__c;
                    //CRM-2618 new datatype change logic
                    Decimal amnt = a+b ;
                    tempAcc.Estimated_Total_Air_Travel_Spend__c  = amnt ;
                }
            }
            accToUpdate.put(tempAcc.Id,tempAcc);         
        }
        
        //CRM-1902 - Commented the below lines to disable the auto Opportunity creation
        
        /* Save Opportunities */
        /* if(oppoList.size() > 0){
        if(oppoList.size()>0) Database.insert(oppoList);
        }*/
        
        /* Update Account types */
        /*for(id aId : amexAccounts){    //All amex Accounts
            if(accToUpdate.containsKey(aId)){
                accToUpdate.get(aId).AMEX__c = true;
            }else{
             accToUpdate.put(aId,New Account(id = aId, AMEX__c = true));
            }   
        }*/

        system.debug('accToUpdate##########'+accToUpdate);
        
        if(accToUpdate.size() > 0){
            Database.update(accToUpdate.values());
        }
        
        
    }
    
        
    /*
    Purpose:  Process AMEX eligibility on update trigger
    Parameters: trigger.new list of product Registrations, record type
    Return: list of production registration. 
    */
    
    // CRM - 3494 - Commented the below method
    /*private List<Product_Registration__c> getProductRegistrationRecords(String recType, List<Product_Registration__c> newList){
        
        List<Product_Registration__c> recTypeProducts = new List<Product_Registration__c>();
        String recTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        
        
        for(Product_Registration__c pr : newList){
            if(pr.RecordTypeId == recTypeId){
                recTypeProducts.add(pr);
            }
        }
        return recTypeProducts;
    }*/
    
    /*
    Purpose: Get accouts for Product registraion
    Parameters: trigger.new list of product Registrations
    Return: list of Accounts. 
    */
    
    // CRM - 3494 - Commented the below method
    /*private Map<Id, Account> getAccounts(List<Product_Registration__c> newList){
        List<Id> accIds = new List<Id>();
        
        for(Product_Registration__c pr : newList){
            if(pr.Account__c != null){
                accIds.add(pr.Account__c);
            }
        }
        
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, CreatedDate, Aquire__c, Agency__c, Dealing_Flag__c, Aquire_Override__c
                                                        FROM Account 
                                                        WHERE Id IN :accIds]);
        return accMap;
    }*/
    
    /*
    Purpose: Get Aquire Product registraions for an account
    Parameters: set of accountIds
    Return: Map of product registrations indexed with accountId. 
    */
    
    // CRM - 3494 - Commented the below method
    /*private Map<Id, Product_Registration__c> getAquireProductRegistrations(Set<id> accountIds){
        Map<Id, Product_Registration__c> aquireProducts = new Map<Id, Product_Registration__c>();
        if(accountIds.size()>0){
            String aquireRecordTypeId = Schema.SObjectType.Product_Registration__c.getRecordTypeInfosByName().get('Aquire Registration').getRecordTypeId();
            for(Product_Registration__c pr : [SELECT Id, Account__c, Stage_Status__c,Membership_Expiry_Date__c ,Max_Airline_Points_for_Membership_Year__c
                                              FROM Product_Registration__c 
                                              WHERE RecordTypeId =:aquireRecordTypeId AND Account__c IN :accountIds]){
                                                  aquireProducts.put(pr.Account__c, pr);
                                              }
        }
        return aquireProducts;
    }*/
    /*
    Purpose: Remove all special characters from Spend Amount.
    */
    // CRM - 3494 - Commented the below method
    /*private String rectifySpendAmount(String str){
        String regExp = '^((0+)?(\\D)+(0+)?|0+)';
        String amount = str.replaceFirst(regExp, '');
        if(amount.contains(',')) amount = amount.remove(','); 
        return amount;
    }*/
    
}