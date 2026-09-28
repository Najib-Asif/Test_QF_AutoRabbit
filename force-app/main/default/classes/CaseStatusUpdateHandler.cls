/*Class Name: CaseStatusUpdateHandler
Test Class Name: CaseStatusUpdateHandlerTest
VERSION  AUTHOR            DATE              DETAIL
1.0   Tanya Kumari    15/05/2026      CRM-10522 RBAC for System Admin
-----------------------------------------------------------------------------------------------------------------------*/
public class CaseStatusUpdateHandler {
    //Open Recoveries have below statuses
    public static set<string> openRecoveryStatus = new set<string>{'New', 'Pending Approval', 'Approved', 'Awaiting Customer', 'Processing','Further Action Required','Expired'};
    public static set<string> oldCaseStatus = new set<string>{'New', 'In Progress', 'Reply Received', 'Waiting for Customer', 'Waiting for Internal'};

    //Below error is only for the Cases in Pending Recovery 
    public static string openRecoveryErrorMsg = 'There are open recoveries on this Case, it will be automatically closed once all Recoveries are finalised.';
    //CDP2-239
    public static Id QCC_OTSRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case OTRS RecType'));
    //CDP2-430
    //Included four new System Admin profiles which has been created as part of RBAC System
    public static Id SYSADMIN_PROFILEID = [select ProfileId from User where Profile.Name = 'System Administrator' Limit 1].ProfileId;
    public static Id QANSYSADMIN_PROFILEID = [select Id from Profile where Name = 'Qantas System Administrator' Limit 1].Id;
    public static Id QANFREIGHTSYSADMIN_PROFILEID = [select Id from Profile where Name = 'Qantas System Admin - Freight' Limit 1].Id;
    public static Id QANQCCSYSADMIN_PROFILEID = [select Id from Profile where Name = 'Qantas System Admin - QCC' Limit 1].Id;
    public static Id QANSNDSYSADMIN_PROFILEID = [select Id from Profile where Name = 'Qantas System Admin - SND' Limit 1].Id;   
    public static void handleCaseStatusUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        //CDP2-353 Below error is only for the Cases in New, In Progress, Waiting for Customer, Waiting for Internal, Reply Received
        String openRecvyCaseErrorMsg = System.Label.CaseClosure_ErrorMessage;
        String caseStartWorkError = System.Label.CaseClosure_NotOwnerErrorMessage; 
        Set<Id> caseIds = new Set<Id>();
        Boolean bypassOTSStatusError = false;
        //CDP2-794 case Record Types and Recovery Record types - EFT, Other, CreditCard, TV 
        List<String> caseRecvyRecordTypes = new List<String>(Label.QCC_CaseRecoveryRecordTypes.split(';')); //Record types of Case which contains a Recovery
        List<String> recvyRecordTypes = new List<String>(Label.QCC_RecoveryRecordTypes.split(';')); 
        list<string> caseRecordTypeIdlist = new list<string>();
        for(string str : caseRecvyRecordTypes){ 
            caseRecordTypeIdlist.add(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
        }
        //CDP2-965 AC04
        Id caseBaggageRecTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CCC_Baggage').getRecordTypeId();

        ////CDP2-239 Bypass OTS Case VR errors for QCC API Integration User
        if(EnableValidationRule__c.getInstance(userInfo.getUserId()) != Null ){
           bypassOTSStatusError = EnableValidationRule__c.getInstance(userInfo.getUserId()).VR_BypassOTSCaseStatusErrors__c;
        }

        if (!newCases.isEmpty()) {                     
            Map<Id, List<Recovery__c>> caseOpenRecoveryMap = new Map<Id, List<Recovery__c>>();
            //CDP2-794 collect all cases that has Recoveries
            Set<Id> caseRecoveries = new Set<Id>();
            //CDP2-794 added case Record Type Check and get only new Recvy (EFT, CC, TV, Other) recordtypes
            for (Recovery__c rec : [SELECT Id, Status__c, Case_Number__c FROM Recovery__c WHERE RecordType.DeveloperName IN: recvyRecordTypes AND Case_Number__c IN : newCases 
                                    AND Case_Number__r.RecordType.DeveloperName IN: caseRecvyRecordTypes]) {
                if(openRecoveryStatus.contains(rec.Status__c)) {
                    if (!caseOpenRecoveryMap.containsKey(rec.Case_Number__c)) {
                        caseOpenRecoveryMap.put(rec.Case_Number__c, new List<Recovery__c>());
                    }
                    caseOpenRecoveryMap.get(rec.Case_Number__c).add(rec);
                }
                caseRecoveries.add(rec.Case_Number__c);
            }
            
            for (Case c : newCases) {
                //CDP2-794 Run below validations only for caseRecvyRecordTypes and Case should have atleast one Recovery either open/closed
                if(caseRecoveries != null && !caseRecoveries.isEmpty() && caseRecoveries.contains(c.Id)){
                    case oldcase = oldCaseMap.get(c.id);
                    List<Recovery__c> relatedRecoveries = caseOpenRecoveryMap != null ? caseOpenRecoveryMap.get(c.Id) : null;
                    // Case has open Recoveries scneario
                    if (relatedRecoveries != null && !relatedRecoveries.isEmpty()) {
                        //CDP2-239 Added bypassOTSStatusError
                        if (!bypassOTSStatusError && c.Status == 'Pending Recovery' && (oldcase.Status == 'New' || oldcase.Status == 'Closed')) {
                            c.addError('The Case must be in progress to update to Pending Recovery');                      
                        }//CDP2-965 AC04
                        if(!bypassOTSStatusError && c.RecordTypeId == caseBaggageRecTypeId &&  oldcase.Status != c.Status &&
                        c.Status == 'Pending Recovery' && (String.isBlank(c.Baggage_Assessment_Outcome__c))){
                        	c.addError('Please complete Baggage Assessment Outcome'); 
                    	}//CDP2-965 AC04
                        //CDP2-197
                        //CDP2-353 Added Pending Recovery check
                        if (c.Status == 'Closed' && oldcase.Status == 'Pending Recovery') {
                            c.addError(openRecoveryErrorMsg );                      
                        }//CDP2-353 
                        else if(c.Status == 'Closed' && oldCaseStatus.contains(oldcase.Status) && !c.SkipValidationsForAutomations__c){
                            c.addError(openRecvyCaseErrorMsg );     
                        }
                    } else {// Closed Recoveries scenario               
						 //CDP2-353 AC03
                        if (c.Status == 'Closed' && oldcase.Status == 'In Progress' && c.OwnerId != oldcase.OwnerId && !bypassOTSStatusError) {
                            c.addError(caseStartWorkError);
                        }//CDP2-353 AC04, CDP2-627 bypassing this VR for Integration user
                        else if(c.Status == 'Closed' && oldCaseStatus.contains(oldcase.Status) && oldcase.Status != 'In Progress' && !bypassOTSStatusError){
                            c.addError(caseStartWorkError);     
                        }//CDP2-353 AC04  
                        //CDP2-265 AC03 No Open Recoveries scenario
                        else if(c.Status == 'Pending Recovery' && !bypassOTSStatusError && oldcase.Status == 'In Progress'){
                    		c.addError('There are no open related Recoveries on this Case');
                		}
                    }
                }
                //CDP2-265 AC03 No Recoveries scenario
                //CDP2-239 If case Status recvd from API (RedApp related) is Pending Recovery then bypass
                else if(caseRecordTypeIdlist.contains(c.RecordTypeId) && c.Status == 'Pending Recovery' && !bypassOTSStatusError){
                    c.addError('There are no open related Recoveries on this Case');
                }
            }
        }
    }


