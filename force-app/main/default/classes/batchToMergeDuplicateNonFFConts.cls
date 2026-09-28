public with sharing class batchToMergeDuplicateNonFFConts implements Database.Batchable<sObject>, Database.stateful, schedulable {
    
   public Contact contNonFFMast;
   public Integer soqlLimit;

    public batchToMergeDuplicateNonFFConts(){}
    public batchToMergeDuplicateNonFFConts(Integer intLmt){
        this.soqlLimit=intLmt;
    }
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query;
        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        String techRecName='Individual Contact';
        system.debug('contact record type id'+contactRTID);
        query='SELECT id,email,firstname,lastname,Phone,Frequent_Flyer_Number__c,QCC_Last_Activity_Date__c,QCC_Last_Flight_Date__c,Source__c,QCC_TECH_FF_Number_External_Id__c,SSU__c FROM Contact WHERE recordtypeid=:contactRTID and firstname!=null and lastname!=null and email!=null and phone!=null and QCC_TECH_RecordType__c=:techRecName order by firstname,lastname,email,phone,createddate,Frequent_Flyer_Number__c asc limit '+soqlLimit;
       return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<contact> scope)
    {
        try 
        {
            Map<String,Id> nonFFMasterContMap=new Map<String,Id>();
            Map<Id,List<Id>> masterContDupMap=new Map<Id,List<Id>>();
            Map<Id,contact> mapScopeConts=new Map<Id,Contact>(scope);

            System.debug('>>>In the execute');
            if(scope!=null)
            {
                if(this.contNonFFMast!=null)
                {
                    String uniquePhone=this.contNonFFMast.Phone.deleteWhitespace().trim().right(9);
                    String key = this.contNonFFMast.FirstName.deleteWhitespace().trim() +this.contNonFFMast.LastName.deleteWhitespace().trim() + uniquePhone +this.contNonFFMast.Email;
                    nonFFMasterContMap.put(key,this.contNonFFMast.id);
                    masterContDupMap.put(this.contNonFFMast.id,new list<Id>());
                    mapScopeConts.put(this.contNonFFMast.id,this.contNonFFMast);
                }
                for(Contact getCont :scope)
                {
                    
                    String uniquePhone=getCont.Phone.deleteWhitespace().trim().right(9);
                    String key = getCont.FirstName.deleteWhitespace().trim() + getCont.LastName.deleteWhitespace().trim() + uniquePhone + getCont.Email;
                    system.debug('>>> here is the Key'+key);
                    //MasterContactMap check if it has NOT matched the current contacts key
                    if(!nonFFMasterContMap.containskey(key))
                    {
                        //Add the Master Contacts unique Key value and the master contacts ID
                        nonFFMasterContMap.put(key,getCont.id);
                        //Add the Master contacts ID and instantiate the list of duplicate contacts IDs
                        masterContDupMap.put(getCont.id,new list<Id>());
                        //Add master contact to a contact variable
                        this.contNonFFMast=mapScopeConts.get(getCont.id);
                    }
                    else //If nonFFMasterContMap already has the unique Key but needs to add more duplicate contacts
                    {
                        masterContDupMap.get(nonFFMasterContMap.get(key)).add(getCont.id);  
                    }
                }
                System.debug('>>>print the mapkeys masterContDupMap'+masterContDupMap.keySet());
                System.debug('>>>print the mapValue masterContDupMap'+masterContDupMap.values());
                System.debug('>>>print the mapValue masterContDupMap value length'+masterContDupMap.values().size());

                //Assign
                for(Contact getCont :scope)
                {
                    if(masterContDupMap.get(getCont.id)!=null)
                    {
                        for(Id getId: masterContDupMap.get(getCont.id))
                        {
                            if(mapScopeConts.get(getId).Frequent_Flyer_Number__c!=null)
                            {
                                List<Id> getResturnedIds=masterContDupMap.remove(getCont.id);
                                system.debug('>>> the values of deleted key'+getResturnedIds);
                                getResturnedIds.remove(getResturnedIds.indexof(getId));
                                getResturnedIds.add(getCont.id);
                                masterContDupMap.put(getId,getResturnedIds);
                                system.debug('>>> here is the map key'+getId);
                                system.debug('>>> here is the map values'+masterContDupMap.get(getId));
                                system.debug('>>> here is the map values size'+masterContDupMap.get(getId).size());
                                break;
                            }
                        }
                    }
                   
                }
                System.debug('>>>print the mapkeys masterContDupMap after resorting'+masterContDupMap.keySet());
                System.debug('>>>print the mapValue masterContDupMap after resorting'+masterContDupMap.values());
                System.debug('>>>print the mapValue masterContDupMap value length after resorting'+masterContDupMap.values().size());


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
      Database.executeBatch(new batchToMergeDuplicateNonFFConts(soqlLimit));
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
        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Duplicated Merging Field Mapping Failed', 'batchToMergeDuplicateNonFFConts', 
                            'mapFieldsValueToMaster', '', '', false,'', ex);
    }
    return returnMap;
    }
}