public with sharing class QCC_EFTRefundController {

    /**
    * @description  : Handles recovery fulfillment followin
    * @param        : 
    * @return       : 
    * @author       : Cyrille 
    */ 
    @AuraEnabled
    public static List<Recovery__c> updateRecoveryServer(List<Recovery__c> recoveries , String status) {

        List<Recovery__c> recoveryList = new List<Recovery__c>();
        try {
            List<Case> cases = new List<Case>();
            Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Fulfillment_Queue' LIMIT 1 ];
            Map<String , String> recoveryMap = new Map<String , String>();
            Map<String , String> recoveryIds = new Map<String , String>();
            Map<String , String> profilesMap = new Map<String , String>();
            String userProfile = [SELECT Name FROM Profile where id = :Userinfo.getProfileId()].Name;
            for(Recovery__c rec : recoveries){
                rec.Payment_Status__c = status;
                if(status.equalsIgnoreCase('Declined'))
                {
                    //Jira:CDP2-671
                    rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
                    recoveryMap.put(rec.Case_Number__c , 'Recovery Error');
                }
                else
                {
                    //Jira:CDP2-671
                    rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
                    rec.FulfilledBy__c = UserInfo.getUserId();
                    rec.Fulfilled_By_profile__c = userProfile;
                    rec.Recovery_Locked__c = true;
                    rec.Fulfilled_Date__c = System.now();
                    recoveryMap.put(rec.Case_Number__c , 'Closed');
                    recoveryIds.put(rec.Case_Number__c , rec.Id);
                 }
                 
             }
            
            System.debug('recoveryMap ' + recoveryMap);
            for(Case caseObj : [Select Id , OwnerId , Status , SubmitForFinalisation__c,  Resolution_Method__c from Case where Id in :recoveryMap.keySet()]){
                caseObj.Status  = recoveryMap.get(caseObj.Id);
                if(caseObj.status.equalsIgnoreCase('Recovery Error')){
                    caseObj.OwnerId = caseGroup.Id;
                    caseObj.submitForFinalisation__c = true;
                }else{
                    caseObj.Resolution_Method__c = 'Case auto closed';
                    // Added by Puru for QDCUSCON-4500 -- START
                    caseObj.TECH_CCEFTRecoveryId__c = recoveryIds.get(caseObj.Id);
                    // QDCUSCON-4500 -- END
                }
                cases.add(caseObj);
            }

            if(recoveries.size() > 0) update recoveries;
            if(cases.size() > 0) update cases;
            postToFeed(recoveries , status);

            }  catch(Exception ex){
                system.debug('ex###############'+ex);
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Refund Controller', 'QCC_EFTRefundController', 
                    'updateRecoveryServer', String.valueOf(''), String.valueOf(''),false,'', ex);
            }



          return recoveries;
      }

        /**
    * @description  : Post comment to chatter
    * @param        : 
    * @return       : 
    * @author       : Cyrille 
    */ 

     public static void postToFeed(List<Recovery__c> recoveries , String status){
            for(Recovery__c rec : recoveries){  
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ rec.id;
            String body = 'Recovery Fulfillment ' + status +  ' for ' + rec.Type__c;
            //code included for adding the recovery number on chatter for EFT card refunds
            body += '\nRecovery Number: '+rec.Name +''+'('+fullFileURL+')';
            body+='\nRecovery URL:' + fullFileURL;
            body += '\nRecovery Value:' + ( rec.Value__c != null ? rec.Value__c : 0);
            body += '\nFeedback: ' + (String.isNotBlank(rec.Approver_Comment__c) ? rec.Approver_Comment__c : 'N/A');
            body += '\nOriginal Currency: ' + ( String.isNotBlank(rec.Original_Currency__c) ? rec.Original_Currency__c : 'N/A');
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(),rec.Case_Number__c, ConnectApi.FeedElementType.FeedItem, body);
        }
        
        
    }

        /**
    * @description  : Load records
    * @param        : 
    * @return       : 
    * @author       : Cyrille 
    */ 
    @AuraEnabled
    public static List<Recovery__c> getRecoveries(String recType) {
        Boolean search = false;
        String strQuery = 'SELECT Contact_Full_Name__c, Bank_Name__c , Bank_Account_Name__c, Original_Currency__c , Credit_Card_Token__c, Card_Type__c, Amount__c,Case_Number__r.CaseNumber, Approver_Comment__c, Case_Number__r.Status,Name,Payment_Details__c,Payment_Status__c,Status__c,Type__c,Value__c FROM Recovery__c ';
        List<String> conditions = new List<String>();
        try {
            if(String.isNotBlank(recType)){
                if(recType.equalsIgnoreCase('EFT Refund')){
                    conditions.add(' Type__c = \'EFT Refund\' ') ;
                    search = true;
                }else{
                    conditions.add(' Type__c = \'Credit Card Refund\' ') ;
                    search = true;
                }

                if(!search) return null;
                if(conditions.size() > 0){
                    //Jira:CDP2-671
                    strQuery += ' WHERE ( ' + conditions[0] + ') AND Status__c = \'Processing\' AND Payment_Status__c = \'Pending\' AND Case_Number__c != null';
                }
                return Database.query(strQuery);
            }
            } catch(Exception ex){
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Recovery Refund Controller', 'QCC_EFTRefundController', 
                    'getRecoveries', String.valueOf(''), String.valueOf(''),false,'', ex);
            }
            return null;
                
        }

        /**
    * @description  : Retrieve a recovery based on the name entered in the UI
    * @param        : 
    * @return       : 
    */ 
    @AuraEnabled
    public static Recovery__c getRecovery(String recName) {
        if(String.isNotBlank(recName)){
            List<Recovery__c> recoveries = [SELECT Bank_Name__c , Original_Currency__c , Bank_Account_Name__c, Credit_Card_Token__c, Card_Type__c, Amount__c,Case_Number__r.CaseNumber, Approver_Comment__c, Case_Number__r.Status,Name,Payment_Details__c,Payment_Status__c,Status__c,Type__c,Value__c,Contact_Full_Name__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Name =: recName];
            if(recoveries.size() > 0) {
                if(String.isNotBlank(recoveries[0].Type__c)){
                    if(recoveries[0].Type__c.equalsIgnoreCase('EFT Refund') || recoveries[0].Type__c.equalsIgnoreCase('Credit Card Refund')){
                        return recoveries[0];
                    }
                }
            }
        }
        return null;
    }

    /**
    * @description  : Returns the org's base URL and the reports
    * @param        : 
    * @return       : 
    */ 
    @AuraEnabled
    public static String getOrgSettings() {
        Map<String , String> settings = new Map<String , String>();
        settings.put('url' , URL.getSalesforceBaseUrl().toExternalForm());
        List<Report> eftReport = [Select Id from Report where DeveloperName =: 'EFT_Report'];
        List<Report> ccReport = [Select Id from Report where DeveloperName =: 'QantasCCCreditReport'];
        if(eftReport.size() > 0 && eftReport != null){
            settings.put('eftReport' ,  String.valueOf(eftReport[0].Id));
        }

        if(ccReport.size() > 0 && ccReport != null){
            settings.put('ccReport' ,   String.valueOf(ccReport[0].Id));
        }

        return JSON.serialize(settings);
    }
}