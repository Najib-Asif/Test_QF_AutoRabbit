import { LightningElement, api, wire, track } from 'lwc';
import { publish,
        subscribe,
        unsubscribe,
        createMessageContext,
        releaseMessageContext,
        MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import SF_EVENT_CALLSESSION_MESSAGE_CHANNEL from '@salesforce/messageChannel/QCC_Call_Session_Channel__c';
import getCaseRecord from '@salesforce/apex/QCCTaskController.getCaseDetails';
import getStampFFOnCase from '@salesforce/apex/QCCTaskController.stampFFOnCase';



export default class QccCallDetailsMainContainer extends LightningElement {
    //LMS
    context = createMessageContext();
    subscription = null;
    subscriptionSF = null;
    receivedMessage = '';
    changeMessage;
    category;
    stopListen = true;
    @api recordId;
    @api pnrNumberOutput;
    @api ssInteractionId;
    @api flowName = 'QCC_Voice_Call_Handling_Component';
    


    //IVR Details
    @api authenticationStatus = 'Unauthenticated';
    @api qffNumber = '';
    @api qffTier = '';
    @api callerBookingLastName = '';
    @api pnr = '';
    @api pnrContains = ''; //CRM-8775
    @api pnrCreationDate = '';
    @api ivrSelection = '';
    @api queueName;
    @api callerName = '';
    @api callerLocation = '';
    @api phoneNumber = '';
    @api caseId = '';
    @api caseNumber;
    @api title = 'Caller Verification for <waiting for case to load...>';
    @api callType;
    @api isTransfer;
    @api qFAuthenticated=false;
    @api confirmationScreen;
    waitTime='';
    paymentType='';
    travelType='';
    bookingPnrMatchIndex;
    queryDescription;
    
    //1. Load when call is active
    isActive = true;
    showFlow;
    showIVRDetails;
    timeout;
    onPublishChange = false;

    ani;
    phoneCalled;
    isCallInternal;
    isDisconnected;

    connectedCallback(){ 
        console.log('>>> NEW MAIN HANDLE MESSAGE connectedCallback');
        this.init();
    }

    async init() {
        try {
            this.handleSubscribe();
            // const handleSubscribePromise = await this.handleSubscribe();
            console.log('>>> NEW MAIN HANDLE MESSAGE AWAIT handleSubscribe');
            const getSessionStoragePromise = await this.getSessionStorage();
            console.log('>>> NEW MAIN HANDLE MESSAGE AWAIT getSessionStorage');
            const getCaseDetailsPromise = await this.getCaseDetails();
            console.log('>>> NEW MAIN HANDLE MESSAGE AWAIT getCaseDetails');
        } catch (error) {
            console.log('>>> NEW MAIN HANDLE MESSAGE INIT ERROR: ' + JSON.stringify(error));
        }
        
    }

    async getSessionandCase(){
        try {
            const callConnectgetSessionStoragePromise = await this.getSessionStorage();
            console.log('>>> NEW MAIN HANDLE MESSAGE CALL CONNECT AWAIT getSessionStorage');
            const callConnectgetCaseDetailsPromise = await this.getCaseDetails();
            // const callConnectgetCaseDetailsPromise = await this.getCaseDetailsTimed();
            console.log('>>> NEW MAIN HANDLE MESSAGE CALL CONNECT AWAIT getCaseDetails');
        } catch(error) {
            console.log('>>> NEW MAIN HANDLE MESSAGE CALL CONNECT AWAIT ERROR: ' + JSON.stringify(error));
        }
    }

    async setIVRDetailsandFlow(message) {
        const callChangeSetIVRDetailsPromise = await this.setIVRDetails(message);
        console.log('>>> NEW MAIN HANDLE MESSAGE CALL CHANGE AWAIT setIVRDetails');
        const callChangeSetFlowInputsPromise = await this.setFlowInputs();
        console.log('>>> NEW MAIN HANDLE MESSAGE CALL CHANGE AWAIT setFlowInputs');
        const callChangeSetFlowVisibilityPromise = await this.setFlowVisibility();
        console.log('>>> NEW MAIN HANDLE MESSAGE CALL CHANGE AWAIT setFlowVisibility');
    }

    //unsubscribe when disconnectedcallback triggers
    disconnectedCallback() {
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }

    /*RenderedCallback() Invoked when a component is completely rendered on UI. Why do we need this? */
    /*renderedCallback() {
        this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }*/

    handleStatusChange(event) {
       
       
       event.detail.outputVariables.forEach(outputVar => {
            if (outputVar.name === 'varPNRNumber') {
                this.pnrNumberOutput = outputVar.value;
                
            } 
            if (outputVar.name === 'varFlowScreenForAddPNR') {
                this.confirmationScreen = outputVar.value;
                
            } 
        });
       
    }

    @api inputVariables;
    
    handleSubscribe() {
        /*if (this.subscription) {
            return;
        }*/
        console.log('>>> NEW MAIN HANDLE MESSAGE handleSubscribe');
        return new Promise((resolve, reject) => {
            this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
                this.handleMessage(message);
            });
    
            this.subscriptionSF = subscribe(this.context, SF_EVENT_CALLSESSION_MESSAGE_CHANNEL, (message) => {
                this.handleMessageSF(message);
            });
            resolve('Success');
            
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        
        this.subscription = null;
    } 

    handleMessage(message) {
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        //console.log('>>> NEW MAIN HANDLE MESSAGE EVENT: ', this.receivedMessage);
        //NOTE: Disconnect is handled on QCC Voice Wrap up flow
        this.category = message.category;
        switch (this.category) {
            case 'add':
                this.callType = message.data.direction;
            break;

            case 'change':
                console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE: ', JSON.stringify(message, null, '\t'));
                console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE onPublishChange: ', this.onPublishChange);
                console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE ssInteractionId: ', this.ssInteractionId);
                this.isTransfer = (message.data.new.attributes?.['sf_workspaceassociations']) ? true : false;
                            
                let workspaceInfo;
                if (message.data.new.attributes?.['sf_workspaceassociations']) {
                    workspaceInfo = JSON.parse(message.data.new.attributes?.['sf_workspaceassociations']);
                    let workspaceRelates = workspaceInfo?.Relates;
                    let objArray = Object?.values(workspaceRelates);
                    console.log('>>> NEW MAIN HANDLE MESSAGE workspace ', objArray[0]?.id);
                    this.caseId = objArray[0]?.id;
                }
                
                if (!workspaceInfo && this.ssInteractionId) { //if this is undefined, it means it's normal inbound and outbound
                    this.setIVRDetailsandFlow(message);
                    console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE workspaceInfo: ', workspaceInfo);
                } else if (this.onPublishChange && this.ssInteractionId) {//else it's a workspace transfer
                    this.setIVRDetailsandFlow(message);
                    console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE workspaceInfo else: ', workspaceInfo);
                }
            break;

            case 'acw':
                //2023-06-03: Added to handle parallel calls (i.e. agent initiated new interaction internal call while in a call with the customer)
                //If the internal call was wrapped up first, then don't reset variables yet
                console.log('>>> NEW MAIN HANDLE MESSAGE ACW: caseId=' + this.caseId + ' ssInteractionId=' + this.ssInteractionId + ' message.data.id=' + message.data.id);
                if (this.ssInteractionId == message.data.id) {
                  
                    this.resetVariables();

                }
          
            break;

           /* case 'disconnect':
            //2023-06-29: Added to reset call handling flow so that for any new call, the new case appears
            console.log('>>> NEW MAIN HANDLE MESSAGE DISCONNECT: FOR OUTBOUND CALL'+ this.caseId + ' ssInteractionId=' + this.ssInteractionId + ' message.data.id=' + message.data.id);    
            if(this.ssInteractionId == message.data.id)
            {
                this.resetVariables();
            }
            break; */

            //If previous call was not completely wrapped up, reset the values when this event comes and there is no active interaction or call
            case 'interactionSelection':
                console.log('>>> NEW MAIN HANDLE MESSAGE ACW: caseId=' + this.caseId + ' ssInteractionId=' + this.ssInteractionId + ' message.data.interactionId=' + message.data.interactionId);
                if(!message.data.interactionId){
                  
                    this.resetVariables();
                }
            break;
            
        }

    }

    handleMessageSF(message) {
        console.log('>>> NEW MAIN HANDLE MESSAGE SF: ' + JSON.stringify(message));
        //NOTE: Needed if case already opened, agent does NOT pick up a call that will issue a change event.
        //setCustomAttributes() will issue the change event.
        if (message.messageToSend == 'CALL_CONNECTED') {
            this.getSessionandCase();
        }
        
        // if (message.messageToSend == 'CALL_DISCONNECTED') {
        //     console.log('>>> NEW MAIN HANDLE MESSAGE SF CALL_DISCONNECTED');
        //     //reset in case consecutive outbound-inbound calls (or vice versa) if case tab is not closed
        //     this.showIVRDetails = false;
        //     this.ssInteractionId = null;
        //     this.showFlow = false;
        //     this.caseId = '';
        //     this.caseNumber = null;
        //     this.onPublishChange = false;
        //     this.isTransfer = false;
        //     this.title = 'Caller Verification for <waiting for case to load...>';

        // }

    }

    setIVRDetails(message) {
        console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails');
        return new Promise((resolve, reject) => {
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails old authenticationStatus ', this.authenticationStatus);
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails new authenticationStatus ', message.data.new.attributes?.['Participant.QFFAuthenticationStatus']);
            //in case authentication status gets changed (i.e. during mid-call authentication), the flow will refresh/reload
            
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails '+'authenticationStatus: '+ this.authenticationStatus + 'Participant.QFFAuthenticationStatus: '+  message.data.new.attributes?.['Participant.QFFAuthenticationStatus']);

            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails '+'qffNumber: '+ this.qffNumber + 'Participant.QFFNumber: '+  message.data.new.attributes?.['Participant.QFFNumber']);

            //Added this check so the flow won't refresh for outbound scenario when there is no incoming participant data from Genesys. But if mid-call authentication is performed, then this two data points will not be undefined, therefore, the screenflow will refresh with new QFF details.
            if( message.data.new.attributes?.['Participant.QFFAuthenticationStatus'] !== undefined || message.data.new.attributes?.['Participant.QFFNumber'] !== undefined ) {

                if (this.authenticationStatus != message.data.new.attributes?.['Participant.QFFAuthenticationStatus'] || ( this.qffNumber != message.data.new.attributes?.['Participant.QFFNumber'] && message.data.new.attributes?.['Participant.QFFNumber'] !== undefined )) {
                    this.showFlow = false;
                  
                    console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails showflow: ', this.showFlow);
                    this.authenticationStatus = (message.data.new.attributes?.['Participant.QFFAuthenticationStatus']) ? message.data.new.attributes['Participant.QFFAuthenticationStatus'] : 'Unauthenticated';
                    this.qffNumber = (message.data.new.attributes?.['Participant.QFFNumber']) ? message.data.new.attributes['Participant.QFFNumber'] : ((this.qffNumber != '') ? this.qffNumber : '');
                    this.callerName = (message.data.new.attributes?.['Participant.QFFName']) ? message.data.new.attributes['Participant.QFFName'] : ((this.callerName != '') ? this.callerName : '');
                    this.qffTier = (message.data.new.attributes?.['Participant.QFFTier']) ? message.data.new.attributes['Participant.QFFTier'] : ((this.qffTier != '') ? this.qffTier : '');
                    this.callerLocation = (message.data.new.attributes?.['Participant.CallerLocation']) ? message.data.new.attributes['Participant.CallerLocation'] : ((this.callerLocation != '') ? this.callerlocation : '');

                    
                }
            }
            
            console.log('>>> in Call Detail Main Container Message Data'+JSON.stringify(message.data));
            console.log('>>> in Call Detail Main Container Message Attributes'+JSON.stringify(message.data.attributes));
            if(message.data && (message.data.new.attributes || message.data.old.attributes))
                {
                     if(message.data.new.attributes )
                     {
                        this.waitTime=(message.data.new.attributes?.['Interaction.TotalAcdTime']) ? message.data.new.attributes?.['Interaction.TotalAcdTime'] : '0';
                        this.paymentType =(message.data.new.attributes?.['Participant.PaymentType']) ? message.data.new.attributes?.['Participant.PaymentType'] : '';
                        this.travelType= (message.data.new.attributes?.['Participant.TravelType']) ? '/ '+ message.data.new.attributes?.['Participant.TravelType'] +' / ' : '';
                        this.bookingPnrMatchIndex= (message.data.new.attributes?.['Participant.BookingPNRMatchIndex']) ? message.data.new.attributes?.['Participant.BookingPNRMatchIndex'] : '';
                        this.queryDescription=(message.data.new.attributes?.['Participant.EnquiryDescription']) ? message.data.new.attributes?.['Participant.EnquiryDescription'] : '';
                     }
                      else if(message.data.old.attributes )  
                      {
                        this.waitTime=(message.data.old.attributes?.['Interaction.TotalAcdTime']) ? message.data.old.attributes?.['Interaction.TotalAcdTime'] : '0';
                        this.paymentType =(message.data.old.attributes?.['Participant.PaymentType']) ? message.data.old.attributes?.['Participant.PaymentType'] : '';
                        this.travelType= (message.data.old.attributes?.['Participant.TravelType']) ? '/ '+ message.data.old.attributes?.['Participant.TravelType'] +' / ' : '';
                        this.bookingPnrMatchIndex= (message.data.old.attributes?.['Participant.BookingPNRMatchIndex']) ? message.data.old.attributes?.['Participant.BookingPNRMatchIndex'] : '';
                        this.queryDescription=(message.data.old.attributes?.['Participant.EnquiryDescription']) ? message.data.old.attributes?.['Participant.EnquiryDescription'] : '';
                      }
                      if(this.paymentType && (this.paymentType==='Currency' || this.paymentType==='CURRENCY' || this.paymentType==='currency'))
                      {
                         this.paymentType='Commercial';
                      }  
                      
                      if(this.bookingPnrMatchIndex==='-1' && (this.travelType==='/ International / ' || this.travelType==='/ international / ' || this.travelType==='/ INTERNATIONAL / ') && 
                      (this.paymentType==='Points' || this.paymentType==='points' || this.paymentType==='POINTS'))
                      {
                        this.travelType='';
                        this.paymentType='';
                      }
                        console.log('@@OnConnected Interaction.TotalAcdTime: in Call Detail Main Container '+this.waitTime);
                        console.log('@@OnConnected Participant.PaymentType: in Call Detail Main Container '+this.paymentType);
                        console.log('@@OnConnected Participant.TravelType: in Call Detail Main Container '+this.travelType);
                        console.log('@@OnConnected Participant.bookingPnrMatchIndex: in Call Detail Main Container '+this.bookingPnrMatchIndex);
                        console.log('@@OnConnected Participant.EnquiryDescription: in Call Detail Main Container '+this.EnquiryDescription);
                        
                    
                }
                
            
            //this.authenticationStatus = (message.data.new.attributes?.['Participant.QFFAuthenticationStatus']) ? message.data.new.attributes['Participant.QFFAuthenticationStatus'] : 'Unauthenticated';
            
            this.pnr = (message.data.new.attributes?.['Participant.BookingPNR']) ? message.data.new.attributes['Participant.BookingPNR'] : '';
            //Jira: CRM-8775
            console.log('Participant.SpecificNeeds========> ' + message.data.new.attributes['Participant.SpecificNeeds']);
            this.pnrContains = (message.data.new.attributes?.['Participant.SpecificNeeds']) ? message.data.new.attributes['Participant.SpecificNeeds'] : '';
            this.pnrCreationDate = (message.data.new.attributes?.['Participant.BookingPNRCreationDate']) ? message.data.new.attributes['Participant.BookingPNRCreationDate'] : '';
            this.ivrSelection = (message.data.new.attributes?.['Participant.EnquiryType']) ? message.data.new.attributes['Participant.EnquiryType'] : '';
            this.queueName = (message.data.new.attributes?.['Call.QueueName']) ? message.data.new.attributes['Call.QueueName'] : '';
            this.callerLocation = (message.data.new.attributes?.['Participant.CallerLocation']) ? message.data.new.attributes['Participant.CallerLocation'] : '';

            this.callType = message.data.new.direction;
           
            

            //This is the original code for qffNumber, callerName
            // this.qffNumber = (message.data.new.attributes?.['Participant.QFFNumber']) ? message.data.new.attributes['Participant.QFFNumber'] : ((this.qffNumber != '') ? this.qffNumber : '');
            // this.callerName = (message.data.new.attributes?.['Participant.QFFName']) ? message.data.new.attributes['Participant.QFFName'] : ((this.callerName != '') ? this.callerName : '');
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails qffNumber ', this.qffNumber);
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails callerName ', this.callerName);
            if (!this.qffNumber || this.qffNumber.trim() === '' || this.qffNumber == '*') {
                this.qffNumber = (message.data.new.attributes?.['Participant.QFFNumber']) ? message.data.new.attributes['Participant.QFFNumber'] : ((this.qffNumber != '') ? this.qffNumber : '');
                console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails qffNumber inside if', this.qffNumber);
            }

            if (!this.callerName || this.callerName.trim() === '') {
                this.callerName = (message.data.new.attributes?.['Participant.QFFName']) ? message.data.new.attributes['Participant.QFFName'] : ((this.callerName != '') ? this.callerName : '');
                console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails callerName inside if', this.callerName);
            }

            if (!this.callerLocation || this.callerLocation.trim() === '') {
               // this.callerLocation = (message.data.new.attributes?.['Participant.CallerLocation']) ? message.data.new.attributes['Participant.CallerLocation'] : ((this.callerLocation != '') ? this.callerLocation : '');
                console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails callerLocation inside if', this.callerLocation);
            }

            if (!this.qffTier || this.qffTier.trim() === '') {
                this.qffTier = (message.data.new.attributes?.['Participant.QFFTier']) ? message.data.new.attributes['Participant.QFFTier'] : ((this.qffTier != '') ? this.qffTier : '');
                console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails qffTier inside if', this.qffTier);
            }

            this.ani = message.data.new.ani;
            console.log('>>> NEW MAIN HANDLE MESSAGE setIVRDetails message.data.new.ani', message.data.new.ani);
            if (message.data.new.direction == 'Outbound') {
                if (message.data.new.ani !== 'Internal') {
                    this.phoneNumber = message.data.new.calledNumber;
                }
            } else {
                this.phoneNumber = (message.data.new.ani) ? message.data.new.ani : '';
            }

            if (message.data.new.attributes?.['Participant.CaseNumber']) {
                this.title = 'Caller Verification for ' + message.data.new.attributes['Participant.CaseNumber'];
            }

            if (message.data.new.direction == 'Outbound') {
                // this.caseNumber = message.data.new.attributes?.['sf_urlpop'];
                this.caseNumber = message.data.new.attributes?.['Participant.CaseNumber'];
                this.ivrSelection = 'Outbound Call';
            }
            console.log('>>> NEW MAIN HANDLE MESSAGE CHANGE authenticationStatus: ', this.authenticationStatus);
            resolve('Success');

            

        });
        
    }
   

    setFlowInputs() {
        console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs');
        return new Promise((resolve, reject) => {
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs authenticationStatus: ', this.authenticationStatus);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs pnrCreationDate: ', this.pnrCreationDate);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs pnr: ', this.pnr);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs ivrSelection: ', this.ivrSelection);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs phoneNumber: ', this.phoneNumber);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs qffNumber: ', this.qffNumber);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs callerName: ', this.callerName);
            
            if(this.authenticationStatus==='Authenticated')
            {
                this.qFAuthenticated=true;
            }
            if((this.authenticationStatus && this.ivrSelection && this.phoneNumber) || this.callType == 'Outbound' || this.isTransfer){
                console.log('>>> NEW MAIN HANDLE MESSAGE setFlowInputs: EXISTS');
                this.inputVariables = [
                    {
                        // Case record id.
                        name: 'varCaseId',
                        type: 'String',
                        value: this.caseId
                    },
                    {
                        // Unique Call object Id from Genesys.
                        name: 'varCallObject',
                        type: 'String',
                        // value: this.relCaseId
                        value: this.ssInteractionId
                    },
                    {
                        // PNR Number from IVR selection.
                        name: 'varPNRNumber',
                        type: 'String',
                        value: this.pnr
                    },
                    {
                        // Phone Number from IVR selection.
                        name: 'varPassengerPhone',
                        type: 'String',
                        value: this.phoneNumber
                    },
                    {
                        // IVR selection.
                        name: 'varIVRSelection',
                        type: 'String',
                        value: this.ivrSelection
                    },
                    {
                        // FF Number
                        name: 'varFFNumber',
                        type: 'String',
                        value: this.qffNumber
                    },
                    {
                        // Creation Date
                        name: 'varCreationDate',
                        type: 'String',
                        value: this.pnrCreationDate
                    },
                    {
                        // QFF Full Name
                        name: 'varPassengerFullName',
                        type: 'String',
                        value: this.callerName
                    },
                    {
                        // QFF Full Name for PNR Summary After Flow Completion
                        name: 'varQFFName',
                        type: 'String',
                        value: this.callerName
                    },
                    {
                        // QFF Authenticated Status for PNR Summary After Flow Completion
                        name: 'qFAuthenticated',
                        type: 'Boolean',
                        value: this.qFAuthenticated
                    },
                    {
                        // Passenger Last Name
                        name: 'varPassengerLastName',
                        type: 'String',
                        value: this.callerName.split(' ').pop()
                    }
                ];
                
            }
            resolve('Success');  
        });
    }

    setFlowVisibility() {
        console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility');
        return new Promise((resolve, reject) => {
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility: ', this.inputVariables);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility recordId: ', this.recordId);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility caseId: ', this.caseId);
            console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility phoneNumber: ', this.phoneNumber);
            if (this.authenticationStatus || this.callType == 'Outbound') {
                this.showIVRDetails = true;
            }

            if ((this.recordId === this.caseId)) { //This is for outbound scenario and transfer
                this.showFlow = true;
                console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility showflow: ', this.showFlow, this.recordId, this.caseId);
            } else {
                this.showFlow = false;
                console.log('>>> NEW MAIN HANDLE MESSAGE setFlowVisibility showflow else: ', this.showFlow, this.recordId, this.caseId);
            }
            resolve('Success');

        });
    }

    getSessionStorage() {
        console.log('>>> NEW MAIN HANDLE MESSAGE getSessionStorage');
        return new Promise((resolve, reject) => {
            if(sessionStorage.getItem('interactionId')){
                this.ssInteractionId = sessionStorage.getItem('interactionId');
                console.log('>>> NEW MAIN HANDLE MESSAGE SS INTERACTIONID: ', this.ssInteractionId);
            }

            if(sessionStorage.getItem('outboundCaseId')){
                this.caseId = sessionStorage.getItem('outboundCaseId');
                console.log('>>> NEW MAIN HANDLE MESSAGE OUTBOUND CASE ID: ', this.caseId);
            }
            resolve('Success');

        });
        
    }

    getCaseDetails() {
        console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails');
        console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails ssInteractionId: ' + this.ssInteractionId);
        console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails caseId: ' + this.caseId);
        return getCaseRecord({ interaction: this.ssInteractionId, caseNumber: this.caseNumber, caseId: this.caseId })
        .then(result => {
            console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails');
            if (result) {
                console.log('>>> NEW MAIN HANDLE MESSAGE caseInfo', JSON.stringify(result));
                let caseInfo = result[0];
                console.log('>>> NEW MAIN HANDLE MESSAGE caseInfo', JSON.stringify(caseInfo));
                // this.caseNumber = caseInfo.What.Name;
                // this.caseId = caseInfo.WhatId;
                this.caseNumber = caseInfo.CaseNumber;
                this.caseId = caseInfo.Id;
                this.callerName = (caseInfo?.Contact?.Name) ? caseInfo.Contact.Name : '';
                this.qffNumber = (caseInfo?.Contact?.Frequent_Flyer_Number__c) ? caseInfo.Contact.Frequent_Flyer_Number__c : '';
                this.qffTier = (caseInfo?.Contact?.Frequent_Flyer_Tier__c) ? caseInfo.Contact.Frequent_Flyer_Tier__c : '';
                console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails caseId:', this.caseNumber);
                console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails qffNumber:', this.qffNumber);
                console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails callerName:', this.callerName);
                console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails qffTier:', this.qffTier);
                // this.title = 'Caller Verification for '+ this.caseNumber;
                this.onPublishChange = true;
                return true;
            } else {
                return false;
            }
            
        })
        .then(result => {
            console.log('>>> NEW MAIN HANDLE MESSAGE setCustomAttributes');
            console.log('>>> NEW MAIN HANDLE MESSAGE setCustomAttributes recordId: ' + this.recordId);
            console.log('>>> NEW MAIN HANDLE MESSAGE setCustomAttributes caseId: ' + this.caseId);

            console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails showIVRDetails then result: ', this.showIVRDetails);
            if (result) {
                if (this.caseNumber) {
                    this.title = 'Caller Verification for ' + this.caseNumber;
                }
                this.setCustomAttributes(this.caseNumber);
                                
            }
        })
        .catch(error=>{
            console.log('>>> NEW MAIN HANDLE MESSAGE getCaseDetails error: ' + JSON.stringify(error));
        });
    }

    setCustomAttributes(caseNumber) {
        console.log('>>> NEW MAIN HANDLE MESSAGE setCustomAttributes');
        const sec={
            type: 'PureCloud.Interaction.addCustomAttributes',
            data: {
                id: this.ssInteractionId,
                //attributes:{sf_urlpop: caseNumber}
                attributes:{CaseNumber: caseNumber}
            }
        }
        publish(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, sec);
        
    } 
   
    resetVariables() {
        console.log('>>> NEW MAIN HANDLE MESSAGE resetVariables');
        this.showIVRDetails = false;
        this.ssInteractionId = null;
        this.showFlow = false;
        this.caseId = '';
        this.caseNumber = null;
        this.onPublishChange = false;
        this.isTransfer = false;
        this.title = 'Caller Verification for <waiting for case to load...>';
        //Reset Caller-Related Values
        this.authenticationStatus = 'Unauthenticated';
        this.qffNumber = '';
        this.queueName = '';
        this.callerName = '';
        this.callerlocation = '';
        this.qffTier ='';
    }
    
}