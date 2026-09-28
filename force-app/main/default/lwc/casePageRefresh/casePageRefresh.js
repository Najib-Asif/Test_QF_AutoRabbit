import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import SENSITIVE_FIELD from "@salesforce/schema/Case.Sensitive__c";
import PARENTID_FIELD from "@salesforce/schema/Case.ParentId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CasePageRefresh extends LightningElement {
    @api recordId;
    caseValue;
    status;
    sensitive;
    ParentId;
    inter;
    getRecentResponse;
   
    @wire(getRecord, { recordId: "$recordId", fields: [STATUS_FIELD,SENSITIVE_FIELD, PARENTID_FIELD] })
    wiredRecord(response) {
        this.getRecentResponse = response;
        let error = response && response.error;
        let data = response && response.data;
    if (data) {
        this.caseValue = data;
        console.log('response of getRecord '+JSON.stringify(data));
        this.status=data.fields.Status.value;
        this.sensitive=data.fields.Sensitive__c.value;
        this.ParentId=data.fields.ParentId.value;

        //this.status = getFieldValue(data, STATUS_FIELD);
        //this.sensitive = getFieldValue(data, SENSITIVE_FIELD);
        //this.ParentId = getFieldValue(data, PARENTID_FIELD);
        //console.log('status==========> ' + this.status);
        //console.log('sensitive==========> ' + this.sensitive);
        //console.log('ParentId==========> ' + this.ParentId);
      
      if(((this.status=='In Progress' || this.status=='Reply Received') && this.sensitive===true && this.ParentId == null)){

              const evt = new ShowToastEvent({
               title: 'Hang on..... ',
               message: 'Case record is creating at backend. If child case is not created please contact administrator',
               variant: 'success',
             });
             this.dispatchEvent(evt);

           setTimeout(()=>{
             window.location.reload();
             
          },5000);
       }
    }
    else if (error) {
      console.log('error message '+ JSON.stringify(error));
      }
}
}