/*Unhandled Case Closure from chatbot
Created Date: 30 November 2021
Description: This class is to update the status to closed on cases which are unhandled in chatbot
Developer: Navpreet Kaur
FCRM- 858*/

public with sharing class chatTranscriptEventTriggerHelper 
{
    public static ID QantasFreight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
    
    public static void autocloseFreightUnhandledCases(List<LiveChatTranscriptEvent> listTranscriptevents)
    {
        List<ID> caseListIds=new List<ID>();
        List<ID> listTranscriptsIds=new List<ID>();
        List<Case> listUpdateCases=new List<Case>();
        List<Case> listQueryCases=new List<Case>();
        List<LiveChatTranscriptEvent> listEvents=new List<LiveChatTranscriptEvent>();
        Map<String, LiveChatTranscriptEvent__mdt> eventTypes = LiveChatTranscriptEvent__mdt.getAll();
        
            
        
         
        
        User UID=[select id,name from user where name='Automated Process' limit 1];
       
        
        List<LiveChatTranscript> listLiveChatRelRecs=new List<LiveChatTranscript>();
        Map<Id,List<LiveChatTranscriptEvent>> mapChatEvents;
        
        
        
        if(listTranscriptevents!=null && listTranscriptevents.size()>0)
        {
            
            for(LiveChatTranscriptEvent eachTrans:listTranscriptevents)
            {
                if(eachTrans.LiveChatTranscriptId!=null && eachTrans.type=='LeaveVisitor')
                {
                    listTranscriptsIds.add(eachTrans.LiveChatTranscriptId);
                }
            }        
        }
        
       
        listEvents=[select id,type,agentid,liveChatTranscriptid from LiveChatTranscriptEvent where liveChatTranscriptid IN:listTranscriptsIds];
        listLiveChatRelRecs=[select id, caseid from LiveChatTranscript where Id IN :listTranscriptsIds];
        
        
        if(listLiveChatRelRecs!=null && listLiveChatRelRecs.size()>0)
        {
            for(LiveChatTranscript getRecs:listLiveChatRelRecs)
            {
                if(getRecs.caseid!=null)
                {
                    caseListIds.add(getRecs.caseid);
                }
            } 
        }
        
        
        listQueryCases=[select id,createdbyid,ownerid,status,Origin from case where id IN:caseListIds and recordtypeid=:QantasFreight];
        
        for(LiveChatTranscript eachTransRecs:listLiveChatRelRecs)
        {
            for(LiveChatTranscriptEvent eachTransEvent:listEvents)
            {
                
                
                if(eachTransEvent.LiveChatTranscriptid.equals(eachTransRecs.id))
                {
                    if(mapChatEvents==null)
                    {
                        mapChatEvents=new Map<Id,List<LiveChatTranscriptEvent>>();
                        mapChatEvents.put(eachTransRecs.caseId, new List<LiveChatTranscriptEvent>());
                    }
                    if(mapChatEvents!=null && mapChatEvents.get(eachTransRecs.caseId)!=null)
                    {
                        mapChatEvents.get(eachTransRecs.caseId).add(eachTransEvent);
                    }
                    if(mapChatEvents!=null && !mapChatEvents.containsKey(eachTransRecs.caseId))
                    {
                        mapChatEvents.put(eachTransRecs.caseId,new list<LiveChatTranscriptEvent>());
                        mapChatEvents.get(eachTransRecs.caseId).add(eachTransEvent);
                    }
                }
               
            }
        }
        
       
        if(listEvents!=null && listEvents.size()>0 && mapChatEvents!=null && mapChatEvents.values().size()>0)
        {
            for(Case eachCase:listQueryCases)
            {
                String ownerIds=string.valueof(eachCase.OwnerId);
                
                
                    if(ownerIds.startswith('005') && eachcase.createdbyid.equals(UID.id) && eachCase.origin.contains('Webchat'))
                    {
                       
                        Boolean flag=false;
                        for(LiveChatTranscriptEvent eventRecs:mapChatEvents.get(eachCase.id))
                        {
                            
                            if(eventRecs.AgentId!=null)
                            {
                                
                                flag=true;
                                
                                if(eventTypes.containskey(eventRecs.type))
                                {
                                    
                                    eachCase.Status='closed';
                                    listUpdateCases.add(eachCase);
                                }
                            }  
                        }
                        if(flag==false && eachCase.ownerId.equals(UID.id))
                        {
                            
                            eachCase.Status='closed';
                            listUpdateCases.add(eachCase);
                        }
                    }
                
            }
        }
        
        if(listUpdateCases!=null && listUpdateCases.size()>0)
        {
            
            update listUpdateCases;
        }
        
    }

}