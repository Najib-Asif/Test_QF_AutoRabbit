/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Class to be invoked from Recovery Trigger
Inputs:
Test Class:    
************************************************************************************************
History
************************************************************************************************
27-Nov-2017    Praveen Sampath                Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class LoyaltyAPIHelper { 
    /*--------------------------------------------------------------------------------------      
     Method Name:        invokeLoyaltyAPI
     Description:        Method to Invoke Loyalty API Service
     Parameter:          FF Number, Points,Last Name,Case Number, Recovery Id
    --------------------------------------------------------------------------------------*/    
    @future(Callout = true)
    public static void invokeLoyaltyAPI(String ffNumber, Integer pointsAdded, String lastName, String caseNumber, String recoveryId){
        try{
            //239 - Updated record type to Other_Recovery
            Recovery__c objRecovery = [Select Id, Name, Status__c , FulfilledBy__c, Type__c,Recovery_System_log__c,
                                       Fulfilled_By_profile__c , Recovery_Locked__c, API_Attempts__c, Case_Number__c
                                       from Recovery__c where (RecordType.DeveloperName='Other_Recovery' or RecordType.DeveloperName='Customer_Connect')  AND Id =: recoveryId];

            LoyaltyRequestWrapper loyaltyReq = new LoyaltyRequestWrapper();
            String todayString = String.valueOf(system.today());
            List<String> lsttoday = todayString.split('-');
            String activityDate = lsttoday[2]+''+lsttoday[1]+''+lsttoday[0];
            loyaltyReq.activityDate = activityDate;
            loyaltyReq.validationLevel = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIValidationLevel');
            loyaltyReq.partnerID = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIPartnerID');
            
            LoyaltyRequestWrapper.Member member = new LoyaltyRequestWrapper.Member();
            member.surname = lastName;
            
            LoyaltyRequestWrapper.Payment payment = new LoyaltyRequestWrapper.Payment();
            
            payment.transactionReference = objRecovery.Name;
            payment.basePointsSign = '+';
            payment.numberOfBasePoints = pointsAdded;
            payment.statementText='COMPLIMENTS OF CUSTOMER CONTACT';
            
            loyaltyReq.payment = payment;
            loyaltyReq.member = member;
            //239 - For testing purposes, put to false later
            //356-Navya changes
            Boolean isSuccess = false;
            HttpResponse response;
            String additionalComment;
            String comments;
            if(ffNumber != null) {
                //239 - For testing purposes, uncomment later
               response  = QCC_InvokeCAPAPI.invokeLoyaltyPostAPI(ffNumber,loyaltyReq);
            } else {
                additionalComment = 'Frequent Flyer Number not available';
                objRecovery.Qantas_points_Error_message__c = 'No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery';
                objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
            }
            if(response!=null){
            isSuccess = (response.getStatusCode() == 200) ;
            }
            System.debug('isSuccess::'+isSuccess);
            String userProfile = [SELECT Name FROM Profile where id = :Userinfo.getProfileId()].Name;
            //status of Recovery Process Status to Finalised
            if(isSuccess){
                //239 - Process Status to be updated to Finalised on API success
                objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusFinalised');
                objRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusFinalised');
                objRecovery.FulfilledBy__c = UserInfo.getUserId();
                objRecovery.Fulfilled_By_profile__c = userProfile;
                objRecovery.Fulfilled_Date__c = System.now();
               objRecovery.Qantas_points_Error_message__c = '';
                comments = 'Loyalty API call successful after Attempt #'+ (Integer.valueOf(objRecovery.API_Attempts__c) + 1);
            }else{
                if(objRecovery.Status__c != CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised')){
                    objRecovery.API_Attempts__c = objRecovery.API_Attempts__c == null ? 0 : objRecovery.API_Attempts__c;
                    objRecovery.API_Attempts__c++;
                    comments = additionalComment == null ? 'Loyalty API call unsuccessful Attempt #'+ Integer.valueOf(objRecovery.API_Attempts__c) : 'Loyalty API call unsuccessful Attempt #'+ Integer.valueOf(objRecovery.API_Attempts__c) + '\n' + additionalComment;
                }
                //CDP2-356 Changes by Navya start
                
                if(objRecovery.API_Attempts__c>=3){//Change this to 3 after testing 
                    objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                    objRecovery.Status__c = 'Further Action Required';
                    System.debug('response.getBody():::'+response.getBody());// Sample response body (you will replace this with your actual httpresponse.getBody())
                    
                    
                    // Deserialize the JSON response into a Map
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    // Retrieve the message from the top level
                    String message = (String) jsonResponse.get('message');
                    
                    // Retrieve the details map and then get the reason
                    Map<String, Object> details = (Map<String, Object>) jsonResponse.get('details');
                            String reason='';
                            if(details!=null){
                                 reason = (String) details.get('reason');
                            }
                    
                    // Output the values for debugging or usage
                    System.debug('Message: ' + message);
                    System.debug('Reason: ' + reason);
                   objRecovery.Qantas_points_Error_message__c = message +': ' + reason;
                    objRecovery.Recovery_System_log__c = objRecovery.Recovery_System_log__c == null ? '':objRecovery.Recovery_System_log__c ;
                    objRecovery.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000) + ' Processing failed, please resubmit recovery' + '</li></ul>' + objRecovery.Recovery_System_log__c;
                    //objRecovery.Recovery_System_log__c = 'Processing failed, please resubmit recovery';
                    
                }
                //CDP2-356 Changes by Navya end

                //'Finalisation Declined';//QantasConfigData - RecoveryStatusFinalisation Declined
            }
            if(!Test.isRunningTest()) {
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, objRecovery.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments);
            }
            update objRecovery;
        }
        catch(Exception ex){
            system.debug('ex##########'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Invoked from RecoveryTriggerHelper', 'LoyaltyAPIHelper', 
                                    'invokeLoyaltyAPI', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
}