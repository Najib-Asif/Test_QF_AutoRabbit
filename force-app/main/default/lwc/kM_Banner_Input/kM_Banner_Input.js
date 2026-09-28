import { LightningElement,wire } from 'lwc';
import getBannerText from '@salesforce/apex/KM_Banner_Controller.fetchBannerText';
import updateBannerText from '@salesforce/apex/KM_Banner_Controller.updateBannerText';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KM_Banner_Input extends LightningElement {
    @wire(getBannerText) bannerInfo;
 
    handleSave() {

        console.log('Push****'+this.template.querySelector("lightning-input-rich-text").value)
        
        updateBannerText({  metdataName: 'KM_Banner_Config__mdt',
                            recordDevName : 'Internal_Community_Banner',
                            label : 'Internal Community Banner',
                            fieldToUpdate : 'Banner_Text__c',
                            valToUpdate : this.template.querySelector("lightning-input-rich-text").value})
            .then(result => {
                console.log('Banner updated successfully');
                const evt = new ShowToastEvent({
                    //title: this._title,
                    message: 'Banner Text Updated Successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                console.log('Error');
            });
    }

    handleClear(){
        this.template.querySelector("lightning-input-rich-text").value = '';
    }
}