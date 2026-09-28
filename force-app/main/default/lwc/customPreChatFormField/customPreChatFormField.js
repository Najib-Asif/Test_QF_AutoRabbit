import { track, api, LightningElement } from "lwc";

export default class CustomPreChatFormField extends LightningElement {
    choiceListDefaultValue='';
    minLengthErrorMessage='';
    

    /**
    * Form field data.
    * @type {Object}
    */
    @api fieldInfo = {};

    countryCode = '+61';
    phoneNumber = '';
    phoneval = '';

    countryOptions = [
        { label: '+61', value: '+61' },
        { label: '+64', value: '+64' }
    ];

    @api
    get name() {
        return this.fieldInfo.name;
    }

    @api
    get value() {
        const lightningCmp = this.isTypeChoiceList ? this.template.querySelector("lightning-select") : this.template.querySelector("lightning-input");
        console.log('Taking value from here');
        if(this.isPhone){
        return this.phoneval;

        }
        return this.isTypeCheckbox ? lightningCmp.checked : lightningCmp.value;
    }

    @api
    reportValidity() {
        const lightningCmp = this.isTypeChoiceList ? this.template.querySelector("lightning-select") : this.template.querySelector("lightning-input");
        return lightningCmp.reportValidity();
    }

    get type() {
        switch (this.fieldInfo.type) {
            case "Phone":
                return "tel";
            case "Text":
            case "Email":
            case "Number":
            case "Checkbox":
            case "ChoiceList":
                return this.fieldInfo.type.toLowerCase();
            default:
                return "text";
        }
    }

    get isPhone() {
        console.log("Phone find");
        return this.type.toLowerCase() === "tel";
    }


    get isTypeCheckbox() {
        return this.type === "Checkbox".toLowerCase();
    }

    get isTypeChoiceList() {
        return this.type === "ChoiceList".toLowerCase();
    }

    /**
    * Formats choiceList options and sets the default value.
    * @type {Array}
    */
    get choiceListOptions() {
        let choiceListOptions = [];
        choiceListOptions.push({ label: "Select", value: "" ,disabled: true});
        const choiceListValues = [...this.fieldInfo.choiceListValues];
        choiceListValues.sort((valueA, valueB) => valueA.order - valueB.order);
        for (const listValue of choiceListValues) {
            if (listValue.isDefaultValue) {
                this.choiceListDefaultValue = listValue.choiceListValueName;
            }
            choiceListOptions.push({ label: listValue.label, value: listValue.choiceListValueName });
        }
        return choiceListOptions;
    }

    get minlength(){
        console.log('Field name---'+this.fieldInfo.name);
        if(this.fieldInfo.name.toLowerCase().includes('pnr')){
            this.minLengthErrorMessage = "PNR must be exactly 6 alphanumeric characters."
            return 6;
        }
        return '';
    }

    get pattern(){
        console.log('PATTERN FOR---'+this.fieldInfo.name);
        if(this.fieldInfo.name.toLowerCase().includes('pnr')){
            this.patternMismatchError = "PNR must be exactly 6 alphanumeric characters."
            return '[a-zA-Z0-9]{6}';
        }
        return ;
    }

    handleCountryChange(event) {
        this.countryCode = event.detail.value;
        this.updatePrechatPhone();
    }
 
    handlePhoneChange(event) {
        // digits only
        this.phoneNumber = event.target.value.replace(/\D/g, '');
        this.updatePrechatPhone();
    }
 
    updatePrechatPhone() {
        if (!this.phoneNumber) return;
 
        const normalizedPhone = `${this.countryCode} ${this.phoneNumber}`;
        this.phoneval = normalizedPhone;
        
    }

}