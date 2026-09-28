import { api, LightningElement } from 'lwc';
import ID_FIELD from "@salesforce/schema/Recovery__c.Id";
import PROCESSSTATUS_FIELD from "@salesforce/schema/Recovery__c.Process_Status__c";
import { updateRecord } from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class RecoveryUpdateToFinalised extends LightningElement {
    @api recordId;

    @api invoke() {
        if(this.recordId != null){
            this.updateRecvyProcessStatus();
        }
    }

    updateRecvyProcessStatus(){

        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[PROCESSSTATUS_FIELD.fieldApiName] = 'Finalised';

        const recordInput = {fields: fields};
        
        updateRecord(recordInput).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Recovery is updated to Finalised status",
                    variant: "success",
                })
            );
          }).catch(error => { 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating status for this Recovery.',
                    message: error.body ? error.body.message : 'Unknown error',
                    variant: 'error'
                })
            );
        });
    }
}