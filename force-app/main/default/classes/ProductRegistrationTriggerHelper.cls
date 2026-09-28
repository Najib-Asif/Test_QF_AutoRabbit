/*----------------------------------------------------------------------------------------------------------------------
Author:        Benazir Amir
Company:       Capgemini
Description:   Class to be invoked from ProductRegistration Trigger
Inputs:
Test Class:    ProductRegistrationTriggerHelperTest. 
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
public class ProductRegistrationTriggerHelper {

    /*--------------------------------------------------------------------------------------      
    Method Name:        amexProdRegValidation
    Description:        Validate only one Active Amex product can be Added for an Account 
    Parameter:          ProductRegistration New Map And Old Map 
    --------------------------------------------------------------------------------------*/    
    public static void amexProdRegValidation(Map<Id,Product_Registration__c> newMapProdReg, Map<Id, Product_Registration__c> oldMapProdReg){
        try{
            Map<Id, Set<Id>> mapAccIdProdReg = new Map<Id, Set<Id>>();
            Set<Id> setAccId = new Set<Id>();
            Set<Id> setprodRegId = new Set<Id>();

            String amexRegRecTypeName = CustomSettingsUtilities.getConfigDataMap('Prd Reg AEQCC Registration Rec Type');
            Id amexRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c', amexRegRecTypeName);
            Boolean isEnabled = EnableValidationRule__c.getInstance().VR_To_enforce_the_No_Second_Active_AMEX__c;

            //From Hierarchy customseting enable this validation for the current user
            if(isEnabled){
                
                //Loop New Map
                for(Product_Registration__c prodReg: newMapProdReg.values()){
                    if(prodReg.RecordTypeId == amexRecId){
                        setAccId.add(prodReg.Account__c);
                        Set<Id> setTempId = mapAccIdProdReg.containsKey(prodReg.Account__c)? mapAccIdProdReg.get(prodReg.Account__c): new Set<Id>();
                        setTempId.add(prodReg.Id);
                        mapAccIdProdReg.put(prodReg.Account__c, setTempId);
                    }
                }

                //Only if Set is greated than zero
                if(setAccId.size()>0){
                    //Query to fetch All Active Amex product and gropu by Account
                    AggregateResult[] groupedResults = [SELECT Account__c, count(Id) activeAmexCount FROM Product_Registration__c 
                                                        where Account__c IN : setAccId and RecordTypeId =: amexRecId and  Active__c = true 
                                                        group by Account__c]; 

                    //Loop Aggregate result and add Error to Porduct that has more than one Active Amex
                    for(AggregateResult ar :groupedResults){
                        if((Integer) ar.get('activeAmexCount') > 1){
                            String accId = (String)ar.get('Account__c');
                            if(mapAccIdProdReg.containskey(accId)){
                                for(Id prodregId: mapAccIdProdReg.get(accId)){
                                    Product_Registration__c prodReg = newMapProdReg.get(prodregId);
                                    prodReg.addError(CustomSettingsUtilities.getConfigDataMap('ProdReg_MSG_No_Second_Avtive_Amex'));
                                }
                            }
                        }
                    }
                }

            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'amexProdRegValidation', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        processAccountAndOpportunity
    Description:        Create opportunity based on travel frequency, Change account type
    Parameter:          ProductRegistration New List 
    --------------------------------------------------------------------------------------*/    
    public static void processAccountAndOpportunity(List<Product_Registration__c> newList){
        try{
            ProductRegistrationHandler PRH = new ProductRegistrationHandler();
            PRH.processAccountAndOpportunity(newList);
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'processAccountAndOpportunity', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        calculateAMEXAcceptRejectCode
    Description:        Calculate the Qantas Accept or Reject Code for the AMEX Product
    Parameter:          ProductRegistration New Map and Old Map
    --------------------------------------------------------------------------------------*/    
    public static void calculateAMEXAcceptRejectCode(Map<Id, Product_Registration__c> newMapProdReg, Map<Id,Product_Registration__c> oldMapProdReg){
        try{
            
            Map<Id, String> mapAccCustomer = new Map<Id, String>(); 
            Map<Id, Boolean> mapAccAmexStatus = new Map<Id, Boolean>();
            Map<String, String> mapAmexResCode = new Map<String, String>(); 
            List<Account> lstUpdateAcc = new List<Account>();

            String amexRegRecTypeName = CustomSettingsUtilities.getConfigDataMap('Prd Reg AEQCC Registration Rec Type');
            Id amexRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c', amexRegRecTypeName);
            
            //Looping all Amex Product created or Edited
            for(Product_Registration__c prodReg: newMapProdReg.values()){
                Product_Registration__c oldProdReg = oldMapProdReg == Null? Null: oldMapProdReg.get(prodReg.Id);
                system.debug('prodReg#######'+prodReg);
                system.debug('oldProdReg######'+oldProdReg);
                system.debug('prodReg.RecordTypeId#####'+prodReg.RecordTypeId);
                system.debug('amexRecId#########'+amexRecId);
                system.debug('prodReg.Customer_s_Requested_Choice__c#######'+prodReg.Customer_s_Requested_Choice__c);
                if( prodReg.RecordTypeId == amexRecId && prodReg.Customer_s_Requested_Choice__c != '' &&
                    prodReg.Active__c && (oldProdReg == Null || 
                               ( prodReg.Customer_s_Requested_Choice__c != oldProdReg.Customer_s_Requested_Choice__c)))
                {
                    mapAccCustomer.put(prodReg.Account__c, prodReg.Customer_s_Requested_Choice__c);
                    //mapAccAmexStatus.put(prodReg.Account__c, prodReg.Active__c);
                }

                if( prodReg.RecordTypeId == amexRecId && (oldProdReg == Null || prodReg.Active__c != oldProdReg.Active__c)){
                    if(!mapAccAmexStatus.containsKey(prodReg.Account__c) || mapAccAmexStatus.get(prodReg.Account__c) == false){
                        mapAccAmexStatus.put(prodReg.Account__c, prodReg.Active__c);
                    }
                }
            }

            //Get All AMEX_Response_Code_Setting__mdt Value when mapAccCustomer is not Null
            if(mapAccCustomer.size() > 0){
                mapAmexResCode = CustomSettingsUtilities.getAllAmexResponseCode();
            }
            system.debug('mapAccCustomer#########'+mapAccCustomer);
            system.debug('mapAmexResCode#########'+mapAmexResCode);
            system.debug('mapAccAmexStatus#######'+mapAccAmexStatus);
            //Get All Accounts of Amex Product that are edited or Created 
            for(Account acc: [Select Id, Agency__c, Aquire_Override__c, Dealing_Flag__c, AMEX_response_Code__c from Account
                              where Id IN: mapAccAmexStatus.Keyset() or Id IN: mapAccCustomer.Keyset()])
            {
                if(mapAccCustomer.containsKey(acc.Id)){
                    acc.AMEX_response_Code__c = CustomSettingsUtilities.getAmexResponseCodeForAccount( mapAmexResCode, 
                                                                                                       acc.Agency__c, 
                                                                                                       acc.Dealing_Flag__c, 
                                                                                                       acc.Aquire_Override__c, 
                                                                                                       mapAccCustomer.get(acc.Id));
                }
                if(mapAccAmexStatus.containsKey(acc.Id)){
                    acc.AMEX__c = mapAccAmexStatus.get(acc.Id);
                }
                lstUpdateAcc.add(acc);
            }

            update lstUpdateAcc;

        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'calculateAMEXAcceptRejectCode', String.valueOf(''), String.valueOf(''),false,'',ex);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        updateAmexDetailsOnAquire
    Description:        Get all the amex details to update on corresponding aquire record
    Parameter:          ProductRegistration New List 
    --------------------------------------------------------------------------------------*/    
    public static void updateAmexDetailsOnAquire(List<Product_Registration__c> newList){
        try{
            clsAccountEligibilityHelper.updateAmexDetailsOnAquire(newList);
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'updateAmexDetailsOnAquire', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        updateRelatedAquireMembers
    Description:        
    Parameter:          ProductRegistration New List 
    --------------------------------------------------------------------------------------*/    
    public static void updateRelatedAquireMembers(Map<Id,Product_Registration__c> newMapProdReg){
        try{
            clsAquireRegistrationsHelper.updateRelatedAquireMembers(newMapProdReg);
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'updateRelatedAquireMembers', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
        
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateMembershipNumberonAccount
    Description:        Method to update the Membership# on Account, onl for QBR Product
    Parameter:          ProductRegistration New Map & Old Map 
    --------------------------------------------------------------------------------------*/    
    public static void updateMembershipNumberonAccount(Map<Id,Product_Registration__c> newMapProdReg, Map<Id,Product_Registration__c> oldMapProdReg){
        try{

            List<Account> lstUpdateAcc = new List<Account>();
            Set<Id> setAccId = new Set<Id>();
            String activeStatus = CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Status');
            //On Insert and Update of QBR Product
            if(newMapProdReg != Null){
                String acqRegRecTypeName = CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Rec Type');
                Id acqRecId = GenericUtils.getObjectRecordTypeId('Product_Registration__c', acqRegRecTypeName);
               
                for(Product_Registration__c prodReg: newMapProdReg.values()){
                    Product_Registration__c oldProdReg = oldMapProdReg != Null? oldMapProdReg.get(prodReg.Id): Null;
                    if(prodReg.RecordTypeId == acqRecId && ((oldProdReg != Null && 
                                                       ((oldProdReg.Stage_Status__c != prodReg.Stage_Status__c &&
                                                        (prodReg.Stage_Status__c == activeStatus ||  oldProdReg.Stage_Status__c == activeStatus)) || 
                                                        prodReg.Membership_Number__c != oldProdReg.Membership_Number__c || 
                                                        prodReg.Key_Contact_Office_ID__c != oldProdReg.Key_Contact_Office_ID__c ||
                                                        prodReg.GDS_QBR_Discount_Code__c != oldProdReg.GDS_QBR_Discount_Code__c)) 
                                                    || oldMapProdReg == Null)
                    ){
                        setAccId.add(prodReg.Account__c);
                    }
                }
            }
            //For Delete of QBR Product
            else{
                for(Product_Registration__c prodReg: oldMapProdReg.values()){
                    setAccId.add(prodReg.Account__c);
                }
            }
            system.debug('setAccId######'+setAccId);

            Map<Id, String> mapAccMembership = new Map<Id, String>();
            Map<Id, Product_Registration__c> mapAccProdReg = new Map<Id, Product_Registration__c>();
            //Looping All Product registration for the Account
            for(Product_Registration__c prodReg: [Select Id, Membership_Number__c, Account__c, Key_Contact_Office_ID__c,
                                                  GDS_QBR_Discount_Code__c, Account__r.No_of_Aquires__c, 
                                                  Account__r.Aquire_Membership_Number__c, Stage_Status__c
                                                  from Product_Registration__c where Account__c IN: setAccId])
            {
                system.debug('prodReg####'+prodReg.Key_Contact_Office_ID__c);
                system.debug('prodReg1111111###'+prodReg.GDS_QBR_Discount_Code__c);
                if(prodReg.Stage_Status__c == activeStatus){
                    if(!mapAccMembership.containsKey(prodReg.Account__c))
                        mapAccMembership.put(prodReg.Account__c, prodReg.Membership_Number__c);
                    else{
                        mapAccMembership.put(prodReg.Account__c, '');
                    }
                    mapAccProdReg.put(prodReg.Account__c, prodReg);
                }            
            }
            system.debug('mapAccMembership######'+mapAccMembership);
            system.debug('mapAccProdReg########'+mapAccProdReg);

            //Get All Account and Update Membership Number
            if(setAccId.size() > 0){
                for(Id accId: setAccId){
                    lstUpdateAcc.add(new Account( Id = accId,
                                                  Aquire_Membership_Number__c = mapAccMembership.containsKey(accId)? mapAccMembership.get(accId):'',
                                                  Indirect_Discount_Code__c = mapAccProdReg.containsKey(accId)? mapAccProdReg.get(accId).GDS_QBR_Discount_Code__c:'',
                                                  key_Contact_Office_ID__c = mapAccProdReg.containsKey(accId)? mapAccProdReg.get(accId).Key_Contact_Office_ID__c:''));
                }
            }
            system.debug('lstUpdateAcc######'+lstUpdateAcc);
            update lstUpdateAcc;
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'updateMembershipNumberonAccount', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createCaseOnMultipleActiveQBR
    Description:        Method to Create case when Multiple ACtive QBR created under an Account
    Parameter:          Account Old Map 
    --------------------------------------------------------------------------------------*/    
    public static void createCaseOnMultipleActiveQBR(Map<Id, Product_Registration__c> newMapAccount, Map<Id,Product_Registration__c> oldMapAccount){
       try{
            system.debug('newMapAccount#########'+newMapAccount);
            String recTypeName = CustomSettingsUtilities.getConfigDataMap('Case SystemAdmin RecordType');
            List<CreatecaseWrapper.caseWrapper> lstCaseWrapper = new List<CreatecaseWrapper.caseWrapper>();
            Set<Id> setAccId = new Set<Id>();
            Id recTypeId =  GenericUtils.getObjectRecordTypeId('Product_Registration__c', CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Rec Type'));
            for(Product_Registration__c prodReg: newMapAccount.values()){
                Product_Registration__c oldProdReg = oldMapAccount != Null? oldMapAccount.get(prodReg.Id): Null;
                system.debug('oldProdReg#######'+oldProdReg);
                system.debug('prodReg#########'+prodReg);
                if(oldProdReg == Null || prodReg.Account__c != oldProdReg.Account__c || 
                    prodReg.Stage_Status__c != oldProdReg.Stage_Status__c && prodReg.RecordTypeId == recTypeId){
                    setAccId.add(prodReg.Account__c);
                }

            }
            system.debug('setAccId#####3'+setAccId);

            AggregateResult[] groupedResults  = [SELECT Account__c, count(Id) activeCount FROM Product_Registration__c where 
                                                 Account__c IN: setAccId and Stage_Status__c = 'Active'  and RecordTypeId =: recTypeId
                                                 GROUP BY Account__c];
            
            for (AggregateResult ar : groupedResults)  {
                Integer prodRegActiveCount = (Integer) ar.get('activeCount');
                if(prodRegActiveCount > 1 && prodRegActiveCount < 3){
                    CreatecaseWrapper.caseWrapper caseWrap = new CreatecaseWrapper.caseWrapper();
                    caseWrap.recType = recTypeName;
                    caseWrap.accId = (String) ar.get('Account__c');
                    caseWrap.caseStatus = CustomSettingsUtilities.getConfigDataMap('CaseStatus_MultiQBR');
                    caseWrap.caseReason = CustomSettingsUtilities.getConfigDataMap('CaseReason_MultiQBR');
                    caseWrap.caseOrg = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_MultiQBR');
                    caseWrap.casePriority = CustomSettingsUtilities.getConfigDataMap('CasePriority_MultiQBR');
                    caseWrap.caseType = CustomSettingsUtilities.getConfigDataMap('CaseType_MultiQBR');                    
                    caseWrap.caseSubType = CustomSettingsUtilities.getConfigDataMap('CaseSubType_MultiQBR');
                    caseWrap.caseSubType2= CustomSettingsUtilities.getConfigDataMap('CaseSubType2_MultiQBR');
                    caseWrap.caseSubject = CustomSettingsUtilities.getConfigDataMap('CaseSubject_MultiQBR');
                    caseWrap.caseDesc = CustomSettingsUtilities.getConfigDataMap('CaseDescription_MultiQBR');
                    lstCaseWrapper.add(caseWrap);
                }
            }

            system.debug('lstCaseWrapper#######'+lstCaseWrapper);
            List<Case> lstCaseCreate = CreatecaseWrapper.createCaseMultipleACtiveQBR(lstCaseWrapper);
            insert lstCaseCreate; 
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Product Registration Trigger', 'ProductRegistrationTriggerHelper', 
                                     'createCaseOnMultipleActiveQBR', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
}