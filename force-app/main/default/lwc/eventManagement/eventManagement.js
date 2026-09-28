import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import LOGO_QANTAS from '@salesforce/resourceUrl/Qantas_Logo';
import registerForEvent from '@salesforce/apex/EventManagementSiteController.createEventResponse';
import getDataOnLoad from '@salesforce/apex/EventManagementSiteController.getInitialData';

const CONSTANS_FOR_USE = {
    CM_NAME: 'campaignMemberName',
    C_NAME: 'campaignName',
    IS_VALID: 'isValid',
    IS_EXPIRED: 'isExpired',
    IS_RESPONDED: 'isResponded',
    MESSAGE_ACCEPT: 'Thank you, {0}, for accepting the ticket. We hope you enjoy the show.',
    MESSAGE_REJECT: 'We appreciate you letting us know, {0}, We\'re sorry you won\'t be able to attend. We hope to see you at a future event.',
    MESSAGE_INVALID: 'We\'re sorry, but an error occurred during your registration. To resolve this, please click the registration link within the email again.',
    MESSAGE_CONFIRMATION: 'Hey {0}, you have been invited for {1} event. Could you please confirm your registration for the event?',
    MESSAGE_EXPIRED: 'Unfortunately, the registration period for tickets to {0} has expired. We are no longer able to process registrations.',
    MESSAGE_RESPONDED: 'You have already responded to {0} event. We are no longer able to process registrations.',
    RESPONSE_ACCEPT: 'accept',
    RESPONSE_REJECT: 'reject'
};

export default class EventManagement extends LightningElement {
    
    qantasLogoUrl = LOGO_QANTAS;
    tokenObj = {};
    encodedToken;
    isConfirmationRequired = false;
    messageToDisplay;
    
    // To fetch state parameters from the url
    @wire(CurrentPageReference)
    getCurrentPageReference(pageReference) {
        if (pageReference) {
            this.encodedToken = pageReference.state.ekvp;
            this.populateTokenObject(this.encodedToken);
            console.log('encodedToken - '+this.encodedToken);
        }
    }

    // To get encoded key value pair parameter from the urlParams
    populateTokenObject(providedToken) {
        getDataOnLoad({ token: providedToken })
        .then((returnedObj) => {
            this.tokenObj[CONSTANS_FOR_USE.C_NAME] = returnedObj[CONSTANS_FOR_USE.C_NAME];
            this.tokenObj[CONSTANS_FOR_USE.CM_NAME] = returnedObj[CONSTANS_FOR_USE.CM_NAME];
            this.tokenObj[CONSTANS_FOR_USE.IS_VALID] = returnedObj[CONSTANS_FOR_USE.IS_VALID];
            this.tokenObj[CONSTANS_FOR_USE.IS_EXPIRED] = returnedObj[CONSTANS_FOR_USE.IS_EXPIRED];
            console.log('Returned Obj:');
            console.log(returnedObj);
            console.log('Token Obj:');
            console.log(this.tokenObj);
            if (returnedObj && returnedObj[CONSTANS_FOR_USE.IS_VALID] == 'true') {
                if (returnedObj[CONSTANS_FOR_USE.IS_RESPONDED] == 'true') {
                    this.isConfirmationRequired = false;
                    this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_RESPONDED.replace('{0}', returnedObj[CONSTANS_FOR_USE.C_NAME]);
                } else if (returnedObj[CONSTANS_FOR_USE.IS_EXPIRED] == 'false') {
                    this.isConfirmationRequired = true;
                    this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_CONFIRMATION.replace('{0}', returnedObj[CONSTANS_FOR_USE.CM_NAME])
                                            .replace('{1}', returnedObj[CONSTANS_FOR_USE.C_NAME]);  
                } else {
                    this.isConfirmationRequired = false;
                    this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_EXPIRED.replace('{0}', returnedObj[CONSTANS_FOR_USE.C_NAME]);
                }
            } else {
                this.isConfirmationRequired = false;
                this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_INVALID;
            }
        }).catch((error) => { 
            this.isConfirmationRequired = false;
            this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_INVALID;
        });
    }

    handleClick(e) {
        let buttonValue = e.target.value;
        console.log(buttonValue);
        if (this.encodedToken && buttonValue) {
            registerForEvent({
                token: this.encodedToken,
                responseValue: buttonValue
            }).then((returnedValue) => {
                console.log('one two');
                if (returnedValue) {
                    this.messageToDisplay = (buttonValue == CONSTANS_FOR_USE.RESPONSE_ACCEPT) 
                                            ? CONSTANS_FOR_USE.MESSAGE_ACCEPT.replace('{0}', this.tokenObj[CONSTANS_FOR_USE.CM_NAME])
                                            : CONSTANS_FOR_USE.MESSAGE_REJECT.replace('{0}', this.tokenObj[CONSTANS_FOR_USE.CM_NAME]);
                    console.log('three four');
                } else {
                    this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_INVALID;
                    console.log('five six');
                }
            }).catch((error) => {
                this.messageToDisplay = CONSTANS_FOR_USE.MESSAGE_INVALID;
                console.log('seven eight');
                console.log('error - '+error)
            }).finally(() => {
                this.isConfirmationRequired = false;
            });
            console.log('nine ten');
        }
    }
}