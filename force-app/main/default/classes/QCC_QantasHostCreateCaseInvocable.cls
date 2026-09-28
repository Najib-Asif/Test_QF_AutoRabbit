//for contacts with always call ticked
//for GRAPHITE-958
public class QCC_QantasHostCreateCaseInvocable {
    @InvocableMethod
    public static void createCaseUponQantasHostCreation(List<id> qantasHostIds){
        System.debug('>>>createCaseUponQantasHostCreation - qantasHostIds:'+ qantasHostIds);
        try{
            //get List of created QCC_First_Host__c and relate the contact to new case
            List<QCC_First_Host__c> qantasHostRecords = new List<QCC_First_Host__c>([SELECT Name,createdDate, QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c 
                                                                                     FROM QCC_First_Host__c 
                                                                                     WHERE  Id in :qantasHostIds AND QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = TRUE]);
           
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
            String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
            String conditionClause = ' WHERE Module_Name__c =  \'Case Always Call\'';
            List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords (metaName, conditionClause);
            system.debug('>>>metaObjects: ' + metaObjects);
            
            List<sObject> newCaseRecords = QCC_UtilityHelper.transformSourceToTargetObjects('Case Always Call', qantasHostRecords,metaObjects , 'Case', recordTypeId, null);
            
            System.debug('>>>newCaseRecords: '+newCaseRecords);
            insert newCaseRecords;
    	}catch(Exception ex){
            System.debug('>>>exeption: '+ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC Qantas Host - Create Case', 'QCC_QantasHostCreateCaseInvocable', 'createCaseUponQantasHostCreation', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}