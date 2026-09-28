public without sharing class QCC_SurveyResponseTriggerHelper implements TriggerHelper.Processor {
    public static Map<Id, Survey_Response__c> oldRecMap = new Map<Id, Survey_Response__c>();
    public static String functionName = 'QCC - Survey Response Trigger';
    
    public void processTrigger(List<Survey_Response__c> newRecs, List<Survey_Response__c> oldRecs, TriggerHelper.Action triggerAction){
        Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
        if (triggerAction == TriggerHelper.Action.BEFOREINSERT) { 
            System.debug('>>>SurveyRecords: '+newRecs);
            if(apexSwitch.get('createCaseFromSurveyResponse') != null && apexSwitch.get('createCaseFromSurveyResponse').Active__c) { // Check if Custom Setting for createCaseFromSurveyResponse is True
                removeLeadingZeros(newRecs);
            }
        }
        if (triggerAction == TriggerHelper.Action.AFTERINSERT) { 
           if(apexSwitch.get('createCaseFromSurveyResponse') != null && apexSwitch.get('createCaseFromSurveyResponse').Active__c) { // Check if Custom Setting for createCaseFromSurveyResponse is True
            	createCaseFromSurveyResponse(newRecs);
           }
        }
        
        
    }
    
    public static void createCaseFromSurveyResponse(List<Survey_Response__c> newRecords)
    {
        try{
            List<String> frequentFlyerNumberList = new List<String>();
            Map<string,List<Contact>> otherRefDataMap = new Map<String,List<sObject>>();
            
            
            /**
            Frequent Flyer Number - QCC_Frequent_Flyer_Number__c
			Flight Number - QCC_Flight_Number__c
			Cabin Class
            Departure Airport
            Departure Date - QCC_Departure_Date__c
			Arrival Port            
            */
            
            Map<string,Survey_Response__c> surveyResponseMap = new Map<string,Survey_Response__c>();
            //collect QCC_Frequent_Flyer_Number__c to determine the contact for case creation
            for(Survey_Response__c surveyRecord : newRecords){
                frequentFlyerNumberList.add(surveyRecord.QCC_Frequent_Flyer_Number__c);
                String departureDateStr = QCC_SpecialLogicUtilityHelper.convertDateToDateTimeString(string.Valueof(surveyRecord.QCC_Departure_Date__c) );
                String surveyKey = surveyRecord.QCC_Frequent_Flyer_Number__c  + departureDateStr + surveyRecord.QCC_Departure_Airport__c + surveyRecord.QCC_Flight_Number__c +  surveyRecord.QCC_Arrival_Port__c + surveyRecord.QCC_Cabin_Class__c;
                
                System.debug('>>>surveyKey: '+surveyKey);
                surveyResponseMap.put(surveyKey, surveyRecord);
            }
            
            for(Group groupRecord : [SELECT Id, developerName FROM Group WHERE developerName = 'QANTAS_VIP_Post_Travel_Queue']){
                otherRefDataMap.put(groupRecord.developerName, new List<Sobject>{groupRecord});
            }
            
            List<Contact> contactList = [SELECT Id,Frequent_Flyer_Number__c FROM Contact WHERE Frequent_Flyer_Number__c IN :frequentFlyerNumberList	 AND RecordType.Name = 'Individual Contact']; //Get contacts by frequent flyer numbers
            for(Contact contactRecord : contactList ){
                otherRefDataMap.put(contactRecord.Frequent_Flyer_Number__c, new List<Contact>{contactRecord});
            }
            
            //TODO: Update logic for retrieving recordtype
            Id recordTypeId = Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
            String conditionClause = ' WHERE Module_Name__c =  \'Case Survey Response\'';
            List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords ('QCC_Source_to_Target_Object_Mapping__mdt', conditionClause);
            system.debug('>>>metaObjects: ' + metaObjects);
            
            //Create new case records using QCC Source to Target Object Mappings: Case Survey Response metadata
            List<Case> newCaseRecords = QCC_UtilityHelper.transformSourceToTargetObjects('Case Survey Response', newRecords,metaObjects , 'Case', recordTypeId, otherRefDataMap);
   
            List<Survey_Response__c> surveyToUpdate = new  List<Survey_Response__c>();
            if(!newCaseRecords.isEmpty()){
                insert newCaseRecords;
                System.debug('>>>newCaseRecords: '+newCaseRecords);
                for(Case caseRecord : newCaseRecords){
                    //String surveyKey = surveyRecord.QCC_Frequent_Flyer_Number__c  +  surveyRecord.QCC_Departure_Airport__c + surveyRecord.QCC_Departure_Date__c + surveyRecord.QCC_Flight_Number__c +  surveyRecord.QCC_Arrival_Port__c + surveyRecord.QCC_Cabin_Class__c;
                    String surveyKey = caseRecord.Frequent_Flyer_Number__c + caseRecord.Departure_Date_Time__c + caseRecord.Departure_Airport__c + caseRecord.Flight_Number__c + caseRecord.Arrival_Airport__c + caseRecord.Cabin_Class__c;
                    System.debug('>>>surveyKeyCase: '+surveyKey);
                    if (surveyResponseMap.containsKey(surveyKey)){
                        Survey_Response__c sr = new Survey_Response__c();
                        sr.case__c = caseRecord.Id;
                        sr.id = surveyResponseMap.get(surveyKey).id;
                        surveyToUpdate.add(sr);
                    }
                }

            }
            
          	update surveyToUpdate;
            
            

        }catch(exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_SurveyResponseTriggerHelper', 'createCaseFromSurveyResponse', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
    }
    
    //Remove leading zeros from Frequent Flyer Number
    public static void removeLeadingZeros(List<Survey_Response__c> newRecords){
        for(Survey_Response__c surveyRecord : newRecords){
           if( !string.isEmpty(surveyRecord.QCC_Frequent_Flyer_Number__c)){
                surveyRecord.QCC_Frequent_Flyer_Number__c = surveyRecord.QCC_Frequent_Flyer_Number__c.replaceFirst('^0+','');
            }
        }
        
    }

}