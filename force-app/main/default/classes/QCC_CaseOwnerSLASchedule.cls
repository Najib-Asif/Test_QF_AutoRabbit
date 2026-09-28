/*----------------------------------------------------------------------------------------------------------------------
Author: Praveen Sampath 
Company: Capgemini  
Purpose: Invokes QCC_CaseOwnerSLABatch daily and moves case to SLA Queue
Date:    
************************************************************************************************
History
************************************************************************************************
18-May-2018    Praveen Sampath              Initial Design           
-----------------------------------------------------------------------------------------------------------------------*/
global class QCC_CaseOwnerSLASchedule implements Schedulable {
  
   global void execute(SchedulableContext SC) {
	   	Date yesterday = system.today().adddays(-1);
	   	Integer limitval = 100;
	   	if(String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_SLALimit'))){
	   		limitval = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_SLALimit'));
	   	}
		String query = 'select Id, SLA_Queue__c from Case where Valid_SLA_Queue_Migration__c = true  and Due_Date__c =: yesterday';
		QCC_CaseOwnerSLABatch invokeBatch = new QCC_CaseOwnerSLABatch(query); 
		Database.executeBatch(invokeBatch, limitval);
   }
   
}