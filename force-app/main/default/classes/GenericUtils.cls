/*----------------------------------------------------------------------- 
Author       :  Praveen S
Company      :  Capgemini   
Description  :  This is a Utility class used to manipulate generic functions
Test Class   :  ObjectUtilsTest
Created Date :  01/12/2016
History
<Date>      <Authors Name>     <Brief Description of Change>
-----------------------------------------------------------------------*/
public class GenericUtils {
    
    public virtual class RecordTypeException extends Exception {}
    // To avoid Multiple Object instance
    private static string sObjectName ='';
    private static Map<String, Schema.RecordTypeInfo> recordTypeInfo;
    private static Map<Integer, String> monthsMap = new Map<Integer, String>{
        1  => 'Jan',
            2  => 'Feb',
            3  => 'March',
            4  => 'April',
            5  => 'May',
            6  => 'June',
            7  => 'July',
            8  => 'Aug',
            9  => 'Sept',
            10 => 'Oct',
            11 => 'Nov',
            12 => 'Dec'
            };
                
    /*------------------------------------------------------------
    Method Name:     getObjectRecordTypeId
    Description:   Method to extract the ID of the given record type
    Inputs:        Object, Record Type Name
    ------------------------------------------------------------*/
    public static Id getObjectRecordTypeId(String objectName, String recordTypeName){
        system.debug('objectName======='+objectName+'recordTypeName===='+recordTypeName);
        if(recordTypeInfo == Null )//Added to avoid exception
            recordTypeInfo  = new Map<String, Schema.RecordTypeInfo>();
        //if(sObjectName == '' || sObjectName != objectName ){
        if (sObjectName.equals('') || sObjectName != objectName) {
            sObjectName = objectName;
            recordTypeInfo = getObjectRecordTypeId(objectName);
            if(!recordTypeInfo.containsKey(recordTypeName)){
                throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');
            }
            //Retrieve the record type id by name
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        }
        else{
            if(!recordTypeInfo.containsKey(recordTypeName))
                throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');
            //Retrieve the record type id by name
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        }
    }
    
