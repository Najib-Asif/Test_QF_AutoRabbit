import { LightningElement } from 'lwc';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import createTransferTask from '@salesforce/apex/QCCTaskController.createTransferTask';
export default class QccTransferNotes extends LightningElement {

    context = createMessageContext();
    subscription = null;
    transferNotes;
   
    connectedCallback(){ 
        this.handleSubscribe(); 
    }

    disconnectedCallback() {
        console.log('@@@ disconnectedCallback Transfer Notes');
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }
    handleSubscribe() {
        if (this.subscription) {
            console.log('@@@ this.subscription POPULATED ALREADY Transfer Notes');
            return;
        }
        this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }

    handleUnsubscribe() { 
        unsubscribe(this.subscription);
        this.subscription = null;
    }   

    handleMessage(message) {
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        console.log('received message'+this.receivedMessage);
        console.log('^^^^^^received message category'+message.category);
        if(message.category ==='add')
        {
            console.log('>>>message category data CHANGE in ADD'+JSON.stringify(message));
          
            if (message.data.attributes)
            {
                this.transferNotes=(message.data.attributes?.['Participant.TransferNotes']) ?message.data.attributes?.['Participant.TransferNotes']: '';
            }
            
           
        }
        if(message.category ==='change')
        {
            console.log('>>>message category data CHANGE in Change'+JSON.stringify(message));
          
            if (message.data.new.attributes)
            {
                this.transferNotes=(message.data.new.attributes?.['Participant.TransferNotes']) ?message.data.new.attributes?.['Participant.TransferNotes']: '';
            }
            if (message.data.old.attributes)
            {
                this.transferNotes=(message.data.old.attributes?.['Participant.TransferNotes']) ?message.data.old.attributes?.['Participant.TransferNotes']: '';
            }
        
        }
        if(message.category ==='acw')
        {
            console.log('>>>message category data CHANGE in ACW '+JSON.stringify(message));
            this.transferNotes='';
        
        }
        if(message?.category ==='completeConsultTransfer' || message?.category ==='blindTransfer')
        {
            console.log('>>>message category data in Transfer Calls '+JSON.stringify(message));
            //messageJson = JSON.stringify(message);
            createTransferTask({ getMessage: JSON.stringify(message) })
            .then(result => {
                console.log('Transfer Log Successfully Created!');
            })
            .catch(error => {
                console.error('Error creating Transfer log!:', error);
            });
        
        }
        console.log('>> the print the transfer notes'+this.transferNotes);
    }
}