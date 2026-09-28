/**
 * author: dattaraj.deshmukh@qantas.com.au
 * desc: 	Wrapper class to parse JSON response from Ex-gratia API.
 * history:
 * 			1/11/2023	- Dattaraj Deshmukh - Created
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.FieldNamingConventions')
public without sharing class ExgratiaFlightPassSearchWrapper {
    
    @AuraEnabled public Integer Flight_ID;
	@AuraEnabled public String Flight;
	@AuraEnabled public String Flight_date;
	@AuraEnabled public String Flight_IDR;
	@AuraEnabled public String Departing_port;
	@AuraEnabled public String ODP;
	@AuraEnabled public String Disruption;
	@AuraEnabled public String Disruption_reason;
	@AuraEnabled public Integer Disruption_duration;
	@AuraEnabled public String Flight_eligibility;
	@AuraEnabled public String Flight_eligibility_reason;
	@AuraEnabled public Integer Pax_with_PNR_ID;
	@AuraEnabled public String PNR;
	@AuraEnabled public String Travel_plan_ID;
	@AuraEnabled public String Pax_first_name;
	@AuraEnabled public String Pax_last_name;
	@AuraEnabled public String FF_ID;
	@AuraEnabled public String FF_Tier;
	@AuraEnabled public String Cabin_class;
	@AuraEnabled public String Amount_code;
	@AuraEnabled public String Seat_number;
	@AuraEnabled public String Booking_email;
	@AuraEnabled public String Booking_phone_number;
	@AuraEnabled public String Booking_currency;
	@AuraEnabled public String POS_location;
	@AuraEnabled public String Payment_eligibility;
	@AuraEnabled public String Payment_eligibility_reason;
	@AuraEnabled public String PNR_remarks_updated_with_eligibility;
	@AuraEnabled public String PNR_remarks_updated_with_card_issuance;
	@AuraEnabled public Integer ID;
	@AuraEnabled public String Correlation_ID;
	@AuraEnabled public String Issuance_email_address_validation;
	@AuraEnabled public String Issuance_email_address_validation_failure_reason;
	@AuraEnabled public String Issuance_email;
	@AuraEnabled public String Issuance_phone_number;
	@AuraEnabled public String Issuance_phone_number_validation;
	@AuraEnabled public String Issuance_phone_number_validation_failure_reason;
	@AuraEnabled public String Bespoke_exgratia_payment;
	@AuraEnabled public String Issuance_status;
	@AuraEnabled public String Issuance_failure_reason;
	@AuraEnabled public String Amount;
	@AuraEnabled public String Amount_validation;
	@AuraEnabled public String Issuance_currency;
	@AuraEnabled public String Issuance_currency_validation;
	@AuraEnabled public String Issuance_currency_validation_failure_reason;
	@AuraEnabled public String SMS_type_sent;
	@AuraEnabled public String SMS_status_code;
	@AuraEnabled public String Batch_ID;
	@AuraEnabled public String Extraction_datetime;
	@AuraEnabled public String Sequance_No;
	@AuraEnabled public String Voucher_ID;
	@AuraEnabled public String Issue_date_time;
	@AuraEnabled public String Created_date_time;
	@AuraEnabled public String Last_updated_date_time;

	
	public static List<ExgratiaFlightPassSearchWrapper> parse(String json) {
		return (List<ExgratiaFlightPassSearchWrapper>) System.JSON.deserialize(json, List<ExgratiaFlightPassSearchWrapper>.class);
	}

	public static ExgratiaFlightPassSearchWrapper parseSingleRecord(String json) {
		return (ExgratiaFlightPassSearchWrapper) System.JSON.deserialize(json, ExgratiaFlightPassSearchWrapper.class);
	}

}