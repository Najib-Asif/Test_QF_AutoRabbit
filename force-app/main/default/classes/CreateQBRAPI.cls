/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Webservice Class to be create QBR Product Registration for an AMEX Product
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
24-APR-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/CreateQBR')
global with sharing class CreateQBRAPI  {

    @HttpPost
    global static void create(List<QBRProductRegWrapper> lstprodRegistrations) {
        Savepoint sp = Database.setSavePoint(); 
        Boolean isException = false;
        
        try{
            system.debug('lstprodRegistrations#####'+lstprodRegistrations);
            set<String> setAmexId = new Set<String>();
            for(QBRProductRegWrapper qbrProdWrap: lstprodRegistrations){
                setAmexId.add(qbrProdWrap.amexProductId);
            }

            //Map AmexId and Product Details 
            Map<Id, Product_Registration__c> mapAmexProdReg = createAmexProdRegMap(setAmexId);
            Set<Id> setAccId = new Set<Id>();
            for(Product_Registration__c prdReg: mapAmexProdReg.values()){
                setAccId.add(prdReg.Account__c);
            }
            Map<Id, Id> mapQBRPrdreg = createQBRProdRegMap(setAccId);

            List<Product_Registration__c> lstUpdatePrdReg = new List<Product_Registration__c>();
            List<Account> lstUpdateAcc = new List<Account>();
            for(QBRProductRegWrapper qbrProdWrap: lstprodRegistrations){
                system.debug('qbrProdWrap.qbrinfo#######'+qbrProdWrap.qbrinfo);
                //Set Amex detail
                Product_Registration__c amexProdReg = mapAmexProdReg.get(qbrProdWrap.amexProductId);
                Account acc = amexProdReg.Account__r;
                if(qbrProdWrap.qbrinfo != Null){
                    //amexProdReg.Process_Status__c = 'Success';
                    //Create QBR Or Update QBR
                    Product_Registration__c qbrProd = createQBRProductReg(qbrProdWrap.qbrinfo, acc);
                    if(mapQBRPrdreg.containsKey(acc.Id)){
                        qbrProd.Id = mapQBRPrdreg.get(acc.Id);
                    }
                    lstUpdatePrdReg.add(qbrProd);
                    //acc = updateAccount(acc, qbrProdWrap.qbrinfo);
                }
                
                //Adding for STME - 3360
                if(qbrProdWrap.enrolmentStatusCode!='' && qbrProdWrap.enrolmentStatusCode.startsWith('S') ){
                    amexProdReg.Process_Status__c = 'Success';
                    
                }
                else{
                    amexProdReg.Process_Status__c = 'Failure'; 
                }
                
                amexProdReg.AMEX_Accept_or_Reject_Code__c = qbrProdWrap.enrolmentStatusCode;
                amexProdReg.AMEX_Accept_or_Reject_Code_Description__c = qbrProdWrap.enrolmentStatusDescription;
                lstUpdatePrdReg.add(amexProdReg);

                //Update Account 
               
                acc.Qantas_Accept_or_Reject_Code__c = qbrProdWrap.enrolmentStatusCode;
                acc.Airline_Level__c = acc.Airline_Level__c == '' || acc.Airline_Level__c == Null ?amexProdReg.Airline_Level__c.remove('L'):acc.Airline_Level__c;
                lstUpdateAcc.add(acc);
                //acc = updateAccount(amexProdReg, qbrProdWrap.statusCode);
            }
            update lstUpdateAcc;
            upsert lstUpdatePrdReg;

        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug('Exception###'+ex);
            isException = true;
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Amex Stream - Create QBR API', 'CreateQBRAPI', 
                                     'create', String.valueOf(lstprodRegistrations), String.valueOf(''), true,'', ex);
            
        }
        finally{
            if(CustomSettingsUtilities.getConfigDataMap('createIntegrationLogQBRAPI') == 'Yes' && !isException){
               CreateLogs.insertLogRec( 'Log Integration Logs Rec Type', 'Amex Stream - Create QBR API', 'CreateQBRAPI', 
                                     'create', String.valueOf(lstprodRegistrations), String.valueOf(''), true, '', null);          
            }
        }

    }

    private static Map<Id, Product_Registration__c> createAmexProdRegMap(Set<String> setAmexId){
        Map<Id, Product_Registration__c> mapAmexPrdreg = new Map<Id, Product_Registration__c>();
        for(Product_Registration__c amexProdreg: [Select Id, Account__c, Account__r.Name, Account__r.Airline_Level__c,
                                                  Stage_Status__c, Airline_Level__c from Product_Registration__c 
                                                  Where Id IN: setAmexId])
        {
            mapAmexPrdreg.put(amexProdreg.Id, amexProdreg);
        }
        return mapAmexPrdreg;
    }

    private static Map<Id, Id> createQBRProdRegMap(Set<Id> setAccId){
        Map<Id, Id> mapQBRPrdreg = new Map<Id, Id>();
        Id qbrRectypeId =  GenericUtils.getObjectRecordTypeId('Product_Registration__c', CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Rec Type'));
        String activeStatus = CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Status');
        for(Product_Registration__c qbrProdreg: [Select Id, Stage_Status__c,Account__c from 
                                                  Product_Registration__c Where Account__c IN: setAccId and 
                                                  RecordTypeId =: qbrRectypeId and Stage_Status__c =: activeStatus ])
        {
            mapQBRPrdreg.put(qbrProdreg.Account__c, qbrProdreg.Id);
        }
        return mapQBRPrdreg;
    }
    
    private static Product_Registration__c createQBRProductReg(QBRProductRegWrapper.QBRProduct qbrInfo, Account acc){
        system.debug('qbrWrap#######'+qbrInfo);
        Product_Registration__c prdReg = new Product_Registration__c();
        prdReg.RecordTypeId =  GenericUtils.getObjectRecordTypeId('Product_Registration__c', CustomSettingsUtilities.getConfigDataMap('Prd Reg Aquire Registration Rec Type'));
        prdReg.Account__c = acc.Id;
        prdReg.Membership_Number__c = qbrInfo.membershipNumber;
        prdReg.Stage_Status__c = qbrInfo.membershipStatus;
        prdReg.Enrolment_Date__c = qbrInfo.membershipStartDate;
        prdReg.Name = acc.Name;
        prdReg.Aquire_Membership_Start_Date__c = qbrInfo.membershipStartDate;
        prdReg.Aquire_Membership_End_Date__c = qbrInfo.membershipEndDate;
        prdReg.Membership_Expiry_Date__c = qbrInfo.membershipEndDate;
        system.debug('prdReg#######'+prdReg);
        return prdReg;
    }

    
    /*private static Account updateAccount(Account acc, QBRProductRegWrapper.QBRProduct qbrInfo){
        acc.Industry =  qbrInfo.companyIndustry;
        acc.Airline_Level__c = qbrInfo.companyAirlineLevel;
        acc.GST_Registered__c = qbrInfo.companyGSTRegistered;
        acc.Aquire_Entity_Type__c = qbrInfo.companyEntityType;
        return acc;
    }*/
}