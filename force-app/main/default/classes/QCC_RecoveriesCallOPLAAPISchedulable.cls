/*-----------------------------------------------------------------------------------------
    Author: Nga Do
	Company: Capgemini
	Description: initial schedule job to call QCC_RecoveriesCallOPLAAPIBatchable
	Inputs: 
	Test Class: QCC_RecoveriesCallOPLAAPISchedulableTest
	***************************************************************************************
	History:
	***************************************************************************************
	15-May-2018
 ------------------------------------------------------------------------------------------*/
global class QCC_RecoveriesCallOPLAAPISchedulable implements Schedulable {
	

	global void execute(SchedulableContext sc) {
		QCC_RecoveriesCallOPLAAPIBatchable callOPLAAPIBatch = new QCC_RecoveriesCallOPLAAPIBatchable();
		Database.executebatch(callOPLAAPIBatch, 100);
	}


}