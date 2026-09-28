import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import AWB_NUMBER from "@salesforce/schema/Case.Freight_AWB_Number__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const fields = [AWB_NUMBER];

export default class AwbPageRefresh extends LightningElement {
    @api recordId;
    caseRecord;
    awbNumber;
    oldCaseRecord;
   
    @wire(getRecord, { recordId: "$recordId", fields})
    wiredCase({error, data}) {
        if (data) {
            this.oldCaseRecord = this.caseRecord;
            this.caseRecord = data;
            console.log('**********AWB Refresh Component Loaded***********');
            if (this.oldCaseRecord != undefined && getFieldValue(this.oldCaseRecord, AWB_NUMBER) != getFieldValue(this.caseRecord, AWB_NUMBER)) 
            {
               const evt = new ShowToastEvent({
               title: 'Please wait... ',
               message: 'Refresh from iCargo is in-progress',
               variant: 'success',
             });
             this.dispatchEvent(evt);
                setTimeout(()=>{
                    window.location.reload();
                    console.log('**********AWB Case Page Refresh***********');
                }, 5000);
            }
        } else {
            console.log('AWB Case Page Refresh - error message - '+ JSON.stringify(error));
        }
    }
}