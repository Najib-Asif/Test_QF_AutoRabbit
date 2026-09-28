import { LightningElement, api } from 'lwc';
import updateCaseValidation from '@salesforce/apex/Case_Controller.updateCaseValidation';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CaseCloseButtonCmp extends LightningElement {
    @api recordId; // Automatically gets the Case ID when on the Case page
    @api objectApiName;

    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
      }

    handleSubmit(event) {
        console.log('Button Clicked');
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        var status = fields.Status;
        console.log('Status----'+status);
        //this.dispatchEvent(new CloseActionScreenEvent());
        updateCaseValidation({ caseId: this.recordId,status: status })
            .then((result) => {
                console.log('Error------'+result);
                if (result === 'Success') {
                    // Show success toast
                    this.showToast('Success', 'The case was successfully updated.', 'success');
                    location.reload();
                } else {
                    // Show error toast with the validation message
                    this.showToast('Validation Error', result, 'error');
                }
            })
            .catch((error) => {
                // Handle unexpected errors
                console.error('Error closing case:', error);
                this.showToast('Error', 'An unexpected error occurred.', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            })
        );
    }
}