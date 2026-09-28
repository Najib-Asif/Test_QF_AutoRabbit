public with sharing class caseTriggerNavigator 
{
    static Map<Id, String> freight_rectypeMap = new Map<Id, String>();
    static Map<Id, String> qcc_rectypeMap = new Map<Id, String>();
    static Map<Id, String> mapServiceRequest=new Map<Id,String>();
    static Map<Id, Case> mapNewAfterRTFilter=new Map<Id,Case>();
    static Map<Id, Case> mapOldAfterRTFilter=new Map<Id,Case>();
    static Map<Id, Case> mapNewAfterRTFilterSer=new Map<Id,Case>();
    static Map<Id, Case> mapOldAfterRTFilterSer=new Map<Id,Case>();
    static List<Case> newMapAfterFilt=new List<Case>();
    //public static Boolean executedAlready = false;

    public caseTriggerNavigator() 
    {
           
      
    }
    //Receives oldmap for events Before and After Update 
    public static void freightInvocationHandler(Map<Id,Case> oldMap,Map<Id,Case> newMap)
    {
        Map<String, Schema.RecordTypeInfo> caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        

      /*Filter by Freight and Service Request record types */
      if(caseRT.isEmpty()==false)
      {
        for(String recType: caseRT.keySet()) 
        {
            system.debug('@@@ the value of record type info'+caseRT.get(recType).getDeveloperName().contains('Service Request'));
         if(caseRT.get(recType).getDeveloperName().contains('Freight'))
         {
            freight_rectypeMap.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
         }
         else if(caseRT.get(recType).getDeveloperName().contains('Service Request'))
         {
            mapServiceRequest.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
         } 
        }
      }
        if(newMap!=null && newMap.isEmpty()==false && oldMap!=null && oldMap.isEmpty()==false)
        {
            for(Id key:newMap.keyset())
            {
                if(freight_rectypeMap.containskey(newMap.get(key).RecordTypeId) && freight_rectypeMap.containskey(oldMap.get(key).RecordTypeId))
                {
                    mapNewAfterRTFilter.put(key,newMap.get(key));
                    mapOldAfterRTFilter.put(key,oldMap.get(key));

                }
                else if(mapServiceRequest.containskey(newMap.get(key).RecordTypeId) &&
                mapServiceRequest.containskey(oldMap.get(key).RecordTypeId))
                {
                    mapNewAfterRTFilterSer.put(key,newMap.get(key));
                    mapOldAfterRTFilterSer.put(key,oldMap.get(key));
                    
                }
            }
            if(mapNewAfterRTFilter!=null && mapNewAfterRTFilter.isEmpty()==false &&
             mapOldAfterRTFilter!=null && mapOldAfterRTFilter.isEmpty()==false)
            {
                Freight_CaseTriggerHandler.autoChangeStatus(mapNewAfterRTFilter.values(),mapOldAfterRTFilter);

                //Invocation without conditions verification
                Freight_CaseTriggerHandler.autoAssignPriorityAsPremiumManualAccounts(mapNewAfterRTFilter.values(),mapOldAfterRTFilter); //FCRM-887
                 
            }  
            
       }
    }
    //Receives only the newMap
    public static void freightInvocationHandler2(List<Case> newCaseList)
    {
        Map<String, Schema.RecordTypeInfo> caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        

      /*Filter by Freight and Service Request record types */
      if(caseRT.isEmpty()==false)
      {
        for(String recType: caseRT.keySet()) 
        {
            system.debug('@@@ the value of record type info'+caseRT.get(recType).getDeveloperName().contains('Service Request'));
         if(caseRT.get(recType).getDeveloperName().contains('Freight'))
         {
            freight_rectypeMap.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
         }
         else if(caseRT.get(recType).getDeveloperName().contains('Service Request'))
         {
            mapServiceRequest.put(caseRT.get(recType).getRecordTypeId(),caseRT.get(recType).getDeveloperName());
         } 
        }
      }
        system.debug('@@@freightInvocationHandler2 is called from the navigator');
        if(newCaseList!=null && newCaseList.size()>0)
        {
            system.debug('@@@newMap is NOT EMPTY in the navigator'+newCaseList);
            system.debug('@@@freight_rectypeMap keyset'+freight_rectypeMap.keyset());
            for(Case key:newCaseList)
            {
                system.debug('@@@the value of key'+key.RecordTypeId);
                
                if(freight_rectypeMap.containskey(key.RecordTypeId))
                {
                    if((key.Freight_WebToCaseType__c != '' && key.Origin == 'Web')
                    ||
                    (key.Freight_AWB_Number__c!=null && !key.Freight_AWB_Number__c.startswith('081')))
                    {
                        
                        Freight_CaseTriggerHandler.assignRecordTypeWebToCase(newCaseList); 
                    }
                    if(key.origin=='Web' && key.SuppliedEmail!=null)
                    {
                        
                        Freight_CaseTriggerHandler.freightAssociateAcctsWeb2Case(newCaseList); 
                    }
                    newMapAfterFilt.add(key);
                    
                }
            }
            if(newMapAfterFilt!=null && newMapAfterFilt.size()>0)
                {
                
                    system.debug('invocation in newMapAfterFilt'+newMapAfterFilt);
                    //Invocation without conditions verification
                    Freight_CaseTriggerHandler.autoAssignCaseToCSUQueue(newMapAfterFilt);
                    Freight_CaseTriggerHandler.autoAssignPriorityAsPremium(newMapAfterFilt);
                    Freight_CaseTriggerHandler.assignUrgentPriorityForCasesWithHotWords(newMapAfterFilt);
                    Freight_CaseTriggerHandler.freightMaskCreditCard(newMapAfterFilt);
                    Freight_CaseTriggerHandler.autoCloseAuotmaticReplayCases(newMapAfterFilt);
                }
            

        }
    }
}