/*****************************************************************************************************
ClassName   : AccountEligibilityLogHandler
CreatedBy   : Gourav Bhardwaj
Jira        : 1787
Description : Add functionality to capture Aquire Override Flag Start/End Dates and their change history.
TestClass   : TestAccountEligibilityLogHandler

Change History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Gourav Bhardwaj         1821        Add functionality to capture Corporate Deal Flag            T01
Start/End Dates change history in Eligibility Log
Gourav Bhardwaj         1898        Create AccountEligibilityLog record when Account            T02
record is created                           
Praveen Sampath                     Added createAccountEligiblityLogs Method to create AccountEligiblityLogs
All Old methods are removed, as the logic is changed.
Added createAccountEligiblityLogrecord generic Method to create AccountEligiblityLogs
******************************************************************************************************/
public class AccountEligibilityLogHandler {
    public static List<Account_Eligibility_Log__c> insertUpdateList = new List<Account_Eligibility_Log__c>();
    
    //Set of records which are inserted, which be used for intraday records update. 
    public static Set<Id> insertUpdateAcountSet = new Set<Id>();
    public static List<Account> accountUpdateList = new List<Account>();
    
    //Map of AccountId:FieldName to field which needs to be updated.
    private static Map<String,String> accountToField = new Map<String,String>();
    private static String aquireOverrideLabel = Schema.Account.fields.Aquire_Override__c.getDescribe().getLabel();  
    private static String travelAgentLabel = Schema.Account.fields.Agency__c.getDescribe().getLabel();
    private static String accountAirlineEligibilityLabel= Schema.Account.fields.Aquire_Eligibility_f__c.getDescribe().getLabel();
    private static String accountPrimaryNotEligibleReasonLabel = Schema.Account.fields.Primary_Reason_Not_Eligible__c.getDescribe().getLabel();    
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createAccountEligiblityLogs
    Description:        Method to Create Eligiblity Log Record
                                  Update End Date
                                  Delete logs if have same Start Date
    Parameter:          Account New Map & Old Map 
    --------------------------------------------------------------------------------------*/    
    public static void createAccountEligiblityLogs(Map<Id,Account> mapNewAcc, Map<Id, Account> mapOldAcc){
        
        set<Account_Eligibility_Log__c> setUpsertAccLog = new Set<Account_Eligibility_Log__c>();
        set<Account_Eligibility_Log__c> setDelAccLog = new Set<Account_Eligibility_Log__c>();
        List<Account_Eligibility_Log__c> lstUpsertAccLog = new List<Account_Eligibility_Log__c>();
        List<Account_Eligibility_Log__c> lstDelAccLog = new List<Account_Eligibility_Log__c>();
        Map<Id,Map<String, Account_Eligibility_Log__c>> mapAccIdAccEligiblity = new Map<Id,Map<String, Account_Eligibility_Log__c>>();
        
        //get All Record and hols in map for tracking 
        Map<String,Account_Logs_Tracker__c> mapAccLogTracker = new Map<String, Account_Logs_Tracker__c>();
        for(Account_Logs_Tracker__c accTrack: Account_Logs_Tracker__c.getall().values() )
        {
            if( accTrack.Object__c == 'Account' && accTrack.Active__c == true )
                mapAccLogTracker.put(accTrack.Field_Label__c+'-'+accTrack.Value__c, accTrack);
        }
        
        //get latest field set of exisitng log records 
        Date dEndDate = date.newinstance(3999, 12, 31);
        for( Account_Eligibility_Log__c accEligibility: [Select Id, FieldName__c, EndDate__c, Account__c, 
                                                         StartDate__c from  Account_Eligibility_Log__c where 
                                                         EndDate__c =: dEndDate AND Account__c IN: mapNewAcc.keySet() ] )
        {
            Map<String, Account_Eligibility_Log__c> mapAccEligiblity = new Map<String, Account_Eligibility_Log__c>();
            if(mapAccIdAccEligiblity.containsKey(accEligibility.Account__c)){
                mapAccEligiblity = mapAccIdAccEligiblity.get(accEligibility.Account__c);
            }
            mapAccEligiblity.put(accEligibility.FieldName__c, accEligibility);
            mapAccIdAccEligiblity.put(accEligibility.Account__c, mapAccEligiblity);
        }
        
        for(Account newAcc: mapNewAcc.values()){
            Account oldAcc = mapOldAcc != Null?mapOldAcc.get(newAcc.Id):Null;
            Map<String, Account_Eligibility_Log__c> mapAccEligiblity = New Map<String, Account_Eligibility_Log__c>();
            if(mapAccIdAccEligiblity != Null && mapAccIdAccEligiblity.containsKey(newAcc.Id))
                mapAccEligiblity = mapAccIdAccEligiblity.get(newAcc.Id); 
            //Check all field Vlaue changed and if it matches with the Account Logs Tracker List
            List<Schema.FieldSetMember> lstAcctrackingFls = SObjectType.Account.FieldSets.Log_Tracking_Fields.getFields();
            for( Schema.FieldSetMember field: lstAcctrackingFls ){
                if(oldAcc == Null || newAcc.get(field.getFieldPath()) != oldAcc.get(field.getFieldPath())){
                    
                    String tempKey = field.getLabel()+'-'+String.valueOf(newAcc.get(field.getFieldPath()));
                    //Check if the value modified is present in Account Log tracker
                    //Only then new record will be created 
                    if(mapAccLogTracker.containsKey(tempKey) && newAcc.Aquire_Eligibility_f__c == 'N')
                    {
                        //Create record
                        setUpsertAccLog.add(createAccountEligiblityLogrecord(newAcc, field));
                        String gstLabel = 'GST Registered-'+String.valueOf(newAcc.GST_Registered__c);
                        String validEntitylabel = 'Valid Entity Type-' +String.valueOf(newAcc.Valid_Entity_Type__c);
                        
                        system.debug('field.getLabel()#######'+field.getLabel());
                        system.debug('newAcc.Valid_Entity_Type__c#####'+newAcc.Valid_Entity_Type__c);
                        system.debug('oldAcc.Valid_Entity_Type__c#####'+oldAcc.Valid_Entity_Type__c);
                        system.debug('mapAccLogTracker##########'+mapAccLogTracker);
                        system.debug('validEntitylabel#########'+validEntitylabel);
                        system.debug('gstLabel##########'+gstLabel);
                        
                        //Only for Scenario 8 -- when Valid Entity type or GSt Registered is changed but this intern changes Airline Eligiblity
                        if(field.getLabel() == 'GST Registered' && newAcc.Valid_Entity_Type__c == oldAcc.Valid_Entity_Type__c && 
                           mapAccLogTracker.containsKey(validEntitylabel) && !mapAccEligiblity.containsKey('Valid Entity Type')){
                               setUpsertAccLog.add(createAccountEligiblityLogrecords(newAcc, 'Valid Entity Type'));
                               
                           }
                        //Only for Scenario 8 -- when Valid Entity type is changed but this intern changes Airline Eligiblity
                        if(field.getLabel() == 'Valid Entity Type' && newAcc.GST_Registered__c == oldAcc.GST_Registered__c && 
                           mapAccLogTracker.containsKey(gstLabel) && !mapAccEligiblity.containsKey('GST Registered')){
                               setUpsertAccLog.add(createAccountEligiblityLogrecords(newAcc, 'GST Registered'));
                           }
                    }
                    
                    //update the end date if present in Account_Eligibility_Log__c if the field is changed
                    //Delete if created in the same date
                    if(mapAccEligiblity.containsKey(field.getLabel())){
                        Account_Eligibility_Log__c objAccEligibility = mapAccEligiblity.get(field.getLabel());
                        //field is edited in the same day existing record is deleted
                        if(objAccEligibility.StartDate__c == system.today()){
                            setDelAccLog.add(objAccEligibility);
                        }//if not update the end date
                        else{
                            objAccEligibility.EndDate__c = system.today().addDays(-1);
                            setUpsertAccLog.add(objAccEligibility);                                
                        }
                    }
                }
            }
            
            //only when Primary reason is updated
            if(oldAcc != Null && newAcc.Primary_Reason_Not_Eligible__c != oldAcc.Primary_Reason_Not_Eligible__c && 
               newAcc.Aquire_Eligibility_f__c == 'N' && oldAcc.Aquire_Eligibility_f__c == newAcc.Aquire_Eligibility_f__c)
            {
                setUpsertAccLog.add(createAccountEligiblityLogrecord(newAcc, Null));
                //update the end date if present in Account_Eligibility_Log__c if the field is changed
                //Delete if created in the same date
                if(mapAccEligiblity.containsKey(accountAirlineEligibilityLabel)){
                    Account_Eligibility_Log__c objAccEligibility = mapAccEligiblity.get(accountAirlineEligibilityLabel);
                    //field is edited in the same day existing record is deleted
                    if(objAccEligibility.StartDate__c == system.today()){
                        setDelAccLog.add(objAccEligibility);
                    }//if not update the end date
                    else{
                        objAccEligibility.EndDate__c = system.today().addDays(-1);
                        setUpsertAccLog.add(objAccEligibility);                                
                    }
                }
            }
            
            //Logic to delete GST Registered when valid Entity is deleted
            //if(oldAcc != Null && newAcc.Aquire_Eligibility_f__c == 'Y' && 
            if(oldAcc != null && newAcc.Aquire_Eligibility_f__c != null && newAcc.Aquire_Eligibility_f__c.equals('Y') && 
               oldAcc.Aquire_Eligibility_f__c != newAcc.Aquire_Eligibility_f__c && setDelAccLog != Null && 
               mapAccEligiblity != Null && (oldAcc.GST_Registered__c != newAcc.GST_Registered__c ||
                                            oldAcc.Valid_Entity_Type__c != newAcc.Valid_Entity_Type__c))
            {
                if(mapAccEligiblity.containsKey('Valid Entity Type')){
                    Account_Eligibility_Log__c validEntitylog = mapAccEligiblity.get('Valid Entity Type');
                    if(setDelAccLog.contains(validEntitylog)){
                        setDelAccLog.add(mapAccEligiblity.get('GST Registered'));
                    }
                }
                
                if(mapAccEligiblity.containsKey('GST Registered')){
                    Account_Eligibility_Log__c gstEntityLog = mapAccEligiblity.get('GST Registered');
                    if(setDelAccLog.contains(gstEntityLog)){
                        setDelAccLog.add(mapAccEligiblity.get('Valid Entity Type'));
                    }
                }
                
            }
        }
        
        lstDelAccLog.addAll(setDelAccLog);
        lstUpsertAccLog.addAll(setUpsertAccLog);
        Delete lstDelAccLog;
        Upsert lstUpsertAccLog;
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createAccountEligiblityLogrecord 
    Description:        Invoked from createAccountEligiblityLogs to avoid repetative codes 
                        Field Mapping for Eligiblity Log record
    Parameter:          Account and Field Set 
    --------------------------------------------------------------------------------------*/    
    public static Account_Eligibility_Log__c createAccountEligiblityLogrecord(Account newAcc, Schema.FieldSetMember field){
        Account_Eligibility_Log__c accountEligibilityLog = new Account_Eligibility_Log__c();
        accountEligibilityLog.FieldName__c  = field == Null? accountAirlineEligibilityLabel: field.getLabel();
        accountEligibilityLog.StartDate__c = Date.Today();
        accountEligibilityLog.EndDate__c = Date.newinstance(3999,12,31);
        accountEligibilityLog.Account__c = newAcc.Id;
        //log reason as well for the eligibility
        accountEligibilityLog.Reason__c = (field == Null  || field.getLabel() == accountAirlineEligibilityLabel)? newAcc.Primary_Reason_Not_Eligible__c: '';
        
        //Get the data type and update the field 
        String fieldPath = field == Null? 'Aquire_Eligibility_f__c': field.getFieldPath();
        if(field != Null && field.getType() == Schema.DisplayType.Boolean)
            accountEligibilityLog.Value__c =  (newAcc.get(fieldPath) == Null || newAcc.get(fieldPath) == False) ?'N': 'Y';
        else if(field != Null && field.getType() == Schema.DisplayType.Date)
            accountEligibilityLog.Value__c =  (newAcc.get(fieldPath) == Null ) ?'N': 'Y';
        else
            accountEligibilityLog.Value__c =  (newAcc.get(fieldPath) == Null || newAcc.get(fieldPath) == '')?'':String.valueOf(newAcc.get(fieldPath));
        return accountEligibilityLog;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createAccountEligiblityLogrecords 
    Description:        Invoked from createAccountEligiblityLogs to avoid repetative codes 
                        Field Mapping for Eligiblity Log record for GST Registered and Valid Entity
    Parameter:          Account and Field Label 
    --------------------------------------------------------------------------------------*/    
    public static Account_Eligibility_Log__c createAccountEligiblityLogrecords(Account newAcc, String field){
        Account_Eligibility_Log__c accountEligibilityLog = new Account_Eligibility_Log__c();
        accountEligibilityLog.FieldName__c  = field;
        accountEligibilityLog.StartDate__c = Date.Today();
        accountEligibilityLog.EndDate__c = Date.newinstance(3999,12,31);
        accountEligibilityLog.Account__c = newAcc.Id;
        //Get the data type and update the field 
        String fieldPath = field == 'GST Registered'? 'GST_Registered__c': 'Valid_Entity_Type__c';
        accountEligibilityLog.Value__c = String.valueOf(newAcc.get(fieldPath));
        return accountEligibilityLog;
    }
}