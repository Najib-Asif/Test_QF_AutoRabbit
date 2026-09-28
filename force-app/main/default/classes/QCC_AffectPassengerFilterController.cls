public class QCC_AffectPassengerFilterController {
    
    @AuraEnabled 
    public static String fetchEventFailuresValues(String recId){
        List<options> lstFailures = new List<options>();
        try{
            Event__c objEvent = [Select Id, DelayFailureCode__c, Non_Delay_Failure_Code__c from Event__c where Id =: recId ];
            //Add Delay failure to List
            if(String.isNotBlank(objEvent.DelayFailureCode__c) && objEvent.DelayFailureCode__c != Null){
            	lstFailures.add(createOptions(objEvent.DelayFailureCode__c));
            }
            //Add All NON-Delay failure to List
            if(String.isNotBlank(objEvent.Non_Delay_Failure_Code__c) && objEvent.Non_Delay_Failure_Code__c != Null){
                for(String failureVal: objEvent.Non_Delay_Failure_Code__c.split(';')){
                	lstFailures.add(createOptions(failureVal));
                } 
            }
            String failures = Json.serialize(lstFailures);
            return failures;
        }catch(Exception ex){
            
        }
        return null;
    }

    @AuraEnabled
	public static String createReportURL(String recId, String selectVal) {
	      string urler = URL.getSalesforceBaseUrl().toString();
	      system.debug('urler$$$'+urler);
	      return urler;
	}
    public static options createOptions(String failureVal){
    	options optionWrap = new options();
    	optionWrap.label = failureVal;
    	optionWrap.value = failureVal;
        return optionWrap;
    }

    public class options{
    	public String label;
    	public String value;
    }


}