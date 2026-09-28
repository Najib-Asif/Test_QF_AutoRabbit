import { api, LightningElement, wire } from 'lwc';
import getlatestAttachmentName from '@salesforce/apex/CongaTriggerUtility.getLatestAttachment';
import {NavigationMixin } from 'lightning/navigation';


export default class CongaTriggerPageWait extends NavigationMixin (LightningElement) {

    showSpinner;
    @api recordlId;
    @api proposalId;
    @api fileName;
    @api ownerId;

    connectedCallback() {
        
        this.showSpinner = true;
        let intervalId = setInterval(()=> {
            console.log('inside set interval');
            
            getlatestAttachmentName( {
                recordlId: this.recordlId,
                fileName: this.fileName,
                fileOwnerId: this.ownerId
            }).then(result => {
                if(result){
                    this.fileName = result.ContentDocument.Title;
                    clearInterval(intervalId);
                    this.showSpinner = false;
                }}).catch(error => {
                        console.log(error);
                        clearInterval(intervalId);
                    })

        },2000);

    }

    handleRelationshipRecords() {
        let objectName = this.recordlId.startsWith("500") ? 'Case' : this.recordlId.startsWith("a0H") ? 'Proposal__c' : 'Contract__c';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordlId,
                objectApiName: objectName,
                relationshipApiName: 'AttachedContentDocuments',
                actionName: 'view'
            }
        });

    }

}