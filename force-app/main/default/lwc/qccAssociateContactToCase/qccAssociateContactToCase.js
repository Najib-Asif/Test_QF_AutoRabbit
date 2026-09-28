import { LightningElement,api,track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import invokeAssociateContact from "@salesforce/apex/qcc_SearchTabAssociateContact.associateContact";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class QccAssociateContactToCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @api contactId;
    @api associate;
    @track hasRendered = true;

    renderedCallback()
    {
        if(this.hasRendered && this.associate==true)
        {
            console.log('>>> display the contact ID'+this.contactId);
            console.log('>>> display the case ID'+this.recordId);
            if(this.recordId!=null && this.contactId!=null)
            {
                invokeAssociateContact({ 
                    caseId : this.recordId, 
                    contactId : this.contactId
                    
                })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Contact is Associated',
                        message: 'Contact has been associated',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title : 'Error',
                        message : 'Error associating contact. Please Contact System Admin',
                        variant : 'error'
                    });
                    this.dispatchEvent(event);
                });
            }
            this.hasRendered=false;
        }
    }
}