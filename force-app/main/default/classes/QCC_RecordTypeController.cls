/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Controller class of QCC_RecordType LC
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
02-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_RecordTypeController {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    fetchRecordTypes
    Description:    Fetch the Record Types of specified Object 
    Parameter:      String    
    Return:         String    
    ----------------------------------------------------------------------------------------------*/
	@AuraEnabled        
    public static String fetchRecordTypes(String obj){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<RecordType> rtNames = new List<RecordType>();
        List<RecordTypeWrapper> rw = new List<RecordTypeWrapper>();
        List<Schema.RecordTypeInfo> recordtypes = schemaMap.get(obj).getDescribe().getRecordTypeInfos(); 
        for(RecordTypeInfo rt : recordtypes){
            if(!rt.isMaster() && rt.isAvailable()) {
                rw.add(new RecordTypeWrapper(rt.getName(), rt.getRecordTypeId()));
            }
        }        
        return  JSON.serialize(rw);
    }
    
    // Wrapper class which holds the structure of options attribute for lightning:radioGroup tag
    public class RecordTypeWrapper {
        public string label;
        public string value;
        
        public RecordTypeWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}