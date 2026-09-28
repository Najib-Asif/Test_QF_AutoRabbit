import { LightningElement, api } from 'lwc';

export default class Lwcchatpack_paymentcard extends LightningElement {

    @api pcnumber;

    handleClick(event) {
        // Send Custom Event to Agent
        this.dispatchEvent(new CustomEvent('xpayevent', {
            detail: this.pcnumber
        }));

    }

    handlePCNumberChange(e) {
        this.pcnumber = e.detail.value;
    }
}