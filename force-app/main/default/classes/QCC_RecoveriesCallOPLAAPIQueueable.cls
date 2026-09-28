/*----------------------------------------------------------------------------------------------------------------------
Author:        Cuong Ly
Company:       Capgemini
Description:   This Quequeable will be invoked by Recovery Trigger to generate Lounges Pass
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
19-Jun-2018      Cuong Ly               Build execute function
13-Oct-2021    Manjula Ravikumar        JIRA : CRM-5003 | Member API V2 Changes | Introduced differnt callouts and modified wrapper references 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_RecoveriesCallOPLAAPIQueueable implements Queueable, Database.AllowsCallouts  { 

    private List<Recovery__c> listRecoveries;

    /*--------------------------------------------------------------------------------------       
    Method Name:        QCC_RevoveriesCallOPLAAPIQueueable
    Description:        Contructer get the recoveries to execute
    Parameter:          set Id of recovery
    --------------------------------------------------------------------------------------*/
    public QCC_RecoveriesCallOPLAAPIQueueable(Set<Id> setRecoveryId){

        this.listRecoveries = [SELECT 
                                    Id, 
                                    Amount__c, 
                                    FF_Number__c, 
                                    Name, 
                                    Status__c, 
                                    Type__c,
                                    Case_Number__c,
                                    Case_Number__r.Contact.CAP_ID__c,
                                    contact__r.salutation, 
                                    Contact_First_Name__c,
                                    Contact_LastName__c,
                                    Case_Number__r.Contact_Email__c,
                                    LoungePassRequestTime__c,
                                    LoungePassReference__c,
                                    LoungePassErrorMessage__c,
                                    Recovery_System_log__c,
                                    API_Attempts__c
                                FROM 
                                    Recovery__c
                                WHERE 
                                    Id IN: setRecoveryId];
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        execute
    Description:        make callout to OPLA API and update status of recovery based on response from API
    Parameter:          Queueable Context
    --------------------------------------------------------------------------------------*/
    public void execute(QueueableContext context) {
        QCC_OPLALoungePassWrapper.Response oplaResp;
        Set<Id> recoveryIds = new Set<Id>();
        List<Case> cases = new List<Case>();
        String searchFFNumber = '';
        String firstName = '';
        String lastName = '';
        Boolean isSuccess = false;
        for(Recovery__c objRecovery : listRecoveries){
            searchFFNumber = '';
            /* Commented by Purushotham - QDCUSCON-5003 -- START -- Function not needed because there is no Contact for Non FF as part of Remediation
            if(objRecovery.FF_Number__c == null){
                Contact contactSearch = new Contact();
                system.debug('contactSearch.CAP_ID__c=' + objRecovery.Case_Number__r.Contact.CAP_ID__c);
                contactSearch.CAP_ID__c = objRecovery.Case_Number__r.Contact.CAP_ID__c;
                system.debug('contactSearch.CAP_ID__c=' + contactSearch.CAP_ID__c);
                if( GenericUtils.checkBlankorNull(contactSearch.CAP_ID__c)){
                    QCC_CustomerSearchHandler.ContactWrapper contactResult = QCC_CustomerSearchHandler.searchCustomer(contactSearch, '');
                    if(contactResult != null && GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c)){
                        //system.debug('QCC_RecoveriesCallOPLAAPIQueueable$$$$$$$$=' + GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c));
                        searchFFNumber = contactResult.contacts[0].Frequent_Flyer_Number__c; 
                    }
                } 
            }
            QDCUSCON-5003 -- END*/
            isSuccess = false;
            //system.debug('QCC_RecoveriesCallOPLAAPIQueueable objRecovery.FF_Number__c=' + objRecovery.FF_Number__c);
            // check if Frequent Flyer Number is Exist , make a callout
            if(objRecovery.FF_Number__c != null || GenericUtils.checkBlankorNull(searchFFNumber)){ 
                //Firstly, Call to loyalty API to check FF number 
                searchFFNumber = GenericUtils.checkBlankorNull(searchFFNumber) ? searchFFNumber : objRecovery.FF_Number__c;
                // Introduced new Member API V2 url - CRM 5003
                //  QCC_LoyaltyResponseWrapper loyaltyRes = QCC_InvokeCAPAPI.invokeLoyaltyAPI(searchFFNumber);
                QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyRes = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(searchFFNumber);  
                firstName = objRecovery.Contact_First_Name__c;
                lastName = objRecovery.Contact_LastName__c;
                /* Commented by Purushotham on 09 Aug 2018 as requested by Niket
                if(loyaltyRes != null && firstName.equalsIgnoreCase(loyaltyRes.firstName) && lastName.equalsIgnoreCase(loyaltyRes.lastName)){
                */
                if(loyaltyRes != null && lastName.equalsIgnoreCase(loyaltyRes.lastName)){
                    system.debug('QCC_RecoveriesCallOPLAAPIQueueable');             
                    // init OPLA Request
                    QCC_OPLALoungePassWrapper.Request oplaReq = initOPLARequest(objRecovery);
                    // call out
                    oplaResp = QCC_InvokeOPLAAPI.invokeLoungePassPostAPI(oplaReq);
                    isSuccess = oplaResp.isSuccess;
                    if(isSuccess){
                        // if callout is succeed update recovery as follow:
                        //changes by Navya for CDP2-348
                        objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusFinalised');
                        objRecovery.LoungePassRequestTime__c = System.now();
                        objRecovery.LoungePassReference__c = oplaResp.referenceNo;
                        objRecovery.LoungePassErrorMessage__c = '';
                        objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                        objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + 'OPLA API SUCCESS' + '</li></ul>' + objRecovery.Recovery_System_log__c;
                       
                    }else{
                        recoveryIds.add(objRecovery.Id);
                        // if callout is failed update recovery as follow:
                        objRecovery.LoungePassRequestTime__c = System.now();
                        objRecovery.LoungePassErrorMessage__c = oplaResp.errorMessage;
                        objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                        objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + ' Processing failed, please resubmit recovery' + '</li></ul>' + objRecovery.Recovery_System_log__c;
                        objRecovery.LoungePassReference__c = '';
                        objRecovery.API_Attempts__c = objRecovery.API_Attempts__c + 1;
                        //CDP2-348 Changes by Navya start
            
                        if(objRecovery.API_Attempts__c>=3){//Change this to 3 after testing 
                            objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                        }
                        
                    }
                }else{
                    recoveryIds.add(objRecovery.Id);
                    objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                    objRecovery.LoungePassErrorMessage__c = ' Customer\'s frequent flyer details are not valid';
                    objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                    objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + objRecovery.LoungePassErrorMessage__c + '</li></ul>' + objRecovery.Recovery_System_log__c;
                    objRecovery.LoungePassReference__c = '';
                    //CDP2-348 Changes by Navya start
                    //objRecovery.API_Attempts__c = objRecovery.API_Attempts__c + 1;
                }
            }else{
                recoveryIds.add(objRecovery.Id);
                objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                objRecovery.LoungePassErrorMessage__c = ' No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery';
                objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + objRecovery.LoungePassErrorMessage__c + '</li></ul>' + objRecovery.Recovery_System_log__c;
                objRecovery.LoungePassReference__c = '';
                //CDP2-348 Changes by Navya start
                //objRecovery.API_Attempts__c = objRecovery.API_Attempts__c + 1;
            }
            
        }
        Database.update(listRecoveries,false);
        postToChatter(recoveryIds);
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        initRoyaltyRequest
    Description:        initiate royal request
    Parameter:          Frequent flyer Number, Point of Recovery , LastName of contact, affected Passenger Name
    --------------------------------------------------------------------------------------*/ 
    private static QCC_OPLALoungePassWrapper.Request initOPLARequest(Recovery__c recovery){

        QCC_OPLALoungePassWrapper.Request oplaReq = new QCC_OPLALoungePassWrapper.Request();
        
        oplaReq.reference_no = recovery.Name;
        oplaReq.frequent_flyer_no = recovery.FF_Number__c;
        oplaReq.expiry_period = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Expiry Period');
        oplaReq.title = recovery.contact__r.Salutation;
        oplaReq.first_name = recovery.Contact_First_Name__c;
        oplaReq.last_name = recovery.Contact_LastName__c;
        oplaReq.email = recovery.Case_Number__r.Contact_Email__c;
        oplaReq.issuer_code = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Issuer Code');
        //System.debug('@@@@recovery.Type__c=' + recovery.Type__c);
        //System.debug('@@@@pass_type=' + CustomSettingsUtilities.getConfigDataMap(recovery.Type__c));
        oplaReq.pass_type = CustomSettingsUtilities.getConfigDataMap(recovery.Type__c);
        oplaReq.no_of_pass = String.valueOf(recovery.Amount__c);

        return oplaReq;
    }

    public static void postToChatter(Set<ID> recordIds)
    {   
        // Get those records based on the IDs
        List<Recovery__c> declinedRecoverys = [SELECT Id, Case_Number__c, Name, 
                                    Type__c, LoungePassErrorMessage__c, LoungePassReference__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id IN :recordIds];
        
        for(Recovery__c objRecovery: declinedRecoverys){
            if(!Test.isRunningTest()){
                String comments;
                if(GenericUtils.checkBlankorNull(objRecovery.LoungePassReference__c)){
                    comments = 'Recovery for' + objRecovery.Name + ' ' + objRecovery.Type__c + ' has been successful. Reference No: ' + objRecovery.LoungePassReference__c + '\n ';
                }else{
                    comments = 'OPLA API call unsuccessful Attempt 1 \n ' + objRecovery.LoungePassErrorMessage__c;
                }
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, objRecovery.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments); 
            }
        }
    }
}