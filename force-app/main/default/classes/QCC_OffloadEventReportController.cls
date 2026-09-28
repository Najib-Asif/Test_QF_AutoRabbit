public class QCC_OffloadEventReportController {
    @AuraEnabled
    public static List<OffloadData> getData(String idx){
        List<OffloadData> data = new List<OffloadData>();
        
        schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Event__c');
        String eventPrefix = sObjType.getDescribe().getKeyPrefix();
        sObjType = Schema.getGlobalDescribe().get('Affected_Passenger__c');
        String passengerPrefix = sObjType.getDescribe().getKeyPrefix();
        
        try{
            String eventId = '';
            if(idx.startsWith(eventPrefix)){
                eventId = idx;
            }else if(idx.startsWith(passengerPrefix)){
                Affected_Passenger__c pass = [select id, event__c from Affected_Passenger__c where id = :idx];
                eventId = pass.event__c;
            }
            
            if(String.isBlank(eventId)){
                return data;
            }
            
            Event__c ev = [select id, NoOfPaxToBeOffloadedFrom_1stClass__c, NoOfPaxToBeOffloadedFrom_Business__c, 
                           NoOfPaxToBeOffloadedFrom_Eco__c, NoOfPaxToBeOffloadedFrom_PremEco__c from event__c where id = :eventId];
            data.add(new OffloadData('First Class', ev.NoOfPaxToBeOffloadedFrom_1stClass__c));
            data.add(new OffloadData('Business', ev.NoOfPaxToBeOffloadedFrom_Business__c));
            data.add(new OffloadData('Premium Economy', ev.NoOfPaxToBeOffloadedFrom_PremEco__c));
            data.add(new OffloadData('Economy', ev.NoOfPaxToBeOffloadedFrom_Eco__c));
            
            for(Affected_Passenger__c pass : [Select id, OffloadRequest__c, event__c, cabin__c from Affected_Passenger__c where event__c = :eventId]){
                for(OffloadData old : data){
                    if(old.cabinClass.startsWithIgnoreCase(pass.Cabin__c)){
                        Switch on pass.OffloadRequest__c{
                            when 'Accepted'{
                                old.accepted++;
                            }
                        }
                    }
                }
            }
            
        }catch(exception ex){
            return data;
        }
        
        return data;
    }
    
    public class OffloadData{
        @AuraEnabled
        public String cabinClass{get;set;}
        @AuraEnabled
        public integer targetNumber{get;set;}
        @AuraEnabled
        public integer accepted{get;set;}
        @AuraEnabled
        public integer pendingNumber{get{
            return targetNumber-accepted;
        }set;}
        
        public OffloadData(String cabin, decimal target){
            cabinClass = cabin;
            targetNumber = target != null ? Integer.valueOf(target) : 0;
            accepted = 0;
            //pendingNumber = 0;
        }
    }
}