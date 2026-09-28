import { LightningElement, api, wire, track } from 'lwc';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import getEnvSetting from '@salesforce/apex/QCC_VoiceUtils.getEnvSetting';
import getCaseRecord from '@salesforce/apex/QCCTaskController.getCaseDetailsBasedOnInteraction'; //Apr-15 added to check if current Case opened is related to the current call
import {ShowToastEvent} from "lightning/platformShowToastEvent";
export default class QccWrapUpButtons extends NavigationMixin(LightningElement) {
    //Changed header from extends LightningElement to NavigationMixin(LightningElement)
    //Added import { NavigationMixin }
    //Added method sendWrapup called from handleGoNext
    @api recordId;
    @api caseId;
    @api interactionId;
    @api isSurveySelected;
    @api availableActions = [];
    @api postSurveyTarget;
    @api outboundCaseId = '';
    @api inputNotes;

    //LMS
    context = createMessageContext();
    subscription = null;
    receivedMessage = '';
    agentInitialStatus;

    @api displaySurveyButton;   
    callState;
    @api displaySaveButton=false;

    isDisconnected;
    caseForTheCall;
    phoneCalled;
    isCallInternal;
    @api internalCallWrapupReminder;

    @wire(getEnvSetting)
        getEnvSetting({error, data}){
        if(data){
            this.postSurveyTarget = data.Voice_Survey_Target__c
        }
        else if(error){
            console.log("@@@WUB HANDLE MESSAGE getEnvSetting ERROR" , error);
        }
    }
    
    connectedCallback(){
        this.init();
        this.caseId = this.recordId; //Added for getCaseRecord()
        console.log('@@@WUB HANDLE MESSAGE connectedCallback caseid and recordid', this.caseId, this.recordId);
    }

    async init() {
        try {
            this.handleSubscribe()
            console.log('@@@WUB HANDLE MESSAGE INIT handleSubscribe');

            const getSessionStoragePromise = await this.getSessionStorage();
            console.log('@@@WUB HANDLE MESSAGE INIT AWAIT getSessionStorage');

            const getCaseDetailsPromise = await this.getCaseDetails();
            console.log('@@@WUB HANDLE MESSAGE INIT AWAIT getCaseDetailsPromise');

        } catch (error) {
            console.log('@@@WUB HANDLE MESSAGE INIT ERROR: ' + JSON.stringify(error));
        }
        
    }

    async getSessionAndCase() {
        try {
            const getSessionStoragePromise = await this.getSessionStorage();
            console.log('@@@WUB HANDLE MESSAGE getSessionAndCase AWAIT getSessionStorage');

            const getCaseDetailsPromise = await this.getCaseDetails();
            console.log('@@@WUB HANDLE MESSAGE getSessionAndCase AWAIT getCaseDetailsPromise');

        } catch (error) {
            console.log('@@@WUB HANDLE MESSAGE getSessionAndCase ERROR: ' + JSON.stringify(error));
        }
        
    }

