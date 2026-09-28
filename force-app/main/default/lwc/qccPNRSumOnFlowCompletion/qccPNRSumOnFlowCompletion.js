import { LightningElement, api, track } from 'lwc';
import getURLAddress from '@salesforce/apex/QCC_PNRHighlightPanelController.getURLAddress';
export default class QccPNRSumOnFlowCompletion extends LightningElement 
{
    @api varPNRNumber;
    @api varQFFName;
    @api callerTypePicklist;
    @api callerFullName;
    @api varPassengerFullName;
    ARDURL='';
    @api varARDURLValue='';
    @api QFFVerified=false;
    @api NonQFF=false;
    @api qFAuthenticated;
    @track hasRendered = true;

    renderedCallback()
    {
        if(this.hasRendered)
        {
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for varPNRNumber'+this.varPNRNumber);
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for varPassengerFullName'+this.varPassengerFullName);
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for callerTypePicklist'+this.callerTypePicklist);
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for callerFullName'+this.callerFullName);
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for varQFFName'+this.varQFFName);
            console.log('>>> qccPNRSUMONFLOWCOMPLETION for qFAuthenticated'+this.qFAuthenticated);

           if((this.callerFullName.trim() === '' || this.callerFullName.trim() === null || this.callerFullName.trim() === undefined ) 
                && (this.callerTypePicklist === '' || this.callerTypePicklist === undefined || this.callerTypePicklist === null)
                && (this.varPassengerFullName))
            {
                console.log('@@@ inside the else if check for NON FF');
                this.callerFullName=this.varPassengerFullName;
            }
            if( this.callerTypePicklist === '' || this.callerTypePicklist === undefined || this.callerTypePicklist === null)
            {
                console.log('@@@ inside the else if check for NO On Behalf');
                this.callerTypePicklist='Passenger';
            }
        
            if(this.varPNRNumber !== undefined && this.varPNRNumber!== '' && this.varPNRNumber !== null)
            {
                    this.getURLAddress();
            }
            
            this.hasRendered=false;
        }
        
    }
    
    getURLAddress() {
        getURLAddress()
        .then(result => {
            if (result) {
                console.log('@@@ getURLAddress call to QccPNRSumOnFlowCompletion', JSON.stringify(result));
                let metadataInfo=result[0];
                console.log('@@@  metadataInfo from the result', JSON.stringify(metadataInfo));
                this.ARDURL=metadataInfo.ARD_Url__c;
                console.log('@@@ getARD URL received initally from the constroller'+this.ARDURL);  
                this.varPNRNumber=this.varPNRNumber.trim();

                let ARDURLFinal=this.ARDURL;
                this.ARDURLFinal=ARDURLFinal.replace('{pnrnum}',this.varPNRNumber);
                console.log('@@@  varPNRNumberFinal Value after PNRNUmber replacement'+this.ARDURLFinal);

                this.varARDURLValue=this.ARDURLFinal;
                console.log('@@@  varPNRNumberFinal Value after linking'+this.varPNRNumber);
            }
        })
        .catch(error=>{
            console.log('@@@ @@@ getURLAddress call to QccPNRSumOnFlowCompletion error: ' + JSON.stringify(error));
        });
    }

}