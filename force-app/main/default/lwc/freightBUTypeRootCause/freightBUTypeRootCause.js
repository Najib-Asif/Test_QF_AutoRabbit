import { LightningElement,api,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FreightBUTypeRootCause extends LightningElement {

    @api recordId;
    @api objectApiName = "Case";

    recordTypeId;
    canEditFields = false;

    isLoading = false;
    showModal = false;

    level1FieldLabel;
    level2FieldLabel;
    level3FieldLabel;

    level1FieldApiName = 'Business_Type__c';
    level2FieldApiName = 'Resolved_Reasons_Sub_Type__c';
    level3FieldApiName = 'Freight_Resolve_Reason__c';
    resolutionCommentApiName ='Freight_Resolve_Comments__c';

    // Selected values
    selectedLevel1Value;
    selectedLevel2Value;
    selectedLevel3Value;
    updatedResolutionComments ;


    originalLevel1Value;
    originalLevel2Value;
    originalLevel3Value;
    originalResolutionComments ;

    

    get Fields() {
            return this.objectApiName ? [
                `${this.objectApiName}.RecordTypeId`, 
                `${this.objectApiName}.${this.level1FieldApiName}`,
                `${this.objectApiName}.${this.level2FieldApiName}`, 
                `${this.objectApiName}.${this.level3FieldApiName}`,
                `${this.objectApiName}.${this.resolutionCommentApiName}`
            ] : [];
        }

    @wire(getRecord, { recordId: '$recordId', fields: '$Fields' })
    wiredRecord({ data, error }) {
        if (data) {
            this.recordTypeId = data.fields?.RecordTypeId?.value;
            this.originalLevel1Value = data.fields?.[this.level1FieldApiName]?.value;
            this.originalLevel2Value = data.fields?.[this.level2FieldApiName]?.value;
            this.originalLevel3Value = data.fields?.[this.level3FieldApiName]?.value;
            this.originalResolutionComments = data.fields?.[this.resolutionCommentApiName]?.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.recordTypeId = undefined;
            console.error('getRecord error:', error);
        }
    }

    @wire(getObjectInfo,{objectApiName:'$objectApiName'})
    objectInfo({data,error}){
        if(data){
            const fieldsToCheck = [this.level1FieldApiName, this.level2FieldApiName,this.level3FieldApiName,this.resolutionCommentApiName];
            this.canEditFields = fieldsToCheck.every(fieldApi => {
                 return data.fields[fieldApi]?.updateable;
            })
            this.level1FieldLabel = data?.fields?.[this.level1FieldApiName]?.label ?? this.level1FieldApiName;
            this.level2FieldLabel = data?.fields?.[this.level2FieldApiName]?.label ?? this.level2FieldApiName;
            this.level3FieldLabel = data?.fields?.[this.level3FieldApiName]?.label ?? this.level3FieldApiName;
        }
    }

    
    handledualControlledPicklistChange(event) {
        const { level1, level2, level3 } = event.detail || {};
        this.selectedLevel1Value = level1;
        this.selectedLevel2Value = level2;
        this.selectedLevel3Value = level3;
        
    }

    handleResolutionCommentsChange(event){
        this.updatedResolutionComments = event.target.value;
    }

    async handleSave(){
        
        try {

            
            // Trigger validation on all lightning-inputs
                
            const childCmp = this.template.querySelector(
                    'c-dual-controlled-dependent-picklist'
                );
            const isChildValid = childCmp ? childCmp.validate() : true;

            
            const inputs = this.template.querySelectorAll('lightning-input');
                let isParentValid = true;

                inputs.forEach(input => {
                    if (!input.checkValidity()) {
                        input.reportValidity();
                        isParentValid = false;
                    }
                });
                
            if (!isChildValid || !isParentValid) {
                return; 
            }


            
            this.isLoading = true; // start spinner
            await Promise.resolve();
            const fields = {Id: this.recordId};
            fields[this.level1FieldApiName] = this.selectedLevel1Value;
            fields[this.level2FieldApiName] = this.selectedLevel2Value;
            fields[this.level3FieldApiName] = this.selectedLevel3Value;
            fields[this.resolutionCommentApiName] = this.updatedResolutionComments;

            await updateRecord({ fields });

            this.showModal = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case updated successfully.',
                    variant: 'success'
                })
            );

        }catch (error){
            console.error('updateRecord error =>', JSON.stringify(error));
            const message =
                error?.body?.message ||
                error?.body?.output?.errors?.[0]?.message ||
                'Unknown error occurred';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error'
                })
            );

        }finally {
            this.isLoading = false; 
        }
    }

    get isResolutionCommentRequired() {
        return !!this.selectedLevel1Value || !!this.originalLevel1Value;
    }
/*
    get isSaveDisabled(){
        return !(this.recordId && this.selectedLevel1Value && this.selectedLevel2Value && this.selectedLevel3Value);
    }
*/
    handleCancel(){
        this.showModal = false;
        this.selectedLevel1Value = '';
        this.selectedLevel2Value = '';
        this.selectedLevel3Value = '';
        this.updatedResolutionComments='';
    }
    
    openModal(){
        this.showModal = true;
        this.isLoading = true;  
    }

    handleReady(){
        this.isLoading = false;
    }


}