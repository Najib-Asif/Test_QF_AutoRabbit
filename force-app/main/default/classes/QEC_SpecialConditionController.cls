/**********************************************************************
Name:  QEC_ProposalFareDiscountsController
Copyright © 2019  Qantas Airways.
======================================================
Req: 
QEC - Adding/Editing/Deleting Special Conditions on Proposals and Contracts
======================================================
Purpose:                                                            
Allows user to manage special discounts on Proposals and Contracts 
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0     Anil Nair       05/06/2019      Initial Development
========================================================
Methods
1. insertRecords() - Inserts special condition records on proposals and contracts
2. getSpecialConditions() - Retrieves special conditions already added to proposals and contracts
3. deleteRecord() - Deletes special conditons on proposal or contract
4. getFares() - Returns all Fare structures
5. getFieldMap - Returns a map of fields for each special condition type
6. getPicklistMap() - Returns a map of picklist values for all the picklists present in the special condition object
7. getObjectType() - Returns the name of the object when an id is provided.
***********************************************************************/
public with sharing class QEC_SpecialConditionController {    
    
    @AuraEnabled
    public static void insertRecords(List<QEC_Special_Condition__c> specialConditionList) {
        Map<String, Id> airportNameIdMap = new Map<String, Id>();
        for(Airport_Code__c ac : [SELECT Id,Name FROM Airport_Code__c]){
            airportNameIdMap.put(ac.Name,ac.Id);
        }
        List<Id> contractIds = new List<Id>();
        for(QEC_Special_Condition__c spc : specialConditionList){
            String originStr = spc.QEC_Origin__c;
            String destnStr = spc.QEC_Destination__c; 
            spc.QEC_Origin__c = airportNameIdMap.get(originStr.toUpperCase());
            spc.QEC_Destination__c = airportNameIdMap.get(destnStr.toUpperCase());
            if(spc.Contract__c != null) {
                contractIds.add(spc.Contract__c);
            }
        }
        Map<Id,Id> contractMap  = new Map<Id,Id>();
        for(Contract__c con : [select id, Proposal__c from Contract__c where id in :contractIds]){
            contractMap.put(con.Id, con.Proposal__c);
        }
        for(QEC_Special_Condition__c spc : specialConditionList) {
            if(spc.Contract__c != null) {
                spc.Proposal__c = contractMap.get(spc.Contract__c);
            }
        } 
        try{
            insert specialConditionList;
        }
        catch(Exception e){
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, List<QEC_Special_Condition__c>> getSpecialConditions(Id recordId) {
        Map<String, List<QEC_Special_Condition__c>> specialConditionMap = new Map<String, List<QEC_Special_Condition__c>>();
        for (QEC_Special_Condition__c specialCondition : [select id,Name, QEC_Baggagecode__c,QEC_BlockRevenueTarget__c,QEC_Blocksize__c,QEC_Cancellation__c,
                                                          QEC_Class__c,QEC_Conditions__c,QEC_DayofWeek__c,QEC_Destination__c,QEC_Discount__c,QEC_Fare__c,
                                                          QEC_FarebasisFarerulenumber__c,QEC_Flightnumber__c,QEC_FromDate__c,QEC_HourDay__c, 
                                                          QEC_KgPc__c,QEC_Network__c,QEC_NoShow__c,QEC_Numberofpieces__c,QEC_Origin__c,QEC_Route__c,QEC_TimefromDeparture__c,
                                                          QEC_ToDate__c,QEC_Type__c from QEC_Special_Condition__c where Proposal__c =:recordId or Contract__c =:recordId order by createddate DESC]) {
                                                              if(specialConditionMap.containsKey(specialCondition.QEC_Type__c)) {
                                                                  List<QEC_Special_Condition__c> specialConditionList = specialConditionMap.get(specialCondition.QEC_Type__c);
                                                                  specialConditionList.add(specialCondition);
                                                                  specialConditionMap.put(specialCondition.QEC_Type__c,specialConditionList);
                                                              }
                                                              else {
                                                                  List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
                                                                  specialConditionList.add(specialCondition);
                                                                  specialConditionMap.put(specialCondition.QEC_Type__c,specialConditionList);
                                                              }
                                                          }
        return specialConditionMap;
    }
    
    @AuraEnabled
    public static void deleteRecord(Id recordId){
        QEC_Special_Condition__c recordToDelete = new QEC_Special_Condition__c(Id=recordId);
        delete recordToDelete;
    }
    
    @AuraEnabled
    public static List<Fare_Structure__c> getFares() {
        return [select id,Name,productcode__c,segment__c,network__c,market__c, cabin__c,category__c from Fare_Structure__c ];
    }
    
    @AuraEnabled
    public static Map<String,List<Object>> getFieldMap() {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('QEC_Special_Condition__c'.toLowerCase()).getDescribe().Fields.getMap();
        Map<String, list<Object>> fieldMap = new Map<String, list<Object>>();
        for (QEC_Special_Condition_Field_Mapping__mdt scf : [select Fields__c, Special_Condition_Type__c from QEC_Special_Condition_Field_Mapping__mdt]) {
            List<Object> fieldList = new List<Object>();
            for (String s : scf.Fields__c.split(',')) {
                Schema.DescribeFieldResult fd = fMap.get(s.toLowerCase()).getDescribe();
                fieldObject fo = new fieldObject(fd.getName(), fd.getType().name(), fd.getLabel(), fd.getInlineHelpText(),fd.isCreateable()?false:true);
                fieldList.add(fo);
            }
            fieldMap.put(scf.Special_Condition_Type__c, fieldList);
        }
        return fieldMap;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getPicklistMap() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('QEC_Special_Condition__c'.toLowerCase()).getDescribe().Fields.getMap();
        for(Schema.SObjectField sfield: fieldMap.Values()) {
            //system.debug(sfield.getDescribe().getName() + ' ' + sfield.getDescribe().getType().name());
            if(sfield.getDescribe().getType().name() == 'PICKLIST' || sfield.getDescribe().getType().name() == 'MULTIPICKLIST'){
                List<String> picklistValues = new List<String>();
                for (Schema.PicklistEntry ple : sfield.getDescribe().getPicklistValues()){
                    pickListValues.add(ple.getLabel());
                }
                picklistMap.put(sfield.getDescribe().getName(), picklistValues);
            }
        }
        return picklistMap;
        
    }
    @AuraEnabled
    public static String getObjectType(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }
    
    public class fieldObject {
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String fieldType {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public String helpText {get;set;}
        @AuraEnabled public Boolean disabled {get;set;}
        public fieldObject(String fn, String ft, String fl,String ht, Boolean db){
            fieldName = fn;
            fieldType = ft;
            fieldLabel = fl;
            helpText = ht;
            disabled = db;
        }
    }    
}