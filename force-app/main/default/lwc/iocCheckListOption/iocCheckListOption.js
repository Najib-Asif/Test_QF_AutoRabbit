/* eslint-disable getter-return */
import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import getCheckListOptions from '@salesforce/apex/IOCCJMCheckListController.getCheckListOptions';
import getAccessVal from '@salesforce/apex/IOCCJMCheckListController.getAccessVal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class IOCCheckListOptions extends LightningElement {
    @api value;
    @api recordId;
    @wire(getCheckListOptions) optionRet;
    @wire(getAccessVal) accessLevelRet;
    @wire(CurrentPageReference) pageRef;
    @track enableButton = false;
    get options() {
        let myoptions=[]; 
        if(typeof this.optionRet.data !== "undefined"){
            let self = this.optionRet.data;

            self.forEach(singleVal => {
                myoptions.push({ 
                    label: singleVal,
                    value: singleVal
                });
            });
        }
        return myoptions;
    }

    get accessLevel() {
        if(typeof this.accessLevelRet.data !== "undefined"){
            return this.accessLevelRet.data;
        }
        return true;
    }

    handleChange(event) {   
        this.value = event.detail.value;
        this.enableButton = true;
    }

    handleButtonClick(event){
        //this.value = event.detail.value;
        //this.enableButton = false;
        if(this.value === null  || this.value === undefined){
            this.showErrorToast();
        }
        else{
            fireEvent(this.pageRef, 'optionChange', this.value);
            event.preventDefault();
            const currentVal = new CustomEvent('selected', {detail: this.value});
            this.dispatchEvent(currentVal);
            
            this.showToast('', 'Actions from "' + this.value + '" added!  ', 'Success');    
            this.value = '';  
        }      
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error!',
            message: 'Select a checklist to add to the action plan.',
            variant: 'error',  
        });
        this.dispatchEvent(event);
    }

    showToast(title, message, variant ) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            
        });
        this.dispatchEvent(event);
    }

    
}