import { LightningElement, api, track } from 'lwc';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import { NavigationMixin } from 'lightning/navigation';
import stampAWSURLRedirect from '@salesforce/apex/QCCTaskController.stampAWSURLRedirect';

export default class QccSendWrapUpCode extends NavigationMixin(LightningElement) {
    @api taskId
    @api interactionId;
    @api wrapUpCode;
    @api genesysUserId;
    @api url;
    @api window_vf_aws;
    //@track window_vf_aws;
    @api vf_url;
    @api wrapUpHTML;

    //LMS
    context = createMessageContext();
    subscription = null;
    receivedMessage = '';

    connectedCallback(){
        this.handleSubscribe();
        //this.sendWrapup();
        this.sendWrapup2();
    }

    disconnectedCallback() {
        releaseMessageContext(this.context);
    }


    handleSubscribe() {
        if (this.subscription) {
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
        this.category = message.category;
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        console.log('@@@ WUB HANDLE MESSAGE sendWrapup message: ', this.receivedMessage);
        switch (this.category) {
            
            case 'acw':
                if(this.window_vf_aws!=null){
                    //Accessing the AWS response from the pop-up is not allowed because of cross-origin policy
                    // this.wrapUpHTML = this.window_vf_aws.document.getElementsByTagName("pre")[0].innerHTML;
                    // console.log('@@@ WUB HANDLE MESSAGE sendWrapup wrapUpHTML',String(this.wrapUpHTML));
                    this.window_vf_aws.close();
                    console.log('@@@ WUB HANDLE MESSAGE sendWrapup aws window closed');
                }
                else{
                    console.log('@@@ WUB HANDLE MESSAGE sendWrapup window_vf_aws null');
                }

            break;
        }
    }

    sendWrapup(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                //url: this.wrapupURL + '?conversationid='+this.interactionId + '&wrapupcode=fb772f70-270f-4215-8c06-50028317d890',
                // url: 'https://qantas--hfadtdev.sandbox.lightning.force.com/apex/QCC_WrapupURLConnection'
                url: '/apex/QCC_WrapupURLConnection'
            }
        }).then((url) => {
            console.log('@@@ WUB HANDLE MESSAGE sendWrapup: ' + this.url);
            console.log('@@@ WUB HANDLE MESSAGE sendWrapup interactionId: ' + this.interactionId);
            console.log('@@@ WUB HANDLE MESSAGE sendWrapup wrapUpCode: ' + this.wrapUpCode);
            console.log('@@@ WUB HANDLE MESSAGE sendWrapup genesysUserId: ' + this.genesysUserId);
            this.vf_url=this.url+this.interactionId+'&'+this.wrapUpCode+'&'+this.genesysUserId;
            let window_target=`_blank`;
            //Pop-up centered
            let window_style='directories=no,titlebar=no,location=no,toolbar=no,status=no,menubar=no,scrollbars=no,resizable=no,left=500,top=500,width=400,height=400,visible=none';
            this.window_vf_aws=window.open(this.vf_url,window_target,window_style,'');

        }).then(() => {
            fetch(JSON.stringify(this.vf_url))
            .then(response => {
                console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch URL',this.vf_url);
                console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch response status: ',response.status);
                console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch response : ',response);
                if(response.ok){
                    console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch response.ok : ',response.ok);
                    console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch OK');
                }
            })
            .catch(error => {
                console.log('@@@ WUB HANDLE MESSAGE sendWrapup fetch error', error);
            });
        });

    }

    sendWrapup2(){
        this.vf_url=this.url+this.interactionId+'&'+this.wrapUpCode+'&'+this.genesysUserId;
        console.log('@@@ WUB HANDLE MESSAGE sendWrapup URL',this.vf_url);
        let window_target=`_blank`;
        //Pop-up centered
        let window_style='directories=no,titlebar=no,location=no,toolbar=no,status=no,menubar=no,scrollbars=no,resizable=no,left=500,top=500,width=400,height=400,visible=none';
        this.window_vf_aws=window.open(this.vf_url,window_target,window_style,'');
        this.stampAWSURLRedirect();
    }

    stampAWSURLRedirect() {
        stampAWSURLRedirect({ awsURLConnection: this.vf_url, taskRecordId: this.taskId })
        .then(result => {
            if (result) {
                console.log('@@@ WUB HANDLE MESSAGE stampAWSURLRedirect', JSON.stringify(result));
            }
        })
        .catch(error=>{
            console.log('@@@ WUB HANDLE MESSAGE stampAWSURLRedirect error: ' + JSON.stringify(error));
        });
    }
}