public class clsAquireRegistrationsHelper{
    
    public static boolean isRunUpdateRelatedAquireMembers = FALSE;
    
    public static void updateRelatedAquireMembers(map<Id,Product_Registration__c> productsMap){
        if(!isRunUpdateRelatedAquireMembers){
            
            map<String,Id> recordTypeMap = getRecordTypes('Product_Registration__c');
            Id aquireRecordTypeId = recordTypeMap.get('Aquire_Account');
            Id amexRecTypeId = recordTypeMap.get('AMEX_Account'); 
            
            map<Id,Associated_Person__c> memberMap = new map<Id,Associated_Person__c>();
            map<Id,set<Id>> acountPregMap = new map<Id,Set<Id>>();
            list<Associated_Person__c> membersToUpdate = new list<Associated_Person__c>();
            
            //get Accounts of AquireProducts
            for(Product_Registration__c aquireReg : productsMap.values()){
                if(aquireReg.recordTypeid == aquireRecordTypeId){
                    if(acountPregMap.get(aquireReg.Account__c) == null){
                        acountPregMap.put(aquireReg.Account__c,new set<Id>());
                    }
                    acountPregMap.get(aquireReg.Account__c).add(aquireReg.Id);
                }
            }
            if(!acountPregMap.isEmpty()){
                system.debug('Accounts having Aquire:'+acountPregMap);
                memberMap = new map<Id,Associated_Person__c>([select id,Active_Aquire_Record__c,Account__c from Associated_Person__c where Account__c in:acountPregMap.keyset()]);
            }
            
            //update memebers of the AquireProducts
            if(memberMap != null && !memberMap.values().isEmpty()){
                for(Associated_Person__c aqMember :memberMap.values()){
                    boolean isActiveAquire = false;
                    for(Id aquireRegId : acountPregMap.get(aqMember.Account__c)){
                        system.debug('Inloop:'+productsMap.get(aquireRegId).recordTypeId +'|'+ aquireRecordTypeId);
                        if(productsMap.get(aquireRegId).recordTypeId == aquireRecordTypeId){
                            if(productsMap.get(aquireRegId).Stage_Status__c == 'Active'){
                                isActiveAquire = true;
                            }
                        }        
                    }
                    system.debug('isActiveAquire:'+isActiveAquire);
                    if(aqMember.Active_Aquire_Record__c != isActiveAquire ){
                        aqMember.Active_Aquire_Record__c = isActiveAquire;
                        membersToUpdate.add(aqMember);        
                    }
                    system.debug(membersToUpdate);
                }
                if(!membersToUpdate.isEmpty()){
                    system.debug(membersToUpdate);
                    update membersToUpdate;
                }
            }
        }
        
        isRunUpdateRelatedAquireMembers = true;
    }
    
    /*purpose: util methods record type ids
    parameters: object name
    return: map of name and recordtype id. 
    */
    public static map<String,Id> getRecordTypes(string sObjectName){
        List<RecordType> recordTypes = [Select DeveloperName, Id From RecordType where sObjectType=:sObjectName and isActive=true];
        Map<String,Id> sObjRecordTypes = new Map<String,Id>();
        
        for(RecordType rt: recordTypes){
            sObjRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        return sObjRecordTypes;  
    }     
}