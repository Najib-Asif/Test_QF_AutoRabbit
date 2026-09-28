import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import PNR_OBJECT from '@salesforce/schema/PNR__c';
import PNR_NUMBER_FIELD from '@salesforce/schema/PNR__c.PNR__c';
import CASE_ID_FIELD from '@salesforce/schema/PNR__c.Case__c';
export default class AdditionalPnr extends LightningElement {
    @api recordId;
    @api primaryPNR;
    @track pnrs = [
        { id: this.generateId(), value: '', saved: false, addAnotherPNR: false }
    ];
    @track isSaving = false;

    case;
    handleInputChange(event) {
        const id = event.target.dataset.id;
        const pnr = this.pnrs.find(p => p.id === id);
        pnr.value = event.target.value;
    }

    handleAddNewPnr() {
        this.pnrs.push({ id: this.generateId(), value: '', saved: false, addAnotherPNR: false });
        this.refreshComponent();
    }

    handleSave(event) {
        const id = event.target.dataset.id;
        const pnr = this.pnrs.find(p => p.id === id);
            if (this.validatePnr(pnr.value)) {
                this.isSaving = true;
    
                const fields = {};
                fields[PNR_NUMBER_FIELD.fieldApiName] = pnr.value;
                fields[CASE_ID_FIELD.fieldApiName] = this.recordId;
    
                const recordInput = { apiName: PNR_OBJECT.objectApiName, fields };
                console.log('recordInput::' + JSON.stringify(recordInput));
                
    
                createRecord(recordInput)
                    .then(result => {
                        pnr.saved = true;
                        pnr.recordId = result.id;
                        this.showToast('Success', 'Additional PNR saved successfully', 'success');
                        this.refreshComponent();
                       
                    })
                    .catch(error => {
                        console.log('Error object:', error);
                        this.showToast('Error', 'Error saving Additional PNR: ' + error.body.message, 'error');
                    })
                    .finally(() => {
                        this.isSaving = false;
                    });
            } else {
                // Don't proceed with saving if validation fails
                console.log('Validation failed. Record not saved.');
            }
        
    }
    

      handleSaveAndAdd(event) {
        const id = event.target.dataset.id;
        const pnr = this.pnrs.find(p => p.id === id);
        if ( this.validatePnr(pnr.value)) {
            if (!pnr.recordId) {
                this.handleSave(event);
            }
            this.handleAddNewPnr();
            pnr.addAnotherPNR = true;
        }
   
    }

    
    handleDelete(event) {
        const id = event.target.dataset.id;
        const pnrIndex = this.pnrs.findIndex(p => p.id === id);

        this.isSaving = true;

        deleteRecord(this.pnrs[pnrIndex].recordId)
            .then(() => {
                this.pnrs.splice(pnrIndex, 1);
                this.showToast('Success', 'Additional PNR deleted successfully', 'success');
                
                if (this.pnrs.length === 0) {
                    this.handleAddNewPnr();
                } else if (this.pnrs.length === pnrIndex) {
                    this.pnrs[pnrIndex - 1].addAnotherPNR = false;
                    this.refreshComponent();
                } else {
                    this.refreshComponent();
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error deleting Additional PNR: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    
     validatePnr(pnrValue) {
        const pnrPattern = /^[a-zA-Z0-9]{6}$/;
            if (!pnrValue) {
                this.showToast('Error', 'Additional PNR cannot be empty', 'error');
                return false;
            }
        
            if (!pnrPattern.test(pnrValue)) {
                this.showToast('Error', 'Additional PNR must be exactly 6 alphanumeric characters', 'error');
                return false;
            }
            return true;
       
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    refreshComponent() {
        this.pnrs = [...this.pnrs];
    }

    disconnectedCallback()
    {
      
    }

    generateId() {
        return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    }
}