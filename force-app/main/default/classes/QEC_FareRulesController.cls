/**********************************************************************
Name:  QEC_FareRulesController
Copyright © 2019  Qantas Airways.
======================================================
Purpose:                                                            
Allows user to manage fare rules in contract object
======================================================
VERSION  AUTHOR            DATE              DETAIL
1.0   Ram Kolli        09/09/2019      Initial Development
========================================================
Methods
1. getRuleGuidelines() - retrieves and send related fare rules on contract object to UI
2. saveFareRules() - updates fare rules in QEC_Rule__c object
***********************************************************************/
public with sharing class QEC_FareRulesController {
    @AuraEnabled
    public static List<guidelines> getRuleGuidelines(String dealType, String marketSegment, Id recordId) {
        // Map<Id, QEC_Rule__c> ruleMap = new Map<Id,QEC_Rule__c>();
        List<String> dealTyp = dealType.split(',');
        List<String> mktSgmt = marketSegment.split(',');
        //List<String> locations = location.split(',');
        Map<String,QEC_Rule__c> newMap = new Map<String,QEC_Rule__c>();
        //Find user location
        Contract__c contract = [select id,Opportunity__c, QL_Includes_JQ__c, Opportunity__r.OwnerId from contract__c where id =: recordId];
        User loginUser = [select id, country from user where id=: contract.Opportunity__r.OwnerId];
        String countryCode = loginUser.country;
        Map<Id, QEC_Rule__c> ruleMap = new Map<Id,QEC_Rule__c>([select Id,Duplicate_Check__c, Name,Contract__c, Deal_Type__c,Location__c,Market_Segment__c,Description__c, Sequence_Number__c,Recommended__c 
                                                                from QEC_Rule__c where Contract__c =: recordId and Location__c =:countryCode and Market_Segment__c =:mktSgmt 
                                                                and Deal_Type__c =: dealTyp order by Sequence_Number__c]);
        Boolean isJQInclusion = contract.QL_Includes_JQ__c;
        for(QEC_Rule__c rule : ruleMap.values()){
            newMap.put(rule.Duplicate_Check__c, rule);
        }
        
        List<guidelines> wrapperList = new List<guidelines>(); 
        for (QEC_Rule_Guidelines__c guideline : [select id, Deal_Type__c, Location__c , Market_Segment__c, Sequence_Number__c, 
                                                 Name, Text__c, Recommended__c,Duplicate_Check__c from QEC_Rule_Guidelines__c where 
                                                 Location__c =: countryCode and Market_Segment__c =: mktSgmt and 
                                                 Deal_Type__c =: dealTyp order by Sequence_Number__c asc]) {
                                                     guidelines ruleRecord = new guidelines();
                                                     
                                                     if(!newMap.isEmpty()){
                                                         if(!newMap.containsKey(guideline.Duplicate_Check__c)){
                                                             ruleRecord.textAreaData = guideline.Text__c;
                                                             ruleRecord.recommended = false;
                                                             ruleRecord.ruleName = guideline.name;
                                                             ruleRecord.sequence = guideline.Sequence_Number__c;
                                                             ruleRecord.dealType = guideline.Deal_Type__c;
                                                             ruleRecord.location = guideline.Location__c;
                                                             ruleRecord.mktSgmt =  guideline.Market_Segment__c;
                                                             
                                                         }    
                                                         if(newMap.containsKey(guideline.Duplicate_Check__c)){
                                                             ruleRecord.textAreaData = newMap.get(guideline.Duplicate_Check__c).Description__c;
                                                             ruleRecord.recordId = newMap.get(guideline.Duplicate_Check__c).Id;
                                                             ruleRecord.recommended = newMap.get(guideline.Duplicate_Check__c).Recommended__c;
                                                             ruleRecord.ruleName = newMap.get(guideline.Duplicate_Check__c).name;
                                                             ruleRecord.sequence = newMap.get(guideline.Duplicate_Check__c).Sequence_Number__c;
                                                             ruleRecord.dealType = newMap.get(guideline.Duplicate_Check__c).Deal_Type__c;
                                                             ruleRecord.location = newMap.get(guideline.Duplicate_Check__c).Location__c;
                                                             ruleRecord.mktSgmt = newMap.get(guideline.Duplicate_Check__c).Market_Segment__c;
                                                             
                                                         }
                                                     }
                                                     else  {
                                                         ruleRecord.textAreaData = guideline.Text__c;
                                                         ruleRecord.ruleName = guideline.Name;
                                                         ruleRecord.sequence = guideline.Sequence_Number__c;
                                                         ruleRecord.recommended = guideline.Recommended__c;
                                                         ruleRecord.dealType = guideline.Deal_Type__c;
                                                         ruleRecord.location = guideline.Location__c;
                                                         ruleRecord.mktSgmt = guideline.Market_Segment__c;
                                                     }
                                                     System.debug('deal type-- '+ruleRecord.dealType+' ***rule name-- '+ruleRecord.ruleName+' ****toggle----- '+ruleRecord.recommended);
                                                     
                                                      //CRM-5388: Conga Template - Deal sheet changes
                                                     if (isJQInclusion)
                                                     {
                                                         /* CRM-7001 if (guideline.Name.trim().equals('Penalties'))
                                                         {        
                                                             ruleRecord.textAreaData = Label.JQInclusionPenaltiesGuideLine;
                                                         }*/
                                                         if (guideline.Name.trim().equals('Combinations'))
                                                         {   //CRM-7001
                                                             List<Farerules_JQInclusion__mdt> JQInclusionGuideLine=new List<Farerules_JQInclusion__mdt>([SELECT Id, Rule_Description__c, Deal_Type__c,QualifiedApiName FROM Farerules_JQInclusion__mdt where Deal_Type__c = 'DOMESTIC'and QualifiedApiName = 'Combination_DOM']);
                                                             for(Farerules_JQInclusion__mdt JQ:JQInclusionGuideLine){
                                                                 ruleRecord.textAreaData=JQ.Rule_Description__c;
                                                             }
                                                         }
                                                         else if(guideline.Name.trim().equals('Application')){//CRM-7001
                                                             List<Farerules_JQInclusion__mdt> JQInclusionGuideLine=new List<Farerules_JQInclusion__mdt>([SELECT Id, Rule_Description__c, Deal_Type__c,QualifiedApiName FROM Farerules_JQInclusion__mdt where Deal_Type__c = 'DOMESTIC'and QualifiedApiName = 'Application_DOM']);
                                                             for(Farerules_JQInclusion__mdt JQ:JQInclusionGuideLine){
                                                                 ruleRecord.textAreaData=JQ.Rule_Description__c;
                                                             }
                                                         }
                                                         else if(guideline.Name.trim().equals('Application; Fares; Expenses')){//CRM-7003
                                                             List<Farerules_JQInclusion__mdt> JQInclusionGuideLine=new List<Farerules_JQInclusion__mdt>([SELECT Id, Rule_Description__c, Deal_Type__c,QualifiedApiName FROM Farerules_JQInclusion__mdt where Deal_Type__c = 'INTERNATIONAL' and QualifiedApiName = 'Application_INT']);
                                                             for(Farerules_JQInclusion__mdt JQ:JQInclusionGuideLine){
                                                                 ruleRecord.textAreaData=JQ.Rule_Description__c;
                                                             }
                                                         }
                                                         else if(guideline.Name.trim().equals('Constructions & Combinations')){//CRM-7003
                                                             List<Farerules_JQInclusion__mdt> JQInclusionGuideLine=new List<Farerules_JQInclusion__mdt>([SELECT Id, Rule_Description__c, Deal_Type__c,QualifiedApiName FROM Farerules_JQInclusion__mdt where Deal_Type__c = 'INTERNATIONAL' and QualifiedApiName = 'Constructions_and_Combination_INT']);
                                                             for(Farerules_JQInclusion__mdt JQ:JQInclusionGuideLine){
                                                                 ruleRecord.textAreaData=JQ.Rule_Description__c;
                                                             }
                                                         }
                                                     } 
													else if (!isJQInclusion)
                                                     {
                                                    	if (guideline.Name.trim().equals('Penalties'))
                                                         {        
                                                             ruleRecord.textAreaData = guideline.Text__c;
                                                         }
                                                    	else if (guideline.Name.trim().equals('Combinations'))
                                                         {        
                                                             ruleRecord.textAreaData = guideline.Text__c;
                                                         }
                                                     } 
                                                     
                                                    
                          wrapperList.add(ruleRecord);                         
                                                 }
        
        return wrapperList;
    }
    
    @AuraEnabled
    public static String saveFareRules(List<guidelines> ruleList, Id recordId) {
        Set<QEC_Rule__c> upsertRuleSet = new Set<QEC_Rule__c>();
        List<QEC_Rule__c> upsertRuleList = new List<QEC_Rule__c>();
        List<QEC_Rule__c> deleteRuleList = new List<QEC_Rule__c>();
        try{
            for(guidelines wrapper : ruleList) {
                if (wrapper.recommended) {
                    QEC_Rule__c rule  = new QEC_Rule__c();
                    rule.Contract__c = recordId;
                    rule.Name = wrapper.ruleName;
                    rule.Description__c = wrapper.textAreaData;
                    rule.Recommended__c = Boolean.valueOf(wrapper.recommended);
                    rule.Sequence_Number__c = wrapper.sequence;
                    rule.Market_Segment__c = wrapper.mktSgmt;
                    rule.Location__c = wrapper.location;
                    rule.Deal_Type__c = wrapper.dealType;
                    if(wrapper.recordId != null){
                        rule.Id = wrapper.recordId;
                    }
                    upsertRuleSet.add(rule);
                }
                else {
                    if(wrapper.recordId != null) {
                        QEC_Rule__c rule = new QEC_Rule__c(Id=wrapper.recordId);
                        deleteRuleList.add(rule);
                    }
                }
            }
            upsertRuleList.addAll(upsertRuleSet);
            upsert upsertRuleList;
            delete deleteRuleList;
        }catch(Exception e){
            system.debug('exception is '+e.getCause());
        }
        return 'SUCCESS';
    }
    
    public class guidelines{
        @AuraEnabled public Id recordId{get;set;}
        @AuraEnabled public String dealType {get;set;}
        @AuraEnabled public String location {get;set;}
        @AuraEnabled public String mktSgmt {get;set;}
        @AuraEnabled public Boolean recommended {get;set;}
        @AuraEnabled public String ruleName {get;set;}
        @AuraEnabled public Decimal sequence {get;set;}
        @AuraEnabled public String textAreaData {get;set;}
    }
}