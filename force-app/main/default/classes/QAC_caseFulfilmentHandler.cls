/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose 1 : to create case fulfillment records based on custom metadata - QAC_Fulfillment_Status__mdt
 * Referred from 
    > Trigger : trgTradeSiteResponse
*/

public class QAC_caseFulfilmentHandler {
    
    // used in trgTradeSiteResponse trigger
    public static void autoCreateFulfillmentRecords(list<Case> newCases){
        // During Case Insert
        system.debug('inside MDT for FF');
        list<Case_Fulfilment__c> newFFlist = new list<Case_Fulfilment__c>();
        map<Id,Case> caseMap = new map<Id,Case>();
        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        Id CaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        for(Case eachCase : newCases){
            if(eachCase.Id != null && eachCase.Origin == 'QAC Website' && eachCase.RecordTypeId == CaseRTId){
                if(String.isNotBlank(eachCase.Problem_Type__c)) /* && String.isNotBlank(eachCase.Waiver_Sub_Type__c) */
                {
                    waiverTypes.add(eachCase.Problem_Type__c);
                    waiverSubTypes.add(eachCase.Waiver_Sub_Type__c);
                    caseMap.put(eachCase.Id,eachCase);
                }
            }
        }
        doCaseFulfilmentCreation(caseMap,waiverTypes,waiverSubTypes);
    }
    
    public static void doCaseFulfilmentCreation(Map<Id,Case> myMap, Set<String> myWaiverTypes, Set<String> myWaiverSubTypes){
        
        list<Case_Fulfilment__c> myFFlist = new list<Case_Fulfilment__c>();
        Map<String,QAC_Fulfillment_Status__mdt> allFFMDTmap = new Map<String,QAC_Fulfillment_Status__mdt>();
        Map<String,list<String>> allFFName_SeqStringMap = new Map<String,list<String>>();
        String waivCombo = '', myCaseWaivCombo = '';
        
        if(!myWaiverTypes.isEmpty()) /* && !myWaiverSubTypes.isEmpty() */
        {
            for(QAC_Fulfillment_Status__mdt eachFFMDT : [Select MasterLabel,DeveloperName,Fulfillment_Message__c,
                                                         Fulfillment_Status__c,Waiver_Type__c,Waiver_Sub_Type__c,
                                                         Sequence_1__c,Sequence_2__c,Sequence_3__c,Sequence_4__c,
                                                         Sequence_5__c,Sequence_6__c,Sequence_7__c,Sequence_8__c 
                                                         from QAC_Fulfillment_Status__mdt
                                                         where Waiver_Type__c IN: myWaiverTypes AND Waiver_Sub_Type__c IN: myWaiverSubTypes])
            {
                if(eachFFMDT != null)
                {
                    waivCombo = eachFFMDT.Waiver_Type__c+'_'+eachFFMDT.Waiver_Sub_Type__c;
                    allFFMDTmap.put(waivCombo,eachFFMDT);
                    
                    list<String> seqString = new list<String>{eachFFMDT.Sequence_1__c,eachFFMDT.Sequence_2__c,
                                                                eachFFMDT.Sequence_3__c,eachFFMDT.Sequence_4__c,
                                                                eachFFMDT.Sequence_5__c,eachFFMDT.Sequence_6__c,
                                                                eachFFMDT.Sequence_7__c,eachFFMDT.Sequence_8__c};
                    Integer i=0;
                    while(i < seqString.size()){
                        if(seqString[i] == null)
                            seqString.remove(i);
                        else
                            i++;
                    }
                    system.debug('all seq**'+seqString);
                    allFFName_SeqStringMap.put(waivCombo,seqString);
                }                
            }
            
            if(!allFFMDTmap.isEmpty() && !allFFName_SeqStringMap.isEmpty() && !myMap.isEmpty())
            {
                system.debug('FFMDT map'+allFFMDTmap);
                system.debug('FFMDT Sequence map'+allFFName_SeqStringMap);
                
                for(Case eachCase : myMap.values())
                {
                    myCaseWaivCombo = eachCase.Problem_Type__c+'_'+eachCase.Waiver_Sub_Type__c;
                    if(eachCase.Problem_Type__c == allFFMDTmap.get(myCaseWaivCombo).Waiver_Type__c &&
                       eachCase.Waiver_Sub_Type__c == allFFMDTmap.get(myCaseWaivCombo).Waiver_Sub_Type__c)
                    {
                        for(String eachFFMDT_SeqString : allFFName_SeqStringMap.get(myCaseWaivCombo)){
                            Case_Fulfilment__c newFF = new Case_Fulfilment__c();
                            newFF.Fulfilment_Name__c = eachCase.Problem_Type__c;
                            newFF.Category__c = eachFFMDT_SeqString;
                            newFF.Case__c = eachCase.Id;
                            newFF.Status__c = allFFMDTmap.get(myCaseWaivCombo).Fulfillment_Status__c;
                            newFF.Message__c = allFFMDTmap.get(myCaseWaivCombo).Fulfillment_Message__c;
                            newFF.Timestamp__c = System.now();
                            myFFlist.add(newFF);
                        }
                    }
                }
            }
        }

        if(!myFFlist.isEmpty())
            insert myFFlist;
    }
}