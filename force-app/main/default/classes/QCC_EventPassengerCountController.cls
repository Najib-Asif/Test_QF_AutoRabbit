public class QCC_EventPassengerCountController {
	@AuraEnabled
    public static List<passengerData> getData(String idx){
        List<passengerData> data = new List<passengerData>();
        
        //schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Event__c');
        schema.sObjectType sObjType = Event__c.sObjectType;
        String eventPrefix = sObjType.getDescribe().getKeyPrefix();
        //sObjType = Schema.getGlobalDescribe().get('Affected_Passenger__c');
        sObjType = Affected_Passenger__c.sObjectType;
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
            data.add(new passengerData('01. Platinum One'));
            data.add(new passengerData('02. Chairman\'s Lounge Platinum One'));
            data.add(new passengerData('03. Platinum'));
            data.add(new passengerData('04. Chairman\'s Lounge'));
            data.add(new passengerData('05. Lifetime Gold'));
            data.add(new passengerData('06. Lifetime Silver'));
            data.add(new passengerData('07. Gold'));
            data.add(new passengerData('08. Silver'));
            data.add(new passengerData('09. Bronze'));
            data.add(new passengerData('10. Non-Tiered'));
            
            for(Affected_Passenger__c pass : [Select id, TravelledCabin__c, cabin__c, FrequentFlyerTier__c, TECH_Tier_Sortable__c from Affected_Passenger__c where event__c = :eventId]){
                for(passengerData pD : data){
                    System.debug(pD);
                    System.debug(pass.TECH_Tier_Sortable__c);
                    if(pD.tier.containsIgnoreCase(pass.TECH_Tier_Sortable__c)){
                        if(('First Class').containsIgnoreCase(pass.Cabin__c)){
                            pD.firstClass++;
                        } else if(('Business').containsIgnoreCase(pass.Cabin__c)){
                            pD.business++;
                        } else if(('Premium Economy').containsIgnoreCase(pass.Cabin__c)){
                            pD.preEco++;
                        } else if(('Economy').containsIgnoreCase(pass.Cabin__c)){
                            pD.eco++;
                        }
                        continue;
                    }
                }
            }
            
        }catch(exception ex){
            return data;
        }
        
        return data;
    }
    
    public class passengerData{
        @AuraEnabled
        public String tier{get;set;}
        @AuraEnabled
        public integer firstClass{get;set;}
        @AuraEnabled
        public integer business{get;set;}
        @AuraEnabled
        public integer preEco{get;set;}
        @AuraEnabled
        public integer eco{get;set;}
        
        public passengerData(String iTier){
            this.tier = iTier; 
            firstClass = 0;
            business = 0;
            preEco = 0;
            eco = 0;
        }
    }
}