import { LightningElement, api } from 'lwc';
export default class QccWrapUpFlow extends LightningElement {
    @api wrapUpFlow = 'QCC_Voice_WrapUp_Flow';

    //wrapUpVariables
    @api caseId;
    @api interactionId;
    @api callReason;
    @api outboundCaseId;
    @api genesysUserId;
    @api participantId;
    @api ivrSelection;
    

    get wrapUpVariables(){
        return [
            {
                // Case record id.
                name: 'recordId',
                type: 'String',
                value: this.caseId
            },
            {
                // Task CallObject.
                name: 'varInteractionId',
                type: 'String',
                value: this.interactionId
            },
            {
                // IVR Selection to Call Reason.
                name: 'varCallReason',
                type: 'String',
                value: this.callReason
            },
            {
                // Outbound Case Id.
                name: 'varOutboundCaseId',
                type: 'String',
                value: this.outboundCaseId
            },
            {
                // Genesys User Id.
                name: 'varGenesysUserId',
                type: 'String',
                value: this.genesysUserId
            },
            {
                // Genesys User Id.
                name: 'varParticipantId',
                type: 'String',
                value: this.participantId
            },
            {
                // IVR Selection
                name: 'varIvrSelection',
                type: 'String',
                value: this.ivrSelection
            }
        ];
    }
    
}