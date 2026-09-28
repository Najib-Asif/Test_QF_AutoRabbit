import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";
import { createRecord, updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OfferCreationWithJsonScreenAction extends NavigationMixin (LightningElement) {

   @api recordId
   
   isRecordPage = false;
   
   @wire(CurrentPageReference)
    getPageRef(pageRef){
        if (!pageRef) return;
        this.isRecordPage = pageRef.state?.context =='RECORD_DETAIL'
    }

    // Disable Save only on record page
    get disableSaveButton(){
        return !this.isRecordPage;
    }

    // Disable update only on the list view
    get disableUpdateButton(){
        return this.isRecordPage;
    }

    // Setting HeaderTitle
    get headerTitle(){
        return this.isRecordPage? 'Update Offer':'Create Offer'
    }


    async handleCreate(){
        if (!this.refs.jsonBody?.checkValidity()) {
            this.refs.jsonBody?.reportValidity();
            this.showToast('Invalid Input', 'Please enter a valid Input', 'error');
            return;
        }
        let recordInput = {apiName: 'Offer_Catalogue__c'};
        try{
            recordInput.fields = JSON.parse(this.refs.jsonBody.value);
        } catch (e){
            this.showToast('Invalid Input', 'Please enter a valid JSON String', 'error');
            return;
        }

        try {
            const rec = await createRecord(recordInput);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: rec.id,
                    actionName: 'view',
                },
            });
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (e){
            let errorMessage = e?.body?.output?.errors?.[0]?.message || e?.body?.message || 'Error Creating Offer';
            let errorTitle = e?.body?.output?.errors?.[0]?.errorCode || e?.body?.enhancedErrorType || 'Unknown error';
            this.showToast(errorTitle, errorMessage, 'error');
            console.error(JSON.stringify(e));
        }
    }

    async updateHandler(){
        if (!this.refs.jsonBody?.checkValidity()) {
            this.refs.jsonBody?.reportValidity();
            this.showToast('Invalid Input', 'Please enter a valid Input', 'error');
            return;
        }

        let fields;
        try {
            fields = JSON.parse(this.refs.jsonBody.value);
        } catch (e) {
            this.showToast('Invalid Input', 'Please enter a valid JSON String', 'error');
            return;
        }

    
        fields.Id = this.recordId;

        const recordInput = { fields };

        try {
            await updateRecord(recordInput);
            this.showToast('Success', 'Offer updated successfully', 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (e) {
            let errorMessage =
                e?.body?.output?.errors?.[0]?.message ||
                e?.body?.message ||
                'Error Updating Offer';

            let errorTitle =
                e?.body?.output?.errors?.[0]?.errorCode ||
                e?.body?.enhancedErrorType ||
                'Unknown error';

            this.showToast(errorTitle, errorMessage, 'error');
            console.error(JSON.stringify(e));

        }
    }


    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant, mode = 'dismissible ') {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}