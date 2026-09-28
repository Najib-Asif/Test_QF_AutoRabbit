/*-----------------------------------------------------------------------------------------
    Author: Nga Do
    Company: Capgemini
    Description: 
    Inputs: 
    Test Class: QCC_RevoveriesCallLoyaltyAPIQueueTest
    ***************************************************************************************
    History:
    ***************************************************************************************
    15-May-2018
 ------------------------------------------------------------------------------------------*/

public class QCC_RevoveriesCallLoyaltyAPIQueue implements Queueable, Database.AllowsCallouts {

	private List<Recovery__c> listRecoveries;
	private String currentProfileName;

    /*--------------------------------------------------------------------------------------       
    Method Name:        QCC_RevoveriesCallLoyaltyAPIQueue
    Description:        Contructer get all the recovery to execute
    Parameter:          set Id of recovery
    --------------------------------------------------------------------------------------*/
	public QCC_RevoveriesCallLoyaltyAPIQueue(Set<Id> setRecoveryId){

		this.listRecoveries = [SELECT 
									Id, 
									Amount__c, 
									FF_Number__c, 
									Name, 
									Contact_LastName__c, 
									API_Attempts__c, 
									Status__c, 
                                    Case_Number__c
								FROM 
									Recovery__c
								WHERE 
									RecordType.DeveloperName='Customer_Connect' AND Id IN: setRecoveryId and Status__c= : CustomSettingsUtilities.getConfigDataMap('RecoveryStatusInitiated')];
		// get current Profile Name
		currentProfileName = [SELECT Name FROM Profile where id = :Userinfo.getProfileId()].Name;
	}

    /*--------------------------------------------------------------------------------------       
    Method Name:        execute
    Description:        make callout to loyalty API and update status of recovery based on response from API
    Parameter:          Queueable Context
    --------------------------------------------------------------------------------------*/
	public void execute(QueueableContext context) {
        Set<Id> recoveryIds = new Set<Id>();
        List<Recovery__c> declinedRecoverys = new List<Recovery__c>();
        HttpResponse response;
        //Do some action here
        for(Recovery__c objRecovery : listRecoveries){

        	Boolean isSuccess = false;
	        // check if Frequent Flyer Number is Exist , make a callout
	        if(objRecovery.FF_Number__c != null){
	        	// init Loyalty Request
	        	LoyaltyRequestWrapper loyaltyReq = initRoyaltyRequest(objRecovery.FF_Number__c,
	        									Integer.valueOf(objRecovery.Amount__c),
	        									objRecovery.Contact_LastName__c,
	        									objRecovery.Name);
	        	// call out
                response = QCC_InvokeCAPAPI.invokeLoyaltyPostAPI(objRecovery.FF_Number__c, loyaltyReq);
                isSuccess = (response.getStatusCode() == 200) ;
            } 
            else {
                
                objRecovery.Qantas_points_Error_message__c = 'No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery';
                objRecovery.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
            }
            if(isSuccess){
            	// if callout is succeed update recovery as follow:
                objRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
                objRecovery.FulfilledBy__c = UserInfo.getUserId();
                objRecovery.Fulfilled_By_profile__c = currentProfileName;
                objRecovery.Fulfilled_Date__c = System.now();
              objRecovery.Qantas_points_Error_message__c ='';
               
            }else{
            	// if callout is failed update recovery as follow:
                if(objRecovery.Status__c != CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised')){
                    objRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
                    objRecovery.API_Attempts__c = objRecovery.API_Attempts__c == null ? 1 : objRecovery.API_Attempts__c + 1;
                    declinedRecoverys.add(objRecovery);
                }
            }
        }
        Database.update(listRecoveries, false);
        for(Recovery__c recoveryFail : declinedRecoverys){
            if(!Test.isRunningTest() && recoveryFail.Case_Number__c != null){
                Integer attemptCount = Integer.valueOf(recoveryFail.API_Attempts__c);
                String comments = 'Loyalty API call unsuccessful Attempt #'+ attemptCount;
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, recoveryFail.Case_Number__c, ConnectApi.FeedElementType.FeedItem, comments); 
            }
        }
	}

	/*--------------------------------------------------------------------------------------       
    Method Name:        initRoyaltyRequest
    Description:        initiate royal request
    Parameter:          Frequent flyer Number, Point of Recovery , LastName of contact, affected Passenger Name
    --------------------------------------------------------------------------------------*/ 
	private static LoyaltyRequestWrapper initRoyaltyRequest(String ffNumber, Integer pointsAdded, String lastName, String affectedPassengerName){

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
        
        payment.transactionReference = affectedPassengerName;
        payment.basePointsSign = '+';
        payment.numberOfBasePoints = pointsAdded;
        payment.statementText='COMPLIMENTS OF CUSTOMER CONTACT';
        
        loyaltyReq.payment = payment;
        loyaltyReq.member = member;

        return loyaltyReq;
	}

    
}