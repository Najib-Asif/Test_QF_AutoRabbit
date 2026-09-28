/**
 * @author: dattaraj.deshmukh@qantas.com.au
 * @date: 2/11/2023
 * @desc: Class to create recovery records for Exgratia component. 
 * @history
 * 			2/11/2023	-	created 
 */
public without sharing class ExgratiaRecoveryCreator {
	public static final Id RECOVERY_RECORDTYPE_ID = Schema.SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Exgratia_Flight_Pass').getRecordTypeId();
	
	@AuraEnabled
    public static string createRecoveryRecord(String wrapperObjectString, String caseId){
        try {
			Boolean isDuplicate = false;
			system.debug('wrapperObjectString'+wrapperObjectString);
			system.debug('caseId'+caseId);
            ExgratiaFlightPassSearchWrapper wrapperObj = ExgratiaFlightPassSearchWrapper.parseSingleRecord(wrapperObjectString);
			system.debug('wrapperObj'+wrapperObj);
			isDuplicate = isDuplicateRecovery(wrapperObj, caseId);
			system.debug('isDuplicate =='+isDuplicate);
			if(! isDuplicate) {
				createRecovery(wrapperObj, caseId);
			}
            
            return ( isDuplicate == false ? 'Recovery record created successfully!' : 'create recovery record was not created!');
        } catch (Exception e) {
			system.debug(e);
			system.debug(e.getStackTraceString()); 
            throw new AuraHandledException(e.getMessage());
        }
    }

	@testVisible
	private static boolean isDuplicateRecovery(ExgratiaFlightPassSearchWrapper wrapperObj, Id caseId) {

		List<Recovery__c> recoveryRecords = [Select Id, Pax_first_name__c, Pax_last_name__c, FF_ID__c, CorrelationID__c, Case_Number__c
												from Recovery__c
												 Where Case_Number__c =: caseId AND recordTypeId =: RECOVERY_RECORDTYPE_ID];
		Boolean isDuplicate = false;
		if(recoveryRecords != null && !recoveryRecords.isEmpty()) {
			
			for(Recovery__c rec : recoveryRecords) {

				if(String.isNotBlank(rec.Pax_first_name__c) && rec.Pax_first_name__c.equalsIgnoreCase(wrapperObj.Pax_first_name) 
					&& String.isNotBlank(rec.Pax_last_name__c) && rec.Pax_last_name__c.equalsIgnoreCase(wrapperObj.Pax_last_name) && rec.CorrelationID__c.equalsIgnoreCase(wrapperObj.Correlation_ID)) {
						system.debug('rec ='+rec);
						isDuplicate = true;
						break;
				}
			}
		}
		
		return isDuplicate;
		

	}
	@testVisible
	private static void createRecovery(ExgratiaFlightPassSearchWrapper wrapperObj, String caseId) {
		system.debug('wrapperObj'+wrapperObj);
		Recovery__c recovery = new Recovery__c();
		
		recovery.Pax_first_name__c = wrapperObj.Pax_first_name;
		recovery.Pax_last_name__c = wrapperObj.Pax_last_name;
		recovery.PNR__c = wrapperObj.PNR;
		
		recovery.FF_Tier__c = wrapperObj.FF_Tier;
		recovery.Cabin_Class__c = wrapperObj.Cabin_class;
		recovery.Seat_number__c = wrapperObj.Seat_number;
		recovery.Booking_email__c = wrapperObj.Booking_email;
		recovery.Booking_phone_number__c = wrapperObj.Booking_phone_number;
		recovery.Booking_currency__c = wrapperObj.Booking_currency;
		recovery.POS_location__c = wrapperObj.POS_location;
		recovery.Payment_eligibility__c = wrapperObj.Payment_eligibility == 'T' ? true : false;
		recovery.Payment_eligibility_reason__c = wrapperObj.Payment_eligibility_reason ;
		recovery.PNR_remarks_updated_with_eligibility__c = wrapperObj.PNR_remarks_updated_with_eligibility == 'T' ? true : false;
		recovery.PNR_remarks_updated_with_card_issuance__c = wrapperObj.PNR_remarks_updated_with_card_issuance == 'T' ? true : false;
		recovery.Flight__c = wrapperObj.Flight;
		recovery.Flight_date__c = wrapperObj.Flight_date;
		recovery.Flight_IDR__c = wrapperObj.Flight_IDR;
		recovery.Departing_port__c = wrapperObj.Departing_port;
		recovery.ODP__c = wrapperObj.ODP;
		recovery.Disruption__c = wrapperObj.Disruption;
		recovery.Disruption_reason__c = wrapperObj.Disruption_reason;
		recovery.Disruption_duration__c = wrapperObj.Disruption_duration;
		recovery.Flight_elibility__c = wrapperObj.Flight_eligibility  == 'T' ? true : false;
		recovery.Flight_elibility_reason__c = wrapperObj.Flight_eligibility_reason;
		recovery.Issuance_email_address_validation__c	= wrapperObj.Issuance_email_address_validation  == 'T' ? true : false;
		recovery.Issuance_email_address_validation_failur__c = wrapperObj.Issuance_email_address_validation_failure_reason;
		recovery.Issuance_email__c = wrapperObj.Issuance_email;
		recovery.Issuance_phone_number__c = wrapperObj.Issuance_phone_number;
		recovery.Issuance_phone_number_validation__c = wrapperObj.Issuance_phone_number_validation  == 'T' ? true : false;
		recovery.Issuance_phone_number_validation_failure__c = wrapperObj.Issuance_phone_number_validation_failure_reason;
		recovery.Bespoke_exgratia_payment__c = wrapperObj.Bespoke_exgratia_payment == 'T' ? true : false;
		recovery.Issuance_status__c = wrapperObj.Issuance_status;
		recovery.Issuance_failure_reason__c = wrapperObj.Issuance_failure_reason;
		recovery.Issuance_currency__c = wrapperObj.Issuance_currency;
		recovery.Issuance_currency_validation__c = wrapperObj.Issuance_currency_validation == 'T' ? true : false;
		recovery.Issuance_currency_validation_failure_rea__c = wrapperObj.Issuance_currency_validation_failure_reason;
		recovery.SMS_type_sent__c = wrapperObj.SMS_type_sent;
		recovery.SMS_status_code__c = wrapperObj.SMS_status_code;
		recovery.Sequence_No__c = wrapperObj.Sequance_No;
		recovery.Case_Number__c = caseId;
		recovery.RecordTypeId = RECOVERY_RECORDTYPE_ID;
		recovery.CorrelationID__c = wrapperObj.Correlation_ID;
		system.debug('recovery'+recovery);
		insert recovery;
		system.debug('recovery ='+recovery);
		system.debug('recovery Id ='+recovery.id);
		
	}

	
}