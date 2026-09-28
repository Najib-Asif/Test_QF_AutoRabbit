/***********************************************************************************************************************************

Description: Lightning component handler for the FreightRecordtypeAssignment

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-3068    LEx-FreightRecordtypeAssignment                T01
Created Date    : 25/05/17 (DD/MM/YYYY)

Philip Paradero Capgemini       CRM-10461    Code Security Remediation, PSV changes for System and User Mode for SOQL     
Updated Date    : 13/02/2026
**********************************************************************************************************************************/

public with sharing class QL_FreightRecordtypeAssignment {
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    @AuraEnabled public String recID {get;set;}
    @AuraEnabled
    public static List<String> getlistrecType(){
        List<String> listOption = new list<String>();
        try{
            // CRM-10461 PSV Change to run as system
            List<Freight_case_Recordtype__mdt> listtype = [Select Type__c from  Freight_case_Recordtype__mdt WHERE  Type__c!=null WITH USER_MODE Order By Type__c ASC];
            
            for(Freight_case_Recordtype__mdt c : listtype ){
                listOption.add(c.Type__c);
            }                
            
            
        }catch(exception ex){
        }
        return listOption;
    }
    
    @AuraEnabled
    public static QL_FreightRecordtypeAssignment reassignToRecordType(String caseId, String recTypeName){
        QL_FreightRecordtypeAssignment obj = new QL_FreightRecordtypeAssignment();

        try{
            Boolean valueChanged = false;
            List<Case> Updatecase = new List<Case>();
            Map<String,String> Metadatavalues= new Map<String,String>();
            Map<String,String> Caserecordtype = new Map<String,String>();
            // CRM-10461 PSV Change to run as user
            List<Case> objCase = [Select id, ownerId,Type,RecordTypeId,Status FROM Case where Id=:caseId WITH USER_MODE];
            if(!objCase.isEmpty()){
                for(Case eachCase : objCase ){
                    if(eachCase.Status == 'Closed'){
                        obj.isSuccess = false;
                        obj.msg = 'You cannot change the RecordType for Closed case!';
                        return obj;
                    }
                }    
            } 
            
            system.debug('recTypeName**************'+recTypeName); 
            system.debug('objCase **************'+objCase); 
            // CRM-10461 PSV Change to run as system
            for(RecordType listofRType : [select Id, DeveloperName from RecordType where sObjectType = 'case' and DeveloperName like '%Freight%' WITH SYSTEM_MODE])
                Caserecordtype.put(listofRType.DeveloperName, listofRType.Id);
            // CRM-10461 PSV Change to run as system
            for(Freight_case_Recordtype__mdt c: [select Type__c,Recordtype_developer_Name__c from Freight_case_Recordtype__mdt WITH USER_MODE])   
                Metadatavalues.put(c.Type__c,c.Recordtype_developer_Name__c);       
            
            for(Case c : objCase )
            {
                if(Metadatavalues.containsKey(recTypeName))
                {
                    system.debug('Caserecordtype.get(Metadatavalues.get(recTypeName))********'+Caserecordtype.get(Metadatavalues.get(recTypeName)));
                    c.Type=recTypeName;
                    c.RecordTypeId = Caserecordtype.get(Metadatavalues.get(recTypeName));
                    Updatecase.add(c);
                }
            }
            if(Updatecase!=null)  
                // CRM-10461 PSV Change to run as user
                Update as user Updatecase;  
            obj.isSuccess = true;
            obj.msg = 'The case RecordType has been updated!';
        }catch(QueryException ex){ //CRM-10461 Added catch block for query exception
            Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QL Freight Recordtype Assignment', 'QL_FreightRecordtypeAssignment', 
                                        'reassignToRecordType', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
            String msg =  'You don\'t have access to these fields: ' + inaccessibleFields.values();
            throw new AuraHandledException(msg);
        }catch(Exception e){
            system.debug('Error occured: '+e.getMessage());
        }
        return obj;
    }
}