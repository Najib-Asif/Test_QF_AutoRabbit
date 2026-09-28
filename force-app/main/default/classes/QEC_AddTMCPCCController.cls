/***********************************************************************************************************************************
Description: class for Handling TMC PCC management in Proposal and Contract Objects
Lightning Component : QEC_AddTMCPCCcmp

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Ram Kolli             EXPRCON-97     Manage TMC/PCC on Proposal and Contract  objects            T01                    
Created Date    : 20/08/19 (DD/MM/YYYY)

**********************************************************************************************************************************/

public without sharing class QEC_AddTMCPCCController {
    @AuraEnabled public Boolean isProposalRecord {get;set;}
    @AuraEnabled public Boolean isCaseCreated {get;set;}
    @AuraEnabled public String emailDistribution {get;set;}
    @AuraEnabled public List<QEC_AddTMCPCCWrapper> wrapperList = new List<QEC_AddTMCPCCWrapper>();
    
     @AuraEnabled 
    public static String getUserRoleName(){
        Id UserId = UserInfo.getUserId();
        User currentUser = [Select Id, UserRole.Name from User where Id =:UserId Limit 1];
        return currentUser.UserRole.Name != null ? currentUser.UserRole.Name:'';
    }
    
    @AuraEnabled
    public static QEC_AddTMCPCCController getTMCPCC(String recordid){
        Id currentRecordID = Id.valueof(recordId);
        String query;
        List<Id> tmcIds = new List<Id>();
        Proposal__c currentProposal;
        Contract__c currentContract;
        QEC_AddTMCPCCController cntrl = new QEC_AddTMCPCCController();
        //List<QEC_AddTMCPCCWrapper> wrapperList = new List<QEC_AddTMCPCCWrapper>();
        
        if(currentRecordID.getSObjectType().getDescribe().getName() == 'Contract__c') {
            cntrl.isProposalRecord = false;
            query = 'SELECT Id,Contract_Start_Date__c,Contract_End_Date__c,QEC_Distribution_Email__c, (select id,TMC_Info__c, History__c from Contract_TMC_Info__r) from Contract__c WHERE id=: recordId';
        }else{
            cntrl.isProposalRecord = true;
            query = 'SELECT Id,Proposal_Start_Date__c,Proposal_End_Date__c, (select id,TMC_Info__c, History__c from Contract_TMC_Info__r) from Proposal__c WHERE id=: recordId';
        }
        sObject record = Database.query(query);
        
        if(cntrl.isProposalRecord){    
            currentProposal = (Proposal__c)record;
        }else{
            currentContract = (Contract__c)record;
            cntrl.emailDistribution = currentContract.QEC_Distribution_Email__c;
        }
        
        if(cntrl.isProposalRecord && currentProposal.Contract_TMC_Info__r <> null){
            for(QEC_ContractTMCInfo__c obj : currentProposal.Contract_TMC_Info__r){
                tmcIds.add(obj.TMC_Info__c);
            }
        }
        if(!cntrl.isProposalRecord && currentContract.Contract_TMC_Info__r <> null){
            for(QEC_ContractTMCInfo__c obj : currentContract.Contract_TMC_Info__r){
                tmcIds.add(obj.TMC_Info__c);
            }
        }
        for(QEC_ContractTMCInfo__c agencyRecord : [SELECT Id, History__c, PCC_Start_Date__c,PCC_End_Date__c,Proposal__c,TMC_Info__c,Contract__c,TMC_Info__r.PCC__c,TMC_Info__r.Account__r.name,TMC_Info__r.Active__c, TMC_Info__r.Code__c, TMC_Info__r.Account__r.Qantas_Industry_Centre_ID__c from  QEC_ContractTMCInfo__c where TMC_Info__c =: tmcIds AND (Proposal__c =: recordId or Contract__c =: recordId) order by lastmodifieddate desc]){
            QEC_AddTMCPCCWrapper wrapper = new QEC_AddTMCPCCWrapper();
            wrapper.tmcId = agencyRecord.TMC_Info__c;
            wrapper.pcc = agencyRecord.TMC_Info__r.PCC__c;
            wrapper.gds = agencyRecord.TMC_Info__r.Code__c;
            wrapper.sdate = agencyRecord.PCC_Start_Date__c;
            wrapper.edate = agencyRecord.PCC_End_Date__c;
            wrapper.iata = agencyRecord.TMC_Info__r.Account__r.Qantas_Industry_Centre_ID__c;
            wrapper.history = agencyRecord.History__c;
            wrapper.contractTMCId = agencyRecord.Id;
            wrapper.active = agencyRecord.TMC_Info__r.Active__c;
            wrapper.accountName = agencyRecord.TMC_Info__r.Account__r.Name;
            cntrl.wrapperList.add(wrapper);
        }
        if(!cntrl.wrapperList.isEmpty()){
            return cntrl;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<searchWrapper> fetchPCCData(String searchString, String recordId){
        Id currentRecordID = Id.valueof(recordId);
        List<searchWrapper> childWrapper = new List<searchWrapper>();
        Proposal__c currentProposal;
        Contract__c currentContract;
        String query;
        QEC_AddTMCPCCController cntrl = new QEC_AddTMCPCCController();
        if(currentRecordID.getSObjectType().getDescribe().getName() == 'Contract__c') {
            cntrl.isProposalRecord = false;
        }else{
            cntrl.isProposalRecord = true;
        }
        List<Agency_Info__c> agencyList = [SELECT Id, PCC__c,Code__c,Account__c,Active__c, Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c where PCC__c =: searchString or Account__r.Qantas_Industry_Centre_ID__c =: searchString];
        if(cntrl.isProposalRecord){
            query = 'SELECT Id,Proposal_End_Date__c from Proposal__c WHERE Id =: recordId';
        }else{
            query = 'SELECT Id, Contract_End_Date__c from Contract__c where Id =: recordId';
        }
        sObject currentRecord = Database.query(query);
        if(cntrl.isProposalRecord){    
            currentProposal = (Proposal__c)currentRecord;
        }else{
            currentContract = (Contract__c)currentRecord;
        }
        
        for(Agency_Info__c currentAgency : agencyList){
            searchWrapper sw = new searchWrapper();
            sw.tmcId = currentAgency.Id;
            sw.pcc = currentAgency.PCC__c;
            sw.gds = currentAgency.Code__c;
            sw.iata = currentAgency.Account__r.Qantas_Industry_Centre_ID__c;
            sw.sdate = System.today();
            sw.active = currentAgency.Active__c;
            childWrapper.add(sw);
        }
        return childWrapper;
    }
    
    @AuraEnabled
    public static Object performSave(String data, String recordId, String removalArray, String linkedArray,String emailField){
        Boolean returnFlag = false;
        Boolean history = false;
        Date dueDate;
        QEC_AddTMCPCCController returnObj = new QEC_AddTMCPCCController();
        returnObj.isCaseCreated=false;
        try{
            Id currentRecordID = Id.valueof(recordId);
            Set<Agency_Info__c> updateHistorySet = new Set<Agency_Info__c>();
            List<Agency_Info__c> updateHistory = new List<Agency_Info__c>();
            List<QEC_AddTMCPCCWrapper> wrapper = (List<QEC_AddTMCPCCWrapper>)JSON.deserialize(data, List<QEC_AddTMCPCCWrapper>.class);
            List<QEC_AddTMCPCCWrapper> linkedRecords = (List<QEC_AddTMCPCCWrapper>)JSON.deserialize(linkedArray, List<QEC_AddTMCPCCWrapper>.class);
            List<QEC_AddTMCPCCWrapper> removeList = (List<QEC_AddTMCPCCWrapper>)JSON.deserialize(removalArray, List<QEC_AddTMCPCCWrapper>.class);
            List<Id> addAgencyIds = new List<Id>();
            Map<Id, Date> removeAgencyIds = new Map<Id, Date>();
            Id accountId;
            List<QEC_ContractTMCInfo__c> qcList = new List<QEC_ContractTMCInfo__c>();
            if(currentRecordID.getSObjectType().getDescribe().getName() == 'Contract__c') {
                
                Contract__c contract = [select id, Name, Account__c,Opportunity__c,Opportunity__r.OwnerId from Contract__c where id =: currentRecordID];
                accountId = contract.Account__c;
                if(contract.Opportunity__r.OwnerId != UserInfo.getUserId()){
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.UserId = UserInfo.getUserId();
                    otm.TeamMemberRole = 'Account Manager';
                    otm.OpportunityAccessLevel = 'Edit';
                    otm.OpportunityId = contract.Opportunity__c;
                    insert otm;
                }
                returnObj.isProposalRecord = false;
                Contract__c currentContract = new Contract__c(Id=recordId);
                currentContract.QEC_Distribution_Email__c=emailField;
                update currentContract;
                
            }else{
                returnObj.isProposalRecord = true;
            }
            Set<id> qccListIds = new Set<id>();
            //update history for removed reocrds -starts
            if(null != wrapper && wrapper.size() > 0){
                for(QEC_AddTMCPCCWrapper record: wrapper){
                    addAgencyIds.add(record.tmcId);
                    //save newly linked pcc records - starts
                    QEC_ContractTMCInfo__c qc = new QEC_ContractTMCInfo__c();
                    qc.TMC_Info__c = record.tmcId;
                    if(returnObj.isProposalRecord){
                        qc.Proposal__c = recordId;
                    }else{
                        qc.Contract__c = recordId;
                    }
                    qc.PCC_Start_Date__c = record.sdate;
                    dueDate =record.sdate;
                    qc.PCC_End_Date__c = record.edate;
                    qc.History__c = false;
                    qcList.add(qc);
                    qccListIds.add(record.tmcId);
                    //save newly linked pcc records - ends
                }
            }
            Set<id> contractTMCIds = new Set<id>();
            if(null != linkedRecords && linkedRecords.size() > 0){
                for(QEC_AddTMCPCCWrapper record: linkedRecords){
                    QEC_ContractTMCInfo__c qc = new QEC_ContractTMCInfo__c();
                    qc.PCC_End_Date__c = record.edate;
                    qc.History__c = record.history;
                    qc.Id = record.ContractTMCId;
                    qcList.add(qc);
                    qccListIds.add(record.ContractTMCId);
                    //save newly linked pcc records - ends
                    if(record.history == true ){
                        contractTMCIds.add(record.ContractTMCId);
                    }
                }
            }
            
            if(removeList.size() > 0){
                for(QEC_AddTMCPCCWrapper rec: removeList){
                    removeAgencyIds.put(rec.contractTMCId, rec.edate);
                }
                
                
                //update end date to contract end date for removed records - starts
                List<QEC_ContractTMCInfo__c> pccremoveList = new List<QEC_ContractTMCInfo__c>();
                for(QEC_ContractTMCInfo__c record : [select id,History__c, PCC_End_Date__c from QEC_ContractTMCInfo__c where Id =:removeAgencyIds.keySet() ]){
                    for(Id d : removeAgencyIds.keySet()){
                        if(String.valueOf(d).equals(String.valueOf(record.id))){
                            record.PCC_End_Date__c = null != String.valueOf(removeAgencyIds.get(d)) ? removeAgencyIds.get(d) : System.today();
                            record.History__c = true;
                            pccremoveList.add(record);
                        }
                    }
                }
                
                if(!pccremoveList.isEmpty()){
                    update pccremoveList;
                    returnFlag = true;
                }
                //update end date to contract end date for removed records - ends
            }
            
            
            //insert newly linked records
            if(!qcList.isEmpty()){
                upsert qcList;
                returnFlag = true;
                //case creation starts here - case will be created only for Contracts
                if(!returnObj.isProposalRecord) {
                    //String description ;
                    String pccString='';
                    String iataString='';
                    String gdsString='';
                    List<String> addedPair = new List<String>();
                    List<String> modifiedPair = new List<String>();
                    if(null != wrapper){
                        //added PCC/IATA
                        for(Integer i=0; i< wrapper.size(); i++) {
                            if(null != wrapper[i].pcc && (!String.isEmpty(wrapper[i].pcc))){
                                pccString += wrapper[i].pcc+',';
                            }
                            if(null != wrapper[i].iata && (!String.isEmpty(wrapper[i].iata))){
                                iataString += wrapper[i].iata+',';
                            }
                            if(null != wrapper[i].gds && (!String.isEmpty(wrapper[i].gds))){
                                gdsString += wrapper[i].gds+',';
                            }
                            addedPair.add(wrapper[i].pcc +'-'+ wrapper[i].gds);
                        }
                    } 
                    if(null != linkedArray){
                        //Modified PCC/IATA
                        for(Integer i=0; i< linkedRecords.size(); i++){
                            if(null != linkedRecords[i].pcc && (!String.isEmpty(linkedRecords[i].pcc))){
                                pccString += linkedRecords[i].pcc+',';
                            }
                            if(null != linkedRecords[i].iata && (!String.isEmpty(linkedRecords[i].iata))){
                                iataString += linkedRecords[i].iata+',';
                            }
                            if(null != linkedRecords[i].gds && (!String.isEmpty(linkedRecords[i].gds))){
                                gdsString += linkedRecords[i].gds+',';
                            }
                            modifiedPair.add(linkedRecords[i].pcc +'-'+ linkedRecords[i].gds);
                        }
                    }
                    
                    for(Id ids: qccListIds){
                        if(contractTMCIds.size()<1 && !contractTMCIds.contains(ids)){
                            Case c = new Case();
                            String dataNotPresent = Label.QEC_Code_Not_defined;
                            date addDays = system.today();
                            addDays = addDays.addDays(3);
                            iataString=String.isEmpty(iataString) ? dataNotPresent :iataString.removeEnd(',');
                            pccString=String.isEmpty(pccString) ? dataNotPresent : pccString.removeEnd(',');
                            gdsString = String.isEmpty(gdsString) ? dataNotPresent : gdsString.removeEnd(',');
                            String modifiedPairString='';
                            for(String m : modifiedPair){
                                modifiedPairString += m+'\n';
                            }
                            String addedPairString='';
                            for(String m : addedPair){
                                addedPairString += m+'\n';
                            }
                            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
                            c.Related_Contract__c = currentRecordID;
                            c.OwnerId = [select id from Group where  Type = 'Queue' and name='Deal Support Team Queue'].Id;
                            c.Type = Label.Case_Type_Deal_Amendment;
                            c.status =Label.Case_Status_Deal_Support;
                            c.Sub_Type__c = Label.Case_sub_type_IATA_PCC_related;
                            c.Subject = Label.QEC_Case_Subject ;
                            c.AccountId = accountId;
                            //CRM-7815 Case due date update  
                            //CRM-8047 Case due date update
                            c.Due_Date__c = addDays;
                            //c.Due_Date__c = dueDate;
                            c.Description = Label.Case_TMC_PCC_Description+'\n'+'Added TMC/PCC :'+'\n'+addedPairString+'\n'+'Modified TMC/PCC :'+'\n'+modifiedPairString;
                            c.Distribution_Email__c = emailField;
                            c.PCC_Codes_DAT__c=pccString;
                            c.PCC_Codes_DAI__c=pccString;
                            c.IATA_DAT__c= iataString;
                            c.IATA_DAI__c= iataString;
                            c.Date_Effective_DAT__c = System.today();
                            c.New_IATA_Start_Date_DAI__c = system.today();
                            c.GDS_DAT__c=gdsString;
                            c.GDS_DAI__c =gdsString;
                            // c.New_TMC_Name__c= getAccountRelation(c.AccountId); /*Commented as part of Jira CRM- 5688*/ 
                            insert c;
                            returnObj.isProposalRecord = false;
                            returnObj.isCaseCreated = true;
                            break;
                        }
                        //case creation ends here
                    }
                }
                
            }
        }
        catch(Exception e){
            returnFlag = false;
            system.debug('Exception is '+e.getMessage());
            return e.getMessage();
        }        
        if(returnFlag)
            return returnObj;
        return null;
    }
    public static Id getAccountRelation(Id accId){
        Account_Relation__c c = new Account_Relation__c();
        c.Active__c= true;
        c.Relationship__c ='Travel Manager Of';
        c.Related_Account__c =accId;
        insert c;
        return c.id;
    }
    public class searchWrapper{
        @AuraEnabled public String pcc {get;set;}
        @AuraEnabled public String iata {get;set;}
        @AuraEnabled public String gds {get;set;}
        @AuraEnabled public Id tmcId {get;set;}
        @AuraEnabled public Date sdate {get;set;}
        @AuraEnabled public Date edate {get;set;}
        @AuraEnabled public Boolean history {get;set;}
        @AuraEnabled public Boolean active{get;set;}
        
    }
}