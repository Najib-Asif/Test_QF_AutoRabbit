import { LightningElement,api,track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import invokeAssociateContact from "@salesforce/apex/qcc_SearchTabAssociateContact.associateContact";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [{ label: 'First Name', fieldName: 'firstName' , wrapText: true},
        { label: 'Last Name', fieldName: 'lastName' , wrapText: true},
        { label: 'Email', fieldName: 'Email' , wrapText: true},
        { label: 'Phone', fieldName: 'phone' , wrapText: true},
        { label: 'FF No.', fieldName: 'ffNumber', initialWidth: 100 , wrapText: true},
    ];

export default class QccSearchedPNRContactView extends NavigationMixin(LightningElement) {

    //Input from flow to LWC
    passengers=[];
    columns = columns;
    @api recordId;
    @api lastName;
    @api contactId;
    @api contactAssociated=false;
    @api firstName;
    @api phone;
    @api Email;
    @api ffNumber;
    @api create;
    @api associate;
    @track hasRendered = true;
    @api showFF=false;

    

    renderedCallback()
    {
        if(this.hasRendered)
        {
            if(this.ffNumber !== undefined && this.ffNumber!== '' && this.ffNumber !== null)
            {
                    this.showFF=true;
                    
            }
            this.passengers=[{ firstName: this.firstName, lastName: this.lastName, Email: this.Email, phone: this.phone, ffNumber: this.ffNumber }];
            this.hasRendered=false;
        }
    }
    /*handleRowSelection(event){
        this.selectedPassenger = event.detail.selectedRows[0];
        this.firstName = this.selectedPassenger.firstName;
        this.lastName = this.selectedPassenger.lastName;
        this.ffNumber = this.selectedPassenger.qantasFFNo;
        this.passengerSelected = true;
        this.passengerId = this.selectedPassenger.passengerId;
    }  */  
    
}