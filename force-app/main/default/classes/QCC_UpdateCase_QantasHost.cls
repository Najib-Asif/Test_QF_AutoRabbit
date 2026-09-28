/*********************************************************************************
Name         : QCC_UpdateCase_QantasHost
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 28 August 2019
Usages       : This will update Qantas Host field in Case object
*********************************************************************************/
public class QCC_UpdateCase_QantasHost{
    /** 
    This method will get reference number from case description then search in Qantas Host object via name equals reference number
    and update the Qantas Host field in Case object with Qantas host ID
    **/
	@InvocableMethod
    public static void updateHostNumber(List<Id> caseIds){
		List<case> caseRecords = new List<case>([SELECT id,description, contactId FROM Case WHERE id IN :caseIds]);
		Map<Id,Case> caseMap = new Map<id,Case>();
		Map<String,id> referenceMap = new Map<String, id>();
        System.debug('>>>QCC_UpdateCase_QantasHost updateHostNumber');
        
        try{
            for( case caseRecord : caseRecords){
                caseMap.put(caseRecord.id,caseRecord);

                //refrence number is in case description, no need to parse description if null
                if (caseRecord.Description != null ) {
                    //get the reference number from case description
                    String referenceNumber =   extractReferenceNumber(caseRecord.Description);
                    
                    if(referenceNumber != null ){
                        referenceMap.put(referenceNumber, caseRecord.id);
                    }
                }
            }
            
            List<qcc_first_host__c> firstHostRecords = new List<qcc_first_host__c>([SELECT id,name, QCC_First_Host_Contact__c FROM qcc_first_host__c WHERE name in :referenceMap.keySet()]);
            System.debug(firstHostRecords);
            List<Case> caseToUpdate = new List<Case>();
            
            for(qcc_first_host__c firstHostRecord : firstHostRecords ){
                //check if reference number exist in case and if contact in first host and case is the same
                if(caseMap.containsKey(referenceMap.get(firstHostRecord.name))){
                    Case newCase = caseMap.get(referenceMap.get(firstHostRecord.name));
                    newCase.Qantas_Host__c = firstHostRecord.id;
                    System.debug('>>>QCC_First_Host_Contact__c: '+ firstHostRecord.QCC_First_Host_Contact__c);
                    newCase.Due_Date__c = System.today() + 2;
                    newCase.Type = 'Platinum One Email Enquiries';
                    if(null != firstHostRecord.QCC_First_Host_Contact__c){
                        newCase.ContactId = firstHostRecord.QCC_First_Host_Contact__c;
                    }
                    
                    caseToUpdate.add(newCase);
                }
            }
            
            update(caseToUpdate);
        }
        catch(Exception ex){
            System.debug('QCC_UpdateCase_QantasHost.updateHostNumber: ' + ex.getMessage() );
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Update Qantas Host Case', 'QCC_UpdateCase_QantasHost', 'updateHostNumber', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
    }
    
    
    public static String extractReferenceNumber(String caseDescription){
        //capture FH and any consecutive number after `Ref#` e.g(FH123456)
        String regex = 'Ref#(FH\\d+)';
        String referenceNumber;
        Pattern pat = Pattern.compile(regex);
        Matcher matcher = pat.matcher(caseDescription);
        Boolean matches = matcher.find();
        
        //check if pattern match in case description
        if(matches){
            referenceNumber = matcher.group(1);
        }else{
            referenceNumber = null;
        }
       
        return referenceNumber;
       	
    }
  
}