    public static void updateCase(Map<String, List<Id>> mapOfRStatusNCase , set<Id> noGoodWillCases) {
        list<case> caseListUpdate = new list<case>();
        Set<Id> openRecveries = new Set<Id>(); //CDP2-965 AC01
        List<Id> allCaseIds = new List<Id>();
        Id finalRecvyUserId, finalRecvyUserManagerId;//CDP2-965 AC01
        String finalRecvyUserLocation, finalRecvyUserProfile;//CDP2-965 AC01
        if(mapOfRStatusNCase.get('Finalised') != null){
        allCaseIds.addAll(mapOfRStatusNCase.get('Finalised')); }
        if(mapOfRStatusNCase.get('Cancelled') != null){
        allCaseIds.addAll(mapOfRStatusNCase.get('Cancelled'));}
        try{
            for(Case caseRec : [Select Id,status, OwnerId, Origin, Resolution_Method__c, Closed_By__c, ClosedByLocation__c, ClosedByManager__c, Closed_By_Profile__c, //CDP2-965
                                RecordTypeId, (SELECT Id, CreatedBy.Id, CreatedBy.Location__c, CreatedBy.ManagerId, CreatedBy.Profile.Name, Case_Number__c, Status__c FROM 
                                               Recoveries_Case__r order by LastModifiedDate Desc) from Case where Id IN: allCaseIds]){ //CDP2-965
                                
                //CDP2-965 AC01                   
                if(!caseRec.Recoveries_Case__r.isempty()){
                    for(Recovery__c r: caseRec.Recoveries_Case__r){
                        if(r.Status__c == 'Finalised'){
                            finalRecvyUserId = r.CreatedBy.Id;
                            finalRecvyUserManagerId = r.CreatedBy.ManagerId;
                            finalRecvyUserLocation = r.CreatedBy.Location__c;
                            finalRecvyUserProfile = r.CreatedBy.Profile.Name;
                        }
                        if(openRecoveryStatus.contains(r.Status__c)){
                        	openRecveries.add(r.Id);
                            break;
                        }
                    }                        
                }//CDP2-965 AC01
                //CDP2-627 Added criteria for No Goodwill Type Case
                if((caseRec.status == 'Pending Recovery' && openRecveries.isempty() && mapOfRStatusNCase.get('Finalised') != null && //CDP2-965 AC01
                    mapOfRStatusNCase.get('Finalised').contains(caseRec.Id)) || (!noGoodWillCases.isEmpty() && noGoodWillCases.contains(caseRec.Id)
                    /*Fix for CRM-(9502)Incident INC2786023*/ && caseRec.RecordTypeId == QCC_OTSRecordTypeId)){
                    //CDP2-965 AC01  
					caseRec.OwnerId = finalRecvyUserId != null? finalRecvyUserId: caseRec.OwnerId; 
                    caseRec.Resolution_Method__c = 'Auto Closed - Recovery';
                    caseRec.Closed_By__c = caseRec.OwnerId;
                    caseRec.ClosedByLocation__c = finalRecvyUserLocation;
                    caseRec.ClosedByManager__c = finalRecvyUserManagerId;
                    caseRec.Closed_By_Profile__c = finalRecvyUserProfile;
                    //CDP2-965
                    caseRec.status = 'Closed'; 
                        
                    //CDP2-239 Update below fields for Case Closed status, CDP2-627 added Red App as well for No Goodwill scenario
                    if(caseRec.RecordTypeId == QCC_OTSRecordTypeId || (caseRec.RecordTypeId == QCC_OTSRecordTypeId /*Fix for CRM-(9502)Incident INC2786023*/ && !noGoodWillCases.isEmpty() && noGoodWillCases.contains(caseRec.Id))){
                        caseRec.Resolution_Method__c = 'Case auto closed'; //CDP2-965 AC01
                        caseRec.Closed_By__c = UserInfo.getUserId();
                    }
                    caseListUpdate.add(caseRec);
                } //CDP2-430
                //CDP2-356 changes by Navya Added Further Action Required condition
                if((mapOfRStatusNCase.get('Cancelled') != null && mapOfRStatusNCase.get('Cancelled').contains(caseRec.Id)) || 
                   (mapOfRStatusNCase.get('Further Action Required') != null && mapOfRStatusNCase.get('Further Action Required').contains(caseRec.Id)) &&
                    UserInfo.getProfileId() != SYSADMIN_PROFILEID && UserInfo.getProfileId() != QANSYSADMIN_PROFILEID && UserInfo.getProfileId() != QANFREIGHTSYSADMIN_PROFILEID && UserInfo.getProfileId() != QANQCCSYSADMIN_PROFILEID && UserInfo.getProfileId() != QANSNDSYSADMIN_PROFILEID){
                    //CDP2-968
                    caseRec.status = 'In Progress';
                    caseRec.OwnerId = UserInfo.getUserId(); 
                    caseListUpdate.add(caseRec);
                }
            } 
            if(caseListUpdate.Size() > 0) {
                //CDP2-965
                EnableValidationRule__c setting = EnableValidationRule__c.getOrgDefaults();
                setting.BypassVRCaseResolutionAutoClose__c = true;
                upsert  setting;//CDP2-965
                Database.Update(caseListUpdate, false);
               
                //CDP2-965
                setting.BypassVRCaseResolutionAutoClose__c = false;
                upsert  setting;//CDP2-965
            }
        }catch(DMLexception dmle){
          
            for (Integer i = 0; i < dmle.getNumDml(); i++) {               
                if(dmle.getDmlType(i) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || dmle.getDmlMessage(i) != openRecoveryErrorMsg){
                    CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'Recoveries - Auto close pending recovery case', 'CaseStatusUpdateHandler', 
                	'updateCase', String.valueOf(''), String.valueOf(''), false, '', dmle);
                    throw dmle;
                }
            }
        }
        catch (Exception ex) {
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'Recoveries - Auto close pending recovery case', 'CaseStatusUpdateHandler', 
                'updateCase', String.valueOf(''), String.valueOf(''), false, '', ex);
            throw ex;
        }
    }
    public static void handleRecoveryStatusUpdate(List<Recovery__c> newRecoveries, Map<Id, Recovery__c> oldRecoveryMap) {
        Set<String> OTSRecvyTypes = new Set<String>{CustomSettingsUtilities.getConfigDataMap('RType_HotelVoucher'), 
                                    CustomSettingsUtilities.getConfigDataMap('RType_WineVoucher')};
        Map<String, List<Id>> mapOfRcvyStatusCaseId = new Map<String, List<Id>>();
        List<Recovery__c> recordsToUpdate = new List<Recovery__c>();
        //CDP2-627 No Good will cases

        Set<Id> noGoodWillCaseLst = new Set<Id>();
        try{
        for(Recovery__c rec : newRecoveries){
            List<id> caseidlist = new List<id>();
          
            //CDP2-430 Added Cancelled Status
            //CDP2-339 Added oldrecoverymap == Null for OTS Case and Hotel/Wine Voucher case
            //CDP2-356 changes by Navya Added Further Action Required condition
            //CDP2-627 Added No Goodwill for RedApp scenario
            
            if(((rec.Status__c == 'Finalised' || rec.Status__c == 'Cancelled' ) && 
                ((oldrecoverymap == Null && (OTSRecvyTypes.Contains(rec.Type__c) || rec.Type__c == 'No Goodwill')) || 
                (oldrecoverymap != null && rec.Status__c != oldrecoverymap.get(rec.id).Status__c))) ||
               (rec.Status__c == 'Further Action Required' && rec.type__c == 'Qantas Points')){
                   
                //CDP2-627 No Good will cases
                if(rec.Type__c == 'No Goodwill'){
                    noGoodWillCaseLst.add(rec.Case_Number__c); 
                }  
                   
                if(mapOfRcvyStatusCaseId.containsKey(rec.Status__c)){
                    caseidlist = mapOfRcvyStatusCaseId.get(rec.Status__c);
                }
                caseidlist.add(rec.Case_Number__c);
                mapOfRcvyStatusCaseId.put(rec.Status__c, caseidlist);
            }
       
        }
        /*if(!mapOfRcvyStatusCaseId.isempty()){
            //CDP2-627 Added param No Good will cases
            updateCase(mapOfRcvyStatusCaseId, noGoodWillCaseLst);
        }*/
        if (!mapOfRcvyStatusCaseId.isEmpty()) {
            System.enqueueJob(new QCC_ClosePendingRecoveryCaseQueuable(mapOfRcvyStatusCaseId, noGoodWillCaseLst));
        }
        
          }catch(exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recoveries - Auto close pending recovery case', 'CaseStatusUpdateHandler', 
            'handleRecoveryStatusUpdate', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
}