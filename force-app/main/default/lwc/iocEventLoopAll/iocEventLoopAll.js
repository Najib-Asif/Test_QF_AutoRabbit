import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { registerListener, unregisterAllListeners } from 'c/pubsub'; 
import getAllList from '@salesforce/apex/IOCCJMCheckListController.getAllList';
import createAllEvents from '@salesforce/apex/IOCCJMCheckListController.createAllEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class IocEventLoopAll extends LightningElement {
    option='';
    mycheck;
    isoptionChanged= false;
    @api recordId;
    @track allRecords;
    txt= [];

    @wire(CurrentPageReference) pageRef;
    @wire(getAllList, {recordId: '$recordId'}) 
    lstActionPlan(result) {
       console.log('final result1...'+JSON.stringify(result));
        this.mycheck = result;
        if (result.data) {
            this.allRecords = result.data; 
        }
        console.log('final result...'+JSON.stringify(this.allRecords));
    }

    connectedCallback() {
        registerListener('optionChange', this.handleOnOptionChange, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleOnOptionChange(option){
        this.option = option;
        createAllEvents({recordId: this.recordId, checklistType: this.option}).then(() => {
             refreshApex(this.mycheck);
            return this.template.querySelector("c-ioc-dynamic-add").refreshOptions();
        })
    }

    refreshScreen(event){
        console.log('refreshed...'+event.detail);
        refreshApex(this.mycheck);
        if(event.detail != 'Created') {
            this.template.querySelector("c-ioc-dynamic-add").refreshOptions();
        }
    }

    handleCustomEvent(event) {
        const textVal = event.detail;
        const index =  this.txt.findIndex((record) => record.Id === textVal.Id);
          if(index === -1)
          this.txt.push(textVal);
          else
          this.txt[index] = textVal;
        console.log("event value:"+JSON.stringify(this.txt));
    
    }

    showToast(title, message, variant ) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}