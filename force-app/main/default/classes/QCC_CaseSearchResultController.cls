/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Controller class of QCC_CaseSearchResult LC
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
01-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CaseSearchResultController {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    getColumns
    Description:    Returns the columns that are needed for lightning datatable of specified lightning component 
    Parameter:          
    Return:         String    
    ----------------------------------------------------------------------------------------------*/
	@AuraEnabled
    public static String getColumns(String componentName) {
        List<displayColumn> listColumn = new List<displayColumn>();
        for(QCC_Data_Table__mdt dataTable: [SELECT ComponentName__c, Order__c, FieldAPI__c, FieldLabel__c, Sortable__c, Type__c FROM QCC_Data_Table__mdt
                                            WHERE ComponentName__c  = :componentName Order By Order__c]) {
			String fieldLabel = dataTable.FieldLabel__c;
            String fieldAPI = dataTable.FieldAPI__c;
            String fieldDataType = dataTable.Type__c;
            Boolean sortable = dataTable.Sortable__c;
            TypeAttributes typeAttribute;
            // To show the record page by clicking CaseNumber, it needs to be a button with base variant
            if(fieldAPI == 'CaseNumber') {
                fieldDataType = 'button';
                typeAttribute = (TypeAttributes)System.JSON.deserialize('{ "label": { "fieldName": "CaseNumber" }, "variant": "base", "title": { "fieldName": "Description"}}', TypeAttributes.Class);
            } else if(fieldDataType.equalsIgnoreCase('Datetime')) {
                //fieldDataType = 'date';
                //typeAttribute = (TypeAttributes)System.JSON.deserialize('{"year": "numeric", "month":"numeric", "day":"numeric","hour":"2-digit","minute":"2-digit"}', TypeAttributes.Class);
            }
            
            if(fieldAPI != 'CaseNumber') {
                fieldDataType = 'button';
            	typeAttribute = (TypeAttributes)System.JSON.deserialize('{ "label": { "fieldName": "'+fieldAPI+'" }, "variant": "base", "title": { "fieldName": "'+fieldAPI+'"}}', TypeAttributes.Class);                
            }
			listColumn.add(new displayColumn(fieldLabel, fieldAPI, fieldDataType, sortable, typeAttribute));
        }
        return JSON.serialize(listColumn).replaceALL('type_x', 'type');
    }
    
    // Wrapper class to hold the structure of columns attribute of lightning:datatable tag
    public class displayColumn{
        public String label{get;set;}
        public String fieldName{get;set;}
        public String type_x{get;set;}
        public Boolean sortable;
        public TypeAttributes typeAttributes;

        public displayColumn(String label, String fieldName, String inputType, Boolean sortable,TypeAttributes typeAttributes){
            this.label = label;
            this.fieldName = fieldName;
            this.type_x = inputType;
            this.sortable = sortable;
            this.typeAttributes = typeAttributes;
        }
    }
    
    public class TypeAttributes {
        public Label label;
        public String variant;
        public String year;
        public String month;
        public String day;
        public String hour;
        public String minute;
        public Label title;
    }
    
    public class Label {
        public String fieldName;
    }
    //Logic to restrict the profile for create case button
    @AuraEnabled
    public static Boolean getProfileToHide(){
        Boolean check = false;
        Id pflId = UserInfo.getProfileId();
        Profile partnerProfile = [Select Id, Name From Profile Where id =:pflId Limit 1];        
        System.debug(System.Label.QCC_ProfileHide);
        if(partnerProfile != null){
           String pfls = System.Label.QCC_ProfileHide; 
           List<String> prflsNameList = pfls.split(',');                        
           check = prflsNameList.contains(partnerProfile.name); 
        }                 
        return check;
    }
}