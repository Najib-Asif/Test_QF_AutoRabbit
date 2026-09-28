import { LightningElement, api, track } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class ExGratiaFlightPassList extends LightningElement {
	@api flightpasswrapperlist = [];
	@track paxarray = [];
	@api selectedPax;
	@api recordId;

	columns = [
		{ label: 'First Name', fieldName: 'Pax_first_name' },
		{ label: 'Last Name', fieldName: 'Pax_last_name' },
		{ label: 'FF Number', fieldName: 'FF_ID' },
		{ label: 'Flight Number', fieldName: 'Flight' },
		
	];

	connectedCallback() {
	   
		let listofAllPaxArray = JSON.parse(JSON.stringify(this.flightpasswrapperlist));

		listofAllPaxArray.forEach(val => {
		this.paxarray.push(val);
		});
		console.log('this.paxarray',JSON.stringify(this.paxarray));

	}


	handleRowSelection(event) {
		let selectedpaxdetails = event.detail.selectedRows;
		let selectedPax;

		this.flightpasswrapperlist.forEach( wrapperObj => {
			console.log('wrapperObj',JSON.stringify(wrapperObj));
			console.log('selectedpaxdetails',JSON.stringify(selectedpaxdetails));
			selectedpaxdetails.forEach(selectedRow =>{
				if(selectedRow.Pax_with_PNR_ID === wrapperObj.Pax_with_PNR_ID) {
					selectedPax = wrapperObj;
				}
			});
		})
		console.log('selectedPax',JSON.stringify(selectedPax));

		const attributeChangeEvent = new FlowAttributeChangeEvent(
			'selectedPax',
			selectedPax
		);
		this.dispatchEvent(attributeChangeEvent);

	 }
}