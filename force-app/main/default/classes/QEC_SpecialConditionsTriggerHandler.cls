/**********************************************************************
Name:  QEC_SpecialConditionsTriggerHandler
Copyright © 2019  Qantas Airways.
======================================================
Purpose: 
QEC - Summarize the special condition type and JQ routes to help with the approval process
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR                 DATE              DETAIL
1.0     Yuvaraj                 05/06/2019      Initial Development
2.0     Pushkar Purushothaman   04/09/2019      Changes incorporated to associate special conditions to contracts
========================================================
***********************************************************************/
public class QEC_SpecialConditionsTriggerHandler 
{  
    public static void updateSC_ODPair_onProposal(List<QEC_Special_Condition__c> newList)
    {
        Set<Id> propIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        List<QEC_Special_Condition__c> spcList = new List<QEC_Special_Condition__c>();
        List<Contract__c> contractList = new List<Contract__c>();
        Set<Id> airportIds = new Set<Id>();
        for(QEC_Special_Condition__c spc: newList) {
            if(spc.Contract__c != null)contractIds.add(spc.Contract__c);
            airportIds.addAll(new Set<Id>{spc.QEC_Origin__c,spc.QEC_Destination__c}); //CRM-10173
            if(!Trigger.isInsert && spc.QEC_History__c && propIds.IsEmpty()){
                spcList.add(new QEC_Special_Condition__c(Id=spc.id,QEC_History__c=false));
            }         
        }
        if(spcList.size() > 0){
            update spcList;
        }
        if(!airportIds.isEmpty()){
        Map<Id,Airport_Code__c> airportCodeMap = new Map<Id,Airport_Code__c>([Select Id,Name from Airport_Code__c where Id IN:airportIds]); // used where condition to reduce heap size- CRM-10173
        if(contractIds.size() > 0){
            for(Contract__c contrct : [Select Id,QEC_Approval_Condition__c,QEC_JQ_Inclusion_City_Pairs__c,(select id,QEC_Type__c,QEC_Origin__c,QEC_Destination__c,QEC_History__c from Special_Conditions__r) spc from Contract__c WHERE Id IN :contractIds]){
                String specialConditions = '';
                String JQ_OnD = '';
                for(QEC_Special_Condition__c sp : contrct.Special_Conditions__r){
                    if(!sp.QEC_History__c){
                        
                        if(specialConditions == ''){
                            specialConditions = String.valueOf(sp.QEC_Type__c)+';';
                        }
                        else{
                            if(!specialConditions.contains(String.valueOf(sp.QEC_Type__c))){
                                specialConditions = specialConditions+String.valueOf(sp.QEC_Type__c)+';';
                            }
                        }
                        
                    }
                    
                    if(sp.QEC_Type__c == 'JQ Inclusion'){
                       if(airportCodeMap.containsKey(sp.QEC_Origin__c) && airportCodeMap.containsKey(sp.QEC_Destination__c)){
                            if(!JQ_OnD.contains(airportCodeMap.get(sp.QEC_Origin__c).Name+'-'+airportCodeMap.get(sp.QEC_Destination__c).Name))
                                JQ_OnD += airportCodeMap.get(sp.QEC_Origin__c).Name+'-'+airportCodeMap.get(sp.QEC_Destination__c).Name+';';
                        }
                        
                        
                    }
                }
                Contract__c conInst = new Contract__c(Id=contrct.Id);
                conInst.QEC_Approval_Condition__c = specialConditions;
                if(JQ_OnD != ''){
                    conInst.QEC_JQ_Inclusion_City_Pairs__c = JQ_OnD.removeEnd(';');
                }
                contractList.add(conInst);
                System.debug('ContractAppCondition'+specialConditions);
            }
            
        }
        }
        if(contractList.size() > 0)
            update contractList;
    }
}