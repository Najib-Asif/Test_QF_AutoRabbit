import {LightningElement } from 'lwc';
export default class OfferCatalogueCalendarContainer extends LightningElement {

    objectApiName = 'Offer_Catalogue__c';
    records;

    calendarConfig = {
        objectApiName: this.objectApiName,
        fields: [
                    'Id',
                    'Name',
                    'OfferStatus__c',
                    'Offer_Start_Date__c',
                    'Offer_End_Date__c'
                ],
        nameField:'Name',
        statusField:'OfferStatus__c',
        startDateField: 'Offer_Start_Date__c',
        endDateField: 'Offer_End_Date__c',
        filters: [
            {
                fieldApiName: 'OfferStatus__c',
                label: 'Offer Status',
                type:'picklist',
                options: [
                    { label: 'Draft', value: 'Draft' },
                    { label: 'Sales Review', value: 'Sales Review' },
                    { label: 'Revenue Dept', value: 'Revenue Dept' }
                ]

            },
            {
                fieldApiName: 'Offer_Type__c',
                label: 'Offer Type',
                type:'picklist'
            },
            {
                fieldApiName: 'Point_of_Sale_Country__c',
                label: 'Point of Sale (Country)',
                type: 'text'
            },
            {
                fieldApiName: 'Itinerary__c',
                label: 'Itinerary',
                type: 'text'
            }
        ],
        statusClassMap : {
            'Draft': '#95a5a6',
            'Sales Review': '#3498db',
            'Revenue dept': '#1abc9c',
            'Pricing team': '#9b59b6',
            'Live': '#f1c40f',
            'Completed': '#2ecc71',
            'Closed - Not moving ahead': '#e74c3c',
            'Handover to Pricing': '#8e44ad'
        }
    };


}