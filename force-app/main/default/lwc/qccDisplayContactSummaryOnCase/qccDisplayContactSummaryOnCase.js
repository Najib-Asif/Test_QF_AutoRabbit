import { LightningElement, api, track, wire } from 'lwc';
import { publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    MessageContext } from 'lightning/messageService';
import CLIENT_EVENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/purecloud__ClientEvent__c'; 
var  column1=[];
var column2=[];

export default class QccDisplayContactSummaryOnCase extends LightningElement 
{
    @api FFName;
    @api PrefName;
    @api FrequentFlyerNumber;
    @api StatusCredits;
    
    @api tier;
    @api statusCreditTillNxtLvl;
    @api pointsBalance;
    @api TierAnniversaryDate;
    @api recordId;
    @api phone;
    @api email;
    @track hasRendered;
    @api imgSrc;
    @api imgHeight;
    @api imgWidth;
    @api imgBorder;

    //CRM-8740
    @api lifeTimeStatus; 
    @api lifetimeTierImgSrc;
    @api lifetimeTierImgHeight;
    @api lifetimeTierImgWidth;
    @api lifetimeTierImgBorder;

    @api QFFWebLoginDisabled;

    context = createMessageContext();
    subscription = null;
    receivedMessage=null;
   
    connectedCallback(){ 
        this.handleSubscribe(); 
    }

    disconnectedCallback() {
        console.log('@@@ disconnectedCallback Contact Summary');
        this.handleUnsubscribe(); 
        releaseMessageContext(this.context);
    }
    handleSubscribe() {
        if (this.subscription) {
            console.log('@@@ this.subscription POPULATED ALREADY Contact Summary');
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
        if(message?.category)
        {
            console.log('^^^^^^received messdage category'+message.category);
            if(message.category ==='add')
            {
                console.log('>>>message category data ADD '+JSON.stringify(message.category));
                if(message.data.attributes?.['Participant.QFFWebLoginDisabled']==='true')
                {
                    
                    this.QFFWebLoginDisabled=true;
                    console.log('>>> contact summary weblogindisabled inside add category assignment'+this.QFFWebLoginDisabled);
                }
                
            }
            if(message.category ==='connect' || message.category ==='change')
            {
                console.log('>>>message category date'+JSON.stringify(message.data));
                if(message?.data?.old?.attributes)
                {
                    console.log('>>> contact summary old weblogindisabled'+message.data.old.attributes?.['Participant.QFFWebLoginDisabled']);
                    if(message.data.old.attributes?.['Participant.QFFWebLoginDisabled']==='true')
                    {
                        this.QFFWebLoginDisabled=true;
                        console.log('>>> contact summary weblogindisabled inside connect or change old category assignment'+this.QFFWebLoginDisabled);
                    }
                }
                else if(message?.data?.new?.attributes)
                {
                    console.log('>>> contact summary new weblogindisabled'+message.data.new.attributes?.['Participant.QFFWebLoginDisabled']);
                    if(message.data.new.attributes?.['Participant.QFFWebLoginDisabled']==='true')
                    {
                        this.QFFWebLoginDisabled=true;
                        console.log('>>> contact summary weblogindisabled inside connect or change new category assignment'+this.QFFWebLoginDisabled);
                    }
                }
            }
            }
        
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE: Contact Summary received message',this.receivedMessage);
        console.log('@@@ CALL SESSION UTILITY HANDLE MESSAGE: Contact Summary Disabled Flag',this.QFFWebLoginDisabled);
    }
    
    renderedCallback()
    {
        if(this.hasRendered!==true)
        {
            if(this.tier!=null && this.tier!=undefined)
            {
                console.log('The value of tier'+this.tier);
                let ffTierimgText=this.tier;
                this.renderTierImages(ffTierimgText, 'ffTier');
            }
            //CRM-8740
            if (this.lifeTimeStatus != null && this.lifeTimeStatus != undefined) {
                console.log('The value of lifeTimeStatus'+this.lifeTimeStatus);
                let lifetimeTierImgText = this.lifeTimeStatus;
                this.renderTierImages(lifetimeTierImgText, 'lifetimeTier');
            }
            this.hasRendered=true;
        }
         
    }

    //CRM-8740
    renderTierImages(imgText, labelName) {
        const imgList=imgText.split(" ");
                imgList.forEach(element => {
                    console.log('Print the element of the arrayList'+element);
                    if(element.includes("src"))
                    {
                        console.log('Print the index of slash'+element.indexOf("/"));
                        console.log('Print the index length'+element.length);
                        if (labelName == 'ffTier') {
                            this.imgSrc=element.slice(element.indexOf("/"), element.length-1);
                        } else {
                            this.lifetimeTierImgSrc=element.slice(element.indexOf("/"), element.length-1);
                        }

                        console.log('Print the value of imgSrc'+this.imgSrc);
                    }
                    if(element.includes("height"))
                    {
                        console.log('Print the index of colon1'+element.indexOf(":"));
                        console.log('Print the index length'+element.length);
                        if (labelName == 'ffTier') {
                            this.imgHeight=element.slice(element.indexOf(":")+1, element.length-1);
                        } else {
                            this.lifetimeTierImgHeight=element.slice(element.indexOf(":")+1, element.length-1);
                        }
                        console.log('Print the value of imgHeight'+this.imgHeight);
                    }
                    if(element.includes("width"))
                    {
                        console.log('Print the index of colon2'+element.indexOf(":"));
                        console.log('Print the index length'+element.length);
                        if (labelName == 'ffTier') {
                            this.imgWidth=element.slice(element.indexOf(":")+1, element.length-2);
                        } else {
                            this.lifetimeTierImgWidth=element.slice(element.indexOf(":")+1, element.length-2);
                        }
                        console.log('Print the value of imgWidth'+this.imgWidth);
                    }
                    if(element.includes("border"))
                    {
                        console.log('Print the index of equals'+element.indexOf("="));
                        console.log('Print the index length'+element.length);
                        if (labelName == 'ffTier') {
                            this.imgBorder=element.slice(element.indexOf("=")+1, element.length-2);
                        } else {
                            this.lifetimeTierImgBorder=element.slice(element.indexOf("=")+1, element.length-2);
                        }
                        console.log('Print the value of imgBorder'+this.imgBorder);
                    }
                });

    }
   

   
}