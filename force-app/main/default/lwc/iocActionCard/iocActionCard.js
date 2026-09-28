import { LightningElement, api, track } from 'lwc';
import deleteDynamicRecord from '@salesforce/apex/IOCCJMCheckListController.deleteDynamicRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class IocActionCard extends LightningElement{
    @track _rec = {};
    @track isEdit;
    @track editRec;
    @track tempVar;
    @track tempStore = {};
    obj = {Comments: '',ActionCompleted:'' };
    flowName;
    isShowModal = false;
    inputVariable = [];
    
    @api
    get rec(){
        return this._rec;
    }

    set rec(val){
        this._rec = JSON.parse(JSON.stringify(val));
        if(this._rec.completeAction != 'NA') {
            this._rec.actionPlan.hasCA = true;
            this._rec.actionPlan.compAction = this._rec.completeAction;
        }else{
            this._rec.actionPlan.hasNoCA = true;
        }
        console.log('action plan rec...'+JSON.stringify(this._rec));
    }

    get actPlanRec(){
        return this.rec != null ? this.rec.actionPlan : null;
    }

    get buttonLabel(){
        return this.actPlanRec != null && this.actPlanRec.ActionCompleted__c == false? 'Complete Action' : 'Update Action';
    }

    get showForm(){
        return this.actPlanRec != null? true: false;
    }

    handleCancelClick(event){
        this.isEdit = false;
        this.editRec = '';
    }

    handleEditClick(event){
        this.isEdit = true;
        this.editRec = this.rec.actionPlan;
    }

    handleDeleteClick(event){    
        deleteDynamicRecord({objActionPlan: this.rec.actionPlan})
        .then(() => {
            event.preventDefault();
            const updatedEvent =  new CustomEvent('updated', { detail: 'Success' });
            this.dispatchEvent(updatedEvent);
            this.showToast('', '"' + this.actPlanRec.Name + '" action removed!  ', 'Success');            
        })
    }

    handleCompleteAction(event){
        this.isShowModal = true;
        this.inputVariable = [{
            name: "recordId",
            type: "String",
            value: this.actPlanRec.Id
        }];
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    handleSaveAction(){
        setTimeout(() => {
            this.refreshRecords();
        }, 500);
        this.showToast('Success', this.actPlanRec.Name + ' action completed successfully.', 'Success');
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.handleFinish();
            this.refreshRecords();
        }
    }

    refreshRecords(){
        const updatedEvent =  new CustomEvent('updated', { detail: 'Success' });
        this.dispatchEvent(updatedEvent);
    }

    handleFinish() {
        this.isShowModal = false;
        console.log('this.actPlanRec:::'+this.actPlanRec);
        this.showToast('Success', this.actPlanRec.Name + ' action completed successfully.', 'Success');
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