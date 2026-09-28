import {LightningElement,api,track,wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import COUNTRY_FIELD from '@salesforce/schema/User.Country';
import variationProposal from '@salesforce/apex/QEC_ContractVariationController.variationProposal';
import childContractClone from '@salesforce/apex/QEC_ContractVariationController.childContractClone';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class QecContractVariation extends NavigationMixin(LightningElement) {
discountSpecialCondition = false;
renewal = false;
@track usercountry;
@track loaded = false;
@track varProposal;
@track childContractClone;
@track error
@api recordId;

 @wire(getRecord, {
recordId: USER_ID,
fields: [COUNTRY_FIELD]
}) wireuser({error,data}) {
if (error) {
this.error = error ;
} else if (data) {
this.usercountry = data.fields.Country.value;
}
}

 get isUSUser(){
return this.usercountry == 'US';
}

 get isAUUser(){
return this.usercountry == 'AU';
}

 handleChange(event){
let x= this.template.querySelectorAll("lightning-input");

 if(event.target.value === 'discountSpecialCondition'){
this.discountSpecialCondition = event.detail.checked;
for(let i=0;i<x.length;i++){
if(x[i].value === 'renewal'){
x[i].disabled = this.discountSpecialCondition;
}
}
}
else if(event.target.value === 'renewal'){
this.renewal = event.detail.checked;
for(let i=0;i<x.length;i++){
if(x[i].value === 'discountSpecialCondition'){
x[i].disabled = event.detail.checked;
}
}
}
}

 handleSubmit(){
this.loaded = true;
if(this.discountSpecialCondition || this.renewal){
variationProposal({recordId: this.recordId, renewal : this.renewal})
.then(result => {
if(result.error == null){
this.varProposal = result;
this.loaded = false;
const closeEvent = new CustomEvent('CloseQuickAction');
this.dispatchEvent(closeEvent);
this[NavigationMixin.Navigate]({
type: 'standard__recordPage',
attributes: {
recordId: result.recID,
actionName: 'view',
objectApiName : 'Proposal__c'
}
});

 if(this.discountSpecialCondition)
this.showToast('Success!','Proposal created for variation','success');
else
this.showToast('Success!','Renewal Opportunity and Proposal created','success');
}else{
this.showToast('Error!',result.error,'error');
this.loaded = false;
const closeEvent = new CustomEvent('CloseQuickAction');
this.dispatchEvent(closeEvent);
}
})
.catch(error => {
this.error = error;
this.loaded = false;
this.showToast('Error!','An error occurred!','error');
});
}
else{
this.loaded = false;
this.showToast('Error!','Please select the variation type and click Submit','error');
}
}

 showToast(title,msg,variant){
const evt = new ShowToastEvent({
title: title,
message: msg,
variant: variant
});
this.dispatchEvent(evt);
}

 handleCancel(){
const closeEvent = new CustomEvent('CloseQuickAction');
this.dispatchEvent(closeEvent);
}

}