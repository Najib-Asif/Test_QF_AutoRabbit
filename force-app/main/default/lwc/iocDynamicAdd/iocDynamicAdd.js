import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getDynnamicOptions from '@salesforce/apex/IOCCJMCheckListController.getDynnamicOptions';
import createDynamicActionItem from '@salesforce/apex/IOCCJMCheckListController.createDynamicActionItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class IOCCheckListOptions extends LightningElement {
    @api value = '';
    @api recordId;
    @api selectedOption;
    mycheck;
    @track dynamicOption;
    @wire(getDynnamicOptions, {recordId: '$recordId', checklistType: '$selectedOption'})
    lstOptions(result) {
        this.mycheck = result;
        this.dynamicOption=[];
        if(typeof this.mycheck.data !== "undefined"){
            let self = this.mycheck.data;
            self.forEach(singleVal => {
                this.dynamicOption.push({ 
                    label: singleVal,
                    value: singleVal
                });
            });
        }
        console.log(JSON.stringify(this.mycheck ));
    }

    handleChange(event) {   
        this.value = event.detail.value;
    }

    @api
    refreshOptions(){
        refreshApex(this.mycheck);
    }

    addNewRec(){
        if(typeof this.mycheck.data !== "undefined"){
            refreshApex(this.mycheck);
        }
    }
    
    createdNew(event){
        console.log('this.value11::'+this.value);
        if(this.value === null || this.value === undefined || this.value === ''){
            this.showErrorToast();
        }
        else{
            createDynamicActionItem({name: this.value, recordId: this.recordId})
            .then(() => { 
                event.preventDefault();
                const complete= 'Finished';
                const currentVal = new CustomEvent('newrecord', {detail: 'Created'});
                this.dispatchEvent(currentVal);
                this.showToast('', '"' + this.value + '" action added!  ', 'Success');            
                if(typeof this.mycheck.data !== "undefined"){
                    refreshApex(this.mycheck);
                }
            })
        }
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error!',
            message: 'Select a checklist item to add to the action plan.',
            variant: 'error',  
        });
        this.dispatchEvent(event);
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