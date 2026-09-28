/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham
Company:       Capgemini
Description:   Controller class for QCC_Recovery_RecordPage Lightning Component
Inputs:
Test Class:    QCC_RecoveryController_CC_Test 
************************************************************************************************
History
************************************************************************************************
20-Nov-2017      Purushotham               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_RecoveryController_CC {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        updateRecovery
    Description:        Updates Status, Type and Qantas Points fields of the Recovery
    Parameter:          Id, Decimal and String
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String updateRecovery(Id recId, Decimal points, String type) {
        try {
            String qantasPoints = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
            String noGoodwill = CustomSettingsUtilities.getConfigDataMap('No Goodwill Type');
            String openStatus = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusNew');
            String apology = CustomSettingsUtilities.getConfigDataMap('Apology Type');

            Recovery__c recovery = [SELECT Id, Status__c, Type__c, Amount__c FROM Recovery__c WHERE RecordType.DeveloperName='Other_Recovery' AND Id = :recId ];
            
            if(type != apology) {
                recovery.Type__c = qantasPoints;
                if(points == null){
                    points = 0;
                }
                recovery.Value__c = null; 
                recovery.Monetary_Value__c = null;
            } else {
                recovery.Type__c = noGoodwill;
            }
            // change for new request -QDCUSCON-2866-Confirmation before submitting a Recovery
            // Consultant must confirm before change the status
            recovery.Status__c = openStatus;
            //System.debug('Points = '+points);
            recovery.Amount__c = points;
            update recovery;
            return 'true,The Recovery record was updated.';
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Suggested Recovery', 'QCC_RecoveryController_CC', 
                                     'updateRecovery', String.valueOf(''), String.valueOf(''),false,'', ex);
            return 'false'+','+ex.getMessage();
            //throw new AuraHandledException(ex.getMessage());
        }
    }
}