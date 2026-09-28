/*-----------------------------------------------------------------------------------------
    Author: Nga Do
    Company: Capgemini
    Description: 
    Inputs: 
    Test Class: QCC_RecoveriesCallOPLAAPIBatchableTest
    ***************************************************************************************
    History:
    ***************************************************************************************
    22-June-2018
    ***************************************************************************************
    13-Oct-2021    
    JIRA : CRM-5003 | Member API V2 Changes | Introduced differnt callouts and modified wrapper references 
 ------------------------------------------------------------------------------------------*/
global class QCC_RecoveriesCallOPLAAPIBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {

    
    global QCC_RecoveriesCallOPLAAPIBatchable() { 
        
    }
    /*--------------------------------------------------------------------------------------       
    Method Name:        start
    Description:        get all LP recovery has Declined status, and Attempts call API less than 3 times
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id, 
                                            Amount__c, 
                                            FF_Number__c, 
                                            Name, 
                                            Status__c, 
                                            Case_Number__c,
                                            Case_Number__r.Contact.CAP_ID__c,
                                            Contact__r.Salutation,
                                            Contact__r.Frequent_Flyer_Number__c, 
                                            Contact_First_Name__c,
                                            Contact_LastName__c,
                                            Case_Number__r.Contact_Email__c,
                                            LoungePassRequestTime__c,
                                            LoungePassReference__c,
                                            LoungePassErrorMessage__c,
                                            Recovery_System_log__c,
                                            Type__c,
                                            API_Attempts__c 
                                         FROM Recovery__c 
                                         WHERE Type__c =: CustomSettingsUtilities.getConfigDataMap('RecoveryTypeLoungePasses')
                                         AND Status__c = :CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved')
                                         AND API_Attempts__c < 3 AND (RecordType.DeveloperName='Customer_Connect' OR RecordType.DeveloperName='Other_Recovery')]);

    }
    /*--------------------------------------------------------------------------------------       
    Method Name:        execute
    Description:        retry to call to OLAP and update status of recovery, api call attempts
    Parameter:          List Recoveries
    --------------------------------------------------------------------------------------*/ 
    global void execute(Database.BatchableContext BC, List<Recovery__c> recoveries) {
        
        System.debug('######recoveries#####' + recoveries);
        QCC_OPLALoungePassWrapper.Response oplaResp;
        Set<Id> caseIds = new Set<Id>();
        Map<String, Id> mapQueue = new Map<String, Id>();
        Map<Id, String> mapRecoveryErrors = new Map<Id, String>();
        List<Recovery__c> errorRecoveries = new List<Recovery__c>();

        String searchFFNumber = '';
        String firstName = '';
        String lastName = '';

        for(Recovery__c objRecovery : recoveries){
            searchFFNumber = '';
            /* Commented by Purushotham - QDCUSCON-5003 -- START -- Function not needed because there is no Contact for Non FF as part of Remediation
            if(objRecovery.FF_Number__c == null){
                Contact contactSearch = new Contact();
                system.debug('#####QCC_RecoveriesCallOPLAAPIBatchable contactSearch.CAP_ID__c=' + objRecovery.Case_Number__r.Contact.CAP_ID__c);
                contactSearch.CAP_ID__c = objRecovery.Case_Number__r.Contact.CAP_ID__c;
                system.debug('#####QCC_RecoveriesCallOPLAAPIBatchable contactSearch.CAP_ID__c=' + contactSearch.CAP_ID__c);
                if( GenericUtils.checkBlankorNull(contactSearch.CAP_ID__c)){
                    QCC_CustomerSearchHandler.ContactWrapper contactResult = QCC_CustomerSearchHandler.searchCustomer(contactSearch, '');
                    if(contactResult != null && GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c)){
                        system.debug('#####QCC_RecoveriesCallOPLAAPIBatchable QCC_RecoveriesCallOPLAAPIQueueable$$$$$$$$=' + GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c));
                        searchFFNumber = contactResult.contacts[0].Frequent_Flyer_Number__c; 
                    } 
                }
            }
			QDCUSCON-5003 -- END*/
            Boolean isSuccess = false;
            String additionalComment;
            String comments;
            // check if Frequent Flyer Number is Exist , make a callout
            if(objRecovery.FF_Number__c != null || GenericUtils.checkBlankorNull(searchFFNumber)){

                searchFFNumber = GenericUtils.checkBlankorNull(searchFFNumber) ? searchFFNumber : objRecovery.FF_Number__c;
                //Added for Deployement
				QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyRes;
                try{
                    // Introduced new Member API V2 url - CRM 5003
                    //loyaltyRes = QCC_InvokeCAPAPI.invokeLoyaltyAPI(searchFFNumber);
                    loyaltyRes = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(searchFFNumber);  
                }catch(Exception ex){
                    system.debug('ex####'+ex);
                }
                    firstName = objRecovery.Contact_First_Name__c;
                lastName = objRecovery.Contact_LastName__c;
                /* Commented by Purushotham on 09 Aug 2018 as requested by Niket
                if(loyaltyRes != null && firstName.equalsIgnoreCase(loyaltyRes.firstName) && lastName.equalsIgnoreCase(loyaltyRes.lastName)){
                */   
                if(loyaltyRes != null && lastName.equalsIgnoreCase(loyaltyRes.lastName)){
                    system.debug('QCC_RecoveriesCallOPLAAPIBatchable');

                    // init Loyalty Request
                    QCC_OPLALoungePassWrapper.Request oplaReq = initOPLARequest(objRecovery);
                    // call out
                    oplaResp = QCC_InvokeOPLAAPI.invokeLoungePassPostAPI(oplaReq);
                    isSuccess = oplaResp.isSuccess;
                }else{
                    additionalComment = ' Customer\'s frequent flyer details are not valid';
                }
            }else{

                additionalComment = ' No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery';
                objRecovery.LoungePassErrorMessage__c =' No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery';
            }
            System.debug('######additionalComment#####' + additionalComment);
            System.debug('######isSuccess#####' + isSuccess);
            System.debug('######oplaResp#####' + oplaResp);
            if(isSuccess){
                // if callout is succeed update recovery as follow:
                objRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
                objRecovery.LoungePassRequestTime__c = System.now();
                objRecovery.LoungePassReference__c = oplaResp.referenceNo;
               	objRecovery.LoungePassErrorMessage__c ='';
                objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + 'OPLA API SUCCESS' + '</li></ul>' + objRecovery.Recovery_System_log__c;
            }else{
                // if callout is failed update recovery as follow:
                //Commented by Navya for CDP2-348 changes
                //objRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                objRecovery.LoungePassRequestTime__c = System.now();
                if(oplaResp != null){
                    objRecovery.LoungePassErrorMessage__c = oplaResp.errorMessage;

                }else{
                    objRecovery.LoungePassErrorMessage__c = additionalComment;
                }
                objRecovery.API_Attempts__c = objRecovery.API_Attempts__c == null? 1: objRecovery.API_Attempts__c + 1;
                comments = additionalComment == null ? 'OPLA API call unsuccessful Attempt #'+ Integer.valueOf(objRecovery.API_Attempts__c) : 'OPLA API call unsuccessful Attempt #'+ Integer.valueOf(objRecovery.API_Attempts__c) + '\n' + additionalComment;
                if(objRecovery.API_Attempts__c >= 3){
                    //CDP2-348 changes by Navya
                    objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                    objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + ' Processing failed, please resubmit recovery' + '</li></ul>' + objRecovery.Recovery_System_log__c;
                    objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                    caseIds.add(objRecovery.Case_Number__c);
                }
                errorRecoveries.add(objRecovery);
                mapRecoveryErrors.put(objRecovery.Id, comments);
            }
        }
        Database.update(recoveries,false);
        System.debug('######caseIds#####' + caseIds);
        List<Case> casesToUpdate = new List<Case>();
        for(QueueSobject  queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where 
                                     SobjectType ='Case']){
                mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
        }

        // After 3 times failed, update status of Case and bounce back to queue
        if(caseIds != null && caseIds.size() > 0) {
            for(Case cs: [SELECT Id, Status, Cabin_Class__c, Frequent_Flyer_Tier__c FROM Case WHERE Id IN :caseIds]) {
                //CDP2-348 changes by Navya
                //cs.Status = CustomSettingsUtilities.getConfigDataMap('RecoveryError');
                //String queueName = 'Fulfillment_Queue';
                //cs.OwnerId = mapQueue.get(queueName);
                cs.OwnerId = UserInfo.getUserId(); 
                casesToUpdate.add(cs);
            }
        }
        System.debug('######casesToUpdate#####' + casesToUpdate);
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
        for(Recovery__c errObject : errorRecoveries){
            if(mapRecoveryErrors.containsKey(errObject.Id)){
                if(!Test.isRunningTest()) {
                    System.debug('errObject.Case_Number__c:::'+errObject.Case_Number__c);
                    System.debug('ConnectApi.FeedElementType.FeedItem:::'+ConnectApi.FeedElementType.FeedItem);
                    System.debug('mapRecoveryErrors.get(errObject.Id):::'+mapRecoveryErrors.get(errObject.Id));
                    //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, rec.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments);
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, errObject.Case_Number__c, ConnectApi.FeedElementType.FeedItem, mapRecoveryErrors.get(errObject.Id));
                    //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, objRecovery.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments);
                }   
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {

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
        oplaReq.pass_type = CustomSettingsUtilities.getConfigDataMap(recovery.Type__c);
        oplaReq.no_of_pass = String.valueOf(recovery.Amount__c);

        return oplaReq;
    }
}