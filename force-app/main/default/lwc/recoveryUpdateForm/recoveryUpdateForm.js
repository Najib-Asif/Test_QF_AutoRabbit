import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class RecoveryUpdateForm extends LightningElement {
    @api recordId;
    @track formValues = {}; // Stores the original values for change tracking

    isChangeFlag = false;
    isButtonDisabled = false;
    // Capture changes in form fields
    handleFieldChange(event) {
        this.formValues[event.target.fieldName] = event.target.value;
    }
    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Recovery record updated successfully!',
                variant: 'success'
            })
        );
        this.closeQuickAction();
    }
    handleError(event) {
       /* this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Recovery record can not be updated!',
                variant: 'error'
            })
        );
        */
       // console.log(event.detail);
        this.isButtonDisabled = false;
        //this.closeQuickAction();
    }
    handleChnage(event){
        this.isChangeFlag = true;
        this.isButtonDisabled = false;
    }

    handleSubmit(event) {
        this.isButtonDisabled = true;
        event.preventDefault(); // Prevent default form submission
         const fields = event.detail.fields;
        // Check if any field has changed
        if (!this.isChangeFlag) {
           // this.showToast('No Changes', 'No fields were modified.', 'info');            
        }
        else{
            fields.Payment_Details_Added_Manually__c = true;
        }

        fields.Automated_Currency_Conversion_Complete__c = false;        
        fields.Payment_Details_received__c = true;
        fields.Process_Status__c = 'Payment Details Received';

        this.template.querySelector('lightning-record-edit-form').submit(fields);
        
    }

    handleCancel() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}