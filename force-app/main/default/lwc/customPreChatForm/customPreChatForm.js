import { track, api, LightningElement } from "lwc";
import QAC_TERMS_AND_CONDITIONS from '@salesforce/label/c.QAC_Chat_terms_and_Conditions';

export default class CustomPreChatForm extends LightningElement{
    /**
    * Deployment configuration data.
    * @type {Object}
    */
    @api configuration = {};

    startConversationLabel;
    

    isSubmitButtonDisabled = false;

    get prechatForm() {
        const forms = this.configuration.forms || []; 
        return forms.find(form => form.formType === "PreChat") || {};
    }

    get prechatFormFields() {
        return this.prechatForm.formFields || [];
    }

    /**
    * Returns pre-chat form fields sorted by their display order.
    * @type {Object[]}
    */
    get fields() {
        let fields =  JSON.parse(JSON.stringify(this.prechatFormFields));
        this.addChoiceListValues(fields);
        return fields.sort((fieldA, fieldB) => fieldA.order - fieldB.order);
    }

    get termsAndConditions() {
        const chatName = this.configuration.name.toLowerCase();
        if (chatName.includes('qac')) {
            return QAC_TERMS_AND_CONDITIONS;
        }
        //console.log('termsAndConditions'+this.termsAndConditions);
        return '';
    }

    connectedCallback() {
        this.startConversationLabel = "Start Chatting";
    }

    /**
    * Adds values to choiceList (dropdown) fields.
    */
    addChoiceListValues(fields) {
        for (let field of fields) {
            if (field.type === "ChoiceList") {
                const valueList = this.configuration.choiceListConfig.choiceList.find(list => list.choiceListId === field.choiceListId) || {};
                field.choiceListValues = valueList.choiceListValues || [];
            }
        }
    }

    /**
    * Iterates over and validates each form field. Returns true if all the fields are valid.
    * @type {boolean}
    */
    isValid() {
        let isFormValid = true;
        this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
            if (!formField.reportValidity()) {
                isFormValid = false;
            }
        });
        this.template.querySelectorAll("lightning-input").forEach(formField => {
            if (!formField.reportValidity()) {
                isFormValid = false;
            }
        });
        return isFormValid;
    }

    /**
    * Gathers and submits pre-chat data to the app on start-conversation-button click.
    * @type {boolean}
    */
    onStartConversationClick() {
        const prechatData = {};
        if (this.isValid()) {
            this.template.querySelectorAll("c-custom-pre-chat-form-field").forEach(formField => {
                prechatData[formField.name] = String(formField.value);
            });

            this.isSubmitButtonDisabled = true;

            this.dispatchEvent(new CustomEvent(
                "prechatsubmit",
                {
                    detail: { value: prechatData }
                }
            ));
        }
    }
}