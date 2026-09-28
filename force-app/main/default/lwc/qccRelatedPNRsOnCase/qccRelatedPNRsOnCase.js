import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getListUi } from 'lightning/uiListApi';
import PNR_OBJECT from '@salesforce/schema/PNR__c';
import { publish,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import qccCaseChannel from '@salesforce/messageChannel/QCC_Case_Channel__c';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_PNR from '@salesforce/schema/Case.Booking_PNR__c';
import CASE_CONTACT from '@salesforce/schema/Case.ContactId';
import CASE_FIELD from '@salesforce/schema/PNR__c.Case__c';

export default class RelatedPNRs extends LightningElement {
    @api recordId; // Current Case record Id
    pnrRecords;
    error;
    @track pnr;
    context = createMessageContext();
    @wire(getRecord, { recordId: '$recordId', fields: [CASE_PNR,CASE_CONTACT] })
    wiredCase({ error, data }) {
        console.log('data::::'+JSON.stringify(data));
        console.log('wiredCase:::::');
        if (data) {
            const payloadmessage = {
            action: 'refresh',
            pnrValue: data.fields.Booking_PNR__c.value,
            caseContact: data.fields.ContactId.value
            };
            console.log('payloadmessage ::'+ JSON.stringify(payloadmessage) );
            const payload = { payloadData: payloadmessage };
            publish(this.context, qccCaseChannel, payload);
        } else if (error) {
            console.log('error:::'+error);
            console.error('Error loading Case record', error);
        }
    }

   /* @wire(getListUi, {
        objectApiName: PNR_OBJECT,
        listViewApiName: 'PNR_List',
        pageSize: 10,
        criteria: {
            filterScope: 'mine',
            listViewId: null,
            entity: 'PNR__c',
            pageToken: { recordId: '$recordId' }
        }
    })
    wiredPNRs({ error, data }) {
   console.log('recordId NNNN::::::***'+this.recordId);
        console.log('Inside wired PNRS::'+JSON.stringify(data));
        if (data) {
            this.pnrRecords = data.records.records.map(record => ({
                Id: record.id,
                PNR__c: record.fields.PNR__c.value,
                // Add more fields as needed
            }));
console.log('pnrRecords:'+JSON.stringify(this.pnrRecords));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.pnrRecords = undefined;
        }
    }*/
}