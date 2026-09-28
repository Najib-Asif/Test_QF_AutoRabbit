/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-16-2024
 * @last modified by  : Praveen Sampath
**/
public class RecoveryTriggerHelper {

    public static Boolean hasRun = false;
    public static group groupname;
    public static Group getGroup (string type ,string devname){
        if(groupname == null){
            groupname = [Select Id from Group where Type = :type  AND DeveloperName = :devname LIMIT 1 ];
        }
        return groupname;
    }
    

    /**
* @description  : Handles cases assignment to queues
* @param        : 
* @return       : a contact
* @author       : Cyrille 
*/ 
    public static void updateRecoveryType(List<Recovery__c> recoveries, Map<Id, Recovery__c> mapOldMap){
        try{
            List<Case> cases = new List<Case>();
            Group caseGroup = getGroup ('Queue','Baggage_Damaged_Queue_High'); // [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
            for(Recovery__c recovery: recoveries){
                Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id) : null;
                if(oldRecovery != null && 
                    String.isNotBlank(recovery.Type__c) && 
                    recovery.Type__c.equalsIgnoreCase('Bag Replacement')&&
                    String.isNotBlank(recovery.Status__c) 
                    && recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusPendingApproval')
                    ){
                    recovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing');
                }
                
            }
            if(cases.size() > 0) update cases;
            
        }catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Recovery__c Trigger', 'RecoveryTriggerHelper', 
                                    'updateRecoveryType', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    /**
* @description  : Handles cases assignment to queues
* @param        : 
* @return       : a contact
* @author       : Cyrille 
*/ 
    public static void handleRecoveryTrigger(List<Recovery__c> recoveries, Map<Id, Recovery__c> mapOldMap){
        try{
            List<Id> casesId = new List<Id>();
            List<Case> cases = new List<Case>();
            for(Recovery__c recovery: recoveries){
                Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id) : null;
                Boolean rule_2 = false;

                if(String.isNotBlank(recovery.Type__c) && String.isNotBlank(recovery.Status__c)){
                    rule_2 = (recovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing')) 
                              &&( recovery.Type__c.equalsIgnoreCase('Wine') 
                                 //|| recovery.Type__c.equalsIgnoreCase('International Business Lounge Passes') 
                                 //|| recovery.Type__c.equalsIgnoreCase('Qantas club lounge passes') 
                                 || recovery.Type__c.equalsIgnoreCase('Valet Parking or Carwash') 
                                // || recovery.Type__c.equalsIgnoreCase('Travel vouchers')  // comment out due to CDP2-373 
                                 || recovery.Type__c.equalsIgnoreCase('Dinner vouchers')) );
                }
                
                if(rule_2){
                    // trigger case assignment rule
                    if(String.isNotBlank(recovery.Case_Number__c)){
                        casesId.add(recovery.Case_Number__c);
                    }
                    
                }
                
            }
            if(casesId.size() == 0) return;
            for(Case cs:  [SELECT Id , OwnerId FROM Case where Id in :casesId]) {
                cs.submitForFinalisation__c = true;
                cases.add(cs);
            }
            
            if(cases.size() > 0) update cases;
            
            
            //assignCaseToQueue(cases , 'Fulfillment_Queue');
            
        }catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Recovery__c Trigger', 'RecoveryTriggerHelper', 
                                    'handleRecoveryTrigger', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        invokeLoyaltyPostService
Description:        Invoke Loyalty API Service 
Parameter:          List of Recoveries,Map<Id,Recovery>
--------------------------------------------------------------------------------------*/    
    public static void invokeLoyaltyPostService(List<Recovery__c> lstNewRecovery, Map<Id, Recovery__c> mapOldRecovery){
        try{
            for(Recovery__c objRecovery: lstNewRecovery){
                Recovery__c objOldrecovery = mapOldRecovery != Null?mapOldRecovery.get(objRecovery.Id): Null;
                
                //CDP2-239 - Invoke Loyalty API for On the Spot Case Recovery
                if( (objRecovery.Process_Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusSubmitForFinalisation') || 
                    objRecovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved'))  && //existing one not changed for 239
                   (objOldrecovery == Null || objRecovery.Process_Status__c != objOldrecovery.Process_Status__c) &&
                   objRecovery.Type__c == CustomSettingsUtilities.getConfigDataMap('Qantas Points Type')) //Qantas Points
                {
                    system.debug('objRecovery#####'+objRecovery);
                    Integer amount = Integer.valueOf(objRecovery.Amount__c);
                    LoyaltyAPIHelper.invokeLoyaltyAPI(objRecovery.FF_Number__c, amount, objRecovery.Contact_LastName__c, objRecovery.CaseNumber__c, objRecovery.Id);
                }
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'invokeLoyaltyPostService', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        updateCaseRecoveryValue
Description:        Populate the Dollar Value in Case Recovery Value
Parameter:          List of Recoveries
--------------------------------------------------------------------------------------*/ 
    public static void updateCaseRecoveryValue(List<Recovery__c> recoveryList, Map<Id, Recovery__c> mapOldMap) {
        try {
            Map<Id, Case> recoveryCaseMap = new Map<Id, Case>();
            Set<Id> caseIds = new Set<Id>();
            
            for(Recovery__c rec: recoveryList) {
                Recovery__c objOldRecovery = mapOldMap != Null? mapOldMap.get(rec.Id): Null;
                if(objOldRecovery == null || objOldRecovery.Status__c != rec.Status__c){
                    caseIds.add(rec.Case_Number__c);
                }
            }
            
            for(Case cs: [SELECT Id, Recovery_Value__c , Recovery_Quantity__c, Emergency_Expense_Outcome__c, Status, Type FROM Case WHERE Id = :caseIds]) {
                recoveryCaseMap.put(cs.Id, cs);
            }
            
            if(recoveryCaseMap != null) {
                List<Case> casesToUpdate = new List<Case>();
                for(Recovery__c rec: recoveryList) {

                 /*   commented 20/8/24: Sourabh Singh for CDP2-531
                    if(rec.Currency_Conversion_Rate__c != null && rec.Monetary_Value__c != null){
                        rec.Value__c = rec.Currency_Conversion_Rate__c * rec.Monetary_Value__c;
                    }
                  */  

                    if(!recoveryCaseMap.containsKey(rec.Case_Number__c)){
                        
                        continue;
                    }
                    Case cs = recoveryCaseMap.get(rec.Case_Number__c);
                    //239 - If Recovery Process Status is 'Submitted for Finalisation'
                    if(rec.Process_Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusSubmitForFinalisation') || rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised') || rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved') || 
                     rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer')){
                        //Need to cross check with Team
                        cs.Recovery_Value__c = rec.Value__c;
                        cs.Recovery_Quantity__c = rec.Amount__c;
                        system.debug('befi insert');
                    }
                    
                    if(rec.Status__c ==  CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved')){ 
                        //rec.Status__c = 'Submit for Finalisation';
                        //rec.Payment_Status__c = 'Pending';
                    }
                    
                    if(rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing')){
                        if(rec.Stage__c == 'Stage 1'){
                            cs.Stage_1_Reimbursed__c = true;
                        }else if(rec.Stage__c == 'Stage 2'){
                            cs.Stage_2_Reimbursed__c = true;
                            if(cs.Emergency_Expense_Outcome__c == CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeDomestic')){
                                cs.EmergencyExpenseStage__c = 'NA';
                            }
                        }else if(rec.Stage__c == 'Stage 3'){
                            cs.Stage_3_Reimbursed__c = true;
                            cs.EmergencyExpenseStage__c = 'NA';
                        }
                    }
                    casesToUpdate.add(cs);
                    
                }
                
                if(casesToUpdate.size() > 0) {
                    Database.Update(casesToUpdate, false);
                    //update casesToUpdate;
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'updateCaseRecoveryValue', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
   
    /*--------------------------------------------------------------------------------------      
Method Name:        setFulfilledBy
Description:        Set recovery.FulfilledBy__c to null
Parameter:          List of Recoveries
--------------------------------------------------------------------------------------*/ 
    public static void setFulfilledBy(List<Recovery__c> recoveryList , Map<Id, Recovery__c> mapOldMap) {
        try {
            for(Recovery__c recovery: recoveryList){
                
                //if(setQCCRectype.contains(objCase.RecordtypeId)){
                Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id): Null;
                if(String.isNotBlank(recovery.Status__c)){
                    //approved flowers
                    if( recovery.Type__c != null && 
                       recovery.Type__c.equalsIgnoreCase('Flowers') && 
                       recovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved'))){
                           recovery.FulfilledBy__c = null;
                       }
                    
                    else if(recovery.Type__c != null && recovery.Type__c != CustomSettingsUtilities.getConfigDataMap('Qantas Points Type') && recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised') && (oldRecovery == null || (oldRecovery.Status__c != recovery.Status__c))) {
                        recovery.FulfilledBy__c = UserInfo.getUserId();
                        recovery.Fulfilled_Date__c = System.now();
                    }
                }
            }
            
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'setFulfilledBy', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    
    /*--------------------------------------------------------------------------------------      
Method Name:        
Description:        If recovery payment invalid route case to queue
Parameter:          
--------------------------------------------------------------------------------------*/ 
    public static void routeCaseOnRecoveryPaymentUpdate(List<Recovery__c> recoveryList , Map<Id, Recovery__c> mapOldMap) {
        try {
            List<Id> caseIds = new List<Id>();
            List<Case> cases = new List<Case>();
            for(Recovery__c recovery: recoveryList){
                
                //if(setQCCRectype.contains(objCase.RecordtypeId)){
                Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id): Null;
                if(!String.isBlank(recovery.Payment_Status__c) && recovery.Payment_Status__c.equalsIgnoreCase('Declined')){
                    caseIds.add(recovery.Case_Number__c);
                    recovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
                }
                system.debug('==========recovery.Status__c' + recovery.Status__c);
                
            }
            for(Case caseObj : [Select Id , OwnerId , Status , SubmitForFinalisation__c,  Resolution_Method__c from Case where Id in :caseIds]){
                caseObj.SubmitForFinalisation__c = true;
                caseObj.Status = 'Recovery Error';
                cases.add(caseObj);
            }
            
            if(cases.size() > 0) update cases;
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'setFulfilledBy', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        post to chatter on case status change
Description:        Set recovery.FulfilledBy__c to null
Parameter:          List of Recoveries
--------------------------------------------------------------------------------------*/ 
    public static void postToChatter(List<Recovery__c> recoveryList , Map<Id, Recovery__c> mapOldMap) {
        try {
            Map<Id , String> recoveryMessageMap = new Map<Id , String>();
            Map<Id , Case> recoveryCaseMap = new Map<Id , Case>();
      //Added by Bharath to include the chatter post on case from recovery 
            for(Recovery__c recovery: recoveryList){
                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ recovery.id;
                Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id): Null;
                if(oldRecovery != null){
                    if(String.isNotBlank(oldRecovery.Status__c) && String.isNotBlank(recovery.Status__c) && oldRecovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusPendingApproval')) && oldRecovery.Status__c != recovery.Status__c){
                        if((recovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusRejected')) || recovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved')))){
                            String status = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusRejected');
                            if(recovery.Status__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved'))){
                                status = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved');
                            }
                            
                            String content = 'Recovery Approval Request: ' + recovery.Status__c + ' for ' + recovery.Name + '\n' + 
                                'Recovery Number: ' + recovery.Name +'\n' +
                'Recovery URL: ' + fullFileURL +'\n' +
                                'Recovery Type: ' + recovery.Type__c +'\n' + 
                                'Recovery Quantity: ' + (recovery.Amount__c != Null? recovery.Amount__c: 0) + '\n' + 
                                'Recovery Value: ' + (recovery.Value__c != Null? recovery.Value__c: 0).round(System.RoundingMode.UP) + '\n' + 
                                status + ' By : ' + UserInfo.getName();
                            recoveryMessageMap.put(recovery.Id , content);
                            recoveryCaseMap.put(recovery.Case_Number__c , null);
                        }
                        
                    }
                    //// Added by Purushotham for No Frequent Flyer Number -- Start
                    //Need to cross check with Team
                    else if(recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer') && oldRecovery.Status__c != recovery.Status__c && recovery.Type__c == CustomSettingsUtilities.getConfigDataMap('Qantas Points Type')) {
                        String content = 'Recovery was created \n' + 
                            'Recovery Number: ' + recovery.Name +'\n' +
                        'Recovery URL: ' + fullFileURL +'\n' +
                            'Recovery Type: ' + recovery.Type__c + '\n' + 
                            'Status: ' + recovery.Status__c + '\n';
                        recoveryMessageMap.put(recovery.Id , content);
                        recoveryCaseMap.put(recovery.Case_Number__c , null);
                    }
                    //// Added by Purushotham for No Frequent Flyer Number -- End
                    else if(recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised') 
                        && oldRecovery.Status__c != recovery.Status__c 
                        && (recovery.Type__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes')) 
                            || recovery.Type__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes')))) {
                        String content = 'Recovery was finalised \n' + 
                            'Recovery Number: ' + recovery.Name +'\n' + 
              'Recovery URL: ' + fullFileURL +'\n' +
                            'Recovery Type: ' + recovery.Type__c + '\n' + 
                            'Status: ' + recovery.Status__c + '\n' +
                            'Lounge Pass Reference: ' + recovery.LoungePassReference__c + '\n';
                        recoveryMessageMap.put(recovery.Id , content);
                        recoveryCaseMap.put(recovery.Case_Number__c , null);
                    }
                }
            }
            System.debug('recoveryCaseMap.keySet() : ' + recoveryCaseMap.keySet());
            if(!recoveryMessageMap.isEmpty()){
                for(Case caseobj : [Select Id , OwnerId from Case where Id in :recoveryCaseMap.keySet()]){
                    for(Recovery__c recoveryObj : recoveryList){
                        if(caseObj.Id == recoveryObj.Case_Number__c){
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), recoveryObj.Case_Number__c, ConnectApi.FeedElementType.FeedItem, recoveryMessageMap.get(recoveryObj.id));
                        }
                    }
                }
            }
            
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'setFulfilledBy', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*----------------------------------------------------------------------------------------------
Description: Wrapper class used for Suggested Recovery
----------------------------------------------------------------------------------------------*/
    public class CaseCategories {
        String caseGroup;
        String category;
        String subCategory;
        String classification;
    }
    
    /*----------------------------------------------------------------------------------------------      
Method Name:        getSuggestedRange
Description:        Retrieves the Minimum and Maximum range for a Recovery
Parameter:          List<Recovery__c>
----------------------------------------------------------------------------------------------*/
    public static void getSuggestedRange(List<Recovery__c> recoveries) {
        try {
            String recoveryType1 = CustomSettingsUtilities.getConfigDataMap('Case Recovery Type 1');
            String recoveryType2 = CustomSettingsUtilities.getConfigDataMap('Case Recovery Type 2');
            String nonTier = CustomSettingsUtilities.getConfigDataMap('Non-Tier FF');
            String bronzeTier = CustomSettingsUtilities.getConfigDataMap('Bronze FF');
            String silverTier = CustomSettingsUtilities.getConfigDataMap('Silver FF');
            String goldTier = CustomSettingsUtilities.getConfigDataMap('Gold FF');
            String platinumTier = CustomSettingsUtilities.getConfigDataMap('Platinum FF');
            String platinumOneTier = CustomSettingsUtilities.getConfigDataMap('Platinum One FF');
            String caseReopened = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            String none = CustomSettingsUtilities.getConfigDataMap('None Value');
            String pointCalculationType1 = CustomSettingsUtilities.getConfigDataMap('Point Calculation Type 1');
            String pointCalculationType2 = CustomSettingsUtilities.getConfigDataMap('Point Calculation Type 2');
            String durationRange1 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 1');
            String durationRange2 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 2');
            String durationRange3 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 3');
            String qantasPoints = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
            String finalised = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
            String key;
            List<QCC_Suggested_Recovery__mdt> suggestedRecoveryData = new List<QCC_Suggested_Recovery__mdt>();
            Map<String, QCC_Suggested_Recovery__mdt> metadataMap = new Map<String, QCC_Suggested_Recovery__mdt>();
            
            suggestedRecoveryData = [SELECT Label,Type__c, Group__c, Category__c, Sub_Category__c, Point_Calculation__c,
                                     Tier__c, Flight_Duration__c, Classification__c, Recovery_Type__c, Min_Value__c, Max_Value__c
                                     FROM QCC_Suggested_Recovery__mdt];
            for(QCC_Suggested_Recovery__mdt meta: suggestedRecoveryData) {
                if(meta.Point_Calculation__c == pointCalculationType1){
                    key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c+''+meta.Tier__c+''+meta.Recovery_Type__c;
                } else if(meta.Point_Calculation__c == pointCalculationType2) {
                    key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c+''+meta.Tier__c+''+meta.Recovery_Type__c+''+meta.Flight_Duration__c;
                } else {
                    key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c;
                }
                
                key = key.toLowerCase();
                //System.debug('Parent key = '+key);
                metadataMap.put(key, meta);
            }
            System.debug('Map Size ---> '+metadataMap.size());
            //System.debug('Recovery Id ' + recId);
            Set<Id> contactIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            Set<Id> caseIdsWithCaseCategories = new Set<Id>();
            Map<Id, List<Case_Category__c>> caseCategoriesMap = new Map<Id, List<Case_Category__c>>();
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Case> caseMap = new Map<Id, Case>();
            Map<Id, List<Case>> contactCasesMap = new Map<Id, List<Case>>();
            Map<Id, List<Case_Category__c>> contactCaseCategoriesMap = new Map<Id, List<Case_Category__c>>();
            for(Recovery__c rec: recoveries) {
                contactIds.add(rec.Contact__c);
                caseIds.add(rec.Case_Number__c);
            }
            
            for(Contact con: [SELECT Id, Name, Frequent_Flyer_Tier__c FROM Contact WHERE Id = :contactIds]){
                contactMap.put(con.Id, con);
            }
            
            for(Case cs: [SELECT Id, Type, Group__c, Category__c, Sub_Category__c, Classification__c, ContactId, Status, Flight_Duration__c, Case_Category_Count__c, (SELECT Id, Amount__c, Status__c FROM Recoveries_Case__r WHERE Type__c =: qantasPoints AND Status__c =: finalised) FROM Case WHERE Id = :caseIds and (Origin!='Red App' and status!='Closed') limit 1000]) {
                caseMap.put(cs.Id, cs);
                if(cs.Case_Category_Count__c > 0) {
                    caseIdsWithCaseCategories.add(cs.Id);
                }
            }
            
            if(caseIdsWithCaseCategories != null && caseIdsWithCaseCategories.size() > 0) {
                for(Case_Category__c cs: [SELECT Group__c, Category__c, Sub_Category__c, Classification__c, Case__c FROM Case_Category__c WHERE Case__c = :caseIdsWithCaseCategories]) {
                    if(caseCategoriesMap.containsKey(cs.Case__c)){
                        caseCategoriesMap.get(cs.Case__c).add(cs);
                    }
                    else {
                        List<Case_Category__c> c = new List<Case_Category__c>();
                        c.add(cs);
                        caseCategoriesMap.put(cs.Case__c, c);
                    }
                }
            }
            
            //CRM-7851: Query update to avoid maximum execution time limit
            for(Case cs: [SELECT Type, Group__c, Category__c, Sub_Category__c, Classification__c, ContactId FROM Case WHERE ContactId = :contactIds AND Received_Date__c >= Last_N_Months:6 and (Origin!='Red App' and status!='Closed') limit 1000]) {
                if(contactCasesMap.containsKey(cs.ContactId)){
                    contactCasesMap.get(cs.ContactId).add(cs);
                }
                else {
                    List<Case> c = new List<Case>();
                    c.add(cs);
                    contactCasesMap.put(cs.ContactId, c);
                }
            }
            
            //CRM-7851: Query update to avoid maximum execution time limit
            for(Case_Category__c cs: [SELECT Type__c, Group__c, Category__c, Sub_Category__c, Classification__c, Contact_Name__c FROM Case_Category__c WHERE Contact_Name__c = :contactIds AND CreatedDate >= Last_N_Months:6]) {
                if(contactCaseCategoriesMap.containsKey(cs.Contact_Name__c)){
                    contactCaseCategoriesMap.get(cs.Contact_Name__c).add(cs);
                }
                else {
                    List<Case_Category__c> c = new List<Case_Category__c>();
                    c.add(cs);
                    contactCaseCategoriesMap.put(cs.Contact_Name__c, c);
                }
            }
            
            for(Recovery__c rec: recoveries) {
                Decimal minValue = 0;
                Decimal maxValue = 0;
                Decimal sev1Count = 0;
                Decimal sev2Count = 0;
                String recoveryType;
                Boolean SuggestedRecoveryEligible = false;
                String durationRange;
                String tier;
                String caseRecoveryType;
                Decimal caseCountInPastSixMonths = 0;
                Decimal suggestedMinValue = 0;
                Decimal suggestedMaxValue = 0;
                Case cs = caseMap != null ? caseMap.get(rec.Case_Number__c) : null;
                system.debug('===============caseMap' + caseMap);
                if(cs != null) {
                    if(cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Baggage Type') || cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type') ||
                       cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Compliment Type') || cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Query Type')) {
                           // Depreciation Value Process
                       }
                    else {
                        Contact con = contactMap.get(rec.Contact__c);
                        if(con.Frequent_Flyer_Tier__c == null) {
                            tier = nonTier;
                        }
                        else {
                            tier = con.Frequent_Flyer_Tier__c;
                        }
                        
                        if(cs.Status == caseReopened) {
                            caseRecoveryType = recoveryType2;
                        }
                        else if(caseRecoveryType == null){
                            if(contactCasesMap.containsKey(rec.Contact__c)) {
                                for(Case oldCs: contactCasesMap.get(rec.Contact__c)) {
                                    if(oldCs.Type == cs.Type && oldCs.Group__c == cs.Group__c && oldCs.Category__c == cs.Category__c && oldCs.Sub_Category__c == cs.Sub_Category__c && oldCs.Classification__c == cs.Classification__c) {
                                        caseCountInPastSixMonths++;
                                    }
                                }
                            }
                            
                            if(contactCaseCategoriesMap.containsKey(rec.Contact__c) && !(caseCountInPastSixMonths > 1) ) {
                                for(Case_Category__c oldCs: contactCaseCategoriesMap.get(rec.Contact__c)) {
                                    if(oldCs.Type__c == cs.Type && oldCs.Group__c == cs.Group__c && oldCs.Category__c == cs.Category__c && oldCs.Sub_Category__c == cs.Sub_Category__c && oldCs.Classification__c == cs.Classification__c) {
                                        caseCountInPastSixMonths++;
                                    }
                                }
                            }
                            
                            if(caseCountInPastSixMonths > 1) {
                                caseRecoveryType = recoveryType2;
                            }
                            else {
                                caseRecoveryType = recoveryType1;
                            }
                        }
                        
                        List<CaseCategories> caseValues = new List<CaseCategories>();
                        CaseCategories parentCase = new CaseCategories();
                        parentCase.caseGroup = cs.Group__c;
                        parentCase.category = cs.Category__c;
                        if(cs.Sub_Category__c == null) {
                            parentCase.subCategory = none;
                        } else {
                            parentCase.subCategory = cs.Sub_Category__c;
                        }
                        if(cs.Classification__c == null) {
                            parentCase.classification = none;
                        } else {
                            parentCase.classification = cs.Classification__c;
                        }
                        
                        caseValues.add(parentCase);
                        
                        if(cs.Case_Category_Count__c > 0) {
                            List<Case_Category__c> caseCategories = caseCategoriesMap.get(cs.Id);
                            for(Case_Category__c cc: caseCategories) {
                                CaseCategories childCase = new CaseCategories();
                                childCase.caseGroup = cc.Group__c;
                                childCase.category = cc.Category__c;
                                if(cc.Sub_Category__c == null){
                                    childCase.subCategory = none;
                                } else {
                                    childCase.subCategory = cc.Sub_Category__c;
                                }
                                
                                if(cc.Classification__c == null) {
                                    childCase.classification = none;
                                } else {
                                    childCase.classification = cc.Classification__c;
                                }
                                
                                caseValues.add(childCase);
                            }
                        }
                        
                        if(cs.Flight_Duration__c == null || (cs.Flight_Duration__c >= 0 && cs.Flight_Duration__c <= 4)) {
                            durationRange = '0-4';
                        } else if(cs.Flight_Duration__c > 4 && cs.Flight_Duration__c <= 10) {
                            durationRange = '4-10';
                        } else {
                            durationRange = '10+';
                        }
                        
                        for(CaseCategories c: caseValues){
                            System.debug('Group = '+c.caseGroup+' Cat = '+c.category+' Sub= '+c.subCategory+' Class='+c.classification);
                            Boolean isSev1 = false;
                            
                            QCC_Suggested_Recovery__mdt suggestedRec;
                            
                            String primaryKey = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification+''+tier+''+caseRecoveryType;
                            primaryKey = primaryKey.toLowerCase();
                            
                            String secondaryKey = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification+''+tier+''+caseRecoveryType+''+durationRange;
                            secondaryKey = secondaryKey.toLowerCase();
                            
                            String sev1Key = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification;
                            sev1Key = sev1Key.toLowerCase();
                            
                            //System.debug('Primary Key = '+primaryKey);
                            //System.debug('Secondary Key = '+secondaryKey);
                            //System.debug('Sev1 Key = '+sev1Key);
                            
                            if(metadataMap.containsKey(primaryKey)){
                                suggestedRec = metadataMap.get(primaryKey);
                                System.debug('Its a primaryKey');
                            } else if(metadataMap.containsKey(secondaryKey)){
                                suggestedRec = metadataMap.get(secondaryKey);
                                System.debug('Its a secondaryKey');
                            } else if(metadataMap.containsKey(sev1Key)){
                                suggestedRec = metadataMap.get(sev1Key);
                                isSev1 = true;
                                System.debug('Its a sev1Key');
                            }
                            
                            if(suggestedRec != null) {
                                if(!isSev1) {
                                    SuggestedRecoveryEligible = true;
                                    suggestedMinValue = suggestedRec.Min_Value__c;
                                    suggestedMaxValue = suggestedRec.Max_Value__c;
                                    if(cs.Case_Category_Count__c > 0) {
                                        sev2Count = sev2Count + 1;
                                    }
                                } else if(isSev1 && cs.Case_Category_Count__c > 0) {
                                    sev1Count = sev1Count + 1;
                                    if(sev1Count > 1 && SuggestedRecoveryEligible == false) {
                                        SuggestedRecoveryEligible = true;
                                    }
                                }
                            }
                            
                            if(suggestedMinValue > minValue) {
                                minValue = suggestedMinValue;
                            }
                            if(suggestedMaxValue > maxValue) {
                                maxValue = suggestedMaxValue;
                            }
                        }
                        
                        if((sev1Count + sev2Count)  > 1) {
                            //System.debug('sev1count = '+sev1Count+' sev2Count = '+sev2Count);
                            //System.debug('count = '+ (sev1Count + sev2Count));
                            Decimal extraPoints = 0;
                            if(tier == nonTier || tier == bronzeTier || tier == silverTier) {
                                extraPoints = (sev2Count + 0.5 * (sev1Count)).round(System.RoundingMode.CEILING) * 1000;
                                if(extraPoints > 3000) {
                                    extraPoints = 3000;
                                }
                                //System.debug('NBS');
                            }
                            if(tier == goldTier || tier == platinumTier || tier == platinumOneTier) {
                                extraPoints = (sev1Count + sev2Count)*1000 + 1000;
                                if(extraPoints > 4000) {
                                    extraPoints = 4000;
                                }
                            }
                            //System.debug('maxVal = '+ maxValue+' extraPoints = '+extraPoints);
                            maxValue = maxValue + extraPoints;
                        }
                        
                        if(SuggestedRecoveryEligible) {
                            // DO NOT DELETE
                            Decimal pointsAlreadyGiven = 0;
                            if(cs.Recoveries_Case__r != null && cs.Recoveries_Case__r.size() > 0) {
                                List<Recovery__c> otherRecoveries = cs.Recoveries_Case__r;
                                for(Recovery__c r: otherRecoveries) {
                                    pointsAlreadyGiven += r.Amount__c;
                                }
                                if(pointsAlreadyGiven < maxValue) {
                                    minValue = 0;
                                    maxValue = maxValue - pointsAlreadyGiven;
                                }
                                else if(pointsAlreadyGiven >= maxValue) {
                                    minValue = -1;
                                    maxValue = -1;
                                }
                            }
                            rec.Suggested_Minimum__c = minValue;
                            rec.Suggested_Maximum__c = maxValue;
                        }
                    }
                }
            }
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'getSuggestedRange', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
/*----------------------------------------------------------------------------------------------      
Method Name:        isNotFrequentFlyerMember
Description:        Updates Recovery Status if Customer is not having FF#
Parameter:          List<Recovery__c>, Map<Id, Recovery__c>
----------------------------------------------------------------------------------------------*/
    public static void isNotFrequentFlyerMember(List<Recovery__c> newRecList , Map<Id, Recovery__c> oldRecMap) {
        try {
            Set<Id> contactIds = new Set<Id>();
            
            if(oldRecMap != null) {
                for(Recovery__c rec: newRecList) {
                    Recovery__c oldRec = oldRecMap.get(rec.Id);
                    system.debug('==========isNotFrequentFlyerMember===========');
                    system.debug('==========rec.Status__c===========' + rec.Status__c);
                    system.debug('==========oldRec.Status__c===========' + oldRec.Status__c);
                    system.debug('==========rec.FF_Number__c===========' + rec.FF_Number__c);
                    system.debug('==========rec.Type__c===========' + rec.Type__c);
                    system.debug('==========rec.Complementary_Frequent_Flyer_Membership__c===========' + rec.Complementary_Frequent_Flyer_Membership__c);
                    if(rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer') && rec.Status__c != oldRec.Status__c && String.isBlank(rec.FF_Number__c) 
                        && (rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes')
                            || rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes'))) {
                        //rec.Complementary_Frequent_Flyer_Membership__c = true;
                    }

                    if(rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved') && rec.Status__c != oldRec.Status__c && String.isBlank(rec.FF_Number__c) 
                        && (rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Qantas Points Type'))) {
                        //rec.Status__c = 'Awaiting Customer Response';
                        rec.Complementary_Frequent_Flyer_Membership__c = true;
                        system.debug('==========Qantas Points Type===========');
                    }

                    if(rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved') && rec.Status__c != oldRec.Status__c && String.isBlank(rec.FF_Number__c) 
                        && (rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes')
                            || rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes'))) {
                        rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer');
                        rec.Complementary_Frequent_Flyer_Membership__c = true;
                        system.debug('==========RecoveryStatusAwaitingCustomerResponse===========');
                    }

                }
            }
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'isNotFrequentFlyerMember', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

/*----------------------------------------------------------------------------------------------      
Method Name:        isNotFrequentFlyerMember
Description:        Updates Recovery Status if Customer is not having FF#
Parameter:          List<Recovery__c>, Map<Id, Recovery__c>
----------------------------------------------------------------------------------------------*/
    public static void isFrequentFlyerMember(List<Recovery__c> newRecList , Map<Id, Recovery__c> oldRecMap) {
        try {
            Set<Id> contactIds = new Set<Id>();
            
            if(oldRecMap != null) {
                for(Recovery__c rec: newRecList) {
                    Recovery__c oldRec = oldRecMap.get(rec.Id);
                    system.debug('==========isFrequentFlyerMember===========');
                    system.debug('==========rec.Status__c===========' + rec.Status__c);
                    system.debug('==========oldRec.Status__c===========' + oldRec.Status__c);
                    system.debug('==========rec.FF_Number__c===========' + rec.FF_Number__c);
                    system.debug('==========rec.Type__c===========' + rec.Type__c);
                    system.debug('==========rec.Complementary_Frequent_Flyer_Membership__c===========' + rec.Complementary_Frequent_Flyer_Membership__c);

                    if(rec.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved') && rec.Status__c != oldRec.Status__c && String.isNotBlank(rec.FF_Number__c) 
                        && (rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes')
                            || rec.Type__c == CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes'))) {
                        rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing');
                        system.debug('==========Recovery IB Lounge Passes/Recovery DQC Lounge Passes===========');
                    }

                }
            }
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'isNotFrequentFlyerMember', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
/*--------------------------------------------------------------------------------------       
Method Name:        updateCaseStatusRecoveryEvent
Description:        Update the status of Case has Event type
Parameter:          List of Recoveries
--------------------------------------------------------------------------------------*/      
    public static void updateCaseStatusRecoveryEvent(List<Recovery__c> listNewRecovery){
        
        Set<Id> setCaseIds = new Set<Id>();
        // init set of case Id
        for(Recovery__c recovery : listNewRecovery){
            if(recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised')
               || recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined')
               || recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer')){
                   
               }
            setCaseIds.add(recovery.Case_Number__c);
        }
        system.debug('==========setCaseIds===========' + setCaseIds);
        system.debug('==========listNewRecovery===========' + listNewRecovery);
        // get case has recovery status = Finalised or Finalisation Declined to update status
        Map<Id, Case> mapCaseUpdate = new Map<Id, Case>([SELECT Id, Status, Type, FF_Tier__c, Contact.Frequent_Flyer_Number__c
                                                         FROM 
                                                         Case 
                                                         WHERE 
                                                         Id IN: setCaseIds AND 
                                                         Type =: CustomSettingsUtilities.getConfigDataMap('Case Type Event')]);
        system.debug('==========mapCaseUpdate===========' + mapCaseUpdate);
        for(Recovery__c recovery : listNewRecovery){
            if(mapCaseUpdate.containsKey(recovery.Case_Number__c)){
                // if recovery status = Finalised OR Awaiting customer Response, Close case
                if(recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised')
                    || recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined')){
                       
                       mapCaseUpdate.get(recovery.Case_Number__c).Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
                }
                if(String.isBlank(mapCaseUpdate.get(recovery.Case_Number__c).Contact.Frequent_Flyer_Number__c)
                    && recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer')){
                    
                    mapCaseUpdate.get(recovery.Case_Number__c).Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReceived');
                }
            }               
        }
        try{
            Database.update(mapCaseUpdate.values());
            system.debug('==========mapCaseUpdate====AFTER=======' + mapCaseUpdate);
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'updateCaseStatusRecoveryEvent', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
        
    }

/*--------------------------------------------------------------------------------------       
Method Name:        invokeOPLAForLoungePass
Description:        call out to OPLA for Digital Lounge Pass
Parameter:          List of Recoveries
--------------------------------------------------------------------------------------*/      
    public static void invokeOPLAAPIForLoungePass(List<Recovery__c> listNewRecovery, Map<Id, Recovery__c> mapOldMap){
        
        Set<Id> setRecoveryId = new Set<Id>();
        for(Recovery__c recovery : listNewRecovery){
            Recovery__c oldRecovery = mapOldMap != Null? mapOldMap.get(recovery.Id): Null;
            //Changes by Navya for CDP2-348
            if((recovery.Status__c == CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing')) 
                && (oldRecovery == null || (oldRecovery.Status__c != recovery.Status__c))
                && (recovery.Type__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('RecoveryTypeLoungePasses')) 
                    )){
                setRecoveryId.add(recovery.Id); 
            }        
        }
        
        try{
            if(setRecoveryId.size() > 0){
                system.debug('==========setRecoveryId===========' + setRecoveryId);
                ID jobID = System.enqueueJob(new QCC_RecoveriesCallOPLAAPIQueueable(setRecoveryId));
            }
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Trigger', 'RecoveryTriggerHelper', 
                                    'invokeOPLAAPIForLoungePass', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
        
    }
}