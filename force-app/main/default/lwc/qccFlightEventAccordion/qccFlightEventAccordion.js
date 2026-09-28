import { LightningElement , api } from 'lwc';
export default class QccFlightEvnetAccordion extends LightningElement {
    @api flghtEvntItem;
    dynamicClass = 'slds-summary-detail slds-is-close';
    dynamicChevron = 'utility:chevronright';
    handleToggle(event){
        this.dynamicClass = this.dynamicClass === 'slds-summary-detail slds-is-close' ? 'slds-summary-detail slds-is-open' : 'slds-summary-detail slds-is-close';
        this.dynamicChevron = this.dynamicChevron === 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright';

    }
    
}