/*****************************************************************************************
* Created By : Veni Gonzales | ACN | Developer 
* Purpose : This controller is used in the following LWCs: qccCallDetailsMainContainer, 
*           QccCallWrapUpContainer
* REST API :
* Modified Date   : 06/04/2023 (DD/MM/YYYY)
* Modified By     : Veni Gonzales
* JIRA            : ADT-11, ADT-186, ADT-201
* Version         : 1.2 Initial Development (Veni)
******************************************************************************************/
public with sharing class QCCTaskController {

     /************************************
     * Purpose      : Used in QccCallDetailsMainContainer
     * Parameters   : Interaction Id, Case Number and Case Id
     * Returns      : List<Case>
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseDetails( String interaction, String caseNumber, String caseId) {     
        system.debug('>>>getCaseDetails - interaction: ' + interaction);
        system.debug('>>>getCaseDetails - caseNumber: ' + caseNumber);
        system.debug('>>>getCaseDetails - outbound caseId: ' + caseId);
        Case[] curCaseDetails;
        
        if (String.isNotBlank(caseId)) { //Outbound scenario
            curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, ContactId, Contact.Frequent_Flyer_Tier__c, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE Id = :caseId];
        } else {//Inbound scenario
            curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, ContactId, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE InteractionId__c =: interaction AND InteractionId__c != ''];
        }
        
        //old query
        /*Case[] curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE CaseNumber =: caseNumber 
            OR (InteractionId__c =: interaction AND InteractionId__c != '')
            OR Id = :caseId
        ];*/

        if(curCaseDetails.isEmpty()) {
            throw new AuraHandledException('Empty string.');
            //return null;
        } else {
            return curCaseDetails;
        }
    }
    
    /************************************
     * Purpose      : Used in QccCallWrapUpContainer to get Task data based on active interaction Id
     * Parameters   : interaction Id
     * Returns      : List<Task>
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=true)
    public static List<Task> getCaseFromTask( String interaction ) {     
    
        Task[] curCaseDetails = [
            SELECT Id, WhatId, What.Name, CallObject, CallType, QCC_IVR_Selection__c, QCC_Call_Reason__c FROM TASK 
            WHERE CallObject != ''
            AND CallObject =: interaction 
        ORDER BY Created_Date_Time_System__c DESC
            LIMIT 1
        ];

        if(curCaseDetails.isEmpty()) {
            //throw new AuraHandledException('Empty string.');
            return null;
        } else {
            return curCaseDetails;
        }
    }
    
    /************************************
     * Purpose      : Used in QccCallWrapUpContainer to get Task data based on recordId and is TaskSubtype Call
     * Parameters   : recordId
     * Returns      : List<Task>
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=false)
    public static List<Task> getLatestTask( String recordId ) {     
    
        Task[] latestTask = [
            SELECT Id, WhatId, CallObject, CallType, TaskSubtype, QCC_IVR_Selection__c
            FROM Task WHERE WhatId =: recordId 
            AND TaskSubtype = 'Call'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        return latestTask;
    }
    
    /************************************
     * Purpose      : Used in QccCallWrapUpContainer
     * Parameters   : IVR Value selected
     * Returns      : List<QCC_Case_Record_Type_IVR__mdt>
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=false)
    public static List<QCC_Case_Record_Type_IVR__mdt> getCallReason( String ivrSelected ) {     
    
    QCC_Case_Record_Type_IVR__mdt[] callReason = [
            SELECT Id, MasterLabel, Call_Reason__c 
            FROM QCC_Case_Record_Type_IVR__mdt WHERE MasterLabel =: ivrSelected
    ];
        
        if(callReason.isEmpty()) {
            //throw new AuraHandledException('Empty string.');
            return null;
        } else {
            return callReason;
        } 
    }
    
    /************************************
     * Purpose      : Used in QccCallWrapUpContainer
     * Parameters   : Interaction Id, Call Reason
     * Returns      : Wrapup Code
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=false)
    public static String getCallReasonWrapupCode( String interactionId) {  
        String wrapUpCode = '';
        Task[] taskForWrapUp = [
            SELECT Id, WhatId, What.Name, CallObject, CallType, QCC_IVR_Selection__c, QCC_Call_Reason__c FROM TASK 
            WHERE CallObject != ''
            AND CallObject =: interactionId 
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (!taskForWrapUp.isEmpty()) {
            String callReason = taskForWrapUp.get(0).QCC_Call_Reason__c;
            QCC_Call_Reason_Wrapup_Code__mdt[] callReasonWrapupCode = [
                SELECT Id, MasterLabel, Wrapup_Code__c 
                FROM QCC_Call_Reason_Wrapup_Code__mdt WHERE MasterLabel =: callReason
            ];
            
            if (!callReasonWrapupCode.isEmpty()) {
                wrapUpCode = callReasonWrapupCode.get(0).Wrapup_Code__c;
            }
        }
    
        if (String.isNotBlank(wrapUpCode)) {
            return wrapUpCode;
        } else {
            return wrapUpCode; //TO-DO: Need to set default wrap-up in case it fails
        }
        
        
        
    }
    
    /************************************
     * Purpose      : Used in QccCallWrapUpContainer to get Case data based on interaction Id and Case Id
     * Parameters   : Interaction Id and Case Id
     * Returns      : List<Case>
     * Throws       : 
     * Expectations : 
     ************************************/
    @AuraEnabled(cacheable=false)
    public static List<Case> getCaseDetailsBasedOnInteraction(String interaction, String caseId, String outboundCaseId) {     
        system.debug('>>>getCaseDetailsBasedOnInteraction - interaction: ' + interaction);
        system.debug('>>>getCaseDetailsBasedOnInteraction - inbound case Id: ' + caseId);
        system.debug('>>>getCaseDetailsBasedOnInteraction - outboundCaseId: ' + outboundCaseId);
        Case[] curCaseDetails;
        
        if (String.isNotBlank(outboundCaseId)) {
            curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE Id = :outboundCaseId];
        } else {
            curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE InteractionId__c =: interaction AND InteractionId__c != ''
            AND Id =: caseId];
        }
        
        //old query
        /*Case[] curCaseDetails = [
            SELECT Id, CaseNumber, Booking_PNR__c, InteractionId__c, Contact.Name, Contact.Frequent_Flyer_Number__c  
            FROM Case WHERE (InteractionId__c =: interaction AND InteractionId__c != ''
            AND Id =: caseId) OR Id = :outboundCaseId
        ];*/
        
        if(curCaseDetails.isEmpty()) {
            //throw new AuraHandledException('Empty string.');
            return null;
        } else {
            return curCaseDetails;
        } 
    }
    
    /************************************
     * Purpose      : Used in qccSendWrapUpCode LWC to stamp the AWS URL connection that can be used for investigation in case wrap-up is not successful
     * Parameters   : awsURLConnection, taskRecordId
     * Returns      : void
     * Throws       : 
     * Expectations : Updates the task record with the AWS URL Connection
     ************************************/
    @AuraEnabled(cacheable=false)
    public static Task stampAWSURLRedirect(String awsURLConnection, String taskRecordId) {
        Task taskForUpdate;
        try{
            
            if (String.isNotBlank(taskRecordId)) {
                List<Task> tasks = new List<Task>([SELECT Id, TECH_Genesys_Wrapup_URL__c FROM Task WHERE Id =:taskRecordId LIMIT 1]);
                if (!tasks.isEmpty()) {
                    taskForUpdate = tasks.get(0);
                    taskForUpdate.TECH_Genesys_Wrapup_URL__c = awsURLConnection;
                    update taskForUpdate;
                }
            }
            return taskForUpdate;
            
        } catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCCTaskController', 'QCCTaskController',
                                    'stampAWSURLRedirect', String.valueOf(''), String.valueOf(''),false,'', ex);
            return taskForUpdate;
        }
    }
    
    /************************************
     * Purpose      : Used in qccCallDetailsMainContainer LWC to stamp the FF number on Voice case to show bookings
     * Parameters   : caseFFnum, caseRecordId
     * Returns      : void
     * Throws       : 
     * Expectations : Updates the case record with the FF number
     ************************************/
    @AuraEnabled(cacheable=false)
    public static void stampFFOnCase(String caseFFnum, String caseNum) {
        Case caseForUpdate;
        try{
            
            if (String.isNotBlank(caseNum)) {
                List<Case> Cases = new List<Case>([SELECT Id, Frequent_Flyer_Number__c FROM Case WHERE casenumber =:caseNum LIMIT 1]);
                if (!Cases.isEmpty()) {
                    caseForUpdate = Cases.get(0);
                    caseForUpdate.Frequent_Flyer_Number__c = caseFFnum;
                    update caseForUpdate;
                }
            }
            
            
        } catch(Exception ex){
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCCTaskController', 'QCCTaskController',
                                    'stampFFOnCase', String.valueOf(''), String.valueOf(''),false,'', ex);
            
        }
    }
    /*Method Name:createTransferTask */
    @AuraEnabled(cacheable=false)
    public static void createTransferTask(String getMessage) 
    {
        system.debug('>>> received message in controller'+ getMessage);
        Id tastRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        try {
            Map<String,Object> getMsgData = (Map<String,Object>)JSON.deserializeUntyped(getMessage);
            String interactionId=String.valueOf(getMsgData.get('data'));
            List<Task> getTask=[select id,qcc_IVR_Phone_Number__c,WhatId from task where callobject=:interactionId and WhatId!=null order by createddate desc limit 1];
            Task t = new Task();
            t.Status = 'In Progress';
            t.Subject='Transfer Call';
            t.Type='Call';
            t.CallObject=interactionId;
            t.recordTypeId = tastRecordTypeId;
            t.ActivityDate=System.today();
            t.OwnerId=userinfo.getuserid();
            if(getTask!=null && getTask.size()>0)
            {
                t.qcc_IVR_Phone_Number__c=getTask[0].qcc_IVR_Phone_Number__c;
                t.whatid=getTask[0].WhatId;
            }

            upsert t;
        } catch (Exception ex) {
            system.debug('ex######'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCCTaskController', 'QCCTaskController',
                                    'createTransferTask', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
}