public class QCC_PassengerDisruptionCaseController {
    
    @AuraEnabled
    public static List<SectionWrapper> getPassengerRecords(Id caseId){
        List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();
        
        //Query Case record from recordId
        Case caseRecord = [SELECT Passenger_Id__c FROM Case WHERE id =: caseId];
        
        if(caseRecord.Passenger_Id__c != null){
            
            //Query Passenger record using Id from Case
            Affected_Passenger__c passengerRecord = [SELECT Name, FrequentFlyerTier__c, Passenger__r.SSU__c, FrequentFlyerNumber__c, PNR__c, Phone_Number__c ,
                                                     QCC_INTL_IN_CONX__c,QCC_INTL_OUT_CONX__c, QCC_DOM_IN_CONX__c, QCC_DOM_OUT_CONX__c, QCC_Checked_Bags__c,
                                                     QCC_Split_PNR__c, Event__r.Name,Event__r.FlightNumber__c, Event__r.DepartureDelayinHRSandMIN__c,Event__r.ArrivalDelayinHRSandMIN__c,
                                                     Event__r.Scheduled_Departure__c, QCC_Passenger_Notes__c, Event__r.GlobalEvent__c, Event__r.QCC_Heads_Up_Event__c, Event__r.QCC_Heads_Up_Event__r.Name, Event__r.QCC_Heads_Up_Event__r.Comments__c,
                                                     Event__r.QCC_Heads_Up_Event__r.GlobalEvent__c, Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Name,
                                                     Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Global_Event_Type__c,
                                                     Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Global_Event_Sub_Type__c,
                                                     Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Affected_Ports__c, Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.QCC_Significant_News__c,
                                                     Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Comments__c
                                                     FROM Affected_Passenger__c WHERE Id=: caseRecord.Passenger_Id__c ];
            
            System.debug('Passenger: ' + passengerRecord);
            //Map that will contain the generated fields and values per section
            Map<String, FieldsWrapper> sectionMap = new Map<String, FieldsWrapper>();
            System.debug('qcc heads up event id: ' + passengerRecord.Event__r.QCC_Heads_Up_Event__c);

            //Flight Event Active Section
            List<String> flightEventActiveLabelList = new List<String>{'Event Name', 'Flight Number',  'Scheduled Departure Date/Time', 'Departure Delay Length', 'Arrival Delay Length'};
            List<String> flightEventActiveValueList = new List<String>{'Event__r.Name', 'Event__r.FlightNumber__c',  'Event__r.Scheduled_Departure__c', 'Event__r.DepartureDelayinHRSandMIN__c',
                'Event__r.ArrivalDelayinHRSandMIN__c'};

            FieldsWrapper fieldsWrapper1 = new FieldsWrapper();
            fieldsWrapper1.fieldNames = flightEventActiveLabelList;
            fieldsWrapper1.fieldValues = flightEventActiveValueList;
            sectionMap.put('Flight Event Active Section', fieldsWrapper1);
            
            //Passenger Information Section
            List<String> passengerLabelList = new List<String>{'Name', 'Frequent Flyer Tier', 'SSU', 'FF Number', 'PNR', 'Phone Number', 'INTL IN CONX',
                'INTL OUT CONX', 'DOM IN CONX', 'DOM OUT CONX', 'Checked Bags', 'Split PNR'};
            List<String> passengerValueList = new List<String>{'Name', 'FrequentFlyerTier__c', 'Passenger__r.SSU__c', 'FrequentFlyerNumber__c', 'PNR__c', 'Phone_Number__c', 'QCC_INTL_IN_CONX__c',
                'QCC_INTL_OUT_CONX__c', 'QCC_DOM_IN_CONX__c', 'QCC_DOM_OUT_CONX__c', 'QCC_Checked_Bags__c', 'QCC_Split_PNR__c'};
            FieldsWrapper fieldsWrapper2 = new FieldsWrapper();
            fieldsWrapper2.fieldNames = passengerLabelList;
            fieldsWrapper2.fieldValues = passengerValueList;
            sectionMap.put('Passenger Information Section', fieldsWrapper2);

            if(passengerRecord.Event__r.QCC_Heads_Up_Event__c != null){
                //Flight Heads Up Section
                List<String> flightHeadsUpLabelList = new List<String>{'Event Name', 'Comments'};
                List<String> flightHeadsUpValueList = new List<String>{'Event__r.QCC_Heads_Up_Event__r.Name', 'Event__r.QCC_Heads_Up_Event__r.Comments__c'};
                FieldsWrapper fieldsWrapper3 = new FieldsWrapper();
                    fieldsWrapper3.fieldNames = flightHeadsUpLabelList;
                    fieldsWrapper3.fieldValues = flightHeadsUpValueList;
                sectionMap.put('Flight Heads Up Section', fieldsWrapper3);
            }

            if(passengerRecord.Event__r.QCC_Heads_Up_Event__r.GlobalEvent__c != null){
                //Global Heads Up 
                List<String> globalHeadsUpLabelList = new List<String>{'Event Name', 'Global Event Type', 'Global Event Sub-Type', 'Affected Port', 'Significant', 'Comments'};
                List<String> globalHeadsUpValueList = new List<String>{'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Name',
                        'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Global_Event_Type__c',
                        'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Global_Event_Sub_Type__c',
                        'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Affected_Ports__c',
                        'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.QCC_Significant_News__c',
                            'Event__r.QCC_Heads_Up_Event__r.GlobalEvent__r.Comments__c'};
                FieldsWrapper fieldsWrapper4 = new FieldsWrapper();
                    fieldsWrapper4.fieldNames = globalHeadsUpLabelList;
                    fieldsWrapper4.fieldValues = globalHeadsUpValueList;
                sectionMap.put('Global Heads Up Section', fieldsWrapper4);
            }
            for(String section: sectionMap.keySet()){
                SectionWrapper sectionWrapper = new SectionWrapper();
                
                List<PassengerWrapper> passengerWrapperList = new List<PassengerWrapper>();
                FieldsWrapper sectionList = sectionMap.get(section);
                for(Integer x = 0; x < sectionList.fieldNames.size(); x++){
                    PassengerWrapper wrapper = new PassengerWrapper();
                    //wrapper.fieldName = sectionList.fieldNames[x];
                    String fieldAPI = sectionList.fieldValues[x];
                    if (fieldAPI.contains('.')) {
                        List<String> splittedFields = fieldAPI.split('\\.');
                        System.debug('splittedFields: ' + splittedFields);
                        sObject lookupRecord = passengerRecord;
                        if (!splittedFields.isEmpty()) {
                            for(Integer y = 0; y < splittedFields.size() - 1; y++) {
                                String lookupObjectName = splittedFields[y];
                                lookupRecord = lookupRecord.getSObject(lookupObjectName);
                            }
                        }
                        String lookupFieldName = splittedFields[splittedFields.size() - 1];                        
                        //wrapper.fieldValue = String.valueOf(lookupRecord.get(lookupFieldName));
                        if (lookupRecord != NULL) {
                            wrapper.fieldName = sectionList.fieldNames[x];
                            wrapper.fieldValue = String.valueOf(lookupRecord.get(lookupFieldName));
                        }
                    } else {
                        wrapper.fieldName = sectionList.fieldNames[x];
                        wrapper.fieldValue = String.valueOf(passengerRecord.get(fieldAPI));
                    }
                    
                    passengerWrapperList.add(wrapper);
                }
                
                sectionWrapper.sectionName = section;
                sectionWrapper.passengerWrapperList = passengerWrapperList;
                sectionWrapperList.add(sectionWrapper);
            }

            //Heads Up Passenger Record for VIP
            if(passengerRecord.Event__r.QCC_Heads_Up_Event__c != null){
                //This query may be empty if the same passenger does not exist on the Heads Up flight event. Therefore, if that's the case no details will be displayed.
                List<Affected_Passenger__c> passengerRecords = new List<Affected_Passenger__c>([SELECT PassengerId__c, QCC_Passenger_Notes__c, QCC_Heads_Up_Action__c FROM Affected_Passenger__c
                                                            WHERE Passenger__c =: passengerRecord.Passenger__c AND Event__c =: passengerRecord.Event__r.QCC_Heads_Up_Event__c LIMIT 1]);
                
                Affected_Passenger__c passengerRecordVIP = (!passengerRecords.isEmpty()) ? passengerRecords.get(0) : NULL;
                System.debug('passengerRecordVIP: ' + passengerRecordVIP);
                List<PassengerWrapper> passengerHeadsUpWrapperList = new List<PassengerWrapper>();
                List<String> passengerHeadsUpLabels = new List<String>{'Passenger Notes', 'Heads Up Action'};
                    List<String> passengerHeadsUpValues = new List<String>{'QCC_Passenger_Notes__c', 'QCC_Heads_Up_Action__c'};
                        if (passengerRecordVIP != NULL) {
                            for(Integer j = 0; j < passengerHeadsUpLabels.size(); j++){
                                PassengerWrapper wrapper = new PassengerWrapper();
                                //wrapper.fieldName = passengerHeadsUpLabels[j];
                                String fieldAPI = passengerHeadsUpValues[j];
                                if (fieldAPI.contains('.')) {
                                    List<String> splittedFields = fieldAPI.split('\\.');
                                    System.debug('splittedFields: ' + splittedFields);
                                    sObject lookupRecord = passengerRecordVIP;
                                    if (!splittedFields.isEmpty()) {
                                        for(Integer k = 0; k < splittedFields.size() - 1; k++) {
                                            String lookupObjectName = splittedFields[k];
                                            lookupRecord = lookupRecord.getSObject(lookupObjectName);
                                        }
                                    }
                                    String lookupFieldName = splittedFields[splittedFields.size() - 1];                        
                                    //wrapper.fieldValue = String.valueOf(lookupRecord.get(lookupFieldName));
                                    if (lookupRecord != NULL) {
                                        wrapper.fieldName = passengerHeadsUpLabels[j];
                                        wrapper.fieldValue = String.valueOf(lookupRecord.get(lookupFieldName));
                                    }
                                } else {
                                    wrapper.fieldName = passengerHeadsUpLabels[j];
                                    wrapper.fieldValue = String.valueOf(passengerRecordVIP.get(fieldAPI));
                                }
                                
                                passengerHeadsUpWrapperList.add(wrapper);
                            }
                            
                SectionWrapper passengerHeadsUpSectionWrapper = new SectionWrapper();
                passengerHeadsUpSectionWrapper.sectionName = 'Passenger Heads Up Section';
                passengerHeadsUpSectionWrapper.passengerWrapperList = passengerHeadsUpWrapperList;
                sectionWrapperList.add(passengerHeadsUpSectionWrapper);
                }
            }
        }
        
        return sectionWrapperList;
    }
    
    public class PassengerWrapper{
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        
    }
    
    public class SectionWrapper{
        @AuraEnabled
        public String sectionName {get;set;}
        @AuraEnabled
        public List<PassengerWrapper> passengerWrapperList {get;set;}
    }
    
    public class FieldsWrapper{
         @AuraEnabled
        public List<String> fieldNames {get;set;}
        @AuraEnabled
        public List<String> fieldValues{get;set;}
        
    }
    
}