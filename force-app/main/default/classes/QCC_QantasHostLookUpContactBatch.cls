/*********************************************************************************
Name         : QCC_QantasHostLookUpContactBatch
Created By   : Lora Mae Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 October 2019
Usages       : Link a Contact to the created Qantas Host record .
- If contact is not found, call callout method to search for Contact and create it in Saleforce
-- If response is null, create Case record.
*********************************************************************************/
global class QCC_QantasHostLookUpContactBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    Set<Id> qantasHostIds;
    Set<Id> qantasHostIdsToGetConnectingFlights = new Set<Id>();
    Id individualContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
    Id caseEliteProcessRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();

    global QCC_QantasHostLookUpContactBatch(set<Id> qantasHostIds) {
        this.qantasHostIds = qantasHostIds; 
        System.debug('###qantasHostIds: ' + qantasHostIds);
    }
    
    //START METHOD: Query all Qantas Host records passed via Qantas Host Ids.
    global Database.QueryLocator start(Database.BatchableContext BC){
        //TO DO: move query to a custom metadata -> QCC_SOQL_Setting__mdt
        String queryString = 'SELECT Id, QCC_Frequent_Flyer_Number__c, QCC_First_Host_Contact__c, QCC_Contact_Lastname__c, ' +
            'QCC_Departure_Airport__c, QCC_Arrival_Airport_Code__c, QCC_Departure_Airport_Code__c, QCC_PNR__c, QCC_Flight_No__c, ' +
            'QCC_TECH_GetConnectingFlights__c, QCC_TECH_IsCreatedFromEvent__c, QCC_First_Host_First_Name__c, QCC_Departure_Local_Date__c, ' +
            'CreatedDate, QCC_CONX_Arrival_Airport__c, QCC_CONX_Departure_Airport__c, QCC_CONX_Departure_Local_Date__c, QCC_CONX_PNR__c, ' +
            'QCC_CONX_Flight_No__c, QCC_TECH_CONX_Parent_Id__c, QCC_TECH_Comms_Sending_Date__c FROM QCC_First_Host__c WHERE Id IN: qantasHostIds';
        System.debug('###queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    
    //EXECUTE METHOD: Process queried records.
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('###scope: ' + scope);
        String conditionClause = ' WHERE Module_Name__c =  \'Case Qantas Host Call\'';
        List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords ('QCC_Source_to_Target_Object_Mapping__mdt', conditionClause);
        List<String> qHostAirportCodeList = Label.QCC_QantasHostCall_AirportCode_Condition.split(';'); 
        List <Case> caseToCreateList = new List <Case>();
        system.debug('###metaObjects ' + metaObjects);
        
        String tokenDayPrior;

        Map<String,QCC_First_Host__c> ffNumQantasHostMap = new Map<String,QCC_First_Host__c>();
        List<QCC_First_Host__c> qantasHostLists = (List<QCC_First_Host__c>)scope;
        System.debug('###qantasHostLists: ' + qantasHostLists);
        
        for (QCC_First_Host__c qHostRecord : qantasHostLists){
            //If QCC_Frequent_Flyer_Number__c is not empty, store the created Qantas Host record in a Map collection where the key is the FF number and the value is the QHost record.
            if (qHostRecord.QCC_Frequent_Flyer_Number__c != null){
                String ffNumber = qHostRecord.QCC_Frequent_Flyer_Number__c;
                //Remove leading 0 as Contact records save ffNUM without Leading 0.
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');					        
                ffNumQantasHostMap.put(ffNumWithOutLeadingZeros, qHostRecord);
                System.debug('###ffNumQantasHostMap: ' + ffNumQantasHostMap.keySet());
            }
            //If QCC_Frequent_Flyer_Number__c is empty, call the Utility method for Case creation using QCC Source to Target Object Mappings: Case_Qantas_Host_Call metadata
            else {       
                //Create Case only when Qantas Host record has no Contact, AND Departure Port is 'SYD' or 'MEL' and Flight No. is not 'QF0009'
                if(qHostAirportCodeList.contains(qHostRecord.QCC_Departure_Airport__c) && qHostRecord.QCC_Flight_No__c != Label.QCC_QantasHostCall_FlightNumber_Condition){
                    caseToCreateList = QCC_UtilityHelper.transformSourceToTargetObjects('Case Qantas Host Call', qantasHostLists, metaObjects , 'Case', caseEliteProcessRecordTypeId, null);
                    System.debug('###caseToCreateList: ' + caseToCreateList);
                }
            }
        }
        
        //Query the Contact record based on FF # from Qantas Host record and store in a Map collection where the key is the FF number and the value is the Contact record.
        Map <String, Contact> contactMaps = new Map <String, Contact>();        
        for (Contact con : [SELECT Name, Id, Frequent_Flyer_Number__c, RecordType.Name FROM Contact WHERE Frequent_Flyer_Number__c IN: ffNumQantasHostMap.keySet() AND RecordTypeId =: individualContactRecordTypeId]){
            contactMaps.put(con.Frequent_Flyer_Number__c, con);            
        }       
        System.debug('###contactMaps: ' + contactMaps.keySet());
        
        //Main Logic: If Contact is found; update QH record. If not found; create Case
        List<QCC_LookupFrequentFlyerController.CustomerWrapper> contactWrapperLists = new List<QCC_LookupFrequentFlyerController.CustomerWrapper>();
        List<QCC_LookupFrequentFlyerController.Phone> phoneWrapperList = new List<QCC_LookupFrequentFlyerController.Phone>();
        
        //GRAPHITE-1053 Generate a list of QH record to be updated for Day Prior logic
        Map<Id, QCC_First_Host__c> qantasHostRecordsToUpdateMap = new Map<Id, QCC_First_Host__c>();
        
        //GRAPHITE-2185 List all the needed information to get the possible parent Qantas Host records.
        List<String> parentArrivalPorts = new List<String>();
        List<String> parentDeparturePorts = new List<String>();
        List<String> parentPNRs = new List<String>();
        List<String> parentFlightNos = new List<String>();
        for (QCC_First_Host__c qantasHost : qantasHostLists){
            parentArrivalPorts.add(qantasHost.QCC_Arrival_Airport_Code__c);
            parentDeparturePorts.add(qantasHost.QCC_Departure_Airport_Code__c);
            parentPNRs.add(qantasHost.QCC_PNR__c);
            parentFlightNos.add(qantasHost.QCC_Flight_No__c);
        }
        System.debug('parentArrivalPorts: ' + parentArrivalPorts);
        System.debug('parentDeparturePorts: ' + parentDeparturePorts);
        System.debug('parentPNRs: ' + parentPNRs);
        System.debug('parentFlightNos: ' + parentFlightNos);

        //GRAPHITE-2185 Generate a map where key is the connecting flight info and the value is the parent Qantas Host record.
        List<QCC_First_Host__c> parentQantasHostRecords = [
            SELECT Id, QCC_CONX_Flight_No__c, QCC_CONX_Arrival_Airport__c,
            QCC_CONX_Departure_Airport__c, QCC_CONX_PNR__c, QCC_CONX_Departure_Local_Date__c
            FROM QCC_First_Host__c
            WHERE QCC_CONX_Arrival_Airport__c IN: parentArrivalPorts
            OR QCC_CONX_Departure_Airport__c IN: parentDeparturePorts
            OR QCC_CONX_PNR__c IN: parentPNRs
            OR QCC_CONX_Flight_No__c IN: parentFlightNos
        ];

        Map<String, QCC_First_Host__c> parentQantasHostRecordsMap = new Map<String, QCC_First_Host__c>();
        for(QCC_First_Host__c parentQantasHostRecord : parentQantasHostRecords) {
            String mapKey = parentQantasHostRecord.QCC_CONX_Flight_No__c + '###' +
                parentQantasHostRecord.QCC_CONX_Arrival_Airport__c + '###' +
                parentQantasHostRecord.QCC_CONX_Departure_Airport__c + '###' +
                parentQantasHostRecord.QCC_CONX_PNR__c + '###' +
                parentQantasHostRecord.QCC_CONX_Departure_Local_Date__c;
            parentQantasHostRecordsMap.put(mapKey, parentQantasHostRecord);
        }
        System.debug('parentQantasHostRecordsMap: ' + parentQantasHostRecordsMap);

        //Note: Only 1 record is expected here as there is a callout inside this loop and the scope of the batch is 1.
        for (QCC_First_Host__c qHostRecord : qantasHostLists){
            if (qHostRecord.QCC_Frequent_Flyer_Number__c != null){                
                String ffNumber = qHostRecord.QCC_Frequent_Flyer_Number__c;
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');					//remove leading 0 as Contact records save ffNUM without Leading 0   
                System.debug('###ffNumWithOutLeadingZeros: ' + ffNumWithOutLeadingZeros);
                
                //If Qantas Host record's Contact field is already populated, add the record to the list.
                if(qHostRecord.QCC_First_Host_Contact__c != null){
                    qantasHostIdsToGetConnectingFlights.add(qHostRecord.Id);    
                }
                //If Qantas Host record's Contact field is not populated, search for existing SF Contact based on FF num.
                else {
                    //If Contact is found on SF, add it into a List.
                    if (contactMaps.size() > 0 && contactMaps.containsKey(ffNumWithOutLeadingZeros)){
                        qHostRecord.QCC_First_Host_Contact__c = contactMaps.get(ffNumWithOutLeadingZeros).Id;
                        qantasHostIdsToGetConnectingFlights.add(qHostRecord.Id);
                        qantasHostRecordsToUpdateMap.put(qHostRecord.Id, qHostRecord);
                        System.debug('###SF CONTACT FOUND: ');
                    }
                    //If Contact is not found in SF, call API callout method to search for Contact on the external system.
                    else { 
                        string response = QCC_LookupFrequentFlyerController.lookupCustomer(qHostRecord.QCC_Frequent_Flyer_Number__c, qHostRecord.QCC_Contact_Lastname__c, '');
                        System.debug('###API CALL response: ' + response);
                        
                        //If response is success; deserialize the response.
                        if(response != null) {
                            System.debug('###Contact found');
                            QCC_LookupFrequentFlyerController.CustomerWrapper cw = (QCC_LookupFrequentFlyerController.CustomerWrapper)JSON.deserialize(response, QCC_LookupFrequentFlyerController.CustomerWrapper.class);
                            phoneWrapperList = cw.displayPhone;  
                            contactWrapperLists.add(cw);
                            System.debug('###phoneWrapperList: ' + phoneWrapperList);
                            System.debug('###contactWrapperLists: ' + contactWrapperLists);
                        }
                        //Insert Case record for every Qantas Host record without contact record and the callout to retrieve the customer information returns null.
                        else {
                            System.debug('###Create Case');
                            //Create Case only when Qantas Host record has no Contact, AND Departure Port is 'SYD' or 'MEL' and Flight No. is not 'QF0009'
                            if(qHostAirportCodeList.contains(qHostRecord.QCC_Departure_Airport__c) && qHostRecord.QCC_Flight_No__c != Label.QCC_QantasHostCall_FlightNumber_Condition){
                                //Call the Utility method for Case creation using QCC Source to Target Object Mappings: Case_Qantas_Host_Call metadata
                                caseToCreateList = QCC_UtilityHelper.transformSourceToTargetObjects('Case Qantas Host Call', qantasHostLists, metaObjects , 'Case', caseEliteProcessRecordTypeId, null);
                                System.debug('###caseToCreateList: ' + caseToCreateList);
                            }
                        }
                    }
                }
            }
            
            //GRAPHITE-2185 Check if Qantas host record is for a connecting flight.
            String formattedDepartureLocalDate = DateTime.newInstance(qHostRecord.QCC_Departure_Local_Date__c.year(), qHostRecord.QCC_Departure_Local_Date__c.month(), qHostRecord.QCC_Departure_Local_Date__c.day()).format('dd/MM/yyyy');
            String connectingFlightKey = qHostRecord.QCC_Flight_No__c + '###' + qHostRecord.QCC_Arrival_Airport_Code__c + '###' + qHostRecord.QCC_Departure_Airport_Code__c + '###' + qHostRecord.QCC_PNR__c + '###' + formattedDepartureLocalDate;
            System.debug('connectingFlightKey: ' + connectingFlightKey);
            if (parentQantasHostRecordsMap.containsKey(connectingFlightKey)) {
                //GRAPHITE-2185 Update the QCC_TECH_CONX_Parent_Id__c instead of triggering the Day Prior callout.
                if (qHostRecord.QCC_TECH_CONX_Parent_Id__c == null) {
                    QCC_First_Host__c parentQantasHostRecord = parentQantasHostRecordsMap.get(connectingFlightKey);
                    qHostRecord.QCC_TECH_CONX_Parent_Id__c = parentQantasHostRecord.Id;
                    qantasHostRecordsToUpdateMap.put(qHostRecord.Id, qHostRecord);
                }
            } else {
                //GRAPHITE-1053 Get all the Day Prior Form URL for all the QH records with QCC_TECH_IsCreatedFromEvent__c = true
                Qantas_API__c qantasAPIDayPrior = CustomSettingsUtilities.getQantasCAPAPI('QCC_DayPrior');
                System.debug('qantasAPIDayPrior: ' + qantasAPIDayPrior);
                tokenDayPrior = QCC_GenericUtils.getAPIGatewayValidToken('QCC_DayPriorToken');
                System.debug('tokenDayPrior: ' + tokenDayPrior);
                if (qHostRecord.QCC_TECH_IsCreatedFromEvent__c && qantasAPIDayPrior != null && String.isNotEmpty(tokenDayPrior) && qHostRecord.QCC_Departure_Local_Date__c > System.today()) {
                    QCC_InvokeMicroserviceAPI.QantasHostDayPriorRequest requestBody = new QCC_InvokeMicroserviceAPI.QantasHostDayPriorRequest();
                    requestBody.name = qHostRecord.QCC_First_Host_First_Name__c;
                    requestBody.id = qHostRecord.Id;
                    requestBody.dateOfDeparture = String.valueOf(qHostRecord.QCC_Departure_Local_Date__c);
                    System.debug('requestBody: ' + requestBody);

                    QCC_InvokeMicroserviceAPI.QantasHostDayPriorResponse dayPriorWrapper = QCC_InvokeMicroserviceAPI.invokeRetrieveDayPriorURL(
                        qantasAPIDayPrior, tokenDayPrior, JSON.serialize(requestBody)
                    );
                    if (!dayPriorWrapper.hasError) {
                        qHostRecord.QCC_TECH_Day_Prior_Contact_Form__c = dayPriorWrapper.url;
                        qantasHostRecordsToUpdateMap.put(qHostRecord.Id, qHostRecord);
                    }
                }
            }
        }
        System.debug('qantasHostRecordsToUpdateMap: ' + qantasHostRecordsToUpdateMap);
        
        try{
            //Check if the List from the returned response is not null, then only create a Contact record.
            List <Contact> contactToCreate = new List <Contact>();
            if (!contactWrapperLists.isEmpty()){
                //Call method for creating Contact.
                contactToCreate = createContact(contactWrapperLists, phoneWrapperList);
                System.debug('###contactToCreate: ' + contactToCreate);
                
                //Create contact record if the callout response is not null.
                if(!contactToCreate.isEmpty()){
                    System.debug('###contact is created ');
                    insert contactToCreate;
                    
                    //Get QH record to link the created Contact
                    for(Contact con : contactToCreate){
                        //GRAPHITE-1872 Remove leading zero from Frequent Flyer Number
                        String ffNumberWithoutLeadingZero = con.Frequent_Flyer_Number__c.replaceFirst('^0+','');
                        if(ffNumQantasHostMap.containsKey(ffNumberWithoutLeadingZero)) {
                            //If contact FFNumber match the QantasHost
                            QCC_First_Host__c qHostRecord = ffNumQantasHostMap.get(ffNumberWithoutLeadingZero);
                            if (qantasHostRecordsToUpdateMap.containsKey(qHostRecord.Id)) {
                                qHostRecord = qantasHostRecordsToUpdateMap.get(qHostRecord.Id);
                            }
                            qHostRecord.QCC_First_Host_Contact__c = con.Id;
                            qantasHostRecordsToUpdateMap.put(qHostRecord.Id, qHostRecord);
                            qantasHostIdsToGetConnectingFlights.add(qHostRecord.Id);
                        }
                    }
                }
            }            
            System.debug('###qantasHostRecordsToUpdateMap: ' + qantasHostRecordsToUpdateMap);
            
            //Update Qantas Host Records to link Contact.
            if (!qantasHostRecordsToUpdateMap.isEmpty()) {
                update qantasHostRecordsToUpdateMap.values();
            }            
            System.debug('###caseToCreateList: ' + caseToCreateList);
            
            //Insert Case record if the list is not empty.
            if(!caseToCreateList.isEmpty()){
                System.debug('###case is created ');
                insert caseToCreateList;
            }

            //GRAPHITE-2185 Update QCC_DayPriorToken Qantas_API__c record.
            if (tokenDayPrior != null) {
                QCC_GenericUtils.updateToken(tokenDayPrior, 'QCC_DayPriorToken');
            }
        }
        //Log error.
        catch(Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC_QantasHostLookUpContactBatch', 'QCC_QantasHostLookUpContactBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
            
        }
    }
    
    //FINISH METHOD: pass updated QH Ids to another class
    global void finish(Database.BatchableContext BC){
        system.debug('###finish');
        System.debug('###qantasHostIdsToGetConnectingFlights: ' + qantasHostIdsToGetConnectingFlights);
        system.debug('###QCC_QantasHostConnectingFlightBatch');
        
        //Call another batch for GRAPHITE-1174
        Database.executeBatch(new QCC_QantasHostConnectingFlightBatch(qantasHostIdsToGetConnectingFlights), 1);
    }
    
    //method for creating Contact; called on execute method
    public List<Contact> createContact (List<QCC_LookupFrequentFlyerController.CustomerWrapper> conWrapperList, List<QCC_LookupFrequentFlyerController.Phone> phoneWrapperList){
        System.debug('###createContact: ' );
        System.debug('###conWrapperList: ' + conWrapperList);
        System.debug('###phoneWrapperList: ' + phoneWrapperList);
        
        List<Contact> conListToInsert = new List<Contact>();
        String phoneNumber;
        Boolean phoneSelected = false;
        
        for(QCC_LookupFrequentFlyerController.Phone ph: phoneWrapperList) {
            if(ph.label.startsWith('Other')) {
                System.debug('PhoneToBeSelected = '+ph);
                phoneNumber = ph.value;
                break;
            } 
            else if(!phoneSelected) {
                phoneNumber = ph.value;
                phoneSelected = true;
            }
        }
        
        for (QCC_LookupFrequentFlyerController.CustomerWrapper contactWrapperRec : conWrapperList){
            Contact con = new Contact();
            con.LastName = contactWrapperRec.lastName;
            con.FirstName = contactWrapperRec.firstName;
            con.Email = contactWrapperRec.email;
            con.Frequent_Flyer_Number__c = contactWrapperRec.ffNumber;
            con.Frequent_Flyer_Tier__c = contactWrapperRec.ffTierSF; 
            con.RecordTypeId = individualContactRecordTypeId;
            con.Phone = phoneNumber.substringAfter(': ');
            conListToInsert.add(con);
        }   
        System.debug('###conListToInsert: ' + conListToInsert);        
        return conListToInsert;
    }
}