import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class ToastMessage extends LightningElement {
    @api type = "info";
    @api title;
    @api message;
    @api mode;

    connectedCallback(){
        this.displayToast();
    }

    displayToast(){
        // Notify the flow to finish
        this.dispatchEvent( new FlowNavigationFinishEvent());
        //Show toast message
        const event = new ShowToastEvent({
            title: this.title,
            message:
                this.message,
            variant: this.type,
            mode: this.mode
        });
        this.dispatchEvent(event);
    }
}