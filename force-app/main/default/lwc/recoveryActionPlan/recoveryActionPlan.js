import { LightningElement, api, wire, track } from 'lwc';
import getReimbursementData from '@salesforce/apex/RecoveryActionPlanController.getReimbursementData';
import REIMBURSEMENT_DETAILS_DISCLAIMER from '@salesforce/label/c.ReimbursementDetailsDisclaimer';
import REIMBURSEMENT_DETAILS_DISCLAIMER_NODATA from '@salesforce/label/c.ReimbursementDetailsDisclaimerNoData';
import eligible from '@salesforce/resourceUrl/EventActionPlan_Eligible';
import notEligible from '@salesforce/resourceUrl/EventActionPlan_NotEligible';
import { refreshApex } from '@salesforce/apex';

export default class RecoveryActionPlanController extends LightningElement {
    @api recordId;
    @track hotelItems = {}; 
    @track transportItems = {}; 
    @track mealsItems = {}; 
    @track activeSections =[] ;
    @track eligibilityIndicatorHotel;

    
    expenseGuide;
    hasAnyData = false;
    eligibleUrl = eligible;
    notEligibleUrl = notEligible;

    transportEligibility;
    hotelEligibility;
    isHotelEligible = false; // Default value for Hotel Eligibility
    isTransportEligible = false; // Default value for Transport Eligibility
    isMealsEligible = false;
    isArrangementsEligible = false;
    isTransportArrangementsEligible = false; 
    isMealArrangementsEligible = false;// Default value for Meals Eligibility
    disclaimerMessage = REIMBURSEMENT_DETAILS_DISCLAIMER;
    disclaimerMessageNoData = REIMBURSEMENT_DETAILS_DISCLAIMER_NODATA;

    intervalId;

    connectedCallback() {
        this.intervalId = setInterval(() => {     
            console.log('Test 1');       
           this.getAccomorations();
           this.getTransport();
           this.getMeal();
        }, 1000);
        
    }

    disconnectedCallback() {
        
        clearInterval(this.intervalId);
    }

    
    getAccomorations(){
        getReimbursementData({ recordId: this.recordId, name: 'CJL: Accommodation*' })
         .then(result => {
                this.hotelItems = result[0]; // Process first item
                if(this.hotelItems){
                    console.log('Hotel data:', this.hotelItems);
                    this.hasAnyData = true;
                    this.activeSections = [...this.activeSections, '1'];
                    this.isHotelEligible = this.hotelItems.Eligibility_Indicator__c === 'Yes';
                
                    this.isArrangementsEligible = this.hotelItems.Arrangements_Indicator__c === 'Yes';
                    if(this.hotelItems.Expense_Claim_Guide__c)
                        this.expenseGuide = '$' + this.hotelItems.Expense_Claim_Guide__c;
                }
                
            })
            .catch(error => {
                this.hotelItems = undefined;
                console.error('Error fetching hotel accommodation data:', error);
            });
    }
    /*
    @wire(getReimbursementData, { recordId: '$recordId', name: 'CJL: Accommodation*' })
    async wiredHotelData({ error, data }) {
        console.log('Hotel data:', data); // Log data to verify structure
        if (data && data.length > 0) {
            ;
            this.hotelItems = data[0]; // Process first item
            console.log('Hotel data:', this.hotelItems);
            this.hasAnyData = true;
            // Set eligibility indicator based on the hotel data
            await Promise.resolve();
            this.activeSections = [...this.activeSections, '1'];
            this.isHotelEligible = this.hotelItems.Eligibility_Indicator__c === 'Yes';
           
            this.isArrangementsEligible = this.hotelItems.Arrangements_Indicator__c === 'Yes';
            if(this.hotelItems.Expense_Claim_Guide__c)
                this.expenseGuide = '$' + this.hotelItems.Expense_Claim_Guide__c;
            
        } else if (error) {
            console.error('Error fetching hotel accommodation data:', error);
        }
    }
    */
    getTransport(){
        getReimbursementData({ recordId: this.recordId, name: 'CJL: Transport*' })
         .then(result => {
                this.transportItems = result[0]; 
                if(this.transportItems){
                    this.hasAnyData = true;
                    this.activeSections = [...this.activeSections, '2'];
                
                    this.isTransportEligible = this.transportItems.Eligibility_Indicator__c === 'Yes';
                    this.isTransportArrangementsEligible = this.transportItems.Arrangements_Indicator__c === 'Yes';
                }
               
            })
            .catch(error => {
                this.transportItems = undefined;
                console.error('Error fetching transport data:', error);
            });
    }
 /*
    @wire(getReimbursementData, { recordId: '$recordId', name: 'CJL: Transport*' })
    async wiredTransportData({ error, data }) {
        console.log('Transport data:', data); // Log data to verify structure
        if (data && data.length > 0) {
            

            this.transportItems = data[0];
            this.hasAnyData = true;
            await Promise.resolve();
            this.activeSections = [...this.activeSections, '2'];

            // Set eligibility indicator based on the transport data
            this.isTransportEligible = this.transportItems.Eligibility_Indicator__c === 'Yes';
            this.isTransportArrangementsEligible = this.transportItems.Arrangements_Indicator__c === 'Yes';
            

        } else if (error) {
            console.error('Error fetching transport data:', error);
        }
    }
*/
    getMeal(){
        getReimbursementData({ recordId: this.recordId, name: 'CJL: Meals*' })
        .then(result => {            
            this.mealsItems = result[0];     
            if(this.mealsItems){
                this.hasAnyData = true;                
                this.activeSections = [...this.activeSections, '3'];                
                this.isMealsEligible = this.mealsItems.Eligibility_Indicator__c === 'Yes';
                this.isMealArrangementsEligible = this.mealsItems.Arrangements_Indicator__c === 'Yes';
            }  
            })
            .catch(error => {
                this.mealsItems = undefined;
                console.error('Error fetching meals data:', error);
            });
    }
    /*

    @wire(getReimbursementData, { recordId: '$recordId', name: 'CJL: Meals*' })
    async wiredMealsData({ error, data }) {
         // Log data to verify structure
        if (data && data.length > 0) {
            console.log('DJ--> inse 3');
            this.mealsItems = data[0];
            this.hasAnyData = true;
            await Promise.resolve();
            this.activeSections = [...this.activeSections, '3'];
                        // Set eligibility indicator based on the meals data
            this.isMealsEligible = this.mealsItems.Eligibility_Indicator__c === 'Yes';
            this.isMealArrangementsEligible = this.mealsItems.Arrangements_Indicator__c === 'Yes';
            
        } else if (error) {
            console.error('Error fetching meals data:', error);
        }
    }

   */

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get hasHotelData() {
        return this.hotelItems && Object.keys(this.hotelItems).length > 0;
    }

    get hasTransportData() {
        return this.transportItems && Object.keys(this.transportItems).length > 0;
    }

    get hasMealsData() {
        return this.mealsItems && Object.keys(this.mealsItems).length > 0;
    }

    eligibility = {
        status: 'Eligible',
        icon: '✔️',
        class: 'eligible'
    };
}