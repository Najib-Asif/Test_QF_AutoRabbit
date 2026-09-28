import { LightningElement, api,track } from 'lwc';
import invokePNRSearch from '@salesforce/apex/QCC_PNRSearchController.invokePNRSearch';
import invokePNRSearchWithoutLastName from '@salesforce/apex/QCC_PNRSearchController.invokePNRSearchWithoutLastName';



const columns = [
    { label: 'First Name', fieldName: 'firstName' ,wrapText: true},
    { label: 'Last Name', fieldName: 'lastName' , wrapText: true},
    { label: 'FF No.', fieldName: 'qantasFFNo', initialWidth: 100 , wrapText: true}
];


export default class QccCallerPassengerDataTable extends LightningElement {
    // @api recordId;
    passengers;
    columns = columns;
 
    // input from Flow
    @api pnr;
    @api lastName;
    @api creationDate;
    @api history;
    @track selectedRows=[];

    //output from Flow
    @api passengerSelected;
    @api firstName;
    @api qantasFFNo
    @api passengerId
    
    selectedPassenger;

    connectedCallback(){
        this.loadPassengerData();    
    }

    loadPassengerData() {
        console.log('Inside loadPassengerData');
        if(this.lastName){
            invokePNRSearch({ pnr: this.pnr, lastName: this.lastName })
                .then(result => {
                    this.passengers = JSON.parse(result);
                    console.log('Inside loadPassengerData::: this.passengers'+this.passengers);
                    console.log('Inside loadPassengerData length::: this.passengers'+this.passengers.length);
                    console.log('Inside loadPassengerData length::: this.passengers'+this.passengers[0].passengerId);
                    if (this.passengers.length === 1) {
                        this.selectedRows.push(this.passengers[0].passengerId); // Select the first row by default
                        this.handleRowSelection({ detail: { selectedRows: [this.passengers[0]] } }); // Trigger selection event
                        console.log('Inside loadPassengerData::'+this.passengers[0].passengerId);
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }else{
            invokePNRSearchWithoutLastName({pnr: this.pnr, creationDate: this.creationDate, archivalData:this.history})
                .then(result => {
                    this.passengers = JSON.parse(result);
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }

    handleRowSelection(event){

        this.selectedPassenger = event.detail.selectedRows[0];
        this.firstName = this.selectedPassenger.firstName;
        this.lastName = this.selectedPassenger.lastName;
        this.qantasFFNo = this.selectedPassenger.qantasFFNo;
        this.passengerSelected = true;
        this.passengerId = this.selectedPassenger.passengerId;
    }

}