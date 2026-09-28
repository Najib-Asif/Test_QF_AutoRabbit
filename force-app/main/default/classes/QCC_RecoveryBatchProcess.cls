/*----------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   Invokes CAP API to get FF No and invokes Loyalty API to update points balance
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    16-Mar-2018      Purushotham               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
global class QCC_RecoveryBatchProcess implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Contact__c, Type__c,Status__c, Amount__c, FF_Number__c, Contact_LastName__c, CaseNumber__c,Recovery_System_log__c,
                                         Name, FulfilledBy__c, Fulfilled_By_profile__c, CreatedById, API_Attempts__c, Case_Number__c, Contact__r.RecordTypeId
                                         FROM Recovery__c WHERE Type__c = :CustomSettingsUtilities.getConfigDataMap('Qantas Points Type') 
                                         AND  Process_Status__c = :CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusSubmitForFinalisation')
                                         AND Case_Number__r.RecordTypeId != :GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('QCC Migrated Case RecType'))
                                         AND API_Attempts__c < 3 AND (RecordType.DeveloperName='Customer_Connect' or RecordType.DeveloperName = 'Other_Recovery')]);
    }
    
    global void execute(Database.BatchableContext bc, List<Recovery__c> recoveries) {
        try {
            HttpResponse response;
            Set<Id> contactIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<Id, String> contactFFMap = new Map<Id, String>();
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Case> casesToUpdate = new List<Case>();
            Map<Id, String> userProfile = new Map<Id, String>();
            Map<String, Id> mapQueue = new Map<String, Id>();
            //Map<Id, String> mapQueueName = new Map<Id, String>();
            //Map<String, QCCRoutingPriority__mdt> mapQCCPriority = new Map<String, QCCRoutingPriority__mdt>();
            
            for(Recovery__c rec: recoveries) {
                contactIds.add(rec.Contact__c);
                userIds.add(rec.CreatedById);
            }

            for(Contact con: [SELECT Id, FirstName, LastName, Frequent_Flyer_Number__c, CAP_ID__c, Email, Phone_Extension__c, Phone_Area_Code__c, Phone_Line_Number__c, Phone_Country_Code__c FROM Contact WHERE Id IN :contactIds]) {
                /* Commented out, as there will be no contact for Non-FFs. Done as part of Remediation
                if(String.isBlank(con.Frequent_Flyer_Number__c)) {
                    // Call CAP to retrieve FF Number
                    QCC_CustomerSearchHandler.ContactWrapper wrappedContact = QCC_CustomerSearchController.executeSearch(con, '', false);

                    if(wrappedContact != null && wrappedContact.contacts != null && wrappedContact.contacts.size() > 0) {
                        System.debug('FF@@@@'+wrappedContact.contacts[0].Frequent_Flyer_Number__c);
                        con.Frequent_Flyer_Number__c = wrappedContact.contacts[0].Frequent_Flyer_Number__c; 
                    }
                    
                    System.debug('FF###'+con.Frequent_Flyer_Number__c);
                    contactsToUpdate.add(con);
                }
                */
                contactFFMap.put(con.Id, con.Frequent_Flyer_Number__c);
            }
            System.debug('contactFFMap--'+contactFFMap);
            for(User usr: [SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]) {
                userProfile.put(usr.Id, usr.Profile.Name);
            }

            /*for(QCCRoutingPriority__mdt  qccPriority: [Select Id, Cabin__c, Priority__c, Tier__c from QCCRoutingPriority__mdt])
            {
                String key = qccPriority.Cabin__c+''+qccPriority.Tier__c;
                mapQCCPriority.put(key, qccPriority);
            }*/
            
            for(QueueSobject  queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where 
                                     SobjectType ='Case'])
            {
                mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
                //mapQueueName.put(queueObj.QueueId, queueObj.Queue.DeveloperName);
            }

            for(Recovery__c rec: recoveries) {
                LoyaltyRequestWrapper loyaltyReq = new LoyaltyRequestWrapper();
                String todayString = String.valueOf(system.today());
                List<String> lsttoday = todayString.split('-');
                String activityDate = lsttoday[2]+''+lsttoday[1]+''+lsttoday[0];
                loyaltyReq.activityDate = activityDate;
                loyaltyReq.validationLevel = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIValidationLevel');
                loyaltyReq.partnerID = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIPartnerID');
                
                LoyaltyRequestWrapper.Member member = new LoyaltyRequestWrapper.Member();
                member.surname = rec.Contact_LastName__c;
                
                LoyaltyRequestWrapper.Payment payment = new LoyaltyRequestWrapper.Payment();
                
                payment.transactionReference = rec.Name;
                payment.basePointsSign = '+';
                payment.numberOfBasePoints = Integer.valueOf(rec.Amount__c);
                payment.statementText='COMPLIMENTS OF CUSTOMER CONTACT';
                
                loyaltyReq.payment = payment;
                loyaltyReq.member = member;

                Boolean isSuccess = false;
                String additionalComment;
                String comments;

                if(String.isNotBlank(contactFFMap.get(rec.Contact__c))) {
                    response = QCC_InvokeCAPAPI.invokeLoyaltyPostAPI(contactFFMap.get(rec.Contact__c),loyaltyReq);
                    isSuccess = (response.getStatusCode() == 200) ;
                    System.debug('Loyalty Call Status-->'+isSuccess);
                } else {
                    additionalComment = 'Frequent Flyer Number not available';
                }
                
                if(isSuccess){
                    rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
                    //Changes by Navya CDP2-1020
                    rec.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusFinalised');
                    rec.FulfilledBy__c = rec.CreatedById;
                    rec.Fulfilled_By_profile__c = userProfile.get(rec.CreatedById);
                    rec.Fulfilled_Date__c = System.now();
                    rec.Qantas_points_Error_message__c = '';
                    comments = 'Loyalty API call successful after Attempt #'+ (Integer.valueOf(rec.API_Attempts__c) + 1);
                }else{
                    rec.API_Attempts__c = (rec.API_Attempts__c == null || rec.API_Attempts__c == 3) ? 0 : rec.API_Attempts__c;
                    rec.API_Attempts__c++;
                    //rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
                    comments = additionalComment == null ? 'Loyalty API call unsuccessful Attempt #'+ Integer.valueOf(rec.API_Attempts__c) : 'Loyalty API call unsuccessful Attempt #'+ Integer.valueOf(rec.API_Attempts__c) + '\n' + additionalComment;
                    if(rec.API_Attempts__c >= 3 || rec.Contact__r.RecordTypeId == GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'))){
                        //rec.API_Attempts__c = 0;
                        //Changes by Navya CDP2-1020
                        if(rec.API_Attempts__c >= 3)
                        {
                            rec.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                            rec.Status__c = 'Further Action Required';
                            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                            // Retrieve the message from the top level
                            String message = (String) jsonResponse.get('message');
                            
                            // Retrieve the details map and then get the reason
                            Map<String, Object> details = (Map<String, Object>) jsonResponse.get('details');
                            String reason='';
                            if(details!=null){
                                 reason = (String) details.get('reason');
                            }
                           rec.Qantas_points_Error_message__c = message +': ' + reason; 
                            rec.Recovery_System_log__c = rec.Recovery_System_log__c == null ? '':rec.Recovery_System_log__c ;
                            rec.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + ' Processing failed, please resubmit recovery' + '</li></ul>' + rec.Recovery_System_log__c;
                           
                        }
                        //Changes by Navya CDP2-1089
                        if(rec.Type__c != 'Qantas Points'){
                            caseIds.add(rec.Case_Number__c);
                        }
                    }
                }
                if(!Test.isRunningTest()) {
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, rec.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments);
                }
            }

            if(caseIds != null && caseIds.size() > 0) {
                for(Case cs: [SELECT Id, Status, Cabin_Class__c, Frequent_Flyer_Tier__c,recordtype.developername FROM Case WHERE Id IN :caseIds]) {
                    
                    /*String queueSuffix;

                    if(cs.Cabin_Class__c != Null  && cs.Frequent_Flyer_Tier__c != Null )
                    {
                        string key = cs.Cabin_Class__c+''+cs.Frequent_Flyer_Tier__c;
                        queueSuffix = mapQCCPriority.get(key).Priority__c;
                    } else {
                        queueSuffix = 'Low';
                    }*/

                    String queueName = 'Fulfillment_Queue';
                    if(cs.recordtype.developername != 'CCC_Medical'){  // CDP2-1009
                        cs.Status = CustomSettingsUtilities.getConfigDataMap('RecoveryError');
                        cs.OwnerId = mapQueue.get(queueName);
                        casesToUpdate.add(cs);
                    }
                    
                }
            }

            update recoveries;

            if(contactsToUpdate != null && contactsToUpdate.size() > 0) {
                update contactsToUpdate;
            }
            
            if(casesToUpdate != null && casesToUpdate.size() > 0) {
                update casesToUpdate;
            }
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Batch Process', 'QCC_RecoveryBatchProcess', 'execute', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}