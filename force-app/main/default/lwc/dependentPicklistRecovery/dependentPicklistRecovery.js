import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType ,getPicklistValues } from 'lightning/uiObjectInfoApi';
import RECOVERY_OBJECT from '@salesforce/schema/Recovery__c';
import CC_ACCOUNT from '@salesforce/schema/Recovery__c.Cost_Centre_Account_Number__c';

export default class DependentPicklistRecovery extends LightningElement {
    @api selectedCostCentre; // Flow input & output
    @api selectedRefundCostCentre; // Flow input & output
    @api selectedRefundAccount; // Flow input & output
    @api recordTypeId = '01290000000ukasAAA'; // Flow input & output

    @track costCentreOptions = [{ "attributes": null, "label": "Hot", "validFor": [], "value": "Hot" }];
    @track refundCostCentreOptions = [];
    @track refundAccountOptions = [];

    disableChildPicklists = true;
    picklistData;
    recoveryRecordtypeId;

    

    @wire(getPicklistValuesByRecordType , {objectApiName: RECOVERY_OBJECT, recordTypeId: '$recordTypeId' , fieldApiName: CC_ACCOUNT })
    wiredPicklistValues({ error, data }) {
        if (data) {
            
            //console.log('DJ=>'+JSON.stringify(data));
            this.picklistData = data;
            // Populate Parent Picklist
            this.costCentreOptions = data.picklistFieldValues.Cost_Centre_Account_Number__c.values;
           // console.log('DJ=>'+this.costCentreOptions);
        } else if (error) {
            console.log('Error fetching picklist values', error);
        }
    }
    get costCentre(){
        return this.costCentreOptions;
    }


    handleCostCentreChange(event) {
        this.selectedCostCentre = event.detail.value;
        this.selectedRefundCostCentre = '';
        this.refundCostCentreOptions = [];
        this.refundAccountOptions = [];
        this.disableChildPicklists = true;
        var index = this.picklistData.picklistFieldValues.Refund_Cost_Centre__c.controllerValues[this.selectedCostCentre];
        var count = 0;
        for(var i in this.picklistData.picklistFieldValues.Refund_Cost_Centre__c.values){
            var picklistvalues = this.picklistData.picklistFieldValues.Refund_Cost_Centre__c.values[i];
           
            if(picklistvalues.validFor && picklistvalues.validFor.includes(index) ){         
                
                this.selectedRefundCostCentre = picklistvalues.value;
                this.refundCostCentreOptions.push(picklistvalues);
                count++;                
            }
        }

        this.selectedRefundAccount = '';
        index = this.picklistData.picklistFieldValues.Refund_Account__c.controllerValues[this.selectedCostCentre];
        for(var i in this.picklistData.picklistFieldValues.Refund_Account__c.values){
            var picklistvalues = this.picklistData.picklistFieldValues.Refund_Account__c.values[i];
            
            if(picklistvalues.validFor && picklistvalues.validFor.includes(index) ){             
                this.selectedRefundAccount = picklistvalues.value;
                this.refundAccountOptions.push(picklistvalues);    
                count++;            
            }
        }
        if(count >2){
            this.disableChildPicklists = false;
            this.selectedRefundCostCentre = '';
            this.selectedRefundAccount = '';

        }

        this.notifyFlow();
    }
 
    handlechangeRAC(event){
        this.selectedRefundAccount = event.detail.value;
        this.notifyFlow();
    }
    handlechangeRCC(event){
        this.selectedRefundCostCentre = event.detail.value;
        this.notifyFlow();
    }
    notifyFlow() {
        const event = new CustomEvent('valuechange', {
            detail: {
                selectedCostCentre: this.selectedCostCentre,
                selectedRefundCostCentre: this.selectedRefundCostCentre,
                selectedRefundAccount: this.selectedRefundAccount
            }
        });
        this.dispatchEvent(event);
    }
}