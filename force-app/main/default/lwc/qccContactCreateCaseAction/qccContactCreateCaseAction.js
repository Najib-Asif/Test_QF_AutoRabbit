import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
// import { CloseActionScreenEvent } from 'lightning/actions';
import getContactDetails from '@salesforce/apex/QCC_FrequentFlyerProfileDetails.getContactDetails';
import userHasCustomPermission from '@salesforce/apex/QCC_CustomerDetailController.userHasCustomPermission';

export default class QccContactCreateCaseAction extends LightningElement {
    flowApiName = "QCC_Create_Case"; 
    @track contactResult;

    
    @track caseDetails;

    hasPermission = false;



    recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.checkUserPermission().then(()=>{
                if(this.recordId && this.hasPermission){
                    this.fetchContactDetails().then(()=>{
                        this.populateCaseDetails();
                    }).catch(e => {
                        console.error('Error fetching contact details:', e);
                        this.errorMessage = 'There was a problem finding a contact record. Please refresh the screen and try again.';
                    });
                }
            })
        } 
    }

    async checkUserPermission() {
        try {
            const customPermission = 'QCC_View_Case_Creation_Flow';
            this.hasPermission = await userHasCustomPermission({customPermission});
        } catch (error) {
            console.error('Error checking custom permission:', error);
            this.hasPermission = false;
        }
    }

    async fetchContactDetails(){
        try {
            console.log('recordID fetchContactDetails###########', this.recordId);
            this.contactResult = await getContactDetails({ recordId: this.recordId });
        } catch (error) {
            console.error('Error fetching contact details:', error);
            this.errorMessage = 'There was a problem finding a contact record. Please refresh the screen and try again.';
        }
    }

    populateCaseDetails(){
        this.caseDetails = {
            "sobjectType":"Case", 
            "contactId" : this.recordId,//contact id
            "Booking_PNR__c": "",
            "Contact_Email__c": this.contactResult.email,
            "Contact_Phone__c": this.contactResult.phone,
            "First_Name__c": this.contactResult.firstName,
            "Last_Name__c": this.contactResult.lastName,
            "Street__c": this.contactResult.street,//line one + line two 
            "Suburb__c": this.contactResult.suburb, //suburb 
            "Post_Code__c": this.contactResult.postcode, // post
            "State__c": this.contactResult.state,
            "Country__c": this.contactResult.countryName,
        };
    }


    get flowInputVariables () {
        return [
            { name: "contactId", type: "String", value: this.recordId },
            { name: "Input_Case_Details", type: "SObject", value: this.caseDetails }
        ];
    }
    
    
    
    // handleCancel(){
    //     this.dispatchEvent(new CloseActionScreenEvent());
    // }

    // do something when flow status changed
	handleFlowStatusChange(event) {
		console.log("flow status", event.detail.status);
		if (event.detail.status === "FINISHED") {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Success",
					message: "Flow Finished Successfully",
					variant: "success",
				})
			);
		} else if (event.detail.status === "ERROR"){
            this.dispatchEvent(
				new ShowToastEvent({
					title: "There was an error with retreiveing the contact detials",
					message: "There was an error with retreiveing the contact detials. Please refresh and try again. If the problem continues contact the system Administrator",
					variant: "error",
				})
			);
        }
    }
}