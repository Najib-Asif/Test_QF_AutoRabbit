import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = [
    'Event__c.ActionType__c'
];
export default class IocEventChecklist extends LightningElement {
    @api recordId;
    @track checklistType;
    @api recValue;
    optionSelected(event){
        const optionVal = event.detail;
        // eslint-disable-next-line no-undef
        this.checklistType = optionVal;
    }

    @wire(getRecord,{ recordId: '$recordId', fields })
    objEvent({ error, data }) {
        if (data) {
            this.recValue = data.fields.ActionType__c.value;
        }else if(error){
            this.recValue = '';
        }
    }
}