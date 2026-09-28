/*
Test Coverage is achieved by using the TestclsAccountEligibitliyHelper class

Date            Author                  Change
17/03/2015      Kiran Kulkarni          Initial Development 

*/
public class clsAccountEligibilityHelper{
    
    public static boolean hasRunUpdateAmexDetailsOnAquire = false;
    
    /*purpose:  Get all the amex details to update on corresponding aquire record
    parameters: trigger.new list of product registrations
    return: none. 
    */
    public static void updateAmexDetailsOnAquire(list<Product_Registration__c> amexList){
        
        Map<Id,Account> accountMap = new map<Id,Account>();
        list<Product_Registration__c> aquireList = new list<Product_Registration__c>();
        set<Id> accountIdSet = new set<Id>();
        
        map<String,Id> recordTypeMap = getRecordTypes('Product_Registration__c');
        Id aquireRecTypeId = recordTypeMap.get('Aquire_Account');
        Id amexRecTypeId = recordTypeMap.get('AMEX_Account'); 
        if(!hasRunUpdateAmexDetailsOnAquire){
            if(!amexList.isEmpty()){
                for(Product_Registration__c amexRec: amexList){
                    if(amexRec.RecordTypeId == amexRecTypeId ){
                        accountIdSet.add(amexRec.Account__c);
                    } 
                }
                
                accountMap = new map<Id,Account>([select Id,(select id,MCA_Number__c from Product_Registrations__r where recordTypeId =:aquireRecTypeId  limit 1) from Account where id in: accountIdSet]);
                
                if(!accountMap.isEmpty()){
                    for(Product_Registration__c amexRec: amexList){
                        if(amexRec.RecordTypeId == amexRecTypeId && accountMap.get(amexRec.Account__c) != null){
                            Product_Registration__c aquireRec = accountMap.get(amexRec.Account__c).Product_Registrations__r;
                            //aquireRec.AMEX_Choice__c  = amexRec.Customer_s_Requested_Choice__c;
                            aquireRec.MCA_Number__c = amexRec.MCA_Number__c;
                            aquireList.add(aquireRec);
                        } 
                    }                
                }
                
                if(!aquireList.isEmpty()){
                    update aquireList;
                }            
            }
        }
        hasRunUpdateAmexDetailsOnAquire = true;
        
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