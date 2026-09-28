/**Test Class: batchToMergeDuplicateFFContsTest */
public with sharing class batchToMergeDuplicateFFConts implements Database.Batchable<sObject>, Database.stateful,schedulable  {
    
    public Integer soqlLimit;
    public batchToMergeDuplicateFFConts(){}
    public batchToMergeDuplicateFFConts(Integer intLmt){
        this.soqlLimit=intLmt;
    }
    public Contact contFFMast;
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query;
        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        system.debug('contact record type id'+contactRTID);
        query='SELECT id,email,firstname,lastname,Frequent_Flyer_Number__c,QCC_Last_Activity_Date__c,QCC_Last_Flight_Date__c,Source__c,QCC_TECH_FF_Number_External_Id__c,SSU__c FROM Contact WHERE Frequent_Flyer_Number__c!=null and recordtypeid=:contactRTID order by Frequent_Flyer_Number__c,createddate asc';
       return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<contact> scope)
    {
        try 
        {
            Map<String,Id> ffMasterContMap=new Map<String,Id>();
            Map<Id,List<Id>> masterContDupMap=new Map<Id,List<Id>>();
            Map<Id,contact> mapScopeConts=new Map<Id,Contact>(scope);

            if(scope!=null)
            {
                if(this.contFFMast!=null)
                {
                    ffMasterContMap.put(this.contFFMast.Frequent_Flyer_Number__c,this.contFFMast.id);
                    masterContDupMap.put(this.contFFMast.id,new list<Id>());
                    mapScopeConts.put(this.contFFMast.id,this.contFFMast);
                }
                for(Contact getCont :scope)
                {
                    if(!ffMasterContMap.containskey(getCont.Frequent_Flyer_Number__c))
                    {
                        ffMasterContMap.put(getCont.Frequent_Flyer_Number__c,getCont.id);
                        masterContDupMap.put(getCont.id,new list<Id>());
                       
                        this.contFFMast=mapScopeConts.get(getCont.id);
                    }
                    else 
                    {
                        masterContDupMap.get(ffMasterContMap.get(getCont.Frequent_Flyer_Number__c)).add(getCont.id);  
                    }
                }
                if(!masterContDupMap.isEmpty())
                {
                    for(Id getMasterId: masterContDupMap.keySet())
                    {
                        list<Id> lstDupSetIds=masterContDupMap.get(getMasterId); 
                        while(!lstDupSetIds.isempty())
                        {
                            List<Id> duplList=new List<Id>();
                            List<Contact> dupContLst=new List<Contact>();
                            duplList.add(lstDupSetIds.remove(0));
                            dupContLst.add(mapScopeConts.get(duplList[0]));
                            if(!lstDupSetIds.isempty())
                            {
                                duplList.add(lstDupSetIds.remove(0));
                                dupContLst.add(mapScopeConts.get(duplList[1]));
                            }
                            Map<Id,Contact> getDupMap=mapFieldsValueToMaster(mapScopeConts.get(getMasterId),dupContLst);
                            database.merge(getDupMap.get(getMasterId),duplList);
                        }
                    }
                }
            }

        } catch (Exception ex) 
        {
            system.debug('Duplicates Merge Fields Mapping Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - batchToMergeDuplicateFFConts', 'batchToMergeDuplicateFFConts', 
                            'Execute', '', '', false,'', ex);
        }    
    }
 
    public void finish(Database.BatchableContext bc){
    }
    public void execute(SchedulableContext sc) 
       {
          Database.executeBatch(new batchToMergeDuplicateFFConts());
       } 
    public Map<Id,Contact> mapFieldsValueToMaster(Contact getMaster,List<Contact> listConts)
    {
        Map<Id,Contact> returnMap=new Map<Id,Contact>();
        try {
            
        if(getMaster!=null)
        {
                List<Contact> contList=new List<Contact>();
                for(Contact getCont: listConts)
                {
                    if((getMaster.SSU__c ==false) && (getCont.SSU__c!=false))
                    {
                        getMaster.SSU__c=getCont.SSU__c;
                        
                    }
                    if((getMaster.QCC_TECH_FF_Number_External_Id__c ==null || getMaster.QCC_TECH_FF_Number_External_Id__c =='') && (getCont.QCC_TECH_FF_Number_External_Id__c!=null || getCont.QCC_TECH_FF_Number_External_Id__c!=''))
                    {
                        getMaster.QCC_TECH_FF_Number_External_Id__c=getCont.QCC_TECH_FF_Number_External_Id__c;
                        
                    }
                    if((getMaster.Source__c  ==null || getMaster.Source__c  =='') && (getCont.Source__c !=null || getCont.Source__c !=''))
                    {
                        getMaster.Source__c =getCont.Source__c ;
                        
                    }
                    if((getMaster.QCC_Last_Activity_Date__c==null && getCont.QCC_Last_Activity_Date__c!=null) || ((getMaster.QCC_Last_Activity_Date__c!=null && getCont.QCC_Last_Activity_Date__c!=null) &&
                        (getMaster.QCC_Last_Activity_Date__c < getCont.QCC_Last_Activity_Date__c)))
                    {
                        getMaster.QCC_Last_Activity_Date__c=getCont.QCC_Last_Activity_Date__c;
                    }
                    if( (getMaster.QCC_Last_Flight_Date__c==null && getCont.QCC_Last_Flight_Date__c!=null) || ((getMaster.QCC_Last_Flight_Date__c!=null && getCont.QCC_Last_Flight_Date__c!=null) &&
                    (getMaster.QCC_Last_Flight_Date__c < getCont.QCC_Last_Flight_Date__c)) )
                    {
                        getMaster.QCC_Last_Flight_Date__c =getCont.QCC_Last_Flight_Date__c ;
                    }
                    
                }
                returnMap.put(getMaster.id,getMaster);
        }
        return returnMap;
    } catch (Exception ex) {
        system.debug('Duplicates Merge Fields Mapping Exception###'+ex);
        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Duplicated Merging Field Mapping Failed', 'batchToMergeDuplicateFFConts', 
                            'mapFieldsValueToMaster', '', '', false,'', ex);
    }
    return returnMap;
    }
}