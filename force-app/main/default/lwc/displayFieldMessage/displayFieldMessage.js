import { api, wire, LightningElement } from 'lwc';
import { getRecord, getFieldValue  } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_CONTACTID from "@salesforce/schema/Case.ContactId";
import CONTACT_SENSITIVECHECKBOX from "@salesforce/schema/Contact.Sensitive_Contact__c";
import CONTACT_SENSITIVEMESSAGE from "@salesforce/schema/Contact.Sensitive_Contact_Message__c";
import CONTACT_SELECTEDDATETIME from "@salesforce/schema/Contact.Schedule_Sensitive_Message__c";
import hasQCC_EditSensitiveMessage from "@salesforce/customPermission/QCC_EditSensitiveMessage";
import getCurrentDateTime from "@salesforce/apex/qccDateTimeOperations.getCurrentDateTime";
import compareDateTime from "@salesforce/apex/qccDateTimeOperations.compareDateTime";
import compareSelectedDateTime from "@salesforce/apex/qccDateTimeOperations.compareSelectedDateTime";
import convertInGMT from "@salesforce/apex/qccDateTimeOperations.convertInGMT";

export default class DisplayFieldMessage extends LightningElement {
    @api recordId;
    @api objectApiName;
    contactId;
    caseId;
    hasEditPermission = hasQCC_EditSensitiveMessage;
    editMode = false;
    showSpinner = false;
    showPlaceholder = true;
    richTextVal;
    showDateTime=true;
    allowedFormats = ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent', 
                'align', 'link', 'image', 'clean', 'table', 'header', 'color', 'background'];
    selectedDateTime;
    previousSelectedDateTime;
    dateTime;  
    hideSensitiveMessage;
    showDateValidationMsg=false;
    
    @wire(getCurrentDateTime)                   
        
        
   /*    @wire(compareDateTime, ({ getDateTime : this.selectedDateTime }))                   
         CompareDateTime({data, error})
        {
            if (data) {
                console.log('>>> here date and time'+JSON.stringify(data));
                this.hideSensitiveMessage = data;
                console.log('>>> here date and time comparison result'+this.hideSensitiveMessage);
                if (error)
                console.log('error in comparing  current date and time'+error);
              }
              
        } */
        
    connectedCallback() {
        //console.log('this.objectApiName '+ this.objectApiName);
        //console.log('this.recordId '+ this.recordId);
        if (this.objectApiName && this.objectApiName == 'Contact') this.contactId = this.recordId;
        if (this.objectApiName && this.objectApiName == 'Case') {
            this.caseId = this.recordId;
            this.hasEditPermission = false;
        }
       
    }

    handleDateTimeChange(event){
        this.selectedDateTime = event.target.value;
        console.log('>>> here is the selected date time in handle date time'+this.selectedDateTime);
       
        compareSelectedDateTime({ selectedDateTime : this.selectedDateTime}).then(result => {
            console.log('>>> here date and time for the comparison call in handleDateTimeChange'+JSON.stringify(result));
            this.showDateValidationMsg = result;
            
            console.log('>>> here is the comparison result in handleDateTimeChange'+JSON.stringify(result));
           
        }).catch(error => {
            console.log('error in comparing  current date and time with selected'+JSON.stringify(error));
        });


    }


    enableEdit() {
        this.editMode = true;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title: title, message: message, variant: variant }));
    }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        
        console.log('>>> heres the selected datetime in hadle submit'+this.selectedDateTime);

        
       

        console.log('heres the fields data'+JSON.stringify(fields));
       
            fields.Sensitive_Contact_Message__c = this.richTextVal;
            if(this.selectedDateTime==null)
            {
                 fields.Schedule_Sensitive_Message__c=null;
            }
            else{
                   convertInGMT({ selectedDateTime : this.selectedDateTime}).then(result => {
                    console.log('>>> here date and time for the comparison call in handleDateTimeChange'+JSON.stringify(result));
                    fields.Schedule_Sensitive_Message__c=result;
                    
                    console.log('>>> here is the fields schedule date time'+JSON.stringify(fields.Schedule_Sensitive_Message__c));
                    
                   
                }).catch(error => {
                    console.log('error in converting selected date and time in GMT'+JSON.stringify(error));
                });
        
                
            }   
            
        
        if (fields.Sensitive_Contact__c && (!fields.Sensitive_Contact_Message__c || fields.Sensitive_Contact_Message__c.length == 0)) {
            this.showToast('Field Error', 'Please add a message for sensitive contact.', 'error');
        }
        else if(this.showDateValidationMsg)
        {
            this.showToast('Field Error', 'Please select a valid date and time for sensitive contact message.', 'error');
        } 
        else {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showSpinner = true;
        }
    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.editMode = false;
    }

    handleError(event) {
        this.showSpinner = false;
    }
    

    handleOnload(event) {
        if (this.contactId) {
            let rec = event.detail.records[this.contactId];
            //console.log(JSON.stringify(event.detail.records[this.contactId]));
            this.richTextVal = getFieldValue(rec, CONTACT_SENSITIVEMESSAGE);
            let checkbox = getFieldValue(rec, CONTACT_SENSITIVECHECKBOX);
            this.selectedDateTime=getFieldValue(rec, CONTACT_SELECTEDDATETIME);

            console.log('>>> here is event load'+JSON.stringify(event));
            if(this.template.querySelector('.salesforceDateTime'))
            {
                console.log('>>> Inside the date time template'+this.previousSelectedDateTime);
                this.previousSelectedDateTime=this.template.querySelector('.salesforceDateTime').value;
                console.log('>>> Here is previously selected date and time'+this.previousSelectedDateTime);
            }
            
            

        getCurrentDateTime().then((result) => {
                console.log('>>> here is current date and time'+JSON.stringify(result));
                this.dateTime = result
            }).catch((error) => {
                console.log('error in fetching current date and time'+JSON.stringify(error));
            });
            console.log('>>> current date and time is here'+this.dateTime);

        compareDateTime({ contactId : this.contactId}).then(result => {
                console.log('>>> here date and time for the comparison call'+JSON.stringify(result));
                this.hideSensitiveMessage = result;
                
                console.log('>>> print the selected datetime on load'+this.selectedDateTime);
                console.log('>>> print the hide sensitive message on load'+this.hideSensitiveMessage);
                if(checkbox && !this.hideSensitiveMessage && (this.selectedDateTime==null || this.selectedDateTime==undefined))
                {
                    this.showPlaceholder = false;
                }
                else
                {
                    this.showPlaceholder = true; 
                }
                console.log('>>> here date and time comparison result'+this.hideSensitiveMessage);
            }).catch(error => {
                console.log('error in comparing  current date and time'+JSON.stringify(error));
            });
            
            

            
            
          
            
            const editor = this.template.querySelector('lightning-input-rich-text');
            if (!this.richTextVal && editor) {
                editor.setFormat({ align: 'center', size: 16, bold: true, color: 'red' });
            }
        }
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        const fields = event.detail.fields;
        console.log(JSON.stringify(fields));
        if (inputFields) { inputFields.forEach(field => field.reset()); }
        this.editMode = false;
     }

     resetLabel(event)
     {
        console.log('Reset Label is called');
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        const fields = event.detail.fields;
        console.log(JSON.stringify(fields));
        if (inputFields) { inputFields.forEach(field => field.reset()); }
     }

     handleRichChange(event) {
        this.richTextVal = event.target.value;
     }

    @wire(getRecord, { recordId: "$caseId", fields: [CASE_CONTACTID] })
    wiredCase({ error, data }) {
        if (data) {
            this.contactId = getFieldValue(data, CASE_CONTACTID);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactId = undefined;
        }
    }
}