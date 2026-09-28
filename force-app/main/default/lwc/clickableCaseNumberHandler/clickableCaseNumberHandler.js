import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
export default class ClickableCaseNumberHandler extends NavigationMixin(LightningElement){
@api recordId;
@api caseNumber;
    //Navigate to record
    navigateToRecord(event){
        event.preventDefault();
        this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recordId,
				actionName: 'view',
			},
		});
        /*this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        }).then(url => {window.open(url)});
    }*/
    }

}