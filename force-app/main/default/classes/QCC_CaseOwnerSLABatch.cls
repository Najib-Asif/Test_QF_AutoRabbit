/*----------------------------------------------------------------------------------------------------------------------
   Author: Praveen Sampath
   Company: Capgemini
   Purpose: IBatch Apex to  move case to SLA Queue
   Date:
 ************************************************************************************************
   History
 ************************************************************************************************
   18-May-2018    Praveen Sampath              Initial Design
   13-Mar-2021	   Venkat Amiya				Change Prority not queue on SLA breach. Consolidation of Queues. (User Story: QSFR-23).
   -----------------------------------------------------------------------------------------------------------------------*/
global class QCC_CaseOwnerSLABatch implements Database.Batchable<sObject> {

	global final String queryStr;
	global final Date yesterday;
	global Map<String, List<String> > mapError;
	global QCC_CaseOwnerSLABatch(String query){
		queryStr = query;
		yesterday = system.today().adddays(-1);
		mapError = new Map<String, List<String> >();
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('queryStr$$$$$$$$$$$$'+queryStr);
		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<sObject> lstObjs){
		try{
			system.debug('lstCase###########'+lstObjs);
			for(sObject obj: lstObjs) {
				Case objCase = (Case)obj;
				//objCase.OwnerId = objCase.SLA_Queue__c;
				objCase.Priority = 'SLA'; //(User Story: QSFR-23).
			}

			Integer i = 0;
			Database.SaveResult[] lstSaveResult = Database.update(lstObjs, False);
			for(Database.SaveResult sr : lstSaveResult) {
				if (!sr.isSuccess()) {
					Id caseId = lstObjs[i].Id;
					List<String> lstErrorMSG = new List<String>();
					for(Database.Error err : sr.getErrors()) {
						lstErrorMSG.add(err.getMessage());
					}
					mapError.put(caseId, lstErrorMSG);
				}
				i++;
			}
			system.debug('mapError############'+mapError);
		}catch(Exception ex) {
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Owner Update to SLA', 'QCC_CaseOwnerSLABatch',
			                         'QCC_CaseOwnerSLABatch', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
	}

	global void finish(Database.BatchableContext BC){
		List<Log__c> lstLogException = new List<Log__c>();
		Integer i = 0;
		for(String caseId: mapError.keyset()) {
			lstLogException.add(CreateLogs.insertLogBatchRec( 'Log Exception Logs Rec Type', 'QCC - Owner Update to SLA', 'QCC_CaseOwnerSLABatch',
			                                                  'execute', caseId, mapError.get(caseId)));
			i++;
		}
		insert lstLogException;
	}
}