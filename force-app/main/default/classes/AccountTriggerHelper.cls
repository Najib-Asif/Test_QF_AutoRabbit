/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Class to be invoked from Account Trigger
Inputs:
Test Class:    AccountTriggerHelperTest. 
************************************************************************************************
History
************************************************************************************************
06-Mar-2017    Benazir S A               Initial Design
07-Mar-2017    Praveen Sampath          Added createDelAccountLogTracker Method
21-Apr-2017    Praveen/Benazir         Added createCaseOnMultipleActiveQBR Method
-----------------------------------------------------------------------------------------------------------------------*/
public class AccountTriggerHelper {
    public Static Set<Id> setRecTypeId = allNonFreightAccountRecordType();
    
    /*--------------------------------------------------------------------------------------      
Method Name:        updateAccountDetail
Description:        Method to Assign Amex Response Code
Parameter:          Account New List & Old Map 
--------------------------------------------------------------------------------------*/    
    public static void updateAccountDetail(List<Account> newlstAccount, Map<Id,Account> oldMapAccount){
        try{
            Set<Id> setAccId = new Set<Id>();
            Map<String, String> mapAmexResCode = new Map<String, String>();
            Map<Id, String> mapAccCustomer = new Map<Id, String>(); 
            
            
            for(Account acc: newlstAccount){
                Account oldAcc = oldMapAccount.get(acc.Id);
                if(acc.AMEX__c == true && acc.AMEX_response_Code__c != 'D' && setRecTypeId.contains(acc.RecordTypeId) &&
                   ( acc.Agency__c != oldAcc.Agency__c || acc.Aquire_Override__c != oldAcc.Aquire_Override__c || 
                    acc.Dealing_Flag__c != oldAcc.Dealing_Flag__c))
                {
                    setAccId.add(acc.Id);
                }
            }
            
            if(setAccId.size() > 0){
                Id amexRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c',  CustomSettingsUtilities.getConfigDataMap('Prd Reg AEQCC Registration Rec Type'));
                
                for(Product_Registration__c prodReg: [select Id, Customer_s_Requested_Choice__c, Account__c from Product_Registration__c
                                                      where Account__c IN: setAccId AND RecordTypeId =: amexRecId AND Active__c = true ])
                {
                    mapAccCustomer.put(prodReg.Account__c, prodReg.Customer_s_Requested_Choice__c);
                }
                
                if(mapAccCustomer.size() > 0){
                    mapAmexResCode = CustomSettingsUtilities.getAllAmexResponseCode();
                }
            }
            
            for(Account acc: newlstAccount){
                if(setAccId.contains(acc.Id)){
                    acc.AMEX_response_Code__c = CustomSettingsUtilities.getAmexResponseCodeForAccount( mapAmexResCode, 
                                                                                                      acc.Agency__c, acc.Dealing_Flag__c, acc.Aquire_Override__c,
                                                                                                      mapAccCustomer.get(acc.Id)); 
                }
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account Team - Account Trigger', 'AccountTriggerHelper', 
                                    'updateAccountDetail', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        updateAccountTeam
Description:        Method to Assign & create Account team members based on user department
Parameter:          Account New Map & Old Map 
--------------------------------------------------------------------------------------*/    
    public static void updateAccountTeam(Map<Id,Account> newMapAccount, Map<Id,Account> oldMapAccount){
        try{
            //AccountTeamHandler accHandler = new AccountTeamHandler(); // Commented on Feb 23 as this AccountTeamHandler class is no longer used
            List<Account> lstNewAccount = newMapAccount.values();
            // accHandler.setRevenueManualUpdate(lstNewAccount, oldMapAccount);
            //  accHandler.createAccountTeamMembers(lstNewAccount, oldMapAccount);
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account Team - Account Trigger', 'AccountTriggerHelper', 
                                    'updateAccountTeam', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        createAccountEligiblityLogs
Description:        Method to Create AccountIneligibilty Logs and Update
Parameter:          Account New Map & Old Map 
--------------------------------------------------------------------------------------*/    
    public static void createAccountEligiblityLogs(Map<Id,Account> newMapAccount, Map<Id,Account> oldMapAccount){
        try{
            AccountEligibilityLogHandler.createAccountEligiblityLogs(newMapAccount, oldMapAccount);
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account Team - Account Trigger', 'AccountTriggerHelper', 
                                    'createAccountEligiblityLogs', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        calculateDiscountCode
Description:        Method to DiscountCode Calculations on Products
Parameter:          Account New Map & Old Map 
--------------------------------------------------------------------------------------*/    
    public static void calculateDiscountCode(Map<Id,Account> newMapAccount, Map<Id,Account> oldMapAccount){
        try{
            AccountAirlineLevelHandler.updateDiscountCodeOnProducts(newMapAccount, oldMapAccount);
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account Team - Account Trigger', 'AccountTriggerHelper', 
                                    'calculateDiscountCode', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        createDelAccountLogTracker
Description:        Method to Create Delete Tracker Logs records when any Account is Deleted
Parameter:          Account Old Map 
--------------------------------------------------------------------------------------*/    
    public static void createDelAccountLogTracker(Map<Id,Account> oldMapAccount){
        try{
            String recTypeName = CustomSettingsUtilities.getConfigDataMap('Del Log SME Account Rec Type');
            List<CreateLogs.DeleteLogWrapper> lstDelLogWrapper = new List<CreateLogs.DeleteLogWrapper>();
            for(Account acc: oldMapAccount.values()){
                String directvalue = CustomSettingsUtilities.getConfigDataMap('AccListner Type Direct Stream');
                if(acc.Listner_Type__c == directvalue){
                    CreateLogs.DeleteLogWrapper delLogWrapper = new CreateLogs.DeleteLogWrapper();
                    delLogWrapper.recType = recTypeName;
                    delLogWrapper.recName =  acc.Name;
                    delLogWrapper.abnNumber = acc.ABN_Tax_Reference__c;
                    delLogWrapper.sobjectId = acc.Id;
                    delLogWrapper.sobjectName = 'Account';
                    lstDelLogWrapper.add(delLogWrapper);
                }
            }
            List<Delete_Tracker_Log__c> lstDelTrackerLog = CreateLogs.createDeleteLog(lstDelLogWrapper);
            insert lstDelTrackerLog;
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account Team - Account Trigger', 'AccountTriggerHelper', 
                                    'createDelAccountLogTracker', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    //Private Method to add Recortype
    private static Set<Id> allNonFreightAccountRecordType(){
        String allNonFreightAccRecType = String.isBlank(CustomSettingsUtilities.getConfigDataMap('Account RecType1'))?'':CustomSettingsUtilities.getConfigDataMap('Account RecType1');
        allNonFreightAccRecType += String.isBlank(CustomSettingsUtilities.getConfigDataMap('Account RecType2'))?'':CustomSettingsUtilities.getConfigDataMap('Account RecType2');
        allNonFreightAccRecType += String.isBlank(CustomSettingsUtilities.getConfigDataMap('Account RecType3'))?'':CustomSettingsUtilities.getConfigDataMap('Account RecType3');
        List<String> setAllRectypeName = allNonFreightAccRecType.split(';');
        
        Set<Id> setRecId = new Set<Id>();
        for(String recTypeName: setAllRectypeName){
            setRecId.add(GenericUtils.getObjectRecordTypeId('Account', recTypeName)); 
        }
        return setRecId;
    }
    /* Included as part of Global Registration
* To update Account Owner from Account_Manager__mdt
*/
    public static void beforeInsert(List<Account> accList)
    {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        List<Account> agencyAccounts = new List<Account>();
        Set<Id> salesRegionIds = new Set<Id>();
        for(Account acc:accList)
        {
            if(acc.recordtypeId==accRTId)
            {
                agencyAccounts.add(acc); 
                if (String.isNotBlank(acc.Agency_Sales_Region__c)) salesRegionIds.add(acc.Agency_Sales_Region__c);

            } 
        }
        if(agencyAccounts.size()>0)
        {
            OwnerUpdate(agencyAccounts, salesRegionIds);
        }
    }
    /* Included as part of Global Registration
* To update Account Owner from Account_Manager__mdt
*/
    public static void beforeUpdate(List<Account> listOfAcc, map<Id,Account> oldAccMap)
    {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        List<Account> countryChange = new List<Account>();
        Set<Id> salesRegionIds = new Set<Id>();
        String currentUser = [select Name from User where Id = :UserInfo.getUserId()].Name;
        Set<String> excludedUserNamesList = new Set<String>{'Marione Lozano','MARY ELEK','NADINE FERNANDESMONIZ'};
        for(Account acc: listOfAcc)
        {
            if(!excludedUserNamesList.contains(currentUser)){
                if((acc.billingcountrycode!=oldAccMap.get(acc.Id).billingcountrycode) && acc.recordtypeId==accRTId)
                {
                    countryChange.add(acc); 
                    if (String.isNotBlank(acc.Agency_Sales_Region__c)) salesRegionIds.add(acc.Agency_Sales_Region__c);
                }
                if(acc.recordtypeId==accRTId && String.isNotBlank(acc.Agency_Sales_Region__c) && acc.Agency_Sales_Region__c!= oldAccMap.get(acc.Id).Agency_Sales_Region__c)
                {
                    countryChange.add(acc);
                    salesRegionIds.add(acc.Agency_Sales_Region__c);
                }
            }
        }
        if(countryChange.size()>0)
        {
            OwnerUpdate(countryChange, salesRegionIds);
            
        }    
    }
    /* Included as part of Global Registration
* To update Account Owner from Account_Manager__mdt
*/
    public static void OwnerUpdate(List<Account> ownerTobeUpdated, Set<Id> salesRegionIds)
    {
        List<Account_Manager__mdt> ownerList = [Select Developername,Account_OwnerId__c,Country_Code__c, Agency_Sales_Region_Number__c from Account_Manager__mdt];
        Map<String, String> countryOwnerId = new Map<String,String>();
        Set<String> userId = new Set<String>();
        Map<String,User> activeUsers;
        Map<Id, Sales_Region__c> salesRegionRecs = new Map<Id, Sales_Region__c>([Select id, sales_h_region_id__c from Sales_Region__c where id in :salesRegionIds]);
        
        for(Account_Manager__mdt owner:ownerList)
        {
            countryOwnerId.put(owner.Country_Code__c + (owner.Agency_Sales_Region_Number__c ?? ''),owner.Account_OwnerId__c);
            userId.add(owner.Account_OwnerId__c);
        }
        activeUsers=new Map<String,User>([Select Id,IsActive from User where Id in : userId and IsActive=True]);
        for(Account acc: ownerTobeUpdated)
        {
            String key = acc.billingcountrycode + salesRegionRecs.get(acc.Agency_Sales_Region__c)?.sales_h_region_id__c;
            if( countryOwnerId.get(key)!=null && activeUsers.containskey(countryOwnerId.get(key))) {
                acc.OwnerId=countryOwnerId.get(key);
            }
            else if(countryOwnerId.get(acc.billingcountrycode)!=null && activeUsers.containskey(countryOwnerId.get(acc.billingcountrycode)))
            {
                acc.OwnerId=countryOwnerId.get(acc.billingcountrycode);
            }else{
                acc.OwnerId=countryOwnerId.get('DefaultOwner');
            }  
        }   
    }
    
    /*public static boolean run = true;
    public static boolean runOnce(){
        try{
            if(run) {
                run=false;
                return true;
            } else {
                return run;
            }
        }catch(System.NullPointerException e)
        {
            return run;
        }
    }*/
            
    
    public static void updateRelatedRecordsOnOwnerChange(List<Account> accNew, Map<Id,Account> accMap)
    {
        List<sObject> updateRelatedRecords = new List<sObject>();
        Map<Id,Id> accIdnewOwnerId = new Map<Id,Id>();
        String accRecordTypes = Label.Qantas_Sales_Account_Recordtypes;
        system.debug('accNew### '+accNew);
        system.debug('accMap'+accMap);
        
        for(Account acc : accNew)
        {
            String accRecordTypeDevName = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getDeveloperName();
            if(accRecordTypes.Contains(accRecordTypeDevName)) // Jira 5028
            {
                accIdnewOwnerId.put(acc.Id, acc.OwnerId);
                System.debug('accIdnewOwnerId'+accIdnewOwnerId);
            }
        }
        
        List<String> salesAssetRecordTypes = new List<String>();
        salesAssetRecordTypes.addAll(Label.Qantas_Sales_Asset_RecordTypes.split(';'));
        
        for(Asset a : [Select Id, Name, Status, Active__c, OwnerId, AccountId, RecordType.DeveloperName from Asset where 
                       AccountId IN :accIdnewOwnerId.keyset() AND RecordType.DeveloperName IN:salesAssetRecordTypes AND
                       (Status='Draft' OR Active__c = TRUE)])
        {
            if(a.OwnerId != accIdnewOwnerId.get(a.AccountId))
            {
                a.OwnerId = accIdnewOwnerId.get(a.AccountId);
                updateRelatedRecords.add(a);                
            }
        }
        
        Map<Id,Contract_Payments__c> updatedCP = new Map<Id,Contract_Payments__c>();
        List<Invoices__c> updatePayments = new List<Invoices__c>();
        for(Contract__c c : [Select Id, Account__c, (Select Id, Amount__c,OwnerId, Contract_Agreement__c from Contract_Payments__r) 
                             from Contract__c where Account__c IN:accIdnewOwnerId.keyset() AND Active__c = true])
        {
            for(Contract_Payments__c cp : c.Contract_Payments__r)
            {
                if(cp.OwnerId != accIdnewOwnerId.get(c.Account__c))
                {
                    cp.OwnerId = accIdnewOwnerId.get(c.Account__c);
                    updatedCP.put(cp.Id,cp);
                    updateRelatedRecords.add(cp);                    
                }
            }
        }
        
        for(Invoices__c payments : [Select Id, OwnerId, Contract_Payments__c from Invoices__c where 
                                    Contract_Payments__c IN:updatedCP.keyset()])
        {
            if(payments.OwnerId != updatedCP.get(payments.Contract_Payments__c).OwnerId)
            {
                payments.OwnerId = updatedCP.get(payments.Contract_Payments__c).OwnerId;
                updateRelatedRecords.add(payments);     
            }           
        }
        
        if(updateRelatedRecords.size()>0)
        {
            Database.SaveResult[] srList = Database.update(updateRelatedRecords, false);
            
            system.debug('update result '+srList);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Records Successfully Updated');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.' +err.getStatusCode() + ': ' + err.getMessage());                    
                    }
                }
            }     
        }
    }


    public static void updateDomainFromAccountEmail(List<Account> accountList, Map<Id, Account> oldAccountMap) {
        Account oldAccountRec;
        for (Account accRecord : accountList) {
            oldAccountRec = (oldAccountMap == null) ? null : oldAccountMap.get(accRecord.Id);
            if (String.isNotBlank(accRecord.Email__c) 
                && (oldAccountRec == null || accRecord.Email__c != oldAccountRec.Email__c)) 
            {
                accRecord.Account_Domain__c = accRecord.Email__c.substringAfter('@');
            }
        }
    }
}