/***************************
* Created By : Van Cabezas | ACN | Developer 
* Purpose : Apex Extension Class
* REST API : No Rest API Needed

Modified Date   : 08/03/23 (DD/MM/YYYY)
Modified By     : Van Cabezas
JIRA            : ADT-25
Version         : 1.1 -Initial Development | van
                : 1.2 -Test Class for On Screen pop (ADT-207) | van | 08/03/23
Test Class      : QCC_PurecloudExtensionTest
*/
global without sharing class QCC_PurecloudExtension implements 
    purecloud.CTIExtension.ClickToDial,
    purecloud.CTIExtension.ScreenPop,
    purecloud.CTIExtension.SaveLog {
        
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
    Id tastRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
    Map<String, schema.RecordTypeInfo> mapCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    /***************************
    *  Purpose              : Upsert Task Record when view in Salesforce Button in the softphone or Upon call is disconnected.
    *   Parameters          : String data
    *   Returns             : Task Id String
    * 
    *   Throws
    *   Expectations        : 
    */
    public String onSaveLog(String data) {
        // Example: Save interaction log as Task record after interaction is disconnected.
        
        Map<String, Object> saveLogData = (Map<String, Object>) JSON.deserializeUntyped(data);
        Map<String, Object> interaction = ( Map<String, Object>) saveLogData.get('interaction');
        Map<String, Object> attributes = (interaction.containsKey('attributes')) ? ( Map<String, Object>) interaction.get('attributes') : new Map<String, Object>();
        Map<String, Object> callLog = ( Map<String, Object>) saveLogData.get('callLog');
        //CRM-8694 Adding Safe Navigation Operator to Avoid Null Pointer Exceptions
        Boolean isDisconnected = (Boolean)interaction?.get('isDisconnected');
        String callState = (String) interaction?.get('state');
		String interactionId=(String)interaction?.get('id');
        system.debug('>>> Genesys interaction id'+interactionId);
        Map<String, Object> dataToReturn = new Map<String, Object>();
        system.debug('>>>onsaveLog DATA: ' + JSON.serializePretty(saveLogData));
        system.debug('>>>onsaveLog eventName: ' + saveLogData?.get('eventName'));
        String callLogId = '';
        String caseId;
        
          
            if(callState=='CONNECTED' || callState=='DISCONNECTED')
            {
                system.debug('Inside the call state block');
                updateOwnerCallLog(saveLogData);
            }
        
        



        Task t = (Task) JSON.deserialize(JSON.serialize(callLog), Task.class);
        t.Status = 'In Progress';
        t.recordTypeId = tastRecordTypeId;
        
        if (isDisconnected) {
            System.debug('Disconnected is True');
            t.Status = 'Completed';
        }
            
        string callType = String.valueOf(interaction?.get('direction'));
        system.debug('>>>onsaveLog callType 56: '+callType);
        Boolean isMessage = Boolean.valueOf(interaction?.get('isMessage'));
        system.debug('>>>onsaveLog isMessage 58: '+isMessage);
        Boolean isInternal = Boolean.valueOf(interaction?.get('isInternal'));
        system.debug('>>>onsaveLog isInternal 60: '+isInternal);
        string phoneCalled = String.valueOf(interaction?.get('phone'));
        system.debug('>>>onsaveLog phoneCalled 62: '+phoneCalled);
        string isAuthenticated = string.valueOf(attributes?.get('Participant.QFFAuthenticationStatus'));
        system.debug('>>>onsaveLog isAuthenticated 64: '+isAuthenticated);
        //CRM-8697 Populate IVR Selection on task
        String participantSelectedIvr = (String) attributes?.get('Participant.EnquiryType');
        system.debug('>>>onsaveLog participantSelectedIvr 66: '+participantSelectedIvr);
        String participantTransferNote = (String) attributes?.get('Participant.TransferNotes');//CRM-9224
        system.debug('>>>onsaveLog participantTransferNote 69: '+participantTransferNote);
        
        if(callType == 'Inbound'){
            t.Subject = 'Call';
        } else if(callType == 'Outbound'){
            t.Subject = 'Outbound Call';
        }
        if(String.isNotBlank(phoneCalled)) //IVR Number to store the caller's phone number
        {
            t.qcc_IVR_Phone_Number__c=phoneCalled;
        }
         //CRM-8697 Populate IVR Selection on task
        if(String.isNotBlank(participantSelectedIvr)) //IVR Number to store the caller's phone number
        {
            t.QCC_IVR_Selection__c=participantSelectedIvr;
        }

        //CRM-9224
        if(String.isNotBlank(participantTransferNote)){
            t.Transfer_Note__c=participantTransferNote;
        }
        
        //phoneIsInternal checks if the call is internal. Checks the value in 'phone' interaction, 
        //if it contains mypurecloud or qantasairwayslimited, it indicates that the call is Internal
        Boolean phoneIsInternal = /*phoneCalled.contains('mypurecloud') ||*/ phoneCalled?.contains('qantasairwayslimited');
        System.debug('@@@ Phone contains internal: '+phoneIsInternal);
        System.debug('@@@ Phone called details: '+phoneCalled);

        //Genesys has OOTB functionality that re-parents the task to the case that user clicks on the workspace.
        //To prevent this and ensure that the task is linked to the original case that initiated the call, the following logic has been added:
        //- Get the case Id that is initially attached to the task and save on the Task 
        //- The TECH_Original_Case_Id__c will be used as reference to compare everytime the WhatId is changed
        system.debug('>>>onSalveLog saveLogData: ' + JSON.serializePretty(saveLogData));
        system.debug('>>>onSaveLog caseNumber: ' + JSON.serializePretty(attributes));
        system.debug('>>>onSaveLog caseNumber: ' + attributes.containsKey('Participant.CaseNumber'));
        system.debug('>>>onSaveLog caseId: ' + t.WhatId);
        List<Task> taskReference;
        String whatId = (callLog.containsKey('whatid')) ? String.valueOf(callLog.get('whatid')) : null;
        String taskId = (callLog.containsKey('id')) ? String.valueOf(callLog.get('id')) : null;
        if (String.isNotEmpty(interactionId))  {
            List<Case> caseReferences = new List<Case>([SELECT Id, CaseNumber FROM Case WHERE InteractionId__c=:interactionId limit 1]);
            if (!caseReferences.isEmpty()) {
                t.WhatId = caseReferences.get(0).Id;
            }
        }
        system.debug('>>> task what id'+t.WhatId);
        if (String.isNotBlank(whatId) || String.isNotBlank(taskId)) {
            taskReference = new List<Task>([SELECT Id, WhatId, TECH_Original_Case_Id__c FROM Task WHERE Id = :taskId LIMIT 1]);
            Task initialTaskReference = (!taskReference.isEmpty()) ? taskReference.get(0) : new Task(TECH_Original_Case_Id__c=null);
            
            // CRM-8694 commented this to avoid Task without associate to Case 03 03 2025
            if (initialTaskReference.TECH_Original_Case_Id__c == NULL) {
                t.TECH_Original_Case_Id__c = t.WhatId;
            }
            if (initialTaskReference.TECH_Original_Case_Id__c != NULL) {
                if (t.WhatId != initialTaskReference.TECH_Original_Case_Id__c) {
                    t.WhatId = initialTaskReference.TECH_Original_Case_Id__c;
                }
            }
        }
        
        /*if (callState == 'CONNECTED' && !isMessage) { //Do not create task if it's from chat
            upsert t;
        }*/
        
        System.debug('@@@ CallType' +callType);
        if ((callState == 'CONNECTED' || callState == 'DISCONNECTED') && !isMessage && callType != NULL && !isInternal) { //Do not create task if it's from chat
            System.debug('@@@ Upsert task if callType is not null' +callType);
            System.debug('@@@ Task isInternal' +isInternal);
            System.debug('@@@ Phone contains internal: '+phoneIsInternal);
            System.debug('@@@ Phone called details: '+phoneCalled);
          
            if(!phoneIsInternal){
                upsert t;
                System.debug('@@@ Task is created.');
            }   
        } 

        //upsert t;
        callLogId = t.Id;
        return callLogId;
    }
    
    /***************************
    *  Purpose              : Create Case or View Existing Case
    *   Parameters          : String data
    *   Returns             : Json{defaultScreenPop: false, url: case Url}
    * 
    *   Throws
    *   Expectations        : 
    */
    public String onScreenPop(String data) {
            
        System.debug('ON SCREEN POP METHOD');        
        Map<String, Object> dataToReturn = new Map<String, Object>();
        try{
            Map<String, Object> screenPopData = (Map<String, Object>) JSON.deserializeUntyped(data);
            system.debug('>>>onScreenPop data: ' + JSON.serializePretty(screenPopData));
            //CRM-8694 Adding Safe Navigation Operator to Avoid Null Pointer Exceptions
            Map<String, Object> interaction = ( Map<String, Object>) screenPopData?.get('interaction');
            Map<String, Object> attributes= ( Map<String, Object>) interaction?.get('attributes');       
            
            System.debug('>>>onScreenPop attributes'+ JSON.serializePretty(attributes));
            
            //CRM-8694 Adding Safe Navigation Operator to Avoid Null Pointer Exceptions
            Boolean isMessage = Boolean.valueOf(interaction?.get('isMessage'));
            Boolean isInternal = Boolean.valueOf(interaction?.get('isInternal'));
            String participantCaseNumber = (String) attributes?.get('Participant.CaseNumber');
            String participantSelectedIvr = (String) attributes?.get('Participant.EnquiryType');
            String participantQffNumber = (String) attributes?.get('Participant.QFFNumber');
            String participantPnr = (String) attributes?.get('Participant.BookingPNR');
            String participantPhone = (String) interaction?.get('ani');
            string interactionId = (String) interaction?.get('id');
            String url_new_case ='';
            String getContactID = '';
            system.debug('>>>onScreenPop participantCaseNumber: ' + participantCaseNumber);
            //String caseId = convertCaseNoToCaseId(participantCaseNumber);
            //String contactId = getExistingFFContact(participantQffNumber);
            //Jira: CRM-8589
            Contact ffCont = getExistingFFContact(participantQffNumber);
            system.debug('>>>>>>onScreenPop ffCont: ' + ffCont);
            Case inboundCase = getInboundCase(participantCaseNumber);
            
            //CRM-8694  Check if there's existing Case from same ConversationId
            if(inboundCase==null)
            {
                inboundCase = getInboundCaseFromGCInteraction(interactionId);
            }
            
            


           
            system.debug('>>>onScreenPop inboundCase: ' + inboundCase);
            //Case is NEW
            if (inboundCase == NULL) {
                inboundCase = new Case();
                //added fail safe navigator in case Enquiry Type doesn't come from Genesys message. This will prevent attempt-to-dereference null record
                QCC_Case_Record_Type_IVR__mdt caseRecordTypeId = QCC_Case_Record_Type_IVR__mdt.getInstance(participantSelectedIvr?.replaceAll('[^0-9,a-z,A-Z]',''));
                string caseRecordType = (caseRecordTypeId != null) ? mapCaseRecordType.get(caseRecordTypeId.Record_type_name__c).getRecordTypeId() : mapCaseRecordType.get('CCC Voice').getRecordTypeId();
                inboundCase.RecordTypeId = caseRecordType;
                inboundCase.Subject = (caseRecordTypeId != null) ? participantSelectedIvr : (string) interaction.get('queueName');
                inboundCase.Description = 'Case created from a call';
                //Jira: CRM-8589
                //inboundCase.ContactId = (String.isNotBlank(contactId)) ? contactId : null;
                inboundCase = frameContactDetailsOnCase(inboundCase, ffCont);
                inboundCase.Booking_PNR__c = (String.isNotBlank(participantPnr)) ? participantPnr : '';
                inboundCase.Contact_Phone__c = participantPhone;
                inboundCase.type='Voice';
                inboundCase.Frequent_Flyer_Number__c = (String.isNotBlank(participantQffNumber)) ? participantQffNumber : '';
            }
            
            
            //EXISTING CASE - Check if contact is already attached to case. In most instances an existing case would already have a contact attached to it. In which case, system will not override the contact.
            if (inboundCase.ContactId == NULL) {
                //Jira: CRM-8589
                //inboundCase.ContactId = (String.isNotBlank(contactId)) ? contactId : null;
                inboundCase = frameContactDetailsOnCase(inboundCase, ffCont);
            }
            
            //EXISTING CASE - Check if PNR is already attached to case. Where an existing case already have a PNR attached to it, system will not override the PNR.
            if (inboundCase.Booking_PNR__c == NULL) {
                inboundCase.Booking_PNR__c = (String.isNotBlank(participantPnr)) ? participantPnr : '';
            }
            
            inboundCase.InteractionId__c = interactionId;
            
            
            if (!Trigger_Status__c.getValues('CCCVoice_CaseTrigger_Switch').Active__c) {
                TriggerSwitchHelper.stopCaseTrigger();
            }
            system.debug('>>>CCCVoice_CaseTrigger_Switch: ' + Trigger_Status__c.getValues('CCCVoice_CaseTrigger_Switch').Active__c);
            if (!isMessage && !isInternal) { //Do not create task if it's from chat
                upsert inboundCase;
                
                url_new_case ='/lightning/r/Case/'+ inboundCase.Id +'/view';
                dataToReturn=generateDataToReturn(dataToReturn,url_new_case,'',false);
                System.debug('@@@@ Case Upsert: '+ inboundCase);
            } else { //Default screen pop for non-voice interactions (i.e. chat)
                dataToReturn=generateDataToReturn(dataToReturn,'','',true);
            }
            
            return JSON.serialize(dataToReturn);    
        }
        catch(Exception ex){
            system.debug('ON SCREEN POP METHOD Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - PurecloudExtension', 'QCC_PurecloudExtension', 
                                    'onScreenPop', '', '', false,'', ex);
            return JSON.serialize(dataToReturn);
        }
        
        
    }
        
    /***************************
    *  Purpose              : Redirects Link
    *   Parameters          : String data
    *   Returns             : Json{defaultScreenPop: false, url: case Url}
    * 
    *   Throws
    *   Expectations        : 
    */

    public static Map<String, Object> generateDataToReturn(Map<String, Object> dataToReturn,String searchURL,String searchValue,boolean isDefault) {
        if(!String.isBlank(searchURL)) dataToReturn.put('url',searchURL); //uncommented
        if(!String.isBlank(searchValue)) dataToReturn.put('searchValue',searchValue); //uncommented
        dataToReturn.put('defaultScreenPop', isDefault);
        return dataToReturn;
    }   
        
    /***************************
    *  Purpose              : Converts Case number to Case ID
    *   Parameters          : String data
    *   Returns             : Case ID
    * 
    *   Throws
    *   Expectations        : 
    */
        
    public static String convertCaseNoToCaseId(String caseNumber) {
        try{
            List <Case> lookUpCase = new List<Case>([Select Id, CaseNumber From Case Where CaseNumber =: caseNumber limit 1]);
            if (!lookupcase.isEmpty()) {
                return lookupCase.get(0).Id;
            }
        }
        catch(Exception e){
            system.debug('Error Message ===== ' + e.getMessage() + ' Line Number ===== ' + e.getLineNumber());
        }
        return '';
    }
    
    /*----------------------------------------------------------------------------------------------------------------------
    Method Name:        frameContactDetailsOnCase
    Description:        this method will assign first name, last name and email values on to the Case, from Contact.--Jira: CRM-8589
    Parameter:          case, contact
    -----------------------------------------------------------------------------------------------------------------------*/
    public static Case frameContactDetailsOnCase(case inboundCase, Contact ffCont) {
        system.debug('>>>>>>onScreenPop frameContactDetailsOnCase1: ' + inboundCase);
        if (ffCont != null) {
            inboundCase.ContactId = (String.isNotBlank(ffCont.Id)) ? ffCont.Id : null;
            inboundCase.First_Name__c = (String.isNotBlank(ffCont.FirstName)) ? ffCont.FirstName : null;
            inboundCase.Last_Name__c = (String.isNotBlank(ffCont.LastName)) ? ffCont.LastName : null;
            inboundCase.Contact_Email__c = (String.isNotBlank(ffCont.Email)) ? ffCont.Email : null;
        }
        system.debug('>>>>>>onScreenPop frameContactDetailsOnCase2: ' + inboundCase);
        return inboundCase;

    }

    public static Case getInboundCase (String caseNumber) {
        system.debug('>>>>>>onScreenPop getInboundCase1: ' + caseNumber);
        Case inboundCase = null;
        if (String.isNotBlank(caseNumber) && caseNumber != '*') {
            system.debug('>>>>>>onScreenPop getInboundCase2: ' + caseNumber);
            //Jira: CRM-8589
            List <Case> lookUpCase = new List<Case>([Select Id, CaseNumber, ContactId, Booking_PNR__c, First_Name__c, Last_Name__c, Contact_Email__c  From Case Where CaseNumber =: caseNumber limit 1]);
            if (!lookUpCase.isEmpty()) {
                inboundCase = lookUpCase.get(0);
            }
        }
        system.debug('>>>>>>onScreenPop getInboundCase3: ' + caseNumber);
        return inboundCase;
    }

    public static Case getInboundCaseFromGCInteraction (String GCInteraction) {
        system.debug('>>>>>>onScreenPop getInboundCase1 GC Interaction: ' + GCInteraction);
        Case inboundCase = null;
        if (String.isNotBlank(GCInteraction)) {
            system.debug('>>>>>>onScreenPop getInboundCase2 GC Interaction: ' + GCInteraction);
            //Jira: CRM-8589
            List <Case> lookUpCase = new List<Case>([Select Id,InteractionId__c, CaseNumber, ContactId, Booking_PNR__c, First_Name__c, Last_Name__c, Contact_Email__c  From Case Where InteractionId__c =: GCInteraction limit 1]);
            if (!lookUpCase.isEmpty()) {
                inboundCase = lookUpCase.get(0);
            }
        }
        system.debug('>>>>>>onScreenPop getInboundCase3: ' + GCInteraction);
        return inboundCase;
    }
        
    
     
    public static Contact getExistingFFContact (String ffNumber) {
        System.debug('@@@@ PURECLOUD EXTENSION ffNumber > ' + ffNumber);
        //Jira: CRM-8589
        Contact ffCont = null;
        //Added check for record type when trying to match FF contacts
        Id b2cRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        if (String.isNotBlank(ffNumber) && ffNumber != '*') {
            String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+', '');
            System.debug('@@@@ PURECLOUD EXTENSION ffNumWithOutLeadingZeros > '+ ffNumWithOutLeadingZeros);
            List <Contact> ffContact = new List<Contact>([SELECT Id, FirstName, LastName, Email FROM Contact where Frequent_Flyer_Number__c =: ffNumWithOutLeadingZeros AND RecordTypeId = :b2cRecTypeId limit 1]);
            if (!ffContact.isEmpty()) {
                ffCont = ffContact.get(0);
            }
        }
        return ffCont;
    }
        
     public String onClickToDial(String data) {
          // Example: Specify On Behalf of Queue, Caller ID and Name for click-to-dial.
                system.debug('Click to dial Data'+data);
                Map<String, Object> clickToDialData = (Map<String, Object>) JSON.deserializeUntyped(data);
                String lastSelectedQueueId='';
                String caseId = String.valueOf(clickToDialData?.get('objectId'));
                String caseNumber = String.valueOf(clickToDialData?.get('objectName'));
                system.debug('Deserialized data value for clicktodial'+clickToDialData);
                Map<String,String> attributesMap = new Map<String,String>{'caseId'=>caseId, 'caseNumber'=>caseNumber};
                try
                {
            
                //Map<String,String> attributesMap = new Map<String,String>{'sf_urlpop'=>caseNumber};
                //TO-DO: list of queues that will be mapped to click to dial
                lastSelectedQueueId=getLastSelectedQueueDetails(caseId);
                    
                
                if(lastSelectedQueueId==null && lastSelectedQueueId!='')
                {
                    //QCC General Queue if there is not previous call with queue selection
                    //clickToDialData.put('queueId', '2e7ad139-d84d-49bb-bb1a-282d4b210ed7');
                    clickToDialData.put('queueId', System.Label.Genesys_Default_Queue_Id);
                    clickToDialData.put('callerId','+61 291236000');
                }
                else
                {
                     clickToDialData.put('queueId', lastSelectedQueueId);                    
                }
               
                clickToDialData.put('callerIdName', 'Qantas Contact Centre');
                clickToDialData.put('attributes', attributesMap);
                
         }
         catch(exception e)
         {
             system.debug('Exception occurred in click to dial'+e.getMessage());
         }
        
        return JSON.serialize(clickToDialData);
    }
    
    public static String getLastSelectedQueueDetails(String caseId)
    {
        String queueId;
        String ConvId;
        
        system.debug('>>> Call to fetch last selected queue received');
        try
        {
            if(caseId!=null)
            {
               Task getRecentLog=[select id,CallObject from task where WhatId=:caseId or TECH_Original_Case_Id__c=:caseId order by createddate desc limit 1]; 
               if(getRecentLog!=null)
               {
                   ConvId=getRecentLog.CallObject;
               }
            }
            if(ConvId!=null && ConvId!='')
            {
                system.debug('>>> convo Id is not null'+ConvId);
                HttpResponse res = purecloud.SDK.Rest.get('/api/v2/conversations/calls/'+ConvId);
                system.debug('Pure Cloud SDK response'+res);
                if(res.getStatus()=='OK')
                {
                    String resBody =  res.getBody();
                    
                    system.debug('>>> the value of resBody'+resBody);
                    Map<String,object> saveResponse=(Map<String, Object>) JSON.deserializeUntyped(resBody); 
                    system.debug('>>> saveResponse'+saveResponse);
                    //CRM-8694 Adding Safe Navigation Operator to Avoid Null Pointer Exceptions
                    List<Object> participants = (List<Object>)saveResponse?.get('participants') ;
                    system.debug('>>> participants'+participants);
                    if(participants!=null && !participants.isEmpty())
                    {
                        for(Object participant : participants)
                        {
                            String partciStr = JSON.serialize(participant);
                            Map<String,Object> partObj= (Map<String,Object>) JSON.deserializeUntyped(partciStr);
                            String purpose= (String) partObj.get('purpose');
                            String direction= (String) partObj.get('direction');
                            
                             if(purpose=='customer')
                             {
                                system.debug('Inside the if purpose customer check for queue'+purpose); 
                                Map<String,Object> queueObj= (Map<String,Object>) partObj.get('queue');
                                queueId=(String) queueObj.get('id');
                                System.debug('queueid found!: '+queueId);
                            }
                            else if(purpose=='agent' && direction=='outbound')
                            {
                              Map<String,Object> queueObj= (Map<String,Object>) partObj.get('queue');
                                queueId=(String) queueObj.get('id');
                                System.debug('queueid found!: '+queueId);
                            }                          
                        }
                    } 
                    else
                    {
                        system.debug('The SDK API response error occurred');
                    }
                }
            }
        }
        catch(Exception e)
        {
            system.debug('>>> Exception occurred in fetching the last interacted queue id'+e.getMessage());
        }
        system.debug('>>>The Last Selected Queue ID'+queueId);
        return queueId;
}  
   /*Method Name: updateOwnerCallLog 
   Purpose: This is to update case owner for Transfer Calls
   CRM-8694*/
   public static void updateOwnerCallLog(Map<String,Object> getSaveLogData)
   {
       Id tastRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
       try {
           List<Case> caseToUpdate=new List<Case>();
           List<Task> taskToUpdate=new List<Task>();
           Map<String, Object> callLog = ( Map<String, Object>) getSaveLogData.get('callLog');
           Map<String,Object> interactionMap = (Map<String,Object>) getSaveLogData.get('interaction');
           Map<String,Object> attributeMap = (Map<String,Object>) interactionMap.get('attributes');
           String interactionId=String.valueOf(interactionMap.get('id'));
           String transSubject='Transfer Call';
           String callDirection=String.valueof(interactionMap.get('direction'));
           String whatId=null;
            
           List<Task> getLatestTask=[select id,ownerid,status,WhatId,qcc_IVR_Phone_Number__c,Transfer_Note__c,QCC_IVR_Selection__c from task where callobject=:interactionId and subject=:transSubject order by createddate desc limit 1];
           if(getLatestTask!=null && getLatestTask.size()>0 && getLatestTask[0].whatid!=null)
           {
               whatId=getLatestTask[0].whatid;
           }
           List<Case>  getrelCase=[select id,ownerid from case where InteractionId__c =:interactionId or id=:whatId limit 1];
           
           
          
           
           if(getLatestTask!=null && getLatestTask.size()>0)
           {
               Task updateTask=getLatestTask[0];
               updateTask.status='Completed';
               if(getrelCase!=null && getrelCase.size()>0)
               {
                   updateTask.WhatId=getrelCase[0].id;
               }
               
               updateTask.qcc_IVR_Phone_Number__c =String.valueOf(interactionMap.get('phone'));
               updateTask.Transfer_Note__c=String.valueOf(attributeMap?.get('Participant.TransferNotes'));
               updateTask.QCC_IVR_Selection__c=String.valueOf(attributeMap?.get('Participant.EnquiryType'));
               updateTask.OwnerId=UserInfo.getUserId();
               taskToUpdate.add(updateTask);
           }
           
           if(getrelCase!=null && getrelCase.size()>0)
           {
               Case updateCase=getrelCase[0];
               updateCase.ownerid=UserInfo.getUserId();
               caseToUpdate.add(updateCase);
           }

           if(taskToUpdate!=null && taskToUpdate.size()>0)
           {
               update taskToUpdate;
           }       
           if (caseToUpdate!=null && caseToUpdate.size()>0) {
               update caseToUpdate;
           }
           
       } catch (Exception ex) {
           CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_PurecloudExtension', 'QCC_PurecloudExtension',
                                   'createTransferCallLog', String.valueOf(''), String.valueOf(''),false,'', ex);
           
       }
      
    }  
   
}