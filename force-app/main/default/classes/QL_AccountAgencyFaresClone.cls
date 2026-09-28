/*----------------------------------------------------------------------------------------------------------------------
Author:    Mehul Manchanda
Jira:      CRM-3678
Description:  To update the Product Fare on the account when it is changed at PCC level.
Test Class: QL_AccountAgencyFaresCloneTest   
************************************************************************************************************************
History
************************************************************************************************************************
V1		CRM-3870			Bulkified the code
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QL_AccountAgencyFaresClone 
{
    @InvocableMethod
    public static void productFareAccountUpdate (List<Id> idToUpdate)
    { 
        Set<String> uniqueProduct = new Set<String>();
        List<String> productList = new List<String>();
        List<String> initialList = new List<String>();
        List<Account> accListUpd = new List<Account>();
        string accProductList;
        Set<String> stAccId = new Set<String>();
        For(Id accId : idToUpdate)
        {
            stAccId.add(accId);
        }
        
        List<Agency_Info__c> lstAgencyInfo = [SELECT Id,Agency_Product_Fares__c, account__c,Active__c FROM Agency_Info__c WHERE Account__r.Id in :stAccId and Recordtype.Name = 'GDS'];
        Map<Id,List<Agency_Info__c>> mapAccountWiseAgencyInfo = new Map<Id,List<Agency_Info__c>>();
        
        if(!lstAgencyInfo.isEmpty())
        {
        For(Agency_Info__c agencyInfo : lstAgencyInfo)
        {
            if(mapAccountWiseAgencyInfo.containsKey(agencyInfo.account__c))
            {
                List<Agency_Info__c> lstAgncy = mapAccountWiseAgencyInfo.get(agencyInfo.account__c);
                lstAgncy.add(agencyInfo);
            }
            else
            {
                List<Agency_Info__c> lstAgncy = new List<Agency_Info__c>();
                lstAgncy.add(agencyInfo);
                mapAccountWiseAgencyInfo.put(agencyInfo.account__c,lstAgncy);
            }
        }
        
        For (Id accountIdToUpdate : mapAccountWiseAgencyInfo.keySet())
        {
            accProductList = '';
            uniqueProduct.clear();
            initialList.clear();
            productList.clear();
            if(!mapAccountWiseAgencyInfo.isEmpty())  
            {
                For (Agency_Info__c  tmcInfo : mapAccountWiseAgencyInfo.get(accountIdToUpdate))
                {
                    
                    String productFares = tmcInfo.Agency_Product_Fares__c;
                    If (productFares != null & tmcInfo.Active__c == True)
                    {
                        initialList.addAll(productFares.split(';'));
                    }
                }
            }
            If (!initialList.isEmpty())
            {
                uniqueProduct.addAll(initialList);
                uniqueProduct.remove(null);
                productList.addAll(uniqueProduct);
                accProductList = string.join(productList,';');
            }
            else
            {accProductList = '';}
            Account accountToUpdate = new Account();
            accountToUpdate.id = accountIdToUpdate;
            accountToUpdate.Agency_Product_Fare__c = accProductList;
            accListUpd.add(accountToUpdate);
        }
        }
        try 
        {
            if (!accListUpd.isEmpty())
            {
                update accListUpd;
            }
        }
        catch(DmlException e) 
        {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
}