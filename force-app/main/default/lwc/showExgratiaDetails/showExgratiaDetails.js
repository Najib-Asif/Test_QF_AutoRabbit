/**
 * author: dattaraj.deshmukh@qantas.com.au
 * desc: 	LWC component to show details for Exgratia Flight Pass search functionality.
 * 			This componenet is accessed from Flow and all the communications are passed from Flow.
 * history:
 * 			1/11/2023	- Dattaraj Deshmukh - Created
 */
import { LightningElement, api } from 'lwc';
import createRecoveryRecord from "@salesforce/apex/ExgratiaRecoveryCreator.createRecoveryRecord";


/**
 * JSON field keys.
 * Storing keys in array is required to maintain the order of display.
 * By default, JSON sorts keys alphabetically. To overcome this, keys are stored in key arrays 
 * and their index is used to sort the JSON arrays.
 */

const paxWithPnrEligibilityFields = ['PNR','Pax_first_name','Pax_last_name','Disruption_duration','Disruption',
'Disruption_reason', 'Booking_email', 'Flight_eligibility', 'Flight','Flight_date', 'Flight_eligibility_reason', 
'Flight_IDR','Departing_port','ODP', 'FF_ID','FF_Tier','Cabin_class','Seat_number',,'Booking_phone_number','Booking_currency',
'POS_location', 'PNR_remarks_updated_with_card_issuance'];

const flightPassDetailsFields = ['Issuance_status','Payment_eligibility','Payment_eligibility_reason','Amount', 'Issuance_currency',
'Voucher_ID', 'Issue_date_time','Issuance_email', 'Issuance_email_address_validation','Issuance_email_address_validation_failure_reason',
'Issuance_phone_number','Issuance_phone_number_validation',
'Issuance_phone_number_validation_failure_reason','Bespoke_exgratia_payment',
'Issuance_failure_reason','Issuance_currency_validation','Issuance_currency_validation_failure_reason',
'SMS_type_sent','SMS_status_code','Sequance_No'];

const dataLastUpdatesFields = ['Created_date_time','Last_updated_date_time'];


//booleanKeyFields array is used to transform the T/F values to 'Yes/No'.
const booleanKeyFields = ['Payment_eligibility', 'PNR_remarks_updated_with_eligibility','PNR_remarks_updated_with_card_issuance',
'Issuance_email_address_validation', 'Issuance_phone_number_validation', 'Bespoke_exgratia_payment', 'Issuance_currency_validation',
'Flight_eligibility','Amount_validation'];

export default class ShowExgratiaDetails extends LightningElement {
	paxDetailsWrapper = [];
	flightPassDetailsWrapper = [];
	flightDetailsWrapper = [];
	dataLastUpdatesWrapper = [];
	
	//@api values are passed from a Flow
	@api selectedWrapper;
	@api recordId;
	 
	connectedCallback() {
	   
		for(let key in this.selectedWrapper){
			console.log('selectedWrapper:'+this.selectedWrapper);
			
			if(paxWithPnrEligibilityFields.indexOf(key) != -1) {
				let keyLabel = key.replaceAll('_',' ');
				let fieldValue = this.selectedWrapper[key];

				if(key === 'Disruption_duration') {
					fieldValue = this.convertToMinutes(fieldValue);
				}
				let keyValue = booleanKeyFields.indexOf(key) != -1 ? (fieldValue === 'T' ? 'Yes' : 'No') :  fieldValue;
				//let boldClass = (key === 'Pax_first_name') ? 'slds-text-title_bold' : '';
				this.paxDetailsWrapper = [...this.paxDetailsWrapper, {  labelIndex : paxWithPnrEligibilityFields.indexOf(key), key : keyLabel, value : keyValue } ];
			}

			if(flightPassDetailsFields.indexOf(key) != -1) {
				let keyLabel = key.replaceAll('_',' ');
				let fieldValue = this.selectedWrapper[key];
				let keyValue = booleanKeyFields.indexOf(key) != -1 ? (fieldValue === 'T' ? 'Yes' : 'No') :  fieldValue;

				this.flightPassDetailsWrapper = [...this.flightPassDetailsWrapper, { labelIndex : flightPassDetailsFields.indexOf(key), key : keyLabel, value : keyValue } ];
			}

			// if(flightDetailsFields.indexOf(key) != -1) {
			// 	let keyLabel = key.replaceAll('_',' ');
			// 	let fieldValue = this.selectedWrapper[key];
			// 	if(key === 'Disruption_duration') {
			// 		fieldValue = this.convertToMinutes(fieldValue);
			// 	}
			// 	let keyValue = booleanKeyFields.indexOf(key) != -1 ? (fieldValue === 'T' ? 'Yes' : 'No') :  fieldValue;

			// 	this.flightDetailsWrapper = [...this.flightDetailsWrapper, { labelIndex : flightDetailsFields.indexOf(key), key : keyLabel, value : keyValue} ];
			// }

			if(dataLastUpdatesFields.indexOf(key) != -1) {
				let keyLabel = key.replaceAll('_',' ');
				let fieldValue = this.selectedWrapper[key];
				let keyValue = booleanKeyFields.indexOf(key) != -1 ? (fieldValue === 'T' ? 'Yes' : 'No') :  fieldValue;

				this.dataLastUpdatesWrapper = [...this.dataLastUpdatesWrapper, { labelIndex : dataLastUpdatesFields.indexOf(key), key : keyLabel, value : keyValue } ];
			}
		}

		//sort JSON arrays by labelIndex. This helps in maintaining the order of field labels on the screen.
		this.paxDetailsWrapper = this.paxDetailsWrapper.sort((a, b) => { if (a.labelIndex < b.labelIndex) { return -1; }}); 
		this.flightPassDetailsWrapper = this.flightPassDetailsWrapper.sort((a, b) => { if (a.labelIndex < b.labelIndex) { return -1; }});
		this.flightDetailsWrapper = this.flightDetailsWrapper.sort((a, b) => { if (a.labelIndex < b.labelIndex) { return -1; }});
		
		let wrapperClone = Object.assign({}, this.selectedWrapper);


		this.create_recovery(wrapperClone);
		//this.selectedWrapper = {};
		
	}

	//Exgratia API always send minutes. This method to convert minutes into hours and minutes string.
	convertToMinutes(durationInMins) {
		return ( Math.floor(durationInMins/60) + ' Hrs '+ (durationInMins - ( (Math.floor(durationInMins/60) * 60)  )) + ' Minutes ');
	}

	//create recovery records for a each passenger when their details are accessed!
	create_recovery(row) {
		console.log('create_recovery');
		console.log('Case Id'+this.recordId);
		createRecoveryRecord({ wrapperObjectString: JSON.stringify(row), caseId : this.recordId })
		.then((result) => {
			this.error = undefined;
			console.log(result);
		})
		.catch((error) => {
			this.error = error;
			console.log('error:'+error);
			console.log(error);
		});
	}

}