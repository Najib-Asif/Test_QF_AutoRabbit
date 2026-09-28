import { LightningElement,api,wire,track } from 'lwc';
    import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
    import getLevel2Values from '@salesforce/apex/DualDependentPicklistController.getLevel2Values';
    import getLevel3Values from '@salesforce/apex/DualDependentPicklistController.getLevel3Values';

    export default class DualControlledDependentPicklist extends LightningElement {

        @api recordId;
        @api recordTypeId;

        @api objectApiName;
        @api level1FieldLabel;
        @api level2FieldLabel;
        @api level3FieldLabel;

        @api level1FieldApiName;
        @api level2FieldApiName;
        @api level3FieldApiName;

        @api level1Value;
        @api level2Value;
        @api level3Value;

        @track level1FieldOptions = [];     
        @track level2FieldOptions = [];
        @track level3FieldOptions = [];


    @wire(getPicklistValuesByRecordType, {objectApiName: '$objectApiName',recordTypeId: '$recordTypeId'})
    wiredPicklists({ data, error }) {
        if (data) {
            const mapByField = data.picklistFieldValues || {};
            const fieldApi = this.level1FieldApiName; 
            if (fieldApi && mapByField[fieldApi]) {
                this.level1FieldOptions = (mapByField[fieldApi].values || []).map(v => ({
                    label: v.label,
                    value: v.value
                }));
            } else {
                // Field not present or not a picklist for this RT
                this.level1FieldOptions = [];
            }
            this.getLevel3PicklistValues();
            this.getLevel2PicklistValues();
            this.notifyReadyOnce();
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.level1FieldOptions = [];
        }
    }

        
    notifyReadyOnce() {
        this.dispatchEvent(new CustomEvent('ready'));
    }


    handleChange(event){
        const field = event.target.dataset.field;
        const value = event.detail.value;

        if (field === 'level1') {
            this.level1Value = value;
            this.level2Value = null;
            this.level3Value = null;
            this.level2FieldOptions = [];
            this.level3FieldOptions = [];
            this.getLevel2PicklistValues();
        } else if (field === 'level2') {
            this.level2Value = value;
            this.level3Value = null;
            this.level3FieldOptions = [];
            this.getLevel3PicklistValues();
        } else if (field === 'level3') {
            this.level3Value = value;
        }

            
        this.dispatchEvent(new CustomEvent('dualcontrolledpicklistchange', {
                detail: {
                    level1: this.level1Value || null,
                    level2: this.level2Value || null,
                    level3: this.level3Value || null
                }
        }));
    }

    // Level 2 is required only when there are Level 2 options (which depend on L1)
    get isLevel2Required() {
        return (this.level2FieldOptions?.length || 0) > 0;
    }
        
    // Level 3 is required only when there are Level 3 options (which depend on L2)
    get isLevel3Required() {
        return (this.level3FieldOptions?.length || 0) > 0;
    }


    getLevel2PicklistValues() {
        getLevel2Values({
            objectApiName: this.objectApiName,
            level1FieldApiName: this.level1FieldApiName,
            level1Value: this.level1Value,
            level2FieldApiName: this.level2FieldApiName
        })
            .then(values => {
                this.level2FieldOptions = values.map(v => ({ label: v, value: v }));
            })
            .catch(error => {
                console.error('Error retrieving level 2 values', error);
                this.level2FieldOptions = [];
            });
    }

    getLevel3PicklistValues(){
        getLevel3Values({
            objectApiName: this.objectApiName,
            level1FieldApiName: this.level1FieldApiName,
            level1Value: this.level1Value,
            level2FieldApiName: this.level2FieldApiName,
            level2Value : this.level2Value,
            level3FieldApiName : this.level3FieldApiName
        })
            .then(values => {
                this.level3FieldOptions = values.map(v => ({ label: v, value: v }));
            })
            .catch(error => {
                console.error('Error retrieving level 3 values', error);
                this.level3FieldOptions = [];
            });
    }

    
@api
validate() {
    const inputs = this.template.querySelectorAll('lightning-combobox');
    let isValid = true;

    inputs.forEach(input => {
        if (!input.checkValidity()) {
            input.reportValidity();
            isValid = false;
        }
    });

    return isValid;
}


    }