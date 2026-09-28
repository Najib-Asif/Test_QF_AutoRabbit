import { LightningElement, api, wire } from 'lwc';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import SF_EVENT_CALLSESSION_MESSAGE_CHANNEL from '@salesforce/messageChannel/QCC_Call_Session_Channel__c';
import getCaseRecord from '@salesforce/apex/QCCTaskController.getCaseDetails';
import { openTab, getAllTabInfo, openSubtab } from 'lightning/platformWorkspaceApi';

export default class QccCallSession extends LightningElement {
    context = createMessageContext();
    subscription = null;
    @api interactionId;
    @api ivrSelection;
    receivedMessage = '';
    callState;
    callDirection;
    chgCallState;
    discCallState;
    ssCallState;
    chgCallDirection;

    @api recordId;

    connectedCallback(){ 
        // this.getStorage();
        console.log('@@@ CALL SESSION UTILITY connectedCallback');
        console.log('@@@ CALL SESSION UTILITY connectedCallback recordId: ', this.recordId);
        //NOTE: connectedCallback only called once but handleSubscribe called multiple times based on different messages being published
        this.handleSubscribe(); 
    }

    disconnectedCallback() {
        console.log('@@@ disconnectedCallback');
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }

    /*RenderedCallback() Invoked when a component is completely rendered on UI. Why do we need this? */
    /*renderedCallback() {
        console.log('@@@ renderedCallback');
        this.handleUnsubscribe(); 
        this.subscription = subscribe(this.context, CLIENT_EVENT_MESSAGE_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }*/

