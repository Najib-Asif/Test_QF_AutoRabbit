/* Created By :TCS
* Purpose : TS-4468-To include business logic for TMC Triggers on Channel functionality
* Description : To update TMC Info records when an asset is existing for IATA
* References : TMCTrigger
* Test Class : QAC_TMCHandler_Test

Modified Date   : 25/07/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3816, CRM-3845
Version         : V2.0 - GDS PCC Length should be matched based on PCC Min Length and PCC Max Length on GDS Reference Object
TMC Duplicate Rule on PCC, GDS and Account ID

Modified Date   : 07/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3871
Version         : V3.0 - Changes to avoid the CPU limit

Modified Date   : 18/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3908
Version         : V4.0 - Changes to update the GDS Status based on PCC GDS Combination
*/
public with sharing class QAC_TMCHandler 
{
    //PCC Validation based on GDS
    // to update GDS status field on TMC Info records
    public static void QCH_updateTMC(list<Agency_Info__c> newTMCs, map<Id,Agency_Info__c> oldTMCs)
    {
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        
        String[] assetStatus = new String[]{'New','Validating','Accepted'};
            Map<Id,List<String>> existingAstGDSmap = new Map<Id,List<String>>();
        Map<String,GDS_Reference__c> gdsMap = new map<String,GDS_Reference__c>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> gdsValues = new Set<String>();
        Set<String> pccValues = new Set<String>();
        list<Agency_Info__c> existingTMCInfo;
        Set<String> accGDSPCCCombo = new Set<String>();
        Set<String> otherAccGDSPCCCombo = new Set<String>();
        Set<String> incomingTMCInfo = new Set<String>();
        
        
        for(Agency_Info__c eachAg : newTMCs)
        {
            if(eachAg != null && eachAg.RecordTypeId == tmcRTId)
            {
                if(oldTMCs == null ||(oldTMCs != null && eachAg.Active__c != oldTMCs.get(eachAg.Id).Active__c))
                    accIds.add(eachAg.Account__c); 
                
                if(eachAg.PCC__c != null && eachAg.Code__c != null && eachAg.Account__c != null && (oldTMCs == null || (oldTMCs != null && ((eachAg.Code__c != oldTMCs.get(eachAg.Id).Code__c)||(eachAg.PCC__C != oldTMCs.get(eachAg.Id).PCC__C) || (eachAg.Account__c != oldTMCs.get(eachAg.Id).Account__c)))))
                {
                    gdsValues.add(eachAg.Code__c);
                    pccValues.add(eachAg.PCC__c);
                    accountIds.add(eachAg.Account__c);
                }
                
                // Added as part of CRM-3816 to Convert PCC to UpperCase
                if(eachAg.PCC__c!=null)
                    eachAg.pcc__c =eachAg.PCC__c.toUpperCase();
            }    
        }
        system.debug('incoming TMC account Ids***'+accIds);
        
        if(!gdsValues.isEmpty())
        {
            for(GDS_Reference__c gdsReference:[select Id,Name,PCC_Min_Length__c,PCC_Max_Length__c from GDS_Reference__c where PCC_Min_Length__c!=null AND PCC_Max_Length__c !=null AND Name IN:gdsValues])
            {
                if(gdsReference != null)
                    gdsMap.put(gdsReference.Name,gdsReference);
            }
            if(!accountIds.isEmpty() && !pccValues.isEmpty())
            {
                existingTMCInfo = [SELECT Id, Account__c, PCC__c, Code__c FROM Agency_Info__c WHERE Account__c IN: accountIds AND PCC__c IN: pccValues AND Code__c IN: gdsValues AND RecordTypeId =: tmcRTId];
                if(existingTMCInfo.size()>0){
                    for(Agency_Info__c oldTMC : existingTMCInfo){
                        accGDSPCCCombo.add(oldTMC.Account__c+'-'+oldTMC.PCC__c+'-'+oldTMC.Code__c);
                        system.debug('Existing Account GDS PCC Combo***'+accGDSPCCCombo);
                    }
                }
            }
        }
        
        // query for existing assets 
        if(!accIds.isEmpty())
        {
            for(Asset eachAsset : [SELECT Id,Status,AccountId,GDS__c,GDS_Name__c FROM Asset 
                                   WHERE AccountId IN: accIds AND Active__c = True
                                   AND RecordTypeId =: assetRTId AND Status IN: assetStatus])
            {
                if(eachAsset != null){
                    if(existingAstGDSmap.containsKey(eachAsset.AccountId)){
                        existingAstGDSmap.get(eachAsset.AccountId).add(eachAsset.GDS_Name__c);
                    }
                    else{
                        existingAstGDSmap.put(eachAsset.AccountId, new List<String>{eachAsset.GDS_Name__c});
                    }                
                }    
            }
            system.debug('existing Assets***'+existingAstGDSmap);
        }
        for(Agency_Info__c eachTMC : newTMCs)
        {
            if(eachTMC != null & eachTMC.PCC__C != null && eachTMC.RecordTypeId == tmcRTId && (oldTMCs == null || (oldTMCs != null && ((eachTMC.Code__c != oldTMCs.get(eachTMC.Id).Code__c)||(eachTMC.PCC__C != oldTMCs.get(eachTMC.Id).PCC__C)))))
            {
                if(gdsMap.get(eachTMC.Code__c)!=null)
                {
                    if(eachTMC.PCC__C.length()<gdsMap.get(eachTMC.Code__c).pcc_min_length__c || 
                       eachTMC.PCC__C.length()>gdsMap.get(eachTMC.Code__c).pcc_max_length__c)
                    {
                        if(gdsMap.get(eachTMC.Code__c).pcc_min_length__c==gdsMap.get(eachTMC.Code__c).pcc_max_length__c)
                        {
                            eachTMC.pcc__c.adderror(gdsMap.get(eachTMC.Code__c).Name+' PCC length should be '+gdsMap.get(eachTMC.Code__c).pcc_min_length__c+' Characters');
                        }
                        else
                        {
                            eachTMC.pcc__c.adderror(gdsMap.get(eachTMC.Code__c).Name+' PCC length should be between '+gdsMap.get(eachTMC.Code__c).pcc_min_length__c+' and '+
                                                    gdsMap.get(eachTMC.Code__c).pcc_max_length__c+' Characters');
                        }
                    }
                }
            }
            Agency_Info__c existingAgencyInfo = oldTMCs != null ? oldTMCs.get(eachTMC.Id) : null;
            
            if(eachTMC != null && eachTMC.PCC__c != null && eachTMC.Code__c !=null && eachTMC.Account__c != null && eachTMC.RecordTypeId == tmcRTId &&
               (existingAgencyInfo == null || 
                (existingAgencyInfo != null && (eachTMC.Account__c != existingAgencyInfo.Account__c || eachTMC.PCC__c != existingAgencyInfo.PCC__c || eachTMC.Code__c != existingAgencyInfo.Code__c))))
            {
                String tmcCombo = eachTMC.Account__c+'-'+eachTMC.PCC__c+'-'+eachTMC.Code__c;
                system.debug('Account GDS PCC Combo***'+tmcCombo);
                if(!accGDSPCCCombo.isEmpty() && accGDSPCCCombo.contains(tmcCombo)){
                    eachTMC.addError('This ' +eachTMC.Code__c+ ' ' +eachTMC.PCC__c+ ' already exists on this Account');
                    
                }
            }
            
            if(!existingAstGDSmap.isEmpty())
            {
                if(eachTMC != null && eachTMC.RecordTypeId == tmcRTId &&
                   (oldTMCs == null || 
                    (oldTMCs != null && eachTMC.Active__c != oldTMCs.get(eachTMC.Id).Active__c)))
                {
                    if(existingAstGDSmap.get(eachTMC.Account__c) != null && 
                       existingAstGDSmap.get(eachTMC.Account__c).contains(eachTMC.Code__c))
                        
                    {
                        eachTMC.GDS_Status__c = ((eachTMC.GDS_Status__c =='New' || String.isBlank(eachTMC.GDS_Status__c)) && eachTMC.Active__c) ? 'New' : 
                        ((eachTMC.GDS_Status__c =='New' || String.isBlank(eachTMC.GDS_Status__c)) && !eachTMC.Active__c) ? '' : 
                        eachTMC.GDS_Status__c;                           
                    }
                }
            }
        }
    }
    
    // Changes added by Vinoth - For Updating GDS Status based on PCC GDS Combination : CRM-3908
    
    public static void QCH_afterupdateTMC (list<Agency_Info__c> newTMCs, map<Id,Agency_Info__c> oldTMCs)
        
    {
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        Set<Id> accountIds = new Set<Id>();
        Set<String> gdsValues = new Set<String>();
        Set<String> pccValues = new Set<String>();
        Set<String> inactiveGdsValues = new Set<String>();
        Set<String> inactivePccValues = new Set<String>();
        Set<Id> inactiveTMCAccountIds = new Set<Id>();
        Set<String> deregisterGdsValues = new Set<String>();
        Set<String> deregisterPccValues = new Set<String>();
        Set<Id> deregisterTMCAccountIds = new Set<Id>();
        String[] tmcStatus = new String[]{'New','Validating','Rejected'};
            Map<String,Agency_Info__c> agencyMap = new Map<String,Agency_Info__c>();
        List<Agency_Info__c> toUpdateActive = new List<Agency_Info__c>();
        List<Agency_Info__c> toUpdateInactive = new List<Agency_Info__c>();
        List<Agency_Info__c> toUpdateDeregistered = new List<Agency_Info__c>();
        List<Agency_Info__c> existingAcceptedTMCInfo;
        List<Agency_Info__c> existingAgencyTMCInfo;
        
        for(Agency_Info__c eachAg : newTMCs)
        {
            if(eachAg != null && eachAg.RecordTypeId == tmcRTId)
            {
                if(eachAg.PCC__c != null && eachAg.Code__c !=null && eachAg.GDS_Status__c == 'Accepted' && eachAg.ATPCO_Status__c == 'Accepted' && eachAg.Surcharge_Exemption_Status__c == 'Accepted' && eachAg.QDP_Status__c == 'Accepted' &&
                   (oldTMCs == null || 
                    (oldTMCs != null && (eachAg.GDS_Status__c != oldTMCs.get(eachAg.Id).GDS_Status__c || eachAg.ATPCO_Status__c != oldTMCs.get(eachAg.Id).ATPCO_Status__c || eachAg.Surcharge_Exemption_Status__c != oldTMCs.get(eachAg.Id).Surcharge_Exemption_Status__c  || eachAg.QDP_Status__c  != oldTMCs.get(eachAg.Id).QDP_Status__c))))
                    
                {
                    String tmcGDSPCCCombo = eachAg.PCC__c+'_'+eachAg.Code__c;
                    agencyMap.put(tmcGDSPCCCombo,eachAg);
                    gdsValues.add(eachAg.Code__c);
                    pccValues.add(eachAg.PCC__c);
                    accountIds.add(eachAg.Account__c);
                    system.debug('incoming After TMC account Ids***'+accountIds);
                }
                
                if(eachAg != null && eachAg.PCC__c != null && eachAg.Code__c !=null && eachAg.GDS_Status__c == 'Inactive' && eachAg.ATPCO_Status__c == 'Inactive' && eachAg.Surcharge_Exemption_Status__c == 'Inactive' && eachAg.QDP_Status__c == 'Inactive' &&
                   (oldTMCs == null || 
                    (oldTMCs != null && (eachAg.GDS_Status__c != oldTMCs.get(eachAg.Id).GDS_Status__c || eachAg.ATPCO_Status__c != oldTMCs.get(eachAg.Id).ATPCO_Status__c || eachAg.Surcharge_Exemption_Status__c != oldTMCs.get(eachAg.Id).Surcharge_Exemption_Status__c  || eachAg.QDP_Status__c  != oldTMCs.get(eachAg.Id).QDP_Status__c))))
                    
                {
                    inactiveGdsValues.add(eachAg.Code__c);
                    inactivePccValues.add(eachAg.PCC__c);
                    inactiveTMCAccountIds.add(eachAg.Account__c);
                }
                
                if(eachAg != null && eachAg.PCC__c != null && eachAg.Code__c !=null && eachAg.GDS_Status__c == 'Deregistered' && eachAg.ATPCO_Status__c == 'Deregistered' && eachAg.Surcharge_Exemption_Status__c == 'Deregistered' && eachAg.QDP_Status__c == 'Deregistered' &&
                   (oldTMCs == null || 
                    (oldTMCs != null && (eachAg.GDS_Status__c != oldTMCs.get(eachAg.Id).GDS_Status__c || eachAg.ATPCO_Status__c != oldTMCs.get(eachAg.Id).ATPCO_Status__c || eachAg.Surcharge_Exemption_Status__c != oldTMCs.get(eachAg.Id).Surcharge_Exemption_Status__c  || eachAg.QDP_Status__c  != oldTMCs.get(eachAg.Id).QDP_Status__c))))
                    
                {
                    deregisterGdsValues.add(eachAg.Code__c);
                    deregisterPccValues.add(eachAg.PCC__c);
                    deregisterTMCAccountIds.add(eachAg.Account__c);
                }
            }
        }
        
        if(!accountIds.isEmpty() && !pccValues.isEmpty() && !gdsValues.isEmpty())
        {
            
            for(Agency_Info__c eachTMC : [SELECT Id,Account__c,PCC__c,Code__c,Active__c,GDS_Effective_Date__c,Channel_Effective_Date__c,
                                          GDS_Status__c 
                                          FROM Agency_Info__c 
                                          WHERE Account__c NOT IN: accountIds AND PCC__c IN: pccValues AND Code__c IN: gdsValues  
                                          AND RecordTypeId =: tmcRTId AND Active__c = TRUE AND GDS_Status__c IN: tmcStatus])
                
                
            {
                if (eachTMC != null)
                    system.debug('New TMC***'+eachTMC);
                {
                    String TMCCombo = eachTMC.PCC__c+'_'+eachTMC.Code__c;
                    
                    if(agencyMap.containsKey(TMCCombo))
                    {
                        eachTMC.GDS_Status__c = 'Active';
                        eachTMC.ATPCO_Status__c = '';
                        eachTMC.Surcharge_Exemption_Status__c = '';
                        eachTMC.QDP_Status__c = '';
                        eachTMC.GDS_Effective_Date__c = agencyMap.get(TMCCombo).GDS_Effective_Date__c;
                        eachTMC.Channel_Effective_Date__c = agencyMap.get(TMCCombo).Channel_Effective_Date__c;
                        eachTMC.Channel_RecG_Identifier__c = '';
                        eachTMC.Channel_YR_Identifier__c = null ;
                        toUpdateActive.add(eachTMC);
                    }
                }
            }
        }
        
        if(!inactiveTMCAccountIds.isEmpty() && !inactivePccValues.isEmpty() && !inactiveGdsValues.isEmpty())
        {
            existingAcceptedTMCInfo = [SELECT Id, Account__c, PCC__c, Code__c FROM Agency_Info__c WHERE Account__c NOT IN: inactiveTMCAccountIds AND PCC__c IN: inactivePccValues AND Code__c IN: inactiveGdsValues AND GDS_Status__c = 'Accepted' AND RecordTypeId =: tmcRTId];
            
            if(existingAcceptedTMCInfo.isEmpty())
            {
                for(Agency_Info__c eachTMC : [SELECT Id,Account__c,PCC__c,Code__c,Active__c,GDS_Effective_Date__c,Channel_Effective_Date__c,
                                              GDS_Status__c, Channel_End_Date__c, Last_Inactive_Date__c
                                              FROM Agency_Info__c 
                                              WHERE Account__c NOT IN: inactiveTMCAccountIds AND PCC__c IN: inactivePccValues AND Code__c IN: inactiveGdsValues  
                                              AND RecordTypeId =: tmcRTId AND Active__c = TRUE AND GDS_Status__c = 'Active'])
                    
                {
                    if (eachTMC != null)
                    {
                        eachTMC.GDS_Status__c = 'Inactive';
                        eachTMC.Active__c = FALSE;
                        eachTMC.Channel_End_Date__c = system.today();
                        eachTMC.Last_Inactive_Date__c = system.now();
                        toUpdateInactive.add(eachTMC);
                    }
                }
            }
        }
        
        if(!deregisterTMCAccountIds.isEmpty() && !deregisterPccValues.isEmpty() && !deregisterGdsValues.isEmpty())
        {
            existingAgencyTMCInfo = [SELECT Id, Account__c, PCC__c, Code__c FROM Agency_Info__c WHERE Account__c NOT IN: deregisterTMCAccountIds AND PCC__c IN: deregisterPccValues AND Code__c IN: deregisterGdsValues AND GDS_Status__c = 'Accepted' AND RecordTypeId =: tmcRTId];
            
            if(existingAgencyTMCInfo.isEmpty())
            {
                for(Agency_Info__c eachTMC : [SELECT Id,Account__c,PCC__c,Code__c,Active__c,GDS_Effective_Date__c,Channel_Effective_Date__c,
                                              GDS_Status__c, Channel_End_Date__c, Last_Inactive_Date__c
                                              FROM Agency_Info__c 
                                              WHERE Account__c NOT IN: deregisterTMCAccountIds AND PCC__c IN: deregisterPccValues AND Code__c IN: deregisterGdsValues  
                                              AND RecordTypeId =: tmcRTId AND Active__c = TRUE AND GDS_Status__c = 'Active'])
                    
                {
                    if (eachTMC != null)
                    {
                        eachTMC.GDS_Status__c = 'Deregistered';
                        eachTMC.Channel_End_Date__c = system.today();
                        toUpdateDeregistered.add(eachTMC);
                    }
                }
            }
        }
        
        if(!toUpdateActive.isEmpty())
            update toUpdateActive;
        
        if(!toUpdateInactive.isEmpty())
            update toUpdateInactive;
        
        if(!toUpdateDeregistered.isEmpty())
            update toUpdateDeregistered;
    }
    
    // Changes ended
}