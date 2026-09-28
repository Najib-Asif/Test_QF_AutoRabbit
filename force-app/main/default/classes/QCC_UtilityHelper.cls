/*********************************************************************************
Name         : QCC_UtilityHelper
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used for all the reusable method that is used for the creation of records to target object
*********************************************************************************/
public without sharing class QCC_UtilityHelper {
    //@input parameters:
    //	-metaName - name of the metadata object (REQUIRED)
    //	-conditionClause - "where" clause (OPTIONAL)
    public static List<sObject> getObjRecords (String metaName, String conditionClause) {
        List<sObject> settings = new List<sObject>(); 
        String dynamicSOQL = '';
        String object_Fields = '';
        
        List<String> metaNames = new List<String>();
        metaNames.add(metaName);
        Schema.DescribeSobjectResult[] objectDescribe = Schema.describeSObjects(metaNames);
        // For each returned result, get the fields
        for(Schema.DescribeSobjectResult res : objectDescribe) {
            //System.debug('sObject Label: ' + res.getLabel());
            //System.debug('Fields: ' + res.fields.getMap());
            //System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            //Get Parent Object Fields
            for (String fieldName : res.fields.getMap().keySet()) {
                //system.debug('>>>fieldname: ' + fieldName);
                //if (object_Fields == '') {
                if (object_Fields.equals('')) {
                    object_Fields = fieldName;
                } else {
                    object_Fields = object_Fields + ',' + fieldName;
                }
            }
        }
        
        dynamicSOQL = 'SELECT ' + object_Fields + ' FROM ' + metaName;
        if (conditionClause != '') {
            dynamicSOQL = dynamicSOQL + ' ' + conditionClause;
        }
        system.debug('>>>dynamicSOQL: ' + dynamicSOQL);
        settings = Database.query(dynamicSOQL);
        
        return settings;
    }
    
    //@Purpose: This method allows for dynamically querying any object with all its fields with  a return of key-value pair
    //@input paremeters:
    //	-objRecords - any List of custom or standard objects converted into generic sObject type
    //@return type: List of sObject including fields with null values
    public static Map<String,List<sObject>> getObjMap(String objName, String keyName, String conditionClause) {
        Map<String,List<sObject>> obj_Map = new Map<String,List<sObject>>();
        
        List<sObject> records = getObjRecords(objName, conditionClause);
        List<sObject> finalRecords = new List<sObject>();
        if (!records.isEmpty()) {
            finalRecords = typeCastValue(records);
        }
        
        for (sObject obj : finalRecords) {
            String objKeyName = String.valueOf(obj.get(keyName));
            if (obj_Map.containsKey(objKeyName)) {
                obj_Map.get(objKeyName).add(obj);
            } else {
                obj_Map.put(objKeyName,new List<sObject>{obj});
            }
            //obj_Map = (obj_Map.containsKey(objKeyName)) ? obj_Map.put(objKeyName,obj_Map.get(objKeyName).add(obj) : obj_Map.put(objKeyName,new List<sObject>{obj});
        }
        
        return obj_Map;
    }
    
    //@Purpose: This method allows for dynamically transforming to a target object based from an event and/or source object. 
    //@input parameters:
    //	-records - list of records that is the triggering point of transformation
    //	-metaObjects - list of custom metadat type that defines the source to target mapping
    //@return type: List of sObject inserted
    public static List<sObject> transformSourceToTargetObjects (String moduleName, List<sObject> records, List<sObject> metaObjects, String targetObjName, String targetRecordTypeId, Map<String, List<sObject>> otherRefDataMap) {
        Map<String,Map<String,String>> sourceRec_TargetFields_Map = new Map<String,Map<String,String>>(); //Map of Object record => (Map of fieldName => fieldValue)
        Map<String,sObject> parentObject_Map = new Map<String,sObject>();
        
        
        //1. Loop through the records to create the related transaction record
        for (sObject rec : records) {
            System.debug('rec: ' + rec);
            
            Boolean isPlatformEventObject = false; // Flag to Check if the record Object is Platform Event Object or not.
            Map<String,String> fieldValues_Map = new Map<String,String>(); //Map of fieldName => fieldValue
            //2. Loop through the custom metadata to retrieve the mapping between the source object to the target object (which is the related transaction record)
            for (sObject mapObj : metaObjects) {
                system.debug('>>>mapObj: ' + mapObj);
                // Check object Type from metadata
                if(mapObj.get('Type__c') != NULL && mapObj.get('Type__c') == 'Platform_Event_to_Object' && !isPlatformEventObject){
                    isPlatformEventObject = true;        
                }
                //If target value is derived from the originating/source record's field
                String sourceFieldName = String.valueOf(mapObj.get('Source_Field__c'));
                String sourceFieldValue; //Moved out the instantiation
                system.debug('>>>sourceFieldName: ' + sourceFieldName);
                if (mapObj.get('Source_Field__c') != NULL) {
                    //Where sourceFieldValue used to be
                    String targetFieldName = String.valueOf(mapObj.get('Target_Field__c'));
                    system.debug('>>>targetFieldName: ' + targetFieldName);
                    
                    if (sourceFieldName.contains('.')) {
                        List<String> splittedFields = sourceFieldName.split('\\.');
                        System.debug('splittedFields: ' + splittedFields);
                        sObject lookupRecord = rec;
                        if (!splittedFields.isEmpty()) {
                            for(Integer x = 0; x < splittedFields.size() - 1; x++) {
                                String lookupObjectName = splittedFields[x];
                                lookupRecord = lookupRecord.getSObject(lookupObjectName);
                            }
                        }
                        String lookupFieldName = splittedFields[splittedFields.size() - 1];
                        //sourceFieldValue = (String)lookupRecord.get(lookupFieldName); //NOTE: Changed to below
                        sourceFieldValue = String.valueOf(lookupRecord.get(lookupFieldName));
                    } else {
                        sourceFieldValue = String.valueOf(rec.get(sourceFieldName));
                    }
                    system.debug('>>>sourceFieldValue: ' + sourceFieldValue);
                    if(isPlatformEventObject && sourceFieldValue != NULL && sourceFieldValue != ''){ // For Platform Event Object DO NOT OVERWRITE target field Value If source is NULL/Empty
                        fieldValues_Map.put(targetFieldName, sourceFieldValue);       
                    }else{
                        fieldValues_Map.put(targetFieldName, sourceFieldValue);
                    }
                    
                    //If source field is an External Id of a look-up/master-detail object, then get the parent object.
                    //NOTE: The External Id field name on the lookup/master object IS EXPECTED to be the same as the source field name
                    if (Boolean.valueOf(mapObj.get('Is_Relationship_Id__c'))) {
                        //Get the look-up/master object name to create the sObject
                        String parentObjectName = String.valueOf(mapObj.get('Parent_Object__c'));
                        //Instantiate the sObject based on parentObjectName
                        //sObject parentRec = Schema.getGlobalDescribe().get(parentObjectName).newSObject();
                        sObject parentRec = ((SObject)Type.forName(parentObjectName).newInstance()).getSObjectType().newSObject();
                        //Specify the External Id field name and value to retrieve the lookup/master record
                        parentRec.put(sourceFieldName,sourceFieldValue);
                        
                        //Put the record in a map with the External Id value as the unique key. The parentObject_Map is used later to associate to the parent lookup/master record
                        parentObject_Map.put(sourceFieldValue,parentRec);
                        
                        system.debug('>>>parentObject_Map: ' + parentObject_Map);
                        //String parentId = rec.get(mapObj.get(sourceFieldName));
                    }
                }
                
                //TODO : Change the logic after Quarterly and No Flight Update.
                //If target value is pre-determined from a default value
                if (mapObj.get('Source_Field__c') == NULL) {
                    String targetFieldName = String.valueOf(mapObj.get('Target_Field__c'));
                    String defaultFieldValue = String.valueOf(mapObj.get('Default_Value__c'));
                    String specialLogicName = mapObj.get('Special_Logic_Name__c') != NULL ? String.valueOf(mapObj.get('Special_Logic_Name__c')) : moduleName;
                    
                    if (Boolean.valueOf(mapObj.get('Has_Special_Logic__c'))) {
                        String newFieldValue = QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic(specialLogicName, targetFieldName, defaultFieldValue, otherRefDataMap);
                        fieldValues_Map.put(targetFieldName, newFieldValue);
                    } else {
                        fieldValues_Map.put(targetFieldName, defaultFieldValue);
                    }
                } else if (Boolean.valueOf(mapObj.get('Has_Special_Logic__c')) && sourceFieldValue != NULL) { //If target value is determined through a Source Field that needs to be evaluated further
                    String targetFieldName = String.valueOf(mapObj.get('Target_Field__c'));
                    String derivedFieldValue = sourceFieldValue;
                    String specialLogicName = String.valueOf(mapObj.get('Special_Logic_Name__c'));
                    String newFieldValue = QCC_SpecialLogicUtilityHelper.generateValueForFieldWithSpecialLogic(specialLogicName, targetFieldName, derivedFieldValue, otherRefDataMap);
                    fieldValues_Map.put(targetFieldName, newFieldValue);
                }
                
                system.debug('>>>fieldValues_Map: ' + fieldValues_Map);
            }
            
            if(isPlatformEventObject){ // For Platform Event Object use ReplayId, because Standard ID field is not available
                sourceRec_TargetFields_Map.put(String.valueOf(rec.get('ReplayId')),fieldValues_Map);    
            }else{ // For Regular Object use Id field
                sourceRec_TargetFields_Map.put(rec.Id,fieldValues_Map);	
            }
            
            system.debug('>>>sourceRec_TargetFields_Map: ' + sourceRec_TargetFields_Map);
            
            System.debug('CPU Time per loop rec: ' + Limits.getCpuTime());
        }
        
        system.debug('>>>sourceRec_TargetFields_Map: ' + sourceRec_TargetFields_Map);
        
        //3. Convert the map
        Map<String,Object> newObjs = (Map<String,Object>)sourceRec_TargetFields_Map;
        system.debug('>>>newObjs: ' + newObjs);
        system.debug('>>>parentObject_Map: ' + parentObject_Map);
        
        //4. Create the corresponding object
        System.debug('CPU Time before loop createDynamic: ' + Limits.getCpuTime());
        List<sObject> relTransactionRecords = createDynamicObjectRecords (targetObjName, '', newObjs, '', parentObject_Map, targetRecordTypeId);
        System.debug('CPU Time after loop createDynamic: ' + Limits.getCpuTime());
        
        return relTransactionRecords;
    }
    
    //@Purpose: This method allows for dynamically creating records from an input text file which is expected to be in JSON format. 
    //@input parameters:
    //	-objName - API name of the object
    //	-staticResourceName - name of the static resource that references the text file with the record details (Optional - used for Test Class)
    //	-newObjs - Map of RecordId => (Map of fieldName => fieldValue) - Map of record and its fields
    //	-parentFieldName - API name of the lookup object
    //	-parentObject_Map - Map of key=External Id/Unique Id, value=object record. This is used as reference to the parent record in case you are creating child records.
    //@return type: List of sObject inserted
    public static List<sObject> createDynamicObjectRecords (String objName, String staticResourceName, Map<String,Object> newObjs, String parentFieldName, Map<String,sObject> parentObject_Map, String recordTypeId) {
        //Get the object schema of the object name provided as input
        List<String> objectTypes = new List<String>();
        objectTypes.add(objName);
        Schema.DescribeSobjectResult[] objectDescribe = Schema.describeSObjects(objectTypes);
        //For now expecting only one type of object per processing. Get the field attributes of the object.
        Map<String, Schema.SobjectField> fields = new Map<String, Schema.SobjectField>();
        for(Schema.DescribeSobjectResult res : objectDescribe) {
            fields = res.fields.getMap();
        }
        
        //Get the details of the records to be created from a static resource file which is expected to be in JSON format
        List<sObject> newRecords = new List<sObject>();
        //This is used whe loading a JSON text file as reference to create records.
        if (staticResourceName != '') {
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
            String body = sr.Body.toString();
            system.debug('>>>body: ' + body);
            newObjs = (Map<String,Object>)JSON.deserializeUntyped(body);
        }
        system.debug('>>>newObjs: ' + newObjs);
        
        System.debug('CPU Time before loop newObjs: ' + Limits.getCpuTime());
        //sObject newRecTemplate = Schema.getGlobalDescribe().get(objName).newSObject() ;
        //Start creating the record, Loop through the JSON request
        for (Object rec : newObjs.values()) {
            //Convert the JSON string to an object
            Map<String,Object> sourceFieldsMap = (Map<String,Object>)rec;
            system.debug('>>>sourceFieldsMap: ' + sourceFieldsMap);
            
            //Loop through the sourceFieldsMap which came from the JSON request
            //sObject newRec = Schema.getGlobalDescribe().get(objName).newSObject();
            sObject newRec = ((SObject)Type.forName(objName).newInstance()).getSObjectType().newSObject();
            for (String col : sourceFieldsMap.keySet()) {
                System.debug('>>>col: ' + col);
                Schema.DescribeFieldResult fieldDescribe = fields.get(col).getDescribe();
                //Get the field data type
                Schema.DisplayType fieldDataType = fieldDescribe.getType();//fields.get(col).getDescribe().getType();
                
                //Get the value of the column from the JSON
                String colValue = string.valueOf(sourceFieldsMap.get(col));
                
                //Check if the field is a parent/lookup, then derive the lookup id field
                if (col == parentFieldName && parentObject_Map != NULL) { //This is used if you don't have an External Id that you can reference on the lookup/master object
                    if (parentObject_Map.containsKey(colValue)) {
                        colValue = parentObject_Map.get(colValue).Id;
                        system.debug('>>>parentFieldName: ' + parentFieldName+'-'+colValue);
                    }
                } else if (parentObject_Map != NULL) { //This is used if you have an External Id field that you used to determine the parentObject_Map
                    if (parentObject_Map.containsKey(colValue)) {
                        String relationshipName = fieldDescribe.getRelationshipName();//fields.get(col).getDescribe().getRelationshipName();
                        system.debug('>>>relationshipName: ' + relationshipName);
                        newRec.putSObject(relationshipName, parentObject_Map.get(colValue));
                        //Set colValue to NULL to skip the typecasting below since we already set the relationship value in the line above.
                        colValue = NULL;
                    }
                } else if (col.contains('.')) {
                    System.debug('contains .');
                }
                
                //Check if the field is RecordType, then derive the record Type Id
                /**if (col == 'RecordTypeId') {
String recTypeId = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().get(colValue).getRecordTypeId();
colValue = recTypeId;
}*/
                
                //Typecase the value to the field's data type
                if (colValue != NULL) {
                    System.debug('>>>col: ' + col);
                    System.debug('>>>newRec: ' + newRec);
                    System.debug('>>>fieldDataType: ' + fieldDataType);
                    System.debug('>>>colValue: ' + colValue);
                    typeCastValue(col,newRec,fieldDataType,colValue);
                }
            }
            
            if (recordTypeId != null) {
                newRec.put('RecordTypeId', recordTypeId);
            }
            
            newRecords.add(newRec);
            
            System.debug('CPU Time per loop newObjs: ' + Limits.getCpuTime());
        }
        
        system.debug('>>>newRecords: ' + newRecords);
        
        return newRecords;
    }
    
    //This method will typecast values based on the target Salesforce field Display Type/Data Type
    //Refer to the documentation below if need to add other Display type/Data Type
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm 
    public static sObject typeCastValue(String salesforceFieldApi,sObject recToReturn,Schema.DisplayType fieldDataType,String fieldValue){
        
        Set<Schema.DisplayType> displayTypeString = new Set<Schema.DisplayType>{Schema.DisplayType.STRING, Schema.DisplayType.TextArea, Schema.DisplayType.Picklist, Schema.DisplayType.Email, Schema.DisplayType.Multipicklist};
            
            if(fieldValue != null){
                
                if(fielddataType == Schema.DisplayType.Boolean){
                    recToReturn.put(salesforceFieldApi,boolean.valueOf(fieldValue));
                }
                
                if(displayTypeString.contains(fieldDataType)){
                    recToReturn.put(salesforceFieldApi,fieldValue);  
                }
                
                if(fielddataType == Schema.DisplayType.Currency || fielddataType == Schema.DisplayType.Percent){
                    recToReturn.put(salesforceFieldApi,decimal.valueOf(fieldValue));   
                }
                
                if(fielddataType == Schema.DisplayType.Date){
                    recToReturn.put(salesforceFieldApi,date.valueOf(fieldValue));   
                }
                
                if(fielddataType == Schema.DisplayType.DateTime){
                    recToReturn.put(salesforceFieldApi,dateTime.valueOf(fieldValue));   
                }
                
                if(fielddataType == Schema.DisplayType.Time){
                    List<String> parseTimeList = fieldValue.split(':');
                    Integer hh = 0, mm = 0, ss = 0;
                    Integer stringIndex = 0;
                    for(String parseTime : parseTimeList) {
                        switch on stringIndex {
                            when 0 {
                                hh = Integer.valueOf(parseTimeList[stringIndex]);
                            }
                            when 1 {
                                mm = Integer.valueOf(parseTimeList[stringIndex]);
                            }
                            when 2 {
                                String valueInSeconds = parseTimeList[stringIndex];
                                if (valueInSeconds.contains('.')) {
                                    List<String> listValueInSeconds = valueInSeconds.split('\\.');
                                    valueInSeconds = listValueInSeconds[0];
                                }
                                ss = Integer.valueOf(valueInSeconds);
                            }
                        }
                        stringIndex++;
                    }
                    
                    Time newTime = Time.newInstance(hh, mm, ss, 0);
                    recToReturn.put(salesforceFieldApi,newTime);
                }
                
                if(fielddataType == Schema.DisplayType.Double){
                    recToReturn.put(salesforceFieldApi,double.valueOf(fieldValue));
                }
                
                if(fielddataType == Schema.DisplayType.Integer){
                    recToReturn.put(salesforceFieldApi,integer.valueOf(fieldValue));   
                }
                
                if(fielddataType == Schema.DisplayType.ID || fielddataType == Schema.DisplayType.Reference){
                    recToReturn.put(salesforceFieldApi,id.valueOf(fieldValue));
                }
            }
        
        return recToReturn;
    }
    
    //@Purpose: When system performs SOQL query, the result does not include the fields with null values. In some instances it is logical to know that the field has null value.
    //			This method will format the result such that it includes even those fields with null values. This method is re-usable and can be called by other class methods.
    //@input paremeters:
    //	-objRecords - any List of custom or standard objects converted into generic sObject type
    //@return type: List of sObject including fields with null values
    public static List<sObject> typeCastValue(List<sObject> objRecords) {
        for(sObject recToReturn : objRecords){
            Map<String, Schema.SobjectField> fields = recToReturn.getSObjectType().getDescribe().fields.getMap();
            for (String fieldName : fields.keyset()) {
                //system.debug('>>> ' + fieldName + ': ' + fields.get(fieldName));
                String fieldValue = string.ValueOf(recToReturn.get(fieldName));
                if (fieldValue == null && fields.get(fieldName).getDescribe().isUpdateable()) {
                    //system.debug('>>> ' + fieldName + ': ' + fieldValue);
                    recToReturn.put(fieldName, null);
                }
                
            }
        }
        
        return objRecords;
    }
    
    //@Purpose: This method updates the token for Qantas API record if the new token provided is not equals to the current token.
    //@input parameters:
    //	-qantasAPI - The record to be updated.
    //	-token - The new token to be saved as Token__c.
    //@return type: None
    public static void updateQantasAPIToken(Qantas_API__c qantasAPI, String token) {
        if(qantasAPI.Token__c != token) {
            qantasAPI.Token__c = token;
            update qantasAPI;
        }
    }
    
    
    //@Purpose: This method formatting the date to yyyy-mm-dd HH:mm:ss
    //@input parameters:
    //	-datetimeString - The datetime string with dd/mm/yyyy HH:mm:ss format
    //@return type: new formatted date
    public static datetime processDatetime(String datetimeString){ // INPUT MUST BE dd/mm/yyyy HH:mm:ss
        List<String> dateTimeSplitted = datetimeString.split(' '); // Separate Date and Time
        List<String> dateString = dateTimeSplitted[0].split('/'); // Split date
        DateTime formatedDatetime = DateTime.valueOf(dateString[2] + '-' + dateString[1] + '-' + dateString[0] + ' ' + dateTimeSplitted[1]);
        return formatedDatetime;
    }
    
    // @purpose: This method returns local Datetime
    // @return type: datetime
    public static Datetime getLocalDateTime() {
        Datetime dateTimeNow = datetime.now();
        Datetime localDateTime = dateTimeNow.Date();
        localDateTime = localDateTime.addHours(dateTimeNow.hour());
        localDateTime = localDateTime.addMinutes(dateTimeNow.minute());
        localDateTime = localDateTime.addSeconds(dateTimeNow.second());
        
        return localDateTime;
        
        // Datetime now = Datetime.now();
        // Integer offset = UserInfo.getTimezone().getOffset(now);
        // Datetime localDateTime = now.addSeconds(offset/1000);
        
        // return localDateTime;
    }
    
    public static QCC_SOQL_Setting__mdt getSOQLSettingRecordByModuleName(String moduleName) {
        QCC_SOQL_Setting__mdt customMetadataRecord;
        try {
            customMetadataRecord = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c, Filter_Condition__c
                FROM QCC_SOQL_Setting__mdt
                WHERE Module_Name__c =: moduleName LIMIT 1
            ];
        } catch(Exception e) {
            customMetadataRecord = null;
        }
        
        return customMetadataRecord;
    }
    
    //@Purpose: This method converts a time value in String type to Salesforce Time type
    //@input parameters:
    //	-timeValue - The time string with HH:mm format
    //@return type: new formatted time
    public static Time parseStringtoTime (String timeValue) {
        Integer hh = Integer.valueOf(timeValue.substringBefore(':'));
        Integer mm = Integer.valueOf(timeValue.substringAfter(':'));
        system.debug('>>>checkPortsWithCurfew - time:' + hh + ':' + mm);  
        Time covertedTimeValue = Time.newInstance(hh, mm, 0, 0);
        return covertedTimeValue;
    }
    
    //@Purpose: This method get all id that is part of specific public group
    //@input parameters:
    //	-groupName - The name of the group you want to get all the users.
    //@return type: List of Ids
    public static List<Id> getAllUserFromPublicGroup(String groupName) {
        List<Id> userIds = new List<Id>();
        for(GroupMember groupMemberRecord : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name =: groupName]) {
            userIds.add(groupMemberRecord.UserOrGroupId);
        }
        return userIds;
    }
    
    //@Purpose: This method get all user using Id
    //@input parameters:
    //	-userIds - The user id
    //@return type: List of users
    public static List<User> getAllUserByIds(List<Id> userIds) {
        return [SELECT Id, Name FROM User WHERE Id IN: userIds AND IsActive = true];
    }
    
    //@Purpose: This method get all user using UserRoleId
    //@input parameters:
    //	-userRoleIds - The user role id
    //@return type: List of users
    public static List<User> getAllUserByUserRoleIds(List<Id> userRoleIds) {
        return [SELECT Id, Name FROM User WHERE UserRoleId IN: userRoleIds AND IsActive = true];
    }
    
    //@Purpose: This method get Parent Role with child roles
    //@input parameters:
    //@return type: Map of User Role, Parent Role Id as key and all child role as values
    public static Map<Id, List<UserRole>> getUserRoleHierarchyMap() {
        Map<Id, List<UserRole>> userRoleHierarchyMap = new Map<Id, List<UserRole>>();
        for (UserRole role : [SELECT ParentRoleId FROM UserRole]) {
            List<UserRole> userRoleList;
            if (userRoleHierarchyMap.containsKey(role.ParentRoleId)) {
                userRoleList = userRoleHierarchyMap.get(role.ParentRoleId);
            } else {
                userRoleList = new List<UserRole>();
            }
            userRoleList.add(role);
            userRoleHierarchyMap.put(role.ParentRoleId, userRoleList);
        }
        
        return userRoleHierarchyMap;
    }
    
    //@Purpose: This method get all user using UserRoleId
    //@input parameters:
    //	-userRoleId - The user role id
    //	-userRoleHierarchyMap - Map of all the parent role with their child roles
    //@return type: Set of Role Ids
    public static Set<Id> getSubHierarchyRoleIds(Id userRoleId, Map<Id, List<UserRole>> userRoleHierarchyMap) {
        Set<Id> roleIds = new Set<Id>();
        roleIds.add(userRoleId);
        if (userRoleHierarchyMap.containsKey(userRoleId)) {
            for (UserRole childRole : userRoleHierarchyMap.get(userRoleId)) {
                roleIds.addAll(getSubHierarchyRoleIds(childRole.Id, userRoleHierarchyMap));
            }
        }
        return roleIds;
    }
    
    //@Purpose: This method parse the string to get the list of string values
    //@input parameters:
    //	-stringValue - This field will be splitted
    //	-delimiter - This is used to split the stringValue
    //@return type: List of string
    public static List<String> getListFromString(String stringValue, String delimiter) {
        List<String> listToReturn = new List<String>();
        for(String str : stringValue.split(delimiter)) {
            listToReturn.add(str.trim());
        }
        
        return listToReturn;
    }
    
    //@Purpose: This method check if current time is still in range of the office hours
    //@input parameters:
    //	-businessHourRecordName - The name of the Business Hour record to check.
    //	-dateTimeToCheck - The datetime value that needs to be checked if within the Business Hour record.
    //@return type: Flag that will determine if dateTimeToCheck is within the Business Hour.
    public static Boolean checkIfWithinBusinessHours(String businessHourRecordName, DateTime dateTimeToCheck) {
        Boolean isWithinBusinessHours = true;
        
        //Get Business Hour record
        BusinessHours businessHourRecord;
        try {
            businessHourRecord = [SELECT Id FROM BusinessHours WHERE Name =: businessHourRecordName];
        } catch(Exception ex) {
            businessHourRecord = null;
        }
        
        //Find whether the time is within the business hours
        if (businessHourRecord != null) {
            isWithinBusinessHours = BusinessHours.isWithin(businessHourRecord.id, dateTimeToCheck);
        } else {
            isWithinBusinessHours = false;
        }
        
        return isWithinBusinessHours;
    }
    
    // Convert String to Time data type
    // Param : String Time Hour:Minute:Seconds
    public static Time convertStringToTime(String stringTime){
        if(stringTime == '' || stringTime == NULL){
            return null;
        }
        String[] strTimeSplit = stringTime.split(':');
        Time timeValue = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                          ,Integer.valueOf(strTimeSplit[1]) //min
                                          ,0                                //sec
                                          ,0);                              //ms
        return timeValue;
        
    }    
    
    //@purpose: Prevent datetime from adjusting to GMT
    //@param: DateTime
    public static DateTime preventGmtConversion(DateTime dtime){
        Datetime newDateTime = dtime.Date();
        newDateTime = newDateTime.addHours(dtime.hour());
        newDateTime = newDateTime.addMinutes(dtime.minute());
        newDateTime = newDateTime.addSeconds(dtime.second());
        return newDateTime;
    }
    
    public static String getValueFromSObject(String fieldName, sObject sObjectRecord) {
        String fieldValue;
        if (fieldName.contains('.')) {
            List<String> splittedFields = fieldName.split('\\.');
            System.debug('splittedFields: ' + splittedFields);
            sObject lookupRecord = sObjectRecord;
            if (!splittedFields.isEmpty()) {
                for(Integer x = 0; x < splittedFields.size() - 1; x++) {
                    String lookupObjectName = splittedFields[x];
                    lookupRecord = lookupRecord.getSObject(lookupObjectName);
                }
            }
            String lookupFieldName = splittedFields[splittedFields.size() - 1];
            fieldValue = lookupRecord != null ? String.valueOf(lookupRecord.get(lookupFieldName)) : null;
        } else {
            fieldValue = String.valueOf(sObjectRecord.get(fieldName));
        }
        
        return fieldValue;
    }
    
    //@purpose: To check if current user is a CCAT Agent
    //@param: User
    public static Boolean isCCATAgent(User user){
        Boolean isCCATAgent = false;
        
        List<String> Location = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Location, ';');
        List<String> CCATRole = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Roles, ';');
        
        if (user.CCAT_User__c== true) {
            isCCATAgent = true;
        }
        
        return isCCATAgent;
    }
    
    //@purpose: Collect all given User Id's if CCAT Agent
    //@param: User Id's
    public static Set<Id> getListOfCCATUser(List<Id> userIdList){
        Set<Id> userCCATSet = new Set<Id>();
        List<String> Location = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Location, ';');
        List<String> CCATRole = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Roles, ';');
        List<String> nonCCATPermission = QCC_UtilityHelper.getListFromString(Label.QCC_Non_CCAT_Permission, ';');
        
        List<User> userList = [SELECT Id, Location__c, UserRole.Name,CCAT_User__c FROM User WHERE Id IN: userIdList];
        for(User usr : userList){
            if (usr.CCAT_User__c== true) {
                userCCATSet.add(usr.Id);
            }
        }
        return userCCATSet;
    }
    
    //@purpose: Collect all given User Id's if Operational group = Resolution consultant
    //@param: User Id's
     public static Set<Id> getListResolutionConsultant(List<Id> userIdList){
        Set<Id> ResolutionConsultantSet = new Set<Id>();
        List<User> userList = [SELECT Id, Operational_Group__c FROM User WHERE Id IN: userIdList];
        for(User usr : userList){
            if (usr.Operational_Group__c== 'Resolutions') {
                ResolutionConsultantSet.add(usr.Id);
            }
        }
        return ResolutionConsultantSet;
    }
    
    /*----------------------------------------------------------------------------------------------      
Method Name:        isCCATUser   
Description:        it will Check the User is a CCAT or NON CCAT Agent. Jira: CRM-4843
Parameter:          String userIdList
----------------------------------------------------------------------------------------------*/
    @InvocableMethod(label='Check User is CCAT or NON CCAT Agent' description='')
    public static List<Boolean> isCCATUser(List<Id> userIdList)
    {
        List<Boolean> response = new List<Boolean>();
        Boolean isCCATAgent = false;
        System.debug('in side iss CCat user method user id : ' + userIdList[0]);
        List<String> Location = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Location, ';');
        List<String> CCATRole = QCC_UtilityHelper.getListFromString(Label.QCC_CCAT_Roles, ';');
        List<String> nonCCATPermission = QCC_UtilityHelper.getListFromString(Label.QCC_Non_CCAT_Permission, ';');
        
        List<User> userList = [SELECT Id, Location__c, UserRole.Name,CCAT_User__c FROM User WHERE Id IN: userIdList];
        System.debug('userList========> ' + userList);
        for(User usr : userList)
        {
            if (usr.CCAT_User__c==true) {
                isCCATAgent = true;
                System.debug('isCCATAgent=======> ' + isCCATAgent);
                break;
            }
        }
        response.add(isCCATAgent);
        System.debug('response======> ' + response);
        return response;
    }
    
    //@purpose: To group Platform Event Loyalty Status by EventType
    //@param: List<QCC_Loyalty_Status__e>
    //@Return: Map<EventType,List<QCC_Loyalty_Status__e>>
    public static Map<String,List<QCC_Loyalty_Status__e>> groupLoyaltyEventType(List<QCC_Loyalty_Status__e> loyaltyRecordList){
        Map<String,List<QCC_Loyalty_Status__e>> loyaltyStatusPerEventMap = new Map<String,List<QCC_Loyalty_Status__e>>();
        for (QCC_Loyalty_Status__e loyaltyRecord : loyaltyRecordList) {
            if(loyaltyStatusPerEventMap.containsKey(loyaltyRecord.eventType__c)){
                loyaltyStatusPerEventMap.get(loyaltyRecord.eventType__c).add(loyaltyRecord);
            }else{
                loyaltyStatusPerEventMap.put(loyaltyRecord.eventType__c, new List<QCC_Loyalty_Status__e>{loyaltyRecord});
            }
        }
        return loyaltyStatusPerEventMap;
    }
    
    //@purpose: To group Platform Event Pre Departure by EventType
    //@param: List<Platform Event>
    //@Return: Map<EventType,List<sObject>>
    public static Map<String,List<sObject>> groupPlatformEventByEventType(List<sObject> sObjectList){
        Map<String,List<sObject>> sObjectEventMap = new Map<String,List<sObject>>();
        for (sObject sObjectRecord : sObjectList) {
            String eventType = String.valueOf(sObjectRecord.get('eventType__c'));
            if(sObjectEventMap.containsKey(eventType)){
                sObjectEventMap.get(eventType).add(sObjectRecord);
            }else{
                sObjectEventMap.put(eventType, new List<sObject>{sObjectRecord});
            }
        }
        return sObjectEventMap;
    }
    
    //@purpose: GRAPHITE-1020/GRAPHITE-123: Create a List of Contact with Fields populated from Loyalty Event Payload
    //@param: 	List<QCC_Loyalty_Status__e> - list of Loyalty Events for a single FF Number
    //			List<sObject> metaObjects - list of source-to-target mapping records
    //@Return: 	List<Contact> - although this is a list, it will only contain one contact record as the input is only for a single FF Number
    public static List<Contact> createContactFromLoyaltyEvents(List<QCC_Loyalty_Status__e> loyaltyRecordList, List<sObject> metaObjects){
        //Method is expected specifically for Loyalty Status platform event
        sObject combinedloyaltyEventRec;
        String objectName = 'QCC_Loyalty_Status__e';
        List<String> objectNames = new List<String>();
        objectNames.add(objectName);
        
        //Collect the source fieldnames
        Set<String> sourceFieldNames = new Set<String>();
        for (sObject mapObj : metaObjects) {
            String sourceFieldName = String.valueOf(mapObj.get('Source_Field__c'));
            if (sourceFieldName != NULL && sourceFieldName != '') {
                sourceFieldNames.add(sourceFieldName.toLowerCase());
            }
        }
        system.debug('>>>createContactFromLoyaltyEvents_v2 - sourceFieldNames: ' + sourceFieldNames);
        
        //Loop through the loyalty events that related to the single FF Number
        system.debug('>>>createContactFromLoyaltyEvents_v2 - loyaltyRecordList: ' + loyaltyRecordList);
        for (QCC_Loyalty_Status__e sourceloyaltyEventRec : loyaltyRecordList) {
            system.debug('>>>sourceloyaltyEventRec: ' + sourceloyaltyEventRec);
            //The combinedloyaltyEventRec is a single object that combines all loylaty events' attributes to define the contact record's fieldnames
            //Because the sourceloyaltyEventRec has already been committed to the database, code cannot set additional fields to it to combine in combinedloyaltyEventRec.
            //	- To resolve, the sourceloyaltyEventRec is cloned to instantiate it as a new event only serve as a attribute reference for defining the contact record.
            QCC_Loyalty_Status__e cloneLoyaltyEvent = sourceloyaltyEventRec.clone(false,true,true,false);
            combinedloyaltyEventRec = (combinedloyaltyEventRec == NULL) ? cloneLoyaltyEvent : combinedloyaltyEventRec;
            system.debug('>>>LoopEvents - combinedloyaltyEventRec: ' + combinedloyaltyEventRec);
            for (String fieldName : sourceFieldNames) {
                if (cloneLoyaltyEvent.get(fieldName) != NULL) {
                    system.debug('>>>Loop thru meta - fieldName: ' + fieldName);
                    //Fields from multiple loyalty events will be combined in a single event record to serve as a source for creating the contact record
                    combinedloyaltyEventRec.put(fieldName,cloneLoyaltyEvent.get(fieldName));
                }
            }
        }
        system.debug('>>>combinedloyaltyEventRec: ' + combinedloyaltyEventRec);
        
        //Call the transformSourceToTargetObjects to create the contact record
        system.debug('>>>createContactFromLoyaltyEvents_v2 - metaObjects');
        List<Contact> contactList = QCC_UtilityHelper.transformSourceToTargetObjects ('', new List<sObject>{combinedloyaltyEventRec}, metaObjects, 'Contact', null, null);
        
        return contactList;
    }
    
    //@Purpose: This method retrieve the QCC_SOQL_Setting__mdt record by its Developer Name
    //@input parameters:
    //	-developerName - The Developer Name of the QCC_SOQL_Setting__mdt record.
    //@return type: QCC_SOQL_Setting__mdt record that matched the developer name
    public static QCC_SOQL_Setting__mdt getSOQLSettingByDeveloperName(String developerName) {
        System.debug('QCC_UtilityHelper.getSOQLSettingByDeveloperName');
        QCC_SOQL_Setting__mdt soqlSetting;
        
        try {
            soqlSetting = [SELECT Id, DeveloperName, Query_String__c FROM QCC_SOQL_Setting__mdt WHERE DeveloperName =: developerName];
        } catch (Exception ex) {
            soqlSetting = null;
        }
        
        return soqlSetting;
    }
    
    //@Purpose: This method is used to send an mock email populating all the merge field in the email template.
    //@input parameters:
    //	1. targetRecordId - The record Id to be set as the TargetObjectId. (Required)
    //	2. emailTemplateId - The Id of the Email Template to be used in sending mock email. (Required)
    //	3. targetRecordId - The Id to be set as the WhatId. (Optional)
    //@return type: SingleEmailMessage that will be used to get the Subject and TextBody to send the SMS dynamically.
    public static Messaging.SingleEmailMessage generateSMSBodyFromEmailTemplate(Id targetRecordId, Id emailTemplateId, Id whatId) {
        System.debug('QCC_UtilityHelper.generateSMSBodyFromEmailTemplate');
        Messaging.SingleEmailMessage emailMessageToReturn;
        
        //Set the mock email to prevent error in sending.
        list<String> listToAddresses = new list<String>();
        listToAddresses.add('test@example.com');
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(listToAddresses);
        message.setTemplateId(emailTemplateId);
        message.setTargetObjectId(targetRecordId);
        if (whatId != null) {
            message.setWhatId(whatId);
        }
        message.setSaveAsActivity(true); 
        message.treattargetobjectasrecipient = false;
        messages.add(message);
        
        Savepoint sp = Database.setSavepoint();
        
        //Send and rollback so that messages should have a populated values for merge fields
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        System.debug('results: ' + results);
        Database.rollback(sp);
        
        for(Messaging.SingleEmailMessage currentMessage : messages) {
            emailMessageToReturn = currentMessage;//currentMessage.getPlainTextBody();
        }
        System.debug('emailMessageToReturn: ' + emailMessageToReturn);
        
        return emailMessageToReturn;
    }
    
    //@Purpose: This method is used to generate a task record
    //@input parameters:
    //	1. contactRecord - The contact records being created or updated.
    //	2. currentMessage - The SingleEmailMessage record that Subject and TextBody already populated to be used in generating the task record.
    //@return type: Task record to be inserted after the SMS has been sent successfully.
    public static Task generateTaskRecordFromEmailMessage(Contact contactRecord, Messaging.SingleEmailMessage currentMessage, Id whatId) {
        System.debug('QCC_UtilityHelper.generateTaskRecordFromEmailMessage');
        Task newTaskRecord = new Task();
        Date dateToday = System.today();
        
        newTaskRecord.ActivityDate = dateToday;
        newTaskRecord.Description = currentMessage.getPlainTextBody();
        newTaskRecord.Subject = currentMessage.getSubject();
        newTaskRecord.WhoId = contactRecord.Id;
        newTaskRecord.Status = 'Completed';
        newTaskRecord.Priority = 'Normal';
        newTaskRecord.WhatId = whatId;
        newTaskRecord.Task_type__c = 'Customer Interaction';
        
        return newTaskRecord;
    }
    
    /*--------------------------------------------------------------------------------------
Method Name:        modifyJSON
Description:        Modify JSON to be able to deserialize Salesforce reserved words
Parameter:          String from response
--------------------------------------------------------------------------------------*/    
    public static String modifyJSON(String data) {
        //Regex to match the start of the line and the key surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        //Replacement format of the new key surrounded by quotes and ending with a colon
        String replacementFormat = '"{0}" :';
        //A map of existing key to replacement key
        Map<String, String> replacements = new Map<String, String> {'type' => 'type_Z','number' => 'number_Z'};
            //Since our JSON can come in formatted however the endpoint wants, we need to format it to a standard we know and can handle
            String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
        //Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            //Generate our regex based on the key
            String regex = String.format(regexFormat, new List<String> {key});
            //Generate our replacement
            String replacement = String.format(replacementFormat, new List<String> {replacements.get(key)});
            //Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        system.debug('formattedJSON#########'+formattedJSON);
        return formattedJSON;
    }
    
    //@Purpose: GRAPHITE-1372 This method check if the case record is allowed to send the Case Stream callout
    //@input parameters:
    //  1. caseStreamSwitchPerTypeMap - The map holding all the Case Type and Status combination.
    //  2. caseRecord - The case record being checked if can send the Case Stream callout.
    //@return type: None
    public static Boolean checkIfCanSendCaseStreamCallout(Map<String, List<String>> caseStreamSwitchPerTypeMap, Case caseRecord) {
        System.debug('CaseTriggerHelper.checkIfCanSendCaseStreamCallout');
        Boolean canSend = false;
        
        //Check if the current case type is able to send the Case Stream callout.
        if(caseStreamSwitchPerTypeMap.containsKey(caseRecord.Type)) {
            List<String> statusList = caseStreamSwitchPerTypeMap.get(caseRecord.Type);
            System.debug('statusList: ' + statusList);
            //Compare if the list contains the current case status.
            if (statusList.contains(caseRecord.Status)) {
                canSend = true;
            }
        }
        
        return canSend;
    }
    
    //@Purpose: GRAPHITE-1372 This method retrieves all the combination of allowed Type and Status in sending the callout for the Case Stream
    //@input parameters:
    //	1. isBatchProcess - Used to determine whether the Case Stream logic has been triggered from a Batch class or not
    //@return type: Map containing all the combination of allowed Type and Status in sending the callout for the Case Stream
    public static Map<String, List<String>> getAllCaseStreamSwitch(Boolean isBatchProcess) {
        System.debug('CaseTriggerHelper.getAllCaseStreamSwitch');
        Map<String, List<String>> caseStreamSwitchPerTypeMap = new Map<String, List<String>>();
        
        //Get all the QCC_Case_Stream_Switch__mdt records.
        List<QCC_Case_Stream_Switch__mdt> caseStreamSwitchRecords = [SELECT Id, Case_Type__c, Case_Status__c FROM QCC_Case_Stream_Switch__mdt WHERE Is_Batch_Process__c =: isBatchProcess];
        
        //Put all the records to map then set the case type as key.
        for(QCC_Case_Stream_Switch__mdt caseStreamSwitchRecord : caseStreamSwitchRecords) {
            caseStreamSwitchPerTypeMap.put(caseStreamSwitchRecord.Case_Type__c, QCC_UtilityHelper.getListFromString(caseStreamSwitchRecord.Case_Status__c, ';'));
        }
        
        return caseStreamSwitchPerTypeMap;
    }
    
    //@Purpose: This method is used to get the Qantas Host Communication Template to be used based on the Qantas Host record.
    //@input parameters:
    //	1. qantasHostRecord - The record to be compared to each record of the metadata.
    //	2. qantasHostTemplates - The metadata records holding the criteria and the Email Template.
    //@return type: QCC_Qantas_Host_Communication_Template__mdt to be used to generate the Email or SMS content.
    public static QCC_Qantas_Host_Communication_Template__mdt getQantasHostCommunicationTemplate(QCC_First_Host__c qantasHostRecord, List<QCC_Qantas_Host_Communication_Template__mdt> qantasHostTemplates) {
        QCC_Qantas_Host_Communication_Template__mdt selectedCommunicationTemplate = null;
        
        for(QCC_Qantas_Host_Communication_Template__mdt qantasHostTemplate : qantasHostTemplates) {
            //Set this flag to false if any of the field did not meet the criteria
            //This flag determine if the template will be used in the current Qantas Host record
            Boolean canProceed = true;
            
            //Check for the Cabin
            //Note: We are getting the Label instead of the API of the value since we are maintaining the cabin in metadata as First, Business, etc.
            if (qantasHostTemplate.Cabin__c != null) {
                if (qantasHostTemplate.Cabin__c != 'ANY') {
                    List<String> cabins = QCC_UtilityHelper.getListFromString(qantasHostTemplate.Cabin__c, ';');
                    if (!cabins.contains(qantasHostRecord.QCC_Cabin__c)) {
                        canProceed = false;
                    }
                }
            }
            
            System.debug('Cabin canProceed: ' + canProceed);
            
            //Check for Top Platinum One
            if (qantasHostTemplate.Is_Top_Platinum_One__c != qantasHostRecord.QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c) {
                canProceed = false;
            }
            
            System.debug('Top Platinum One canProceed: ' + canProceed);
            
            //Check for Frequent Flyer Tier or Tier Effective Tier
            List<String> frequentFlyerTiers = new List<String>();
            List<String> tierEffectiveTiers = new List<String>();
            if (qantasHostTemplate.Frequent_Flyer_Tier__c != null && qantasHostTemplate.Frequent_Flyer_Tier__c != 'ANY') {
                frequentFlyerTiers = QCC_UtilityHelper.getListFromString(qantasHostTemplate.Frequent_Flyer_Tier__c, ';');
            }
            
            if (qantasHostTemplate.Tier_Effective_Tier__c != null && qantasHostTemplate.Tier_Effective_Tier__c != 'ANY') {
                tierEffectiveTiers = QCC_UtilityHelper.getListFromString(qantasHostTemplate.Tier_Effective_Tier__c, ';');
            }
            
            System.debug('>>>frequentFlyerTiers: ' + frequentFlyerTiers);
            System.debug('>>>tierEffectiveTiers: ' + tierEffectiveTiers);
            
            if (qantasHostTemplate.Frequent_Flyer_Tier__c != 'ANY' &&
                !frequentFlyerTiers.contains(qantasHostRecord.QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c) &&
                qantasHostTemplate.Tier_Effective_Tier__c != 'ANY' &&
                !tierEffectiveTiers.contains(qantasHostRecord.QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c))
            {
                canProceed = false;
            }
            
            System.debug('Tier canProceed: ' + canProceed);
            
            //Check for Departure Port
            if (qantasHostTemplate.Departure_Port__c != null && qantasHostTemplate.Departure_Port__c != 'ANY') {
                List<String> departurePorts = QCC_UtilityHelper.getListFromString(qantasHostTemplate.Departure_Port__c, ';');
                if (!departurePorts.contains(qantasHostRecord.QCC_Departure_Airport__c)) {
                    canProceed = false;
                }
            }
            
            System.debug('>>>Departure Ports canProceed: ' + canProceed);
            
            //Check for Excluded Flights
            if (qantasHostTemplate.Excluded_Flights__c != null) {
                List<String> excludedFlights = QCC_UtilityHelper.getListFromString(qantasHostTemplate.Excluded_Flights__c, ';');
                if (excludedFlights.contains(qantasHostRecord.QCC_Carrier_Code__c + qantasHostRecord.QCC_Flight_No__c)) {
                    canProceed = false;
                }
            }
            
            System.debug('>>>Excluded Flights canProceed: ' + canProceed);
            
            if (canProceed) {
                selectedCommunicationTemplate = qantasHostTemplate;
                break;
            }
        }
        
        return selectedCommunicationTemplate;
    }
    
    //@Purpose: This method is used to get the Spa Booking Communication Template to be used based on the Qantas Host record.
    //@input parameters:
    //	1. qantasHostRecord - The record to be compared to each record of the metadata.
    //	2. qantasSpaBookingTemplates - The metadata records holding the criteria and the Email/SMS Template.
    //@return type: String to be used to generate the Email or SMS content.
    public static String getSpaBookingCommsTemplate(QCC_First_Host__c qantasHostRecord, List<QCC_Spa_Booking_Comms__mdt> qantasSpaBookingTemplates) {
        String selectedCommunicationTemplate = null;
        
        for(QCC_Spa_Booking_Comms__mdt qantasSpaBookingTemplate : qantasSpaBookingTemplates) {
            System.debug('inside getSpaBookingCommsTemplate for loop: qantasSpaBookingTemplate ' + qantasSpaBookingTemplate);
            if(qantasSpaBookingTemplate.Spa_Booking_Status__c != null){
                if(qantasSpaBookingTemplate.Spa_Booking_Status__c == qantasHostRecord.QCC_Spa_Booking_Status__c && 
                   qantasSpaBookingTemplate.Preffered_Contact_Method__c == qantasHostRecord.QCC_Preferred_Contact_Channel__c)
                {
                    selectedCommunicationTemplate = qantasSpaBookingTemplate.Template_Name__c;
                    break;
                }
            }
            
        }
        
        return selectedCommunicationTemplate;
    }
    
    //@Purpose: This wrapper is used to holld all the records needed to generate the Email or SMS content for Qantas Host.
    public class QantasHostTemplateWrapper {
        public Contact contactRecord;
        public QCC_First_Host__c qantasHostRecord;
        public String emailTemplateAPIName;
    }
    
    //@Purpose: This wrapper is used to hold all the records needed during and after sending the SMS for Qantas Host.
    public class QantasHostSendSMSWrapper {
        public Task taskRecord;
        public QCC_First_Host__c qantasHostRecord;
        public SMSWrapper smsWrapper;
    }
    
    //@Purpose: This wrapper is used to generate the request body for the LivePerson Callout
    public class SMSWrapper {
        public String countryCode;
        public String mobileNumber;
        public String message;
        public String senderName;
    }
    
    //@Purpose: This method is used to send the Email for Qantas Host
    //@input parameters:
    //	1. qantasHostToSendEmailMap - The map holding the value of the contact record, qantas host record and the email template name to be used.
    //@return type: None
    public static Messaging.SendEmailResult[] sendQantasHostEmail(Map<Id, QantasHostTemplateWrapper> qantasHostToSendEmailMap) {
        System.debug('QCC_UtilityHelper.sendQantasHostEmail');
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        //Get all OrgWideEmailAddress
        //Map<String,String> orgWideEmailMap = new Map<String,String>();
        Map<String,Id> orgWideEmailMap = new Map<String,Id>();
        for(OrgWideEmailAddress orgWideEmail : [SELECT Id,DisplayName, Address FROM OrgWideEmailAddress]){
            //orgWideEmailMap.put(orgWideEmail.Address,orgWideEmail.DisplayName);
            orgWideEmailMap.put(orgWideEmail.Address,orgWideEmail.Id);
        }
        
        //List all email template names
        Set<String> emailTemplateNames = new Set<String>();
        for(Id qantasHostId : qantasHostToSendEmailMap.keySet()) {
            emailTemplateNames.add(qantasHostToSendEmailMap.get(qantasHostId).emailTemplateAPIName);
        }
        
        System.debug('emailTemplateNames: ' + emailTemplateNames);
        
        //Get all the email template that will be used
        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        for(EmailTemplate emailTemp : [SELECT Id,Developername,HtmlValue,Subject FROM EmailTemplate WHERE Developername IN: emailTemplateNames]){
            emailTemplateMap.put(emailTemp.Developername,emailTemp);
        }
        
        System.debug('emailTemplateMap: ' + emailTemplateMap);
        
        //Generate all email that will be sent to the customer
        for(Id qantasHostId : qantasHostToSendEmailMap.keySet()) {
            QantasHostTemplateWrapper myWrapper = qantasHostToSendEmailMap.get(qantasHostId);
            String emailTemplateAPIName = myWrapper.emailTemplateAPIName;
            if (emailTemplateMap.containsKey(emailTemplateAPIName)) {
                list<String> listToAddresses = new list<String>();
                if (myWrapper.contactRecord.QCC_Travel_Email__c != null) {
                    listToAddresses.add(myWrapper.contactRecord.QCC_Travel_Email__c);
                } else if (myWrapper.contactRecord.Email != null) {
                    listToAddresses.add(myWrapper.contactRecord.Email);
                }
                
                System.debug('listToAddresses: ' + listToAddresses);
                
                //Get the OrgWideEmailAddress
                String orgWideAddressName = myWrapper.contactRecord.SSU__c ? Label.QCC_Qantas_Host_Org_Wide_Address_SSU : Label.QCC_Qantas_Host_Org_Wide_Address;
                
                //Generate the email
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if (!listToAddresses.isEmpty()) {
                    if (orgWideEmailMap.containsKey(orgWideAddressName)) {
                        message.setOrgWideEmailAddressId(orgWideEmailMap.get(orgWideAddressName));
                        
                        // Replace setOrgWideEmailAddressId above with below code as a workaround on Orgwide email filtered profile
                        //message.setSenderDisplayName(orgWideEmailMap.get(orgWideAddressName));
                        //message.setReplyTo(orgWideAddressName);
                    }
                    
                    message.setToAddresses(listToAddresses);
                    message.setTemplateId(emailTemplateMap.get(emailTemplateAPIName).Id);
                    message.setTargetObjectId(myWrapper.contactRecord.Id);
                    message.setWhatId(myWrapper.qantasHostRecord.Id);
                    message.setSaveAsActivity(true);
                    message.treattargetobjectasrecipient = false;
                    messages.add(message);
                }
                
                System.debug('message: ' + message);
            }
        }
        
        System.debug('messages: ' + messages);
        
        Savepoint sp = Database.setSavepoint();
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        System.debug('results: ' + results);
        
        return results;
    }
    
    //@Purpose: This method is used to send the SMS for Qantas Host
    //@input parameters:
    //	1. qantasHostToSendSMSMap - The map holding the value of the contact record, qantas host record and the email template name to be used.
    //	2. moduleName - The module where this method is used:
    //					- Qantas Host Communication Matrix
    //					- Online Form Submission
    //					- Spa Booking Status
    //@return type: None
    public static void sendQantasHostSMS(Map<Id, QantasHostTemplateWrapper> qantasHostToSendSMSMap, String moduleName) {
        System.debug('QCC_UtilityHelper.sendQantasHostSMS: moduleName ' + moduleName);
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        //Get all OrgWideEmailAddress
        Map<String,Id> orgWideEmailMap = new Map<String,Id>();
        for(OrgWideEmailAddress orgWideEmail : [SELECT Id,DisplayName, Address FROM OrgWideEmailAddress]){
            orgWideEmailMap.put(orgWideEmail.Address,orgWideEmail.Id);
        }
        
        //List all email template names
        Set<String> emailTemplateNames = new Set<String>();
        for(Id qantasHostId : qantasHostToSendSMSMap.keySet()) {
            emailTemplateNames.add(qantasHostToSendSMSMap.get(qantasHostId).emailTemplateAPIName);
        }
        
        System.debug('emailTemplateNames: ' + emailTemplateNames);
        
        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        for(EmailTemplate emailTemp : [SELECT Id,Developername,HtmlValue,Subject FROM EmailTemplate WHERE Developername IN: emailTemplateNames]){
            emailTemplateMap.put(emailTemp.Developername,emailTemp);
        }
        
        System.debug('emailTemplateMap: ' + emailTemplateMap);
        
        //Generate the email so that we can get the merge fields
        for(Id qantasHostId : qantasHostToSendSMSMap.keySet()) {
            //Create a dummy email recipient
            list<String> listToAddresses = new list<String>();
            listToAddresses.add('test@example.com');
            System.debug('listToAddresses: ' + listToAddresses);
            
            QantasHostTemplateWrapper myWrapper = qantasHostToSendSMSMap.get(qantasHostId);
            String emailTemplateAPIName = myWrapper.emailTemplateAPIName;
            
            String orgWideAddressName = myWrapper.contactRecord.SSU__c ? Label.QCC_Qantas_Host_Org_Wide_Address_SSU : Label.QCC_Qantas_Host_Org_Wide_Address;
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if (orgWideEmailMap.containsKey(orgWideAddressName)) {
                message.setOrgWideEmailAddressId(orgWideEmailMap.get(orgWideAddressName));
            }
            
            message.setToAddresses(listToAddresses);
            message.setTemplateId(emailTemplateMap.get(emailTemplateAPIName).Id);
            message.setTargetObjectId(myWrapper.contactRecord.Id);
            message.setWhatId(myWrapper.qantasHostRecord.Id);
            message.setSaveAsActivity(true);
            message.treattargetobjectasrecipient = false;
            messages.add(message);
        }
        
        System.debug('messages: ' + messages);
        
        //Generate a map containing all the mock email message with Qantas Host Id as key
        Map<Id, Messaging.SingleEmailMessage> messageMap = new Map<Id, Messaging.SingleEmailMessage>();
        for(Messaging.SingleEmailMessage currentMessage : messages) {
            messageMap.put(currentMessage.getWhatId(), currentMessage);
        }
        
        System.debug('messageMap: ' + messageMap);
        
        Savepoint sp = Database.setSavepoint();
        
        //Send and rollback so that messages should have a populated values for merge fields
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        System.debug('results: ' + results);
        Database.rollback(sp);
        
        System.debug('messages: ' + messages);
        
        List<QantasHostSendSMSWrapper> sendSMSWrapperList = new List<QantasHostSendSMSWrapper>();
        for(Id qantasHostId : qantasHostToSendSMSMap.keySet()) {
            QantasHostTemplateWrapper myWrapper = qantasHostToSendSMSMap.get(qantasHostId);
            System.debug('myWrapper>>>> ' + myWrapper);
            
            //Generate the SMS wrapper
            SMSWrapper smsWrapper = new SMSWrapper();
            if (myWrapper.contactRecord.QCC_TECH_TravelSMSPhoneCountryCode__c != null && myWrapper.contactRecord.QCC_TECH_TravelSMSPhoneNumber__c != null) {
                smsWrapper.countryCode = myWrapper.contactRecord.QCC_TECH_TravelSMSPhoneCountryCode__c.replaceAll('[^a-zA-Z0-9\\s]', '');
                smsWrapper.mobileNumber = myWrapper.contactRecord.QCC_TECH_TravelSMSPhoneNumber__c;
            } else if (myWrapper.contactRecord.QCC_TECH_MobilePhoneCountryCode__c != null && myWrapper.contactRecord.QCC_TECH_MobilePhoneNumber__c != null) {
                smsWrapper.countryCode = myWrapper.contactRecord.QCC_TECH_MobilePhoneCountryCode__c.replaceAll('[^a-zA-Z0-9\\s]', '');
                smsWrapper.mobileNumber = myWrapper.contactRecord.QCC_TECH_MobilePhoneNumber__c;
            }
            
            //Get the Email Message by contact Id.
            if (messageMap.containsKey(myWrapper.qantasHostRecord.Id)) {
                Messaging.SingleEmailMessage currentMessage = messageMap.get(myWrapper.qantasHostRecord.Id);
                System.debug('currentMessage: ' + currentMessage);
                
                smsWrapper.message = currentMessage.getPlainTextBody();
                //smsWrapper.senderName = 'Qantas VIP';
                smsWrapper.senderName = 'Qantas';//CRM-8161
                
                QantasHostSendSMSWrapper sendSMSWrapper = new QantasHostSendSMSWrapper();
                sendSMSWrapper.qantasHostRecord = myWrapper.qantasHostRecord;
                sendSMSWrapper.taskRecord = QCC_UtilityHelper.generateTaskRecordFromEmailMessage(myWrapper.contactRecord, currentMessage, myWrapper.qantasHostRecord.Id);
                sendSMSWrapper.smsWrapper = smsWrapper;
                
                if (sendSMSWrapper.smsWrapper.countryCode != null && sendSMSWrapper.smsWrapper.mobileNumber != null) {
                    sendSMSWrapperList.add(sendSMSWrapper);
                }
            }
        }
        
        System.debug('sendSMSWrapperList: ' + sendSMSWrapperList);
        
        if (!sendSMSWrapperList.isEmpty()) {
            String jsonData = JSON.serialize(sendSMSWrapperList);
            
            if (moduleName == 'Qantas Host Communication Matrix') {
                QCC_QantasHostSendSMSQueueable queueableJob = new QCC_QantasHostSendSMSQueueable();
                queueableJob.sendSMSWrapperString = jsonData;
                
                System.enqueueJob(queueableJob);
            } else if (moduleName == 'Online Form Submission') {
                QCC_QantasHostOnlineFormSendSMSQueueable queueableJob = new QCC_QantasHostOnlineFormSendSMSQueueable();
                queueableJob.sendSMSWrapperString = jsonData;
                
                System.enqueueJob(queueableJob);
            } else if (moduleName == 'Spa Booking Status') {
                System.debug('inside spa booking status module');
                QCC_QantasHostSpaBookingQueueable queueableJob = new QCC_QantasHostSpaBookingQueueable();
                queueableJob.sendSMSWrapperString = jsonData;
                
                System.enqueueJob(queueableJob);
            }
        }
    }
    
    //@Purpose: This method is used to retrieve all the source to target record by a list of module names
    //@input parameters:
    //	1. moduleNames - The list of module name that the source to target record belongs.
    //@return type: Map of source to target record group by its module name
    public static Map<String,List<sObject>> getSourceToTargetRecordsByModuleNames(List<String> moduleNames) {
        System.debug('QCC_UtilityHelper.getSourceToTargetRecordsByModuleNames');
        
        String moduleNameList = '';
        for(String moduleName : moduleNames) {
            moduleNameList += moduleNameList == '' ? '(\'' + moduleName + '\'' : ', \'' + moduleName + '\'';
        }
        moduleNameList += ')';
        System.debug('moduleNameList: ' + moduleNameList);
        
        String conditionClause = ' WHERE Module_Name__c IN ' + moduleNameList;
        
        Map<String,List<sObject>> metaObjects = QCC_UtilityHelper.getObjMap('QCC_Source_to_Target_Object_Mapping__mdt', 'Module_Name__c', conditionClause);
        system.debug('metaObjects: ' + metaObjects);
        
        return metaObjects;
    }
    
    //@Purpose: This method is used to retrieve ALL the Platform Event Switch and return a Map using Module name as a Key
    //@input parameters:
    //@return type: Map of Platform Event Switch
    public static Map<String,QCC_Platform_Event_Switch__c> getPlatformEventSwitch() {
        Map<String,QCC_Platform_Event_Switch__c> switchSettings = new Map<String,QCC_Platform_Event_Switch__c>();
        for(QCC_Platform_Event_Switch__c switchRecord :QCC_Platform_Event_Switch__c.getAll().values()){
            switchSettings.put(switchRecord.Module_Name__c,switchRecord);
        }
        return switchSettings;
    }   
    
    /*--------------------------------------------------------------------------------------
Method Name:        assignVIPCaseUsingAssignmentRule
Description:        GRAPHITE-927: Method to assign a case via the active Assignment Rule. This is only applicable for VIP scenario.
This will be on "after" events:
- new cases inserted
- cases manually updated by user and where the "Assign Using Active Assignment Rule" flag is checked (applicable for post travel)
Parameter:          List<Case> lstCase
--------------------------------------------------------------------------------------*/
    public static void assignVIPCaseUsingAssignmentRule (List<Case> caseList) {
        //Check if records have the assignment flag
        System.debug('>>>assignVIPCaseUsingAssignmentRule');
        List<Case> casesToProcess = new List<Case>();
        for (Case caseRec : caseList) {
            System.debug('>>>caseRec.Comments__c: '+caseRec.Comments__c);
            if (caseRec.Comments__c != NULL){
                if (caseRec.Comments__c.contains(Label.QCC_Case_Assignment_Flag)) {
                    casesToProcess.add(caseRec);
                }
            }
        }
        
        if (!casesToProcess.isEmpty()) {
            //Assignment Rule
            String ruleName = System.Label.QCC_AssignmentRuleName; 
            AssignmentRule rule = [SELECT Id FROM AssignmentRule WHERE Name = :ruleName LIMIT 1];
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.assignmentRuleHeader.assignmentRuleId= rule.id;
            List<Case> casesForAssignment = new List<Case>();
            System.debug('>>>casesToProcess: '+casesToProcess);
            for (Case caseRec : [SELECT Id, Comments__c FROM Case WHERE Id IN: casesToProcess]) {
                if (caseRec.Comments__c != NULL) {
                    if (caseRec.Comments__c.contains(Label.QCC_Case_Assignment_Flag)) {
                        String commentWithOutFlag = caseRec.Comments__c.remove(Label.QCC_Case_Assignment_Flag);
                        caseRec.Comments__c = commentWithOutFlag;
                        caseRec.setOptions(dmlOption);
                        system.debug('>>>assignVIPCaseUsingAssignmentRule - caseRec.Comments__c: ' + caseRec.Comments__c);
                        casesForAssignment.add(caseRec);
                    }
                }
            }
            
            if (!casesForAssignment.isEmpty()) {
                update casesForAssignment;
            }
        }
    }
    
    //@Purpose: This method check whether the specific switch is active.
    //@input parameters:
    //	1. switchName - The name of the Trigger_Status__c record to check if active.
    //@return type: Boolean to determine if switch is active
    public static Boolean checkIfTriggerStatusIsActive(String switchName) {
        Map<String, Trigger_Status__c> triggerStatusSwitch = Trigger_Status__c.getAll();
        Boolean isActive = false;
        if (triggerStatusSwitch.containsKey(switchName)) {
            isActive = triggerStatusSwitch.get(switchName).Active__c;
        }
        
        return isActive;
    }
    
    //@Purpose: This method will replace leading zero from any string
    //@input parameters:
    //	1. stringWithLeadingZero - The string with leading zero
    //@return type: String with replaced leading zeros
    public static String removeLeadingZero(String stringWithLeadingZero) {
        return stringWithLeadingZero.replaceFirst('^0+','');
    }
    
    //@Purpose: This method concatenates all the field value in the list
    //@input parameters:
    //	1. fieldNameList - The list contains all the API Name of the field we want to concatenate.
    //	2. record - The sObject record the field values will come from.
    //@return type: Concatenated string values
    public static String generateConcatenatedFieldValues(List<String> fieldNameList, SObject record) {
        System.debug('QCC_UtilityHelper.generateConcatinatedFieldValues');
        String fieldValue = '';
        for(String fieldName : fieldNameList) {
            if (record.get(fieldName) != null) {
                fieldValue += record.get(fieldName);
            }
        }
        
        return fieldValue;
    }
    
    //@Purpose: This method check whether any field on the list changes value.
    //@input parameters:
    //	1. fieldNameList - The list contains all the API Name of the field we want to check.
    //	2. newRecord - The sObject record the field values will come from.
    //	3. oldRecord - The old record we use to compare the newRecord
    //@return type: Boolean that will determine whether there are change on the list of field names
    public static Boolean checkIfFieldValueChanged(List<String> fieldNameList, sObject newRecord, sObject oldRecord) {
        System.debug('QCC_UtilityHelper.checkIfFieldValueChanged');
        Boolean isChanged = false;
        for(String fieldName : fieldNameList) {
            if (newRecord.get(fieldName) != null || oldRecord.get(fieldName) != null) {
                if (newRecord.get(fieldName) != oldRecord.get(fieldName)) {
                    isChanged = true;
                }
            }
        }
        
        return isChanged;
    }
    //@Purpose: This Method is used For Changing the Phone Number Into E.164 Format
    //@input parameters:
    //
    //@return type: 
    Public Static String PhoneNumbertoE164(String CountryCode, String AreaCode, String PhoneNumber)
    {
        if(AreaCode != null && !String.isEmpty(AreaCode))
        {
            String Acode = AreaCode.replaceAll('[^0-9]','');
            AreaCode = (Acode.startsWith('0') ? Acode.replaceFirst( '0', '') : Acode);
            System.debug('Acode### ' +AreaCode);
        }
        if(CountryCode != null && !String.isEmpty(CountryCode))
        {
            String Ccode = CountryCode.replaceAll('[^0-9]','');
            CountryCode = (Ccode.startsWith('0') ? Ccode.replaceFirst( '0', '') : Ccode);
            System.debug('Ccode### ' +CountryCode);
        }
        if(PhoneNumber != null && !String.isEmpty(PhoneNumber))
        {
            String Phno = PhoneNumber.replaceAll('[^0-9]','');
            PhoneNumber = (Phno.startsWith('0') ? Phno.replaceFirst( '0', '') : Phno);
            System.debug('Phno### ' +PhoneNumber);
        }
		        
        String fphone = (CountryCode != null ? CountryCode : '') + (AreaCode != null ? AreaCode : '') + (PhoneNumber != null ? PhoneNumber : '');
        System.debug('fphonefinal### ' + fPhone);
        fPhone = !String.isEmpty(fphone) ? '+' + fPhone :'';
        System.debug('fPhone3 ' + fPhone);  
        return fPhone;
    }
    /* @Purpose:Method Created to get the instance url for Hyperforce Migration CRM -
       @input parameters:
       @return type: string */ 
       @AuraEnabled
    public static string getDomainURL(){
        string instanceUrl = URL.getOrgDomainUrl().toExternalForm();
        return instanceUrl;
    }

    /* @Purpose:Method Created to get the document url for Hyperforce Migration CRM -
       @input parameters:
       @return type:                 */

    public static string getDyanamicUrl(){
        Document[] doc = [select id,LastModifiedDate from Document where DeveloperName='Freight_Logo'];
        if(doc.isEmpty()) {
            return null;
        } else {
            return URL.getOrgDomainUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+doc[0].Id+
                '&oid='+UserInfo.getOrganizationId()+'&lastMod='+doc[0].LastModifiedDate.getTime();
        }
    }
}