    handleSubscribe() {
        if (this.subscription) {
            console.log('@@@ this.subscription POPULATED ALREADY');
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
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE recordId: ', this.recordId);
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE: ',this.receivedMessage);
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE: message.category=' + message.category + ', message.data.state=' + message.data.state + ', message.data.ani=' + message.data.ani);
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE: message =' + message);

        //1. call in - when call comes in, capture interactionId
        if(message.category === 'station'){
            sessionStorage.setItem('genesysUserId',message.data.userId);
        }
        //Adding condition to only publish session storage if call is Inbound from customer (not new internal call)
        //NOTE: For outbound call, the session storage will be set on the "connect" message category
        if(message.category === 'add' && message.data.state != 'CONTACTING' && message.data.ani != 'Internal'){
            this.setSessionStorage(message);
            console.log('@@@ CALL SESSION UTILITY ADD: ',this.ivrSelection);
        }

        //2023-06-05: Added this event to set the session storage for outbound call and differentiate between outbound call to customer and outbound internal call
        if(message.category ==='connect'){
            console.log('@@@ CALL SESSION UTILITY CONNECT');
            let phoneCalled = message.data.phone;
            let isCallInternal = /*phoneCalled.includes("mypurecloud") || */ phoneCalled.includes("qantasairwayslimited");
            console.log('@@@ CALL SESSION UTILITY CONNECT: message.data.direction=' + message.data.direction + ' message.data.isInternal=' + message.data.isInternal + ' isCallInternal=' + isCallInternal);
            if (message.data.direction === 'Outbound' && !message.data.isInternal && !isCallInternal) {
                this.setSessionStorage(message);
            }
            this.publishCallSessionMessage('CALL_CONNECTED', message.data.direction);
            this.openCaseAndContact(message, message.data?.id, message.data?.attributes?.['Participant.CaseNumber']);
        }

        //session storage cleared on acw event. so in case user refreshes screen, the values retain until wrap-up is done
        if(message.category ==='acw'){ 
            console.log('@@@ CALL SESSION UTILITY ACW: ', message.data.id);
            //2023-06-03: Added to handle parallel calls (i.e. agent initiated new interaction internal call while in a call with the customer)
            //If the internal call was wrapped up first, then don't clear the session storage yet
            if (sessionStorage.getItem('interactionId') == message.data.id) {
                this.clearSessionStorage();
            }
            
        }

        if(message.category ==='disconnect'){ 
            console.log('@@@ CALL SESSION UTILITY DISCONNECT: ' + message.data.id);
            sessionStorage.setItem('isDisconnected',true);
            this.publishCallSessionMessage('CALL_DISCONNECTED', message.data.direction);
            this.openCaseAndContact(message, message.data?.id, message.data?.attributes?.['Participant.CaseNumber']);
        }

        //If there are remnants of the session storage from previous call, clear the session storage first to refresh with new values from incoming call
        //This can happen if previous call was not completely wrapped up
        if(message.category === 'interactionSelection'){
            console.log('@@@ CALL SESSION UTILITY interactionSelection: ', message.data.interactionId);
            if(!message.data.interactionId){
                this.clearSessionStorage();
            }
        }

        if (message.type === 'PureCloud.Interaction.addCustomAttributes') {
            this.openCaseAndContact(message, message.data?.id, message.data?.attributes?.['CaseNumber']);
        }

    }

    publishCallSessionMessage(messageToSend, callType) {
        console.log('@@@ CALL SESSION UTILITY publishCallSessionMessage: ', messageToSend);
        console.log('@@@ CALL SESSION UTILITY publishCallSessionMessage: ', callType);
        const callMsg = {
            sourceSystem: 'qccCallSession',
            messageToSend: messageToSend,
            callType: callType
        }
        publish(this.context, SF_EVENT_CALLSESSION_MESSAGE_CHANNEL, callMsg);
    }

    setSessionStorage(message) {
        this.ivrSelection = message.data.attributes?.['Participant.EnquiryType'];
        sessionStorage.setItem('interactionId',message.data?.id);
        sessionStorage.setItem('ivrSelection',message.data.attributes?.['Participant.EnquiryType']);
        sessionStorage.setItem('participantId',message.data.attributes?.['Salesforce.ParticipantId']);
        sessionStorage.removeItem('isDisconnected');
        
        if (message.data.direction == 'Outbound') {
            sessionStorage.setItem('outboundCaseId',this.recordId);
        }
        if (message.data.attributes?.['sf_workspaceassociations']) {
            let workspaceInfo;
            workspaceInfo = JSON.parse(message.data.attributes?.['sf_workspaceassociations']);
            console.log('@@@ CALL SESSION UTILITY INT ID IN ADD workspace', JSON.stringify(workspaceInfo));
            let workspaceRelates = workspaceInfo.Relates;
            let objArray = Object.values(workspaceRelates);
            console.log('@@@ CALL SESSION UTILITY INT ID IN ADD workspace ', objArray[0]?.id);
            sessionStorage.setItem('transferCaseId',objArray[0]?.id);
        }

    }

    clearSessionStorage() {
        sessionStorage.removeItem('interactionId');
        sessionStorage.removeItem('ivrSelection');
        sessionStorage.removeItem('participantId');
        sessionStorage.removeItem('outboundCaseId');
        sessionStorage.removeItem('transferCaseId');
        sessionStorage.removeItem('isDisconnected');
        sessionStorage.removeItem('flowNavigationClicked');
    }

    async openCaseAndContact(message, interactionId, caseNumber) {
        try {
            //console.log('@@@ openCaseAndContact interactionId: ', interactionId);
            //console.log('@@@ openCaseAndContact caseNumber: ', caseNumber);
            if( interactionId && caseNumber) {
                var contactTab;
                //new Date().toLocaleString() is passed to bypass caching from controller as it is an existing controller. caseNumber parameter is not used in controller.
                const cases = await getCaseRecord({ interaction: interactionId, caseNumber: new Date().toLocaleString(), caseId: undefined });
                //console.log('@@@ openCaseAndContact cases: ', JSON.stringify(cases));
                var caseDet = (cases && cases.length > 0 ) ? cases[0] : undefined;
                var tabInfo = await getAllTabInfo();
                //console.log('@@@ openCaseAndContact tabInfo: ', JSON.stringify(tabInfo));
                var primaryTabId = tabInfo?.filter(record => record.recordId == caseDet?.Id && !record.parentTabId);
                //console.log('@@@ openCaseAndContact primaryTabIdList: ', JSON.stringify(primaryTabId));
                primaryTabId = (primaryTabId && primaryTabId.length > 0 ) ? primaryTabId[0]?.tabId : undefined;
                //console.log('@@@ openCaseAndContact primaryTabId: ', JSON.stringify(primaryTabId));
                if (caseDet && (!primaryTabId || message.category === 'disconnect')) {
                    primaryTabId = await openTab({ recordId: caseDet?.Id, focus: true});
                }
                //console.log('@@@ openCaseAndContact contactTab: ', JSON.stringify(contactTab));
                if (primaryTabId && caseDet?.ContactId) contactTab = await openSubtab(primaryTabId, { recordId: caseDet?.ContactId, focus: false });
                //console.log('@@@ openCaseAndContact contactTab: ', JSON.stringify(contactTab));
            }
        } catch (e) {
            console.log('Error opening tabs');
            console.log(JSON.stringify(e));
        }
    }

}