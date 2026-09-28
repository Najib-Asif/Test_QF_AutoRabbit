import { api, LightningElement } from 'lwc';
import RECOVERY_OBJECT from "@salesforce/schema/Recovery__c";
import ID_FIELD from "@salesforce/schema/Recovery__c.Id";
import PROCESSSTATUS_FIELD from "@salesforce/schema/Recovery__c.Process_Status__c";
import RETRIGGERAPPROVAL_FIELD from "@salesforce/schema/Recovery__c.Retrigger_Approval__c";
import { updateRecord } from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class RecoverySubmitForApproval extends LightningElement {
    @api recordId;

    @api invoke() {
        if(this.recordId != null){
            this.updateRecvyProcessStatus();
        }
    }

    updateRecvyProcessStatus(){

        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[PROCESSSTATUS_FIELD.fieldApiName] = 'Pending Approval';
        fields[RETRIGGERAPPROVAL_FIELD.fieldApiName] = false;

        const recordInput = {fields: fields};
        
        updateRecord(recordInput).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Recovery is submitted for Approval",
                    variant: "success",
                })
            );
          }).catch(error => { 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error submitting this Recovery for Approval.',
                    message: error.body ? error.body.message : 'Unknown error',
                    variant: 'error'
                })
            );
        });
    }
}