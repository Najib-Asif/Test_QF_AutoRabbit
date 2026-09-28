import { LightningElement, api, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/QCCRecoveryCreationPickListController.getPicklistValues';
import { getRecord } from 'lightning/uiRecordApi';
import getSuggestedValues from '@salesforce/apex/QCC_QantasPointsSuggestedValues.getSuggestedValues';
import getFilteredDependentPicklistValues from '@salesforce/apex/QCCRecoveryCreationPickListController.getDependentPicklistValues';

const FIELDS = [
    'Case.ContactId'
];

export default class DependentPicklistComponent extends LightningElement {
    @api controllingFieldApiName;
    @api dependentFieldApiName;
    @api objectApiName;
    @api selectedValuesFinal;
    @api recordId; // The caseId passed from the Flow
    @api suggestedMaxValue;
    @track contactId; 

    @track controllingOptions = [];
    @track showDependentPicklist = false;
    @track dependentOptions = [];
    @api controllingValue = '';
    @api selectedDependentValues = [];
    @api currentUserProfileName;
    @api isCCATUser;
    @api profileExclusionString;
    @api paymentDetailsFlag = false;

    connectedCallback() {
         // Initialize selected values from selectedValuesFinal
        if (this.selectedValuesFinal) {
            this.selectedDependentValues = this.selectedValuesFinal.split(';');
        }
        this.showDependentPicklist = !!this.controllingValue;
         //Commenting as part of CDP2-791
				// adding back for CDP2-619
				//alert(this.controllingValue);
        if( this.controllingValue.includes('EFT'))
        {
            this.showCheckbox = true;
        }
        // Fetch dependent picklist options based on initial values or default state
        this.filterDependentOptions();
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    caseRecord({ error, data }) {
        if (data) {
            this.contactId = data.fields.ContactId.value;
        } else if (error) {
            console.error('Error retrieving record data:', error);
        }
    }

    @wire(getPicklistValues, { objectApiName: '$objectApiName', fieldApiName: '$controllingFieldApiName' })
    wiredControllingPicklist({ error, data }) {
        if (data) {

            this.controllingOptions = data;
            let profileExclusions;
            try {
                profileExclusions = JSON.parse(this.profileExclusionString);
                if (profileExclusions && this.currentUserProfileName && profileExclusions.hasOwnProperty(this.currentUserProfileName)) {
                        this.controllingOptions = this.controllingOptions.filter(option => {
                            return !profileExclusions[this.currentUserProfileName].includes(option.value);
                    });
                }
                if(!isCCATUser && profileExclusions.hasOwnProperty('CCATRecoveries')) {
                    this.controllingOptions =  this.controllingOptions.filter(option => {
                        return !profileExclusions['CCATRecoveries'].includes(option.value);
                    });
                }
            } catch(ex) {
                console.log(ex);
            }
        } else if (error) {
            console.error(error);
        }
    }
   

    handleControllingChange(event) {
        this.controllingValue = event.target.value;
        this.selectedDependentValues = [];
        this.showDependentPicklist = !!this.controllingValue;
        this.filterDependentOptions();
        
        if (this.controllingValue === 'Qantas Points') {
            this.fetchSuggestedValues();
        }
				if( this.controllingValue.includes('EFT'))
        {
						this.showCheckbox = true;
        }
    }

    fetchSuggestedValues() {
        if (this.contactId) {
            getSuggestedValues({ caseNumber: this.recordId, contactId: this.contactId })
                .then(result => {
                    this.suggestedMaxValue = result.Suggested_Maximum__c;
                })
                .catch(error => {
                    console.error('Error retrieving suggested values:', error);
                });
        }
    }

    handleDependentChange(event) {
        const selectedValues = event.detail.value;
        this.selectedDependentValues = [...new Set(selectedValues)];
        
        if(this.selectedDependentValues.includes("US Dot Baggage Refund")){
            this.selectedDependentValues = ["US Dot Baggage Refund"];
        }
        this.selectedValuesFinal = this.selectedDependentValues.join(';');
    }

    handleCheckboxChange(event) {
        this.paymentDetailsFlag = event.target.checked; // Update paymentDetailsFlag when checkbox is toggled
    }

    filterDependentOptions() {
        getFilteredDependentPicklistValues({
            objectName: this.objectApiName,
            controllingField: this.controllingFieldApiName,
            dependentField: this.dependentFieldApiName,
            controllingValue: this.controllingValue
        })
        .then(data => {
            this.dependentOptions = data;
            this.selectedDependentValues.forEach(value => {
                const option = this.dependentOptions.find(opt => opt.value === value);
                if (option) {
                    option.selected = true;
                }
            });
        })
        .catch(error => {
            console.error('Error fetching dependent options:', error);
        });
    }
}