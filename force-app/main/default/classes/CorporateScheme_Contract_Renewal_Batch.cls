/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   Batch Class to Remap the new Contract when old Contract expies
Inputs:        
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
global class CorporateScheme_Contract_Renewal_Batch implements Database.Batchable<sObject>, Database.Stateful{
	
	String batchQuery;
    global Map<String, List<String>> mapError;
    
	global CorporateScheme_Contract_Renewal_Batch(String query) {
		batchQuery = query;
		mapError = new Map<String, List<String>>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('query111111111111111####'+batchQuery);
		return Database.getQueryLocator(batchQuery);
	}

   	global void execute(Database.BatchableContext BC, List<Contract__c> lstContract) {
    	try{
	   		List<Asset> lstUpdateAsset = new List<Asset>();
	   		Map<Id, Id> mapOldandNewContract = new Map<Id, Id>();
	   		String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
	        Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
	        Map<String, Id> mapEndContract = new Map<String, Id>();
	        Set<Id> setAccId = new Set<Id>();

			if(lstContract != Null && lstContract.size()>0){
				for(Contract__c objContract: lstContract){
					
					if(objContract.Contract_End_Date__c == System.today().addDays(-1)){
						mapEndContract.put(objContract.Account__c, objContract.Id);
						setAccId.add(objContract.Account__c);
					}
				}

				for(Contract__c objContract: [Select Id, PreviousContract__c, Type__c,  Contract_Start_Date__c, 
											  Contract_End_Date__c, Account__c  from Contract__c where 
											  Contract_Start_Date__c = TODAY and Status__c ='Signed by Customer' and 
											  Account__c IN: setAccId])
				{
					if(mapEndContract.containskey(objContract.Account__c)){
						mapOldandNewContract.put(mapEndContract.get(objContract.Account__c),objContract.Id);
					}
				}
			}

			system.debug('mapOldandNewContract#########'+mapOldandNewContract);
			
			for(Asset objCorpAsset: [Select Id, Contract__c, Override_Fees_Calculation__c from Asset where RecordtypeId =:corpSchemeRecTypeId and
									  Contract__c IN: mapOldandNewContract.keyset()  and Status != 'Inactive'])
			{
				if(mapOldandNewContract.containskey(objCorpAsset.Contract__c)){
					objCorpAsset.Contract__c = mapOldandNewContract.get(objCorpAsset.Contract__c);
					objCorpAsset.Override_Fees_Calculation__c = false;
				}
				lstUpdateAsset.add(objCorpAsset);
			}
			system.debug('lstUpdateAsset#########'+lstUpdateAsset);

			Integer i = 0, j =0;
			Database.SaveResult[] lstSaveResult = Database.update(lstUpdateAsset, False);
			for(Database.SaveResult sr : lstSaveResult){ 
				if (!sr.isSuccess()) { 
		    		Id assetId = lstUpdateAsset[i].Id;
			        List<String> lstErrorMSG = new List<String>();
	    			for(Database.Error err : sr.getErrors()){
	    				lstErrorMSG.add(err.getMessage());
	    			}
	    			mapError.put(assetId, lstErrorMSG);
			    }
			    i++;
			}
			system.debug('mapError############'+mapError);

		}catch(Exception ex){
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Loyalty Batches', 'CorporateScheme_Contract_Renewal_Batch', 
                                     'execute', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('mapError############'+mapError);

		//GenericUtils.sendEmailonBatchFinish(BC);
		List<Log__c> lstLogException = new List<Log__c>();
		Integer i = 0;
		for(String assetId: mapError.keyset()){
    		lstLogException.add(CreateLogs.insertLogBatchRec( 'Log Exception Logs Rec Type', 'Loyalty Batches', 'CorporateScheme_Contract_Renewal_Batch', 
                                     'execute', assetId, mapError.get(assetId)));
    		i++;
    	}
		insert lstLogException;
		
		// Add batch job calling logic in Finish method
		String schemeQuery = 'Select Id, RecordtypeId, Move_to_Public_Scheme__c from Asset where Scheme_End_Date_f__c = YESTERDAY and Status != \'Inactive\'';
		CorporateScheme_ContractEnd_Batch batchSchemeEnd = new CorporateScheme_ContractEnd_Batch(schemeQuery, mapError.keyset()); 
		database.executebatch(batchSchemeEnd);
	}
	
}