import { LightningElement, track } from 'lwc';

export default class Lwcchatpack_helloworld extends LightningElement {
    @track innerHtml = 'my html';
    @track pcnumber;
    postMessage(e) {
        this.dispatchEvent(new CustomEvent('postmessage', {
            detail: e
        }));
    }
}