/*********************************************************************************
Name         : QCC_setCaseFieldsInvocable
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE - GRAPHITE-1050
Created Date : 07 Jan 2020
Usages       : This class is used to create case for each update case fields like
*********************************************************************************/

public class QCC_setCaseFieldsInvocable {
    
    @InvocableMethod(
        label='QCC_setCaseFieldsInvocable'
        description = 'Set case fields from API and Email-to-Case'
    )
    public static void updateFields(List<RequestWrapper> requests) {
        try{
            System.debug('>>>QCC_setCaseFieldsInvocable');
            Set<Id> caseIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            String moduleName;
            List<string> moduleNameList = new List<String>();
            List<Case> caseOnWatchlist = new List<Case>();
            List<Case> caseWithoutWatchlist = new List<Case>();
            Map<Id,Case> contactCaseMap = new Map<Id,Case>();
            Map<Id,Case> caseRecordMap = new Map<Id,Case>();
            List<Case> caseRecordsToUpdate = new List<Case>();
            List<String> caseTypesContactWatchlist = Label.QCC_CaseTypesContactWatchlistCheck.split(';'); 
            
            for (RequestWrapper request : requests) {                
                caseIds.add(request.caseID);
            }
            
            List<Case> caseRecords =  new List<Case>([SELECT Id, Subject,contactID, Type,CreatedDate, Priority, contact.SSU__c,Origin,RecordTypeId,recordType.Name,Departure_Date_Time__c, 
                                                      Updated_Departure_Date_Time__c, Contact.Frequent_Flyer_Number__c, Owner.Name,Service_Request_Number__c,Contact.Frequent_Flyer_Tier__c,
                                                      recordType.developerName
                                                      FROM Case 
                                                      WHERE Id in :caseIds ]);
            for(Case caseRecord : caseRecords){
                contactIds.add(caseRecord.contactID);
                contactCaseMap.put(caseRecord.contactId, caseRecord);
                caseRecordMap.put(caseRecord.Id, caseRecord);  
            }
            
            List<QCC_Contact_Watchlist__c> watchlistRecords = new List<QCC_Contact_Watchlist__c>([SELECT Id, QCC_Contact__c FROM QCC_Contact_Watchlist__c 
                                                                                                  WHERE 
                                                                                                  QCC_Contact__c IN :contactIds	
                                                                                                  AND  QCC_Watchlist_Start_Date__c  <= TODAY AND QCC_Watchlist_End_Date__c >= TODAY]); 
            System.debug('>>>watchlistRecords: '+watchlistRecords);
            Map<String,QCC_Contact_Watchlist__c> watchlistMap = new Map<String,QCC_Contact_Watchlist__c>();
            for(QCC_Contact_Watchlist__c watchlistRecord : watchlistRecords){
                watchlistMap.put(watchlistRecord.QCC_Contact__c,watchlistRecord );
            }
            
            for (RequestWrapper request : requests) {  
                Id caseContactId = caseRecordMap.containsKey(request.caseID)  ? caseRecordMap.get(request.caseID).contactId : null;
                
                String tempModuleName =  request.moduleName;
                //check if contact is on watchlist
                if(watchlistMap.containsKey(caseContactId) && caseContactId != null){
                    //If case type is on QCC_CaseTypesContactWatchlistCheck append ' - Watchlist' to moduleName
                    if(caseTypesContactWatchlist.contains(caseRecordMap.get(request.caseID).type)){
                        tempModuleName = caseRecordMap.get(request.caseID).type.endsWith('- Watchlist')  ? tempModuleName :tempModuleName + ' - Watchlist';
                        
                    }
                }
                moduleNameList.add(tempModuleName);
            }
            
         
            Map<String,List<sObject>> metaObjectsByModuleName = QCC_UtilityHelper.getSourceToTargetRecordsByModuleNames(moduleNameList); //QCC_UtilityHelper.getObjMap(metaName, 'Module_Name__c', conditionClauseInsert);
            System.debug('>>>metaObjectsByModuleName'+ metaObjectsByModuleName);
            
            for(Case caseRecord : caseRecords ){
                moduleName =  caseRecord.recordType.developerName + ' - ' +caseRecord.Type;
                //if contact is on watchlist append watchlist to module name
                if(watchlistMap.containsKey(caseRecord.contactId)){
                    //Contact of case is on watchlist
                    moduleName = moduleName + ' - Watchlist';
                }
                
                if(metaObjectsByModuleName.containsKey(moduleName)){
                    // Collection of Field from Metada for updating Case record
                    List<sObject> metaObjects = metaObjectsByModuleName.get(moduleName);
                    System.debug('>>>moduleName: '+moduleName);
                    
                    List<Case> caseList =  QCC_UtilityHelper.transformSourceToTargetObjects(moduleName, new List<Case>{caseRecord},metaObjects , 'Case', caseRecord.RecordTypeId, null) ;
                    caseRecordsToUpdate.addAll(caseList);
                }
            }
            
            System.debug('>>>caseRecordsToUpdate: '+caseRecordsToUpdate );
            if(!caseRecordsToUpdate.isEmpty()){
                Database.SaveResult[] saveResultList = Database.update(caseRecordsToUpdate, false);
                //Create the log record for those save result that fails
                QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC_setCaseFieldsInvocable', 'QCC_setCaseFieldsInvocable', '');
            }
            
        }catch(exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC_setCaseFieldsInvocable', 'QCC_setCaseFieldsInvocable', 'updateFields', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
        
    }
    
    
    //@purpose: Wrapper for process builder params
    //@params: 
    //	caseId: case record Id
    //	moduleName: module name in QCC_Source_to_Target_Object_Mapping__mdt (recordtype - type eg QCC Elite Process - PNR Health Check) 
    public class RequestWrapper{
        @InvocableVariable(
            label = 'Case ID'
            description = 'Case ID'
            required=true
        )
        public Id  caseID;
        
        @InvocableVariable(
            label = 'ModuleName'
            description = 'Metadata ModuleName'
            required=true
        )
        public String moduleName;
    }
    
}