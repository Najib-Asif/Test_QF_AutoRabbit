import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CASE_ID from "@salesforce/schema/Case.Id";
import BOOKING_PNR from "@salesforce/schema/Case.Booking_PNR__c";
import getRelatedFlightEvents from '@salesforce/apex/FlightEventLinkage.getFlightEvents';
//import fetchCaseRecord from '@salesforce/apex/FlightEventLinkage.getCaseRecord';
//import fetchFlightEventRecords from '@salesforce/apex/FlightEventLinkage.fetchFlightEventsFromPNR';
import fetchLinkedFlightEventIds from '@salesforce/apex/FlightEventLinkage.getLinkedFlightIdsFromCase';
import createLinkedFlightEventRecords from '@salesforce/apex/FlightEventLinkage.createLinkedFlightEvents';
import QCCCASECHANNEL from '@salesforce/messageChannel/QCC_Case_Channel__c';
//import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';


const CASE_FIELDS = [ CASE_ID, BOOKING_PNR ];
const ERROR_NO_DATA = 'No open flight events found.';
//const ERROR_NO_PNR = 'Please enter a PNR number to view available Flight Events.';
const tableColumns = [
    { label: 'Flight Event Name', fieldName: 'Name', type: 'text' },
    //{ label: 'Event Status', fieldName: 'Status__c', type: 'text' },
    //{ label: 'Flight Status', fieldName: 'Flight_Status__c', type: 'text' }
    { 
        fieldName: 'isLinked', 
        initialWidth: 24,
        type: 'button-icon',
        typeAttributes: {
            name: 'link',
            iconName: { fieldName: 'linkedIconName'}, 
            variant: 'base',
            alternativeText: 'linked status',
            title: 'Linked Status',
            disabled: { fieldName: 'isLinked' }
        }
    },
    {
        initialWidth: 24, 
        type: 'button-icon', 
        typeAttributes: {
            name: 'view',
            iconName: 'utility:preview' 
        } 
    }
];

export default class QccDisplayFlightEventStatus extends NavigationMixin(LightningElement) {
    @api recordId;
    @api tableColumns = tableColumns;
    @api tableData;
    @api messageToDisplay;
    caseRecord;
    oldCaseRecord;
    newCaseRecord;

    connectedCallback() {
        console.log('case record id - ' + this.recordId);
        //this.subscribeToPlatformEvent();
        this.displayFlightEvents(this.recordId);
    }

    async displayFlightEvents(caseId) {
        try {
            let flightEvents = await getRelatedFlightEvents({caseId: caseId});
            if (flightEvents == null || flightEvents.length == 0) {
                this.messageToDisplay = ERROR_NO_DATA;
                this.tableData = null;
            } else {
                console.log('flight events - ' + JSON.stringify(flightEvents));
                let existingFlightEventIds = await fetchLinkedFlightEventIds({caseId: caseId});
                console.log('already linked flight event ids - ' + JSON.stringify(existingFlightEventIds));
                for (let fERecord of flightEvents) {
                    if (existingFlightEventIds.includes(fERecord.Id)) {
                        fERecord.linkedIconName = 'utility:linked';
                        fERecord.isLinked = true;
                    } else {
                        fERecord.linkedIconName = 'utility:link';
                        fERecord.isLinked = false;
                    }
                }
                this.messageToDisplay = null;
                this.tableData = flightEvents;
                console.log('flight events table - ' + JSON.stringify(this.tableData));
            }
        } catch (error) {
            console.log('error occurred while trying to display flight events... ' + JSON.stringify(error));
        }
    }

    handleOnRowAction(event) {
        console.log('row action name - ' + event.detail.action.name);
        console.log('row clicked - ' + JSON.stringify(event.detail.row));
        if (event.detail.action.name == 'link' && event.detail.row.isLinked == false) {
            console.log('link flight event - ' + JSON.stringify(event.detail.row));
            event.detail.row.isLinked = true;
            this.linkFlightEventRecord(this.recordId, event.detail.row);
        } else if (event.detail.action.name == 'view') {
            this.previewEventRecordPage(event.detail.row.Id);
        }
    }

    previewEventRecordPage(eventRecordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: eventRecordId,
                objectAPIName: 'Event__c',
                actionName: 'view'
            }
        });
    }

    async linkFlightEventRecord(caseId, flightEventRec) {
        try {
            console.log('case id - ' + JSON.stringify(caseId));
            console.log('flight event - ' + JSON.stringify(flightEventRec));
            let isSuccess = await createLinkedFlightEventRecords({caseId: caseId, flightEventRecord: flightEventRec});
            if (isSuccess) {
                this.displayFlightEvents(this.recordId);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Link Flight Event',
                    message: 'Flight Event linked successfully',
                    variant: 'success'
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Link Flight Event',
                    message: 'Error occurred while linking Flight Event',
                    variant: 'error'
                }));
            }
        } catch (error) {
            console.log('error occurred while trying to link flight events... ' + JSON.stringify(error));
        }
    }

    handleClick(event) {
        console.log('case record id - ' + this.recordId);
        this.displayFlightEvents(this.recordId);
    }
    /*
    subscribeToPlatformEvent() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(QCCCASECHANNEL, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log( 'subscription response - ' + JSON.stringify(response));
        });
    }

    // Callback invoked whenever a new event message is received
    messageCallback() {
        console.log('new message received: ', JSON.stringify(response));
        // Response contains the payload of the new message received
        this.displayFlightEvents(this.recordId);
    };
    */
}