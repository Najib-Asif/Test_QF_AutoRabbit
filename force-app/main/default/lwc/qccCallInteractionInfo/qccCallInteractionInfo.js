import { LightningElement, api, wire } from 'lwc';
import { publish,
        subscribe,
        unsubscribe,
        createMessageContext,
        releaseMessageContext,
        MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import getEnvSetting from '@salesforce/apex/QCC_VoiceUtils.getEnvSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QccCallInteractionInfo extends LightningElement {
    context = createMessageContext();
    subscription = null;
    @api interactionId;
    @api ssInteractionId;
    receivedMessage;  
    @api ssCaseNumber;
    @api genesysFlowId;
    @api queryDescription;
    
    caseNumber;
    isHovered;
    title;

    //IVR Details - NOTE: Last Name is not on the message?
    //@api isAuthenticated;
    @api authenticationStatus;
    @api qffNumber;
    @api callerBookingLastName;
    @api pnr;
    //CRM-8775
    @api pnrContains;
    @api pnrCreationDate;
    @api ivrSelection;
    @api waitTime;
    @api callerQueuedWaitTime
    @api queueName;
    @api callerName;
    @api callerLocation;
    @api phoneNumber;
    @api qffTier;
    @api paymentType='';
    @api travelType='';

    @wire(getEnvSetting)
        getEnvSetting({error, data}){
        if(data){
            this.genesysFlowId = data.Genesys_Flow_Id__c
        }
        else if(error){
            console.log("@@@@ getEnvSetting ERROR" , error);
        }
    }
    
    connectedCallback(){ 
        
    }

    get isAuthenticated() {
        return this.authenticationStatus === 'Authenticated';
    }

    handleMouseover() {
        this.isHovered = true;
    }

    handleMouseout() {
        this.isHovered = false;
    }

    //Call upon click of the button will ask the caller to give QFF number and PIN to authenticate the call
    //APR-18: Commenting out for testing, this is the authenticate function before change:
    // authenticate() {
    //     console.log('>>> NEW MAIN HANDLE MESSAGE AUTHENTICATE: ' + this.interactionId);
    //     const sec={
    //         type: 'PureCloud.Interaction.updateState',
    //         data: {
    //             action: 'secureSession',
    //             id: this.interactionId,
    //                 secureSessionContext:{
    //                     flowId:this.genesysFlowId,
    //                     userData:'QFFAuthenticated,QFFTier,QFFPreferredName,QFFNumber',
    //                     disconnect:false
    //                 }
    //             }
    //     }   
    //     publish(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, sec);
    // }


    authenticate() {
        console.log('>>> NEW MAIN HANDLE MESSAGE AUTHENTICATE: ' + this.interactionId);
        const sec={
            type: 'PureCloud.Interaction.updateState',
            data: {
                action: 'secureSession',
                id: this.interactionId,
                    secureSessionContext:{
                        flowId:this.genesysFlowId,
                        userData:'QFFAuthenticated,QFFTier,QFFPreferredName,QFFNumber',
                        disconnect:false
                    }
                }
        }   
        publish(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, sec);

        let secureFlowEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Secure flow is in progress - please wait while the customer securely enters their information.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(secureFlowEvent);
    }
    get callerQueuedWaitTimeMins()
    {
        return this.callerQueuedWaitTime?Math.ceil(this.callerQueuedWaitTime/60):undefined;
    }
}