/**
 * @description       : Popup window will appear which has list of checklist and New case will be created with Deal Support record type
 * @author            : Gokulakannan Perumal
 * @group             : 
 * @Created on        : 05-24-2024
 * @last modified by  : Gokulakannan Perumal
**/
import { LightningElement, api, wire } from 'lwc';
import fetchDSCasefields from '@salesforce/apex/QL_RecordTypeSelectionController.fetchDSCasefields';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class QL_NewDealSupportCaseLWC extends NavigationMixin (LightningElement) {
@api recordId;
accountId;
recordTypeId ='01290000001IINIAA4';
isShowModal = true;
isChecked = false;

@wire(fetchDSCasefields,{contId : '$recordId'})
context({data,error}){
    if(data){
      console.log('Account Id'+JSON.stringify(data)); 
      this.accountId = data; 
    }
    else if(error){
        console.log(error);
    }
}

checkboxhandler(event){
   this.isChecked = event.target.checked;
}

handleCase(){
if(this.isChecked){
this.isShowModal=false;
const defaultValues = encodeDefaultFieldValues({
    Related_Contract__c : this.recordId,
    AccountId : this.accountId,
});

this[NavigationMixin.Navigate]({
    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'Case',
        actionName: 'new'
    },
    state: {
        defaultFieldValues: defaultValues,
        recordTypeId: this.recordTypeId
        
    }
});
}
}
}