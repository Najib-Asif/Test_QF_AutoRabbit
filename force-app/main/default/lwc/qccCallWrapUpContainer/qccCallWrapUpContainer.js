import { LightningElement, api } from 'lwc';
import getLatestTask from '@salesforce/apex/QCCTaskController.getLatestTask';
import getCallReason from '@salesforce/apex/QCCTaskController.getCallReason';
import getCaseRecord from '@salesforce/apex/QCCTaskController.getCaseDetailsBasedOnInteraction';
import SF_EVENT_CALLSESSION_MESSAGE_CHANNEL from '@salesforce/messageChannel/QCC_Call_Session_Channel__c';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';

export default class QccCallWrapUpContainer extends LightningElement {
    @api recordId;
    
    //wrapUpVariables
    @api caseId;
    @api interactionId = '';
    @api ivrSelection = '';
    @api callReason = '';
    @api outboundCaseId = '';
    @api genesysUserId = '';
    @api participantId = '';

    showFlow;
    showSpinner = true;

    //handleCurrentTask
    latestTask;
    taskId;
    taskWhatId;
    taskCallType;
    @api taskCallObject;

    callReasonData;
    callStatus;
    callState;

    callData;
    callWhatId;
    callDirection;

    //LMS
    context = createMessageContext();
    subscriptionSF = null;
    
    connectedCallback(){
        this.init();
        this.caseId = this.recordId;
        this.handleSubscribe();
    }

    async init() {
        try {
            console.log('@@@ CWUC HANDLE MESSAGE init recordId: ', this.recordId);
            const callConnectgetSessionStoragePromise = await this.getSessionStorage();
            const getIVRMetadataPromise = await this.handleIVRMetadata();
            //const getCurrentTaskPromise = await this.handleCurrentTask();
            const getCaseDetailsPromise = await this.getCaseDetails();
            
        } catch (error) {
            console.error(JSON.stringify(error));
        }
    }

    async getOutboundCall() {
        try{
            console.log('@@@ CWUC HANDLE MESSAGE getOutboundCall recordId: ', this.recordId);
            const callConnectgetSessionStoragePromise = await this.getSessionStorage();
            const getCaseDetailsPromise = await this.getCaseDetails();
            // this.showFlow = true;

        } catch (error) {
            console.error(JSON.stringify(error));
        }
    }

    handleSubscribe() {
        this.subscriptionSF = subscribe(this.context, SF_EVENT_CALLSESSION_MESSAGE_CHANNEL, (message) => {
            this.handleMessageSF(message);
        });
    }

    handleUnsubscribe() { 
        unsubscribe(this.subscriptionSF);
        this.subscriptionSF = null;
    }   

    handleMessageSF(message) {
        console.log('@@@ CWUC HANDLE MESSAGE handleMessageSF:', JSON.stringify(message));
        if (message.messageToSend == 'CALL_CONNECTED') {
            this.showFlow = false;
            this.showSpinner = true;
            this.getOutboundCall();
        }
    }

    getSessionStorage() {
        console.log('@@@ CWUC HANDLE MESSAGE getSessionStorage recordId: ', this.recordId);
        return new Promise((resolve, reject) => {
            this.showFlow = false; //This will refresh the screen flow

            if(sessionStorage.getItem('interactionId')){
                this.interactionId = sessionStorage.getItem('interactionId');              
            }
            if(sessionStorage.getItem('ivrSelection')){ //This will only be set for inbound calls
                this.ivrSelection = sessionStorage.getItem('ivrSelection');
            }
            if(sessionStorage.getItem('genesysUserId')){ //This is to get the user id that will be attached to the wrapup integration event later
                this.genesysUserId = sessionStorage.getItem('genesysUserId');
            }
            if(sessionStorage.getItem('participantId')){ //This is to get the participant id to be used to update the call log attached that the agent initiated
                this.participantId = sessionStorage.getItem('participantId');
            }
            if(sessionStorage.getItem('outboundCaseId')){ //This will only be set for outbound calls
                this.outboundCaseId = sessionStorage.getItem('outboundCaseId');
            }

            resolve('Success');
        });
    }

    disconnectedCallback() {
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }

    renderedCallback() {
        this.subscriptionSF = subscribe(this.context, SF_EVENT_CALLSESSION_MESSAGE_CHANNEL, (message) => {
            this.handleMessageSF(message);
        });
    }

    handleCurrentTask() { //Set Call Reason to blank if there is no on going call
        console.log('@@@ CWUC HANDLE MESSAGE handleCurrentTask callReason: ', this.callReason);
        return getLatestTask({ recordId: this.recordId })
        .then(result => {
            console.log('@@@ CWUC HANDLE MESSAGE handleCurrentTask: ', JSON.stringify(result));
            this.latestTask = result;
            this.taskCallObject = (result[0]?.CallObject) ? result[0].CallObject : '';

            if (result.length == 0) { //No previous call scenario
                this.showFlow = false;
                this.showSpinner = false;
            } 
            else if(this.interactionId !== result[0]?.CallObject){ //Task is not related to the active call
                this.callReason = ''; //Call reason set to blank by default if the Case opened is not related to the call
                this.showFlow = true;
                this.showSpinner = false;
            }
            return result;
            
        })
        .then(result => {
            console.log('@@@ CWUC HANDLE MESSAGE handleCurrentTask finally');
            console.log('@@@ CWUC HANDLE MESSAGE handleCurrentTask finally result: ', JSON.stringify(result));
            if (result.length > 0) {
                this.showFlow = true;
                this.showSpinner = false;
            }
        })
        .catch(error =>{
            console.error(JSON.stringify(error));
        });
        
    }

    handleIVRMetadata(){ //This will set the IVR Selection/Call Reason for Inbound calls
        console.log('@@@ CWUC HANDLE MESSAGE handleIVRMetadata ivrSelection: ', this.ivrSelection);
        return getCallReason({ ivrSelected: this.ivrSelection })
        .then(result => {
            this.callReasonData = result;
            this.callReason = (result[0]?.Call_Reason__c) ? result[0].Call_Reason__c : '';
        })
        .catch(error =>{
            console.error(JSON.stringify(error));
        });
    }

    getCaseDetails() {
        console.log('@@@ CWUC HANDLE MESSAGE getCaseDetails callReason: ', this.callReason);
        console.log('@@@ CWUC HANDLE MESSAGE getCaseDetails interactionId: ', this.interactionId);
        console.log('@@@ CWUC HANDLE MESSAGE getCaseDetails outboundCaseId: ', this.outboundCaseId);
        return getCaseRecord({ interaction: this.interactionId, caseId: this.caseId, outboundCaseId: this.outboundCaseId })
        .then(result => {
            console.log('@@@ CWUC HANDLE MESSAGE getCaseDetails result: ', JSON.stringify(result));
            if (result.length == 0) { //Case record on screen is not what initiated the call
                let caseInfo = result[0];
                return true;
                
            } else { //Case record on screen is related to the active call
                this.showFlow = true;
                this.showSpinner = false;
                return false;
            }
        })
        .then(result => {
            if(result){ // If there is no interactionId from an active call, this will retrieve last task attached to the case
                this.handleCurrentTask();
            }
        })
        .catch(error =>{
            // If there is no interactionId from an active call, (there is no ongoing call) this will retrieve last task attached to the case
            this.handleCurrentTask();
            console.log('@@@ CWUC HANDLE MESSAGE getCaseDetails catch error on ongoing call');
        });
   }
}