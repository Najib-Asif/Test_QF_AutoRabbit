import { LightningElement, api } from 'lwc';

export default class DatatableColumnClickHandler extends LightningElement {
    @api pnrNum;


    navigateToBookingDetail() {
        const event = new CustomEvent('datatablecolumnclickhandler', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                pnrNum: this.pnrNum
            },
        });
        this.dispatchEvent(event);
    }
}