    /*------------------------------------------------------------
    Method Name:     getObjectRecordTypeId
    Description:   Method to extract the record type information
    Inputs:        Object name
    ------------------------------------------------------------*/
    private static map<String, Schema.RecordTypeInfo> getObjectRecordTypeId(String objectName) {
        // Convert to schema.sObjectType
        //Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
        Schema.SObjectType convertType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = convertType.getDescribe().getRecordTypeInfosByName();
        return recordTypeInfos;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        qccCaseRecordTypeIds
    Description:        Fetch QCC Case RecordTypes
    Parameter:          
    --------------------------------------------------------------------------------------*/  
    private static Set<Id> qccCaseRecordTypeIds(){
        Set<Id> setQCCRectype = new Set<Id>();
        Id recTypeQCCCompliment = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType'));
        setQCCRectype.add(recTypeQCCCompliment);
        Id recTypeCCCBaggage = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        setQCCRectype.add(recTypeCCCBaggage);
        Id recTypeCCCComplaint = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType'));
        setQCCRectype.add(recTypeCCCComplaint);
        Id recTypeCCCInsurance = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'));
        setQCCRectype.add(recTypeCCCInsurance);
        Id recTypeCCCMedical = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
        setQCCRectype.add(recTypeCCCMedical);
        Id recTypeCCCQuery = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType'));
        setQCCRectype.add(recTypeCCCQuery);
        Id recTypeCCCFAR = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType'));
        setQCCRectype.add(recTypeCCCFAR);
        Id recTypeCCCEvent = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
        setQCCRectype.add(recTypeCCCEvent);
        Id recTypeCCOTSR = getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC On The Spot Recovery RecType'));
        setQCCRectype.add(recTypeCCOTSR);
        return setQCCRectype;
    }
    /*------------------------------------------------------------
    Method Name:   getCaseContactGroup
    Description:   return the string to represent the group
    Inputs:        Case's Record type Id
    ------------------------------------------------------------*/
   public static String getCaseContactGroup(String caseRecordType) {
        String groupName = '';
        Set<Id> allQccCaseRecordTypes =  qccCaseRecordTypeIds();
        // Convert to schema.sObjectType
        if(allQccCaseRecordTypes.contains(caseRecordType)){
           groupName = CustomSettingsUtilities.getConfigDataMap('Group Contact Name'); 
        }
        return groupName;
    }
    /*------------------------------------------------------------
    Method Name:   checkABN
    Description:   Method to check if ABN is valid
    Inputs:        Object name
    ------------------------------------------------------------*/
    public static Boolean checkABN(String abn){
        abn = abn.trim();
        if(abn.length() != 11 || !abn.isNumeric()){
            return false;
        }
        return true;
    }
    /*------------------------------------------------------------
    Method Name:   checkBlankorNull
    Description:   Method to check if attribute is Blank/Null
    Inputs:        Object name
    ------------------------------------------------------------*/
    public static Boolean checkBlankorNull(String str){
        if(String.isBlank(str) || str == null){
            return false;
        }
        return true;
    } 
    /*------------------------------------------------------------
    Method Name:     checkisNumeric
    Description:   Method to check if the attribute is Numeric
    Inputs:        Object name
    ------------------------------------------------------------*/
    public static Boolean checkisNumeric(String str){
        if(!str.isNumeric()){
            return false;
        }
        return true;
    }
    
    /*------------------------------------------------------------
    Method Name:     parseStringToGMT
    Description:   parse String DD-MM-YYYY HH:mm:ss or DD/MM/YYYY HH:mm:ss to DateTime in GMT
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static DateTime parseStringToGMT(String dateTimeStr){
        
        try{
            dateTimeStr = dateTimeStr.replaceAll('-', '/');
            Integer day = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[0]);
            Integer month = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[1]);
            Integer year = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[2]);
            
            Integer hour = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[2]);
            
            return DateTime.newInstanceGmt(year, month, day, hour, minute, second);
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        
        return null;
    }
    
    /*------------------------------------------------------------
    Method Name:     parseStringToGMT
    Description:   parse String 2018-05-22T22:15:00+08:00 to DateTime in GMT
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static DateTime parseStringToGMT2(String dateTimeStr){
        
        try{
            dateTimeStr = dateTimeStr.replaceAll('-', '/');
            String timezone = dateTimeStr.right(6);
            system.debug('timezone$$$'+timezone);
            integer multFactor = 1;
            if(String.isNotBlank(timezone) && timezone.startsWith('+')){
                multFactor = -1;
            }
            integer hourDiff = multFactor*integer.ValueOf(timezone.split(':')[0]);
            integer minuteDiff = multFactor*integer.ValueOf(timezone.split(':')[1]);
             system.debug('hourDiff$$$'+hourDiff);
             system.debug('minuteDiff$$$'+minuteDiff);
            
            dateTimeStr = dateTimeStr.removeEnd(timezone);
            
            Integer year = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[0]);
            Integer month = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[1]);
            Integer day = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[2]);
            
            Integer hour = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[2]);
            
            DateTime output = DateTime.newInstanceGmt(year, month, day, hour, minute, second);
            output = output.addHours(hourDiff);
            output = output.addMinutes(minuteDiff);
            return output;
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        
        return null;
    }
    
    /*------------------------------------------------------------
    Method Name:     parseStringToGMT
    Description:   parse String DD-MM-YYYY HH:mm:ss or DD/MM/YYYY HH:mm:ss to DateTime in Local Time
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static DateTime parseStringToLocalTime(String dateTimeStr){
        
        try{
            dateTimeStr = dateTimeStr.replaceAll('-', '/');
            Integer day = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[0]);
            Integer month = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[1]);
            Integer year = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[2]);
            
            Integer hour = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[2]);
            
            return DateTime.newInstanceGmt(year, month, day, hour, minute, second);
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        
        return null;
    }
    
    /*------------------------------------------------------------
    Method Name:   parseDatetoString
    Description:   parse String DD-MM-YYYY HH:mm:ss or DD/MM/YYYY HH:mm:ss to DateTime in Local Time
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static String parseDatetoString(Date dateVal){
        String dateStr;
        String year = String.valueOf(dateVal.year());
        String month= String.valueOf(dateVal.month());
        month = month.length()== 1?'0'+month:month;
        String day = String.valueOf(dateVal.day());
        day = day.length()==1?'0'+day:day;
        dateStr = year+'-'+month+'-'+day;
        return dateStr;
    }

    /*------------------------------------------------------------
    Method Name:    getFullDate
    Description:   return full date CRM-8293: 23 July PROD: Date fields on Case have incorrect format of values
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static String getFullDate(String dateTimeStr) {
        return getFullDate(dateTimeStr, false);
    }
    
    /*------------------------------------------------------------
    Method Name:   getFullDate
    Description:   return full date 
    Inputs:        String dateTimeStr, Boolean isFromCase
    ------------------------------------------------------------*/
    public static String getFullDate(String dateTimeStr, Boolean isFromCase){
        
        try{
            dateTimeStr = dateTimeStr.replaceAll('-', '/');
            Integer day = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[0]);
            Integer month = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[1]);
            Integer year = integer.valueOf((dateTimeStr.split(' ')[0]).split('/')[2]);
            
            Integer hour = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split(' ')[1]).split(':')[2]);
            

            return day + ' ' + ((isFromCase && convertMonthTextToNumber(month).equals('Sept')) ? 'Sep' : convertMonthTextToNumber(month))  + ' ' + year;
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        
        return null;
    }
    
    private static String convertMonthTextToNumber(Integer month)
    {
        return monthsMap.get( month );
    }
    
    /*-----------------------------------------------------------------------------*
    *   Method Name:   dateTimeDiffInMinutes                                       *
    *   Description:   Returns difference between two datetime fields in Minutes   *
    *   Inputs:        Datetime, Datetime                                          *
    *-----------------------------------------------------------------------------*/
    public static Long dateTimeDiffInMinutes(Datetime dt1, Datetime dt2) {
        return (dt2.getTime() - dt1.getTime())/1000/60;
    }

    /*------------------------------------------------------------
    Method Name:   parseStringToLocalDateTime
    Description:   parse String 2018-05-22T22:15:00.000+08:00 or 2018-05-22T22:15:00+08:00 to DateTime in Local -- 2018-05-22 22:15:00
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static DateTime parseStringToLocalDateTime(String dateTimeStr){
        
        try{
            dateTimeStr = dateTimeStr.replaceAll('-', '/');
            String timezone = dateTimeStr.length() == 29 ? dateTimeStr.right(10) : dateTimeStr.right(6);
            dateTimeStr = dateTimeStr.removeEnd(timezone);
            
            Integer year = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[0]);
            Integer month = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[1]);
            Integer day = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[2]);
            
            Integer hour = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[2]);
            
            DateTime output = DateTime.newInstanceGmt(year, month, day, hour, minute, second);
            return output;
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        
        return null;
    }

    /*------------------------------------------------------------
    Method Name:   parseStringToUTC
    Description:   parse String 2018-05-22T10:15:00.000+08:00 or 2018-05-22T10:15:00+08:00 to DateTime in UTC -- 2018-05-22 18:15:00
    Inputs:        String dateTimeStr
    ------------------------------------------------------------*/
    public static DateTime parseStringToUTC(String dateTimeStr){
        System.debug('dateTimeStr length = '+dateTimeStr.length());
        if(dateTimeStr.length() != 29 && dateTimeStr.length() != 25) {
            return null;
        }
        String timezone = dateTimeStr.right(6);
        
        system.debug('timezone$$$'+timezone);
        integer multFactor = 1;
        if(String.isNotBlank(timezone) && timezone.startsWith('+')){
            multFactor = -1;
        }
        integer hourDiff = -1 * integer.ValueOf(timezone.split(':')[0]);
        integer minuteDiff = multFactor*integer.ValueOf(timezone.split(':')[1]);
        system.debug('hourDiff$$$'+hourDiff);
        system.debug('minuteDiff$$$'+minuteDiff);
            
        dateTimeStr = dateTimeStr.removeEnd(timezone);
        dateTimeStr = dateTimeStr.replaceAll('-', '/');
        Integer year = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[0]);
        Integer month = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[1]);
        Integer day = integer.valueOf((dateTimeStr.split('T')[0]).split('/')[2]);
        
        Integer hour = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[0]);
        Integer minute = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[1]);
        Integer second = dateTimeStr.length() == 23 ? integer.valueOf(((dateTimeStr.split('T')[1]).split(':')[2]).split('\\.')[0]) : integer.valueOf((dateTimeStr.split('T')[1]).split(':')[2]);
        
        DateTime output = DateTime.newInstanceGmt(year, month, day, hour, minute, second);
        output = output.addHours(hourDiff);
        output = output.addMinutes(minuteDiff);
        System.debug('parseStringToUTC = '+output);
        return output;
    }
}