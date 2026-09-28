/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir
Company:       Capgemini
Description:   Webservice Class to be create Account, QBR Product Registration(Real Time Syncing from ifly)
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
09-Nov-2017    Praveen Sampath               Initial Design
10-Nov-2017    Benazir Amir                  STME-3704
15-Nov-2017    Benazir Amir                  STME-3740
28-Nov-2017    Benazir Amir                  STME-3741
05-Dec-2017    Benazir Amir                  STME-3796
05-Dec-2017    Benazir Amir                  STME-3839
-----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/StoreQBRRegistration') 
global class CreateAccountQBRAPI {
    /*-------------------------------------------------------------------------------------------------------      
    Method Name:        create
    Description:        Creation of Account & QBR Produt Real Time Sync from Ifly
    Parameter:          NA
    ---------------------------------------------------------------------------------------------------------*/    
    @HttpPost
    global static void create(){
        Savepoint sp = Database.setSavePoint(); 
        Boolean isException = false;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonString;
        try{
            
            jsonString = RestContext.request.requestBody.toString();
            AccountQBRProductWrapper wrpAccQBRPrd = (AccountQBRProductWrapper)JSON.deserialize(jsonString, AccountQBRProductWrapper.class);
            system.debug('wrpAccQBRPrd####'+wrpAccQBRPrd);
            if(wrpAccQBRPrd != Null){
                if(wrpAccQBRPrd.company != Null){ 
                    AccountQBRProductWrapper.Company company = wrpAccQBRPrd.company;
                    
                        Boolean isValidABN =  (GenericUtils.checkBlankorNull(company.abn) && GenericUtils.checkABN(company.abn));
                        
                        Boolean isEligible = false; 
                        system.debug('isValidABN#####'+isValidABN);
                        if(GenericUtils.checkBlankorNull(wrpAccQBRPrd.airlineLevel) && 
                           GenericUtils.checkBlankorNull(company.gstRegistered) && 
                           GenericUtils.checkBlankorNull(company.entityType) &&
                           GenericUtils.checkBlankorNull(wrpAccQBRPrd.status) &&
                           GenericUtils.checkBlankorNull(wrpAccQBRPrd.membershipNumber) && 
                           GenericUtils.checkBlankorNull(company.industry) &&
                           GenericUtils.checkisNumeric(wrpAccQBRPrd.membershipNumber))
                        {
                            isEligible = true;
                        }
                        system.debug('isEligible#####'+isEligible);
                        
                        if(isValidABN && isEligible){
                            List<Account> lstAcc = fetchAccount(company.abn);
                            Account objAcc =  new Account();
                            system.debug('lstAcc####'+lstAcc);
                            //ABN Exist and No QBR Product Exist
                            if(lstAcc != Null && lstAcc.size() == 1){
                                objAcc = lstAcc[0];
                                Boolean isCreateQBR = checkBeforeProdRegCreate(objAcc.Id);
                                if(isCreateQBR){
                                    objAcc = updateAccount(wrpAccQBRPrd, objAcc);
                                    update objAcc; 
                                    
                                    Product_Registration__c objPrdReg = createQBRProductReg(wrpAccQBRPrd, objAcc.id);
                                    insert objPrdReg;
                                    res.statusCode = 200;
                                    res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiSuccess('Sucesfully Created','sucess.created'))); 
                                    
                                }else{
                                    //Send error when account has QBR
                                    res.statusCode = 400;
                                    res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiError('Account has already QBR','error.account.qbr.already.exists')));
                                    
                                }
                                //No ABN Exist and No QBR Product Exist
                            }else if(lstAcc == Null || lstAcc.size() == 0){
                                objAcc = createAccount(wrpAccQBRPrd);
                                insert objAcc;
                                system.debug('objAcc####'+objAcc);
                                Product_Registration__c objPrdReg = createQBRProductReg(wrpAccQBRPrd, objacc.id);
                                insert objPrdReg;
                                res.statusCode = 200;
                                res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiSuccess('Sucesfully Created','sucess.created'))); 
                                
                                system.debug('objPrdRegc####'+objPrdReg);
                            }else{
                                //Send Error multiple ABN
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiError('Multiple ABN','error.account.qbr.multiple.accounts')));
                            }
                        }else{
                            //Send Abn Error
                            res.statusCode = 400;
                            if(!isValidABN){
                                res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiError('ABN Validation Failure Occurred','error.account.qbr.validation.abn.invalid.format')));
                            }else{//Send AirlineEligibility Fields Error
                                res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiError('AirlineEligibility calculation Related Fields Validation Failure Occurred','error.account.qbr.airline.eligibility.calculation')));
                            }
                        }                        
                    
                }
            }
        }catch(Exception ex){
            Database.rollback(sp);
            system.debug('Exception###'+ex);
            isException = true;
            //Send Error cannot process the request sent 
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serializePretty(new ApiError('Exception Occurred','error.account.qbr.generic.error')));
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'RTS Sync Stream - CreateAccountQBRAPI', 'CreateAccountQBRAPI', 
                                    'create', jsonString, String.valueOf(''), true,'', ex);
            
        } 
        finally{
            if(CustomSettingsUtilities.getConfigDataMap('createIntegrationLogAccountQBRAPI') == 'Yes' && !isException){
                CreateLogs.insertLogRec( 'Log Integration Logs Rec Type', 'RTS Sync Stream - CreateAccountQBRAPI', 'CreateAccountQBRAPI', 
                                        'create',jsonString, String.valueOf(''), true, '', null);          
            }
        }
    }
    
    /*----------------------------------------------------------------------------------------------------------      
    Method Name:        fetchAccount
    Description:        Fetches the Account for a single ABN passed from Ifly
    Parameter:          Account ABN parameter 
    ------------------------------------------------------------------------------------------------------------*/    
    private static  List<Account> fetchAccount(String abn){
        Id freightRecordTypeId =  GenericUtils.getObjectRecordTypeId('Account', 'Freight Account');
        List<Account> lstAcc = [select Id, No_of_Aquires__c, No_of_inactive_QBR__c  from Account where ABN_Tax_Reference__c =: abn 
                                and RecordTypeId !=: freightRecordTypeId];
        return lstAcc;
    }
    
    /*--------------------------------------------------------------------------------------------------------------      
    Method Name:        checkBeforeProdRegCreate
    Description:        Conditional check for QBR Creation on no QBR Product/Deactivated QBR to an existing ABN
    Parameter:          Account ID
    -----------------------------------------------------------------------------------------------------------------*/    
    private static  Boolean checkBeforeProdRegCreate(Id AccId){
        Id aquireRecType =  GenericUtils.getObjectRecordTypeId('Product_Registration__c', 'Aquire Registration');
        for(Product_Registration__c prdReg: [select Id, Stage_Status__c   from Product_Registration__c 
                                             where Account__c =: AccId and RecordTypeId =: aquireRecType])
        {
            if(prdReg.Stage_Status__c != 'Deactivated'){ 
                return false;
            } 
        }
        return true;
    }
    
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        createAccount
    Description:        Create the Account from RealTime sync Ifly 
    Parameter:          AccountQBRProductWrapper
    ------------------------------------------------------------------------------------------------------------------*/    
    private static  Account createAccount(AccountQBRProductWrapper accInfo){
        Account objAcc = new account();
        objAcc.ABN_Tax_Reference__c = accInfo.company.abn;
        objAcc.Name = accInfo.company.name;
        objAcc.Aquire_Entity_Type__c = accInfo.company.entityType;
        String customsettingGSTName = 'IflyRealTimeSyncGSTRegistered'+accInfo.company.gstRegistered;
        objAcc.GST_Registered__c = CustomSettingsUtilities.getConfigDataMap(customsettingGSTName);
        objAcc.RecordTypeId =  GenericUtils.getObjectRecordTypeId('Account', 'Prospect Account');
        String customsettingLevelName = 'IflyRealTimeSyncAirlineLevel'+accInfo.airlineLevel;
        objAcc.Airline_Level__c = CustomSettingsUtilities.getConfigDataMap(customsettingLevelName);
        User objUser = [Select Id from user where Alias = 'jtang' limit 1];
        objAcc.ownerId = objUser != NUll?objUser.Id:userInfo.getUserId();
        return objAcc;
    }
    
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        updateAccount
    Description:        Create the Account from RealTime sync Ifly 
    Parameter:          AccountQBRProductWrapper
    --------------------------------------------------------------------------------------------------------------------*/    
    private static  Account updateAccount(AccountQBRProductWrapper accInfo, Account objAcc){
        objAcc.Aquire_Entity_Type__c = accInfo.company.entityType;
        String customsettingGSTName = 'IflyRealTimeSyncGSTRegistered'+accInfo.company.gstRegistered;
        objAcc.GST_Registered__c = CustomSettingsUtilities.getConfigDataMap(customsettingGSTName);
        String customsettingLevelName = 'IflyRealTimeSyncAirlineLevel'+accInfo.airlineLevel;
        objAcc.Airline_Level__c = CustomSettingsUtilities.getConfigDataMap(customsettingLevelName);
        return objAcc;
    }
    
    /*------------------------------------------------------------------------------------------------------------------      
    Method Name:        createQBRProductReg
    Description:        Creates QBR Product from Real Time sync Ifly for an Account 
    Parameter:          AccountQBRProductWrapper,AccountId
    --------------------------------------------------------------------------------------------------------------------*/    
    private static  Product_Registration__c createQBRProductReg(AccountQBRProductWrapper prdRegInfo, Id accId){
        Product_Registration__c objPrdReg = new Product_Registration__c();
        objPrdReg.RecordTypeId =  GenericUtils.getObjectRecordTypeId('Product_Registration__c', 'Aquire Registration');
        objPrdReg.Name = prdRegInfo.company.name;
        objPrdReg.Account__c = accId;
        objPrdReg.Aquire_Entity_Name__c = prdRegInfo.company.name;
        objPrdReg.Membership_Number__c = prdRegInfo.membershipNumber;
        String customsettingStatusName = 'IflyRealTimeSyncStatus'+prdRegInfo.status;
        objPrdReg.Stage_Status__c = CustomSettingsUtilities.getConfigDataMap(customsettingStatusName);
        objPrdReg.Enrolment_Date__c = prdRegInfo.membershipStartDate;
        String customsettingIndustry = 'Industry'+prdRegInfo.company.industry;
        objPrdReg.Aquire_Industry__c = CustomSettingsUtilities.getConfigDataMap(customsettingIndustry);
        return objPrdReg;
    }
    
}