    handleSubscribe() {
        return new Promise((resolve, reject) => {
            if (this.subscription) {
                return;
            }
            this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
                this.handleMessage(message);
            });
            resolve('Success');
        });
        
    }

    handleUnsubscribe() { 
        unsubscribe(this.subscription);
        this.subscription = null;
    }   

    handleMessage(message) {
        this.category = message.category;

        switch (this.category) {
            
            case 'add': 
                console.log('@@@WUB HANDLE MESSAGE CHANGE ADD this.interactionId', message.data.id);
                this.interactionId = message.data.id;
                this.callState = message.data.state;
                this.getSessionAndCase();
            break;

            //2023-06-02: Added category 'change' to check the phone called if it is an Internal call
            case 'change': 
                this.phoneCalled = message.data.new.phone;

                this.isCallInternal = /*this.phoneCalled.includes("mypurecloud") || */ this.phoneCalled.includes("qantasairwayslimited");
                console.log('@@@WUB HANDLE MESSAGE CHANGE is the call internal: ', this.isCallInternal, 'this.phoneCalled: ', this.phoneCalled);
                
                //2023-06-03: Added if condition to check if the call is not internal and is still connected
                //Example: If customer was un-hold after wrapping up an internal call
                if(this.caseId === this.caseForTheCall){
                    if(!this.isCallInternal && message.data.new.isConnected){
                        this.internalCallWrapupReminder = '';
                        this.displaySurveyButton = true;
                        this.displaySaveButton = true;
                        console.log('@@@WUB HANDLE MESSAGE CHANGE Not Internal and Connected case Id: ', this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
                    } 
                }
            break;
            
            case 'disconnect':
                this.phoneCalled = message.data.phone;

                this.isCallInternal = /*this.phoneCalled.includes("mypurecloud") || */ this.phoneCalled.includes("qantasairwayslimited");
                console.log('@@@WUB HANDLE MESSAGE DISCONNECT is the call internal: ', this.isCallInternal, 'this.phoneCalled: ', this.phoneCalled);

                if(this.caseId === this.caseForTheCall){
                    if(!this.isCallInternal){
                        //2023-06-03: In case there is a parallel call (i.e a new interaction internal call made while on the call with customer), the isCallInternal will be set to TRUE, but will revert back to FALSE when survey is initiated to the customer as it will return back to the customer's interactionId
                        this.internalCallWrapupReminder = '';
                        this.displaySurveyButton = false;
                        this.displaySaveButton = true;
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id inbound call for the case NOT internal: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton + 'phoneNumber: ' + this.phoneNumber);
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id inbound call for the case NOT internal: this.isCallInternal ',this.isCallInternal, ' this.phoneCalled: ',this.phoneCalled);
                    } else if(this.isCallInternal && message.data.queueName !== undefined){
                        //2023-06-04: Wrap up for internal call scenario is only required if consultant called on behalf of a queue
                        this.internalCallWrapupReminder = 'For internal calls, if the Softphone is requiring a wrap up, please ensure to wrap up on the Softphone.';
                        this.displaySurveyButton = false;
                        this.displaySaveButton = false;
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id inbound call for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton + 'phoneNumber: ' + this.phoneNumber);
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id inbound call for the case internal: this.isCallInternal ',this.isCallInternal, ' this.phoneCalled: ',this.phoneCalled);
                    }
                    
                
            //2023-06-02: Added the else if(this.caseId === this.outboundCaseId) block below to solve issue with dropped outbound calls that the save button is disabled. Check if outboundCaseId is same as caseId and enable the 'Save' button if the call is disconnected. The if condition above 'if(this.caseId === this.caseForTheCall)' is not getting the outboundCaseId.
                } else if(this.caseId === this.outboundCaseId){
                    if(!this.isCallInternal){
                        this.internalCallWrapupReminder = '';
                        this.displaySurveyButton = false;
                        this.displaySaveButton = true;
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id Outbound call for the case: NOT internal: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton + ' outboundCaseId : ' + this.outboundCaseId);
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id Outbound call for the case: NOT internal: this.isCallInternal ',this.isCallInternal, ' this.phoneCalled: ',this.phoneCalled);
                    } else if(this.isCallInternal && message.data.queueName !== undefined){
                        //2023-06-04: Wrap up for internal call scenario is only required if consultant called on behalf of a queue
                        this.internalCallWrapupReminder = 'For internal calls, if the Softphone is requiring a wrap up, please ensure to wrap up on the Softphone.';
                        this.displaySurveyButton = false;
                        this.displaySaveButton = false;
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id Outbound call for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton + ' outboundCaseId : ' + this.outboundCaseId);
                        console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id Outbound call for the case: internal: this.isCallInternal ',this.isCallInternal, ' this.phoneCalled: ',this.phoneCalled);
                    }
                    
                
                } else {
                    this.displaySurveyButton = false;
                    this.displaySaveButton = false;
                    console.log('@@@WUB HANDLE MESSAGE DISCONNECT Case Id inbound call NOT for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
                }
                this.isDisconnected = true;
                this.callState = message.data.state;
            break;

            case 'acw':
                console.log('@@@WUB HANDLE MESSAGE ACW Case Id ', this.caseId);
                //2023-06-03: Added if condition to clear case for the call only if the wrap up is being done for a non-internal call. (i.e.: Normal inbound and outbound)
                if(!this.isCallInternal){
                    this.caseForTheCall = null;
                    this.displaySurveyButton = false;
                    this.displaySaveButton = true;
                }
                this.internalCallWrapupReminder = '';

                console.log('@@@WUB HANDLE MESSAGE ACW Case Id '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
            break;
            
            //If previous call was not completely wrapped up, reset the values when this event comes and there is no active interaction or call
            case 'interactionSelection':
                //this.interactionId = message.data.interactionId;
                console.log('@@@WUB HANDLE MESSAGE interactionSelection Case Id ', this.caseId + message.data.interactionId);

                if(!message.data.interactionId){
                    
                    this.caseForTheCall = null;
                    this.displaySurveyButton = false;
                    this.displaySaveButton = true;

                    console.log('@@@WUB HANDLE MESSAGE interactionSelection no ongoing call: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
                } 
            break;
        } 

    }

    getSessionStorage() {
        return new Promise((resolve, reject) => {
            if(sessionStorage.getItem('interactionId')){
                this.interactionId = sessionStorage.getItem('interactionId');
    
                console.log('@@@WUB HANDLE MESSAGE getSessionStorage SS INTERACTIONID: ', this.interactionId);
            } 
            //2023-06-02: Updated line below from if(sessionStorage.getItem('transferCaseId')) to solve issue with dropped outbound calls that the save button is disabled. Setting outboundCaseId for getCaseDetails() otherwise it will see the transaction as 'Inbound' instead of 'Outbound'
            if(sessionStorage.getItem('transferCaseId')){
                this.outboundCaseId = sessionStorage.getItem('transferCaseId');
                console.log('@@@WUB HANDLE MESSAGE getSessionStorage SS transferCaseId: ', this.outboundCaseId);
            } else if(sessionStorage.getItem('outboundCaseId')){
                this.outboundCaseId = sessionStorage.getItem('outboundCaseId');
                console.log('@@@WUB HANDLE MESSAGE getSessionStorage SS outboundCaseId: ', this.outboundCaseId);
            }

            if(sessionStorage.getItem('isDisconnected')){
                this.isDisconnected = sessionStorage.getItem('isDisconnected');
                console.log('@@@WUB HANDLE MESSAGE getSessionStorage SS isDisconnected: ', this.isDisconnected);
            } 
            resolve('Success');
        });
        
    }

    disconnectedCallback() {
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }

    renderedCallback() {
        this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }
    
    postCallSurvey() {
        //Passes the value to the Flow and to the field QCC_Post_Call_Survey_Sent in the Task Object if the Initiate Survey button is clicked
        this.isSurveySelected = true;
        console.log('@@@WUB HANDLE MESSAGE postCallSurvey this.interactionId ', this.interactionId);

            const pcs={
                type: 'PureCloud.Interaction.updateState',
                data: {
                    action: 'blindTransfer',
                    id: this.interactionId,
                    participantContext:{
                        transferTarget:this.postSurveyTarget,
                        transferTargetType: "address"
                    }
                }
            }
            publish(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, pcs);
            if (this.isSurveySelected) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Customer has been transferred to the Post-call survey.",
                        variant: "success",
                    })
                );
            }
    }
    assignNotes(event)
    {
        this.inputNotes=event.detail.value;
        if(this.inputNotes.length==0)
        {
            this.displaySaveButton=false;
        }
        else{
            this.displaySaveButton=true;
        }
    }
    handleGoNext() {
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
           const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            
            if(this.interactionId){
                sessionStorage.setItem('flowNavigationClicked',true);
            }
        }

        
    }

    
    getCaseDetails() { //Added to check if current Case opened is related to the current call
        console.log('@@@WUB HANDLE MESSAGE getCaseDetails interactionId and caseId: ', this.interactionId, this.caseId);
        return getCaseRecord({ interaction: this.interactionId, caseId: this.caseId, outboundCaseId: this.outboundCaseId })
        .then(result => {
            console.log('@@@WUB HANDLE MESSAGE getCaseDetails outbound caseId: ', this.outboundCaseId);
            console.log('@@@WUB HANDLE MESSAGE getCaseDetails result: ', JSON.stringify(result));
            if (result.length == 0) {
                console.log('@@@WUB HANDLE MESSAGE getCaseDetails result 0');
                let caseInfo = result[0];
                return true;
                
            } else {
                
                if(this.outboundCaseId != '' && this.outboundCaseId) { //This is for outbound call and transfer
                    if(this.caseId == this.outboundCaseId){
                        this.caseForTheCall = this.caseId;

                        console.log('@@@WUB HANDLE MESSAGE getCaseDetails CASE ID AND OUTBOUND/TRANSFER CASE ID',this.caseId, this.outboundCaseId);

                        //2023-06-02: Added the condition !this.isCallInternal to check if the call is Internal
                        if((this.isDisconnected === undefined || !this.isDisconnected) && !this.isCallInternal){
                            this.displaySurveyButton = true;
                            this.displaySaveButton = false;
                            console.log('@@@WUB HANDLE MESSAGE getCaseDetails OUTBOUND/TRANSFER call for the case: NOT Internal Call '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton+ ' this.isCallInternal: ' + this.isCallInternal + ' this.phoneCalled '+this.phoneCalled);
                        }
                        
                        this.checkIfDisconnected();

                        console.log('@@@WUB HANDLE MESSAGE getCaseDetails OUTBOUND/TRANSFER call for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
                    }

                } else { //This is for inbound call for the case that initiated the call
                    this.caseForTheCall = this.caseId;
                    console.log('@@@WUB HANDLE MESSAGE getCaseDetails inbound call for the case.');
                    console.log('@@@WUB HANDLE MESSAGE getCaseDetails Case ID: ', this.caseId);
                    console.log('@@@WUB HANDLE MESSAGE getCaseDetails isDisconnected: ',this.isDisconnected);
                    //Call is Connected
                    if(this.isDisconnected === undefined || !this.isDisconnected){
                        this.displaySaveButton = false;
                        this.displaySurveyButton = true;
                        console.log('@@@WUB HANDLE MESSAGE getCaseDetails inbound call for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
                    } 

                    this.checkIfDisconnected();
                }

                //For when the Save button is clicked with missing fields
                console.log('@@@WUB HANDLE MESSAGE getCaseDetails flowNavigationClicked ', sessionStorage.getItem('flowNavigationClicked'))
                if(sessionStorage.getItem('flowNavigationClicked')) {
                    this.displaySaveButton = true;
                    this.displaySurveyButton = false;
                }
                return false;
            }

        })
        .catch(error =>{
            // If the interaction id is undefined - that is if there is no ongoing call :
            //If call is not for the case
            console.log('@@@WUB HANDLE MESSAGE getCaseDetails inbound call NOT for the case.');
            console.log('@@@WUB HANDLE MESSAGE getCaseDetails Case ID: ', this.caseId);
            console.log('@@@WUB HANDLE MESSAGE getCaseDetails isDisconnected: ',this.isDisconnected);

            //Ongoing call but case is not for the call
            //May 12: Updated line below from 'if(!this.isDisconnected && this.interactionId)' to catch case not for the call
            if((this.isDisconnected === undefined || !this.isDisconnected ) && this.interactionId){
                this.displaySurveyButton = false;
                this.displaySaveButton = false;

                console.log('@@@WUB HANDLE MESSAGE getCaseDetails inbound call NOT for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);

            //No ongoing call
            } else if (!this.interactionId){
                this.displaySurveyButton = false;
                this.displaySaveButton = true;

                console.log('@@@WUB HANDLE MESSAGE getCaseDetails inbound No ongoing call: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
            }
        });
   }

   checkIfDisconnected(){
        if(this.isDisconnected){ 
            this.displaySaveButton = true;
            this.displaySurveyButton = false;
            console.log('@@@WUB HANDLE MESSAGE checkIfDisconnected call for the case: '+ this.caseId + ' displaySaveButton: '+ this.displaySaveButton + ' displaySurveyButton: '+ this.displaySurveyButton);
        }
   }

}