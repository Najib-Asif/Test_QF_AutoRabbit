import { LightningElement, api, wire, track } from 'lwc';
import qSVG from '@salesforce/resourceUrl/QantasSVG';
import flightEventsApex from '@salesforce/apex/CaseFlightInfoService.getFlightInfoForCase';
import { EnclosingTabId, getTabInfo, openSubtab } from 'lightning/platformWorkspaceApi';

const VIEWALLBUTTON = 'View all';
const VIEWLESSBUTTON = 'View less';
const NOOFRECSDISPLAY = 3;
const QANTASFLGHTPREFIX = 'QF';

export default class QccFlightEventsList extends LightningElement {
    @api recordId;
    @track flightInfoWrapper = [];
    @track flightInfoWrapperTemp = [];
    @track flightEventInfoDefaultLst = [];
    qantasLogo = qSVG + '#qsvg';
    showViewLess = false;
    isDefaultPresent = false;
    errorMessage;
    flightDetailsFirst = {};
    flightDetailsLast = {};
    firstFlag = true;

    connectedCallback() {
        this.flightEventDetails();
    }

    @wire(EnclosingTabId) tabId;

    flightEventDetails(){
        flightEventsApex({ caseId: this.recordId })
            .then(result => {
                 console.log('result...'+ JSON.stringify(result));
                let flightEventInfoWrapperLst = [];
                result.forEach((item) => {
                    if(item.source == 'Error'){
                        this.errorMessage = item.message;
                    } else{
                        let flightDetailsWrapper = {};
                        let flightEventWrapperList = [];
                        let isFEPresent = item.flightEventWrapper != null && item.flightEventWrapper.length != 0 ? true : false;
                        console.log('item...'+JSON.stringify(item));
                        flightDetailsWrapper.flightNumber =  item.flightNumber;
                        //flightDetailsWrapper.lgtngClass =  'light-card';
                        flightDetailsWrapper.isDefault = item.isDefaultRecord != null ? true : false;
                        if(flightDetailsWrapper.isDefault){
                            this.isDefaultPresent = true;
                        }
                        flightDetailsWrapper.isQantas =  item.flightNumber != null ? item.flightNumber.startsWith(QANTASFLGHTPREFIX) : false;
                        flightDetailsWrapper.departureAirport =  item.departureAirport;
                        flightDetailsWrapper.arrivalAirport =  item.arrivalAirport;
                        flightDetailsWrapper.departureCountryName =  item.departureCountryName;
                        flightDetailsWrapper.arrivalCountryName =  item.arrivalCountryName;
                        flightDetailsWrapper.departureAirportCode =  item.departureAirportCode;
                        flightDetailsWrapper.arrivalAirportCode = item.arrivalAirportCode;
                        flightDetailsWrapper.scheduledDepartureDate =  item.scheduledDepartureDate;
                        flightDetailsWrapper.scheduledArrivalDate =  item.scheduledArrivalDate;
                        flightDetailsWrapper.scheduledDepartureTime =  item.scheduledDepartureTime;
                        flightDetailsWrapper.scheduledArrivalTime =  item.scheduledArrivalTime;
                        flightDetailsWrapper.showEstActualDepArr =  (item.delayFailurecode != 'Cancelled') && ((item.estDepDate != null || item.estArrDate != null) || 
                                                                (item.actualDepartDate != null || item.actualArrivalDate != null));
                        flightDetailsWrapper.actualDepartDate = item.actualDepartDate != null ? 'Departed': item.estDepDate != null ? 'Estimated Dep.' : null;
                        flightDetailsWrapper.estActArrLabel = item.actualArrivalDate != null ? 'Arrived': item.estDepDate != null ? 'Estimated Arr.' : 
                        flightDetailsWrapper.estActDepLabel != null ? 'Estimated Arr.' : null;
                        flightDetailsWrapper.actualDepartDate =   item.actualDepartDate != null ? item.actualDepartDate : item.estDepDate != null ? item.estDepDate : null;
                        flightDetailsWrapper.actualArrivalDate =  item.actualArrivalDate != null ? item.actualArrivalDate : item.estArrDate != null ? item.estArrDate : null;
                        flightDetailsWrapper.actualDepartTime =  item.actualDepartTime != null ? item.actualDepartTime : item.estDepTime != null ? item.estDepTime : null;
                        flightDetailsWrapper.actualArrivalTime = item.actualArrivalTime != null ? item.actualArrivalTime : item.estArrTime != null ? item.estArrTime : null;
                        flightDetailsWrapper.feFailureCde =   item.delayFailurecode ;
                        flightDetailsWrapper.showDelay =  item.delayFailurecode != null ?  true : false;
                        flightDetailsWrapper.depDelay =  item.departureDelay ;
                        flightDetailsWrapper.arrDelay =   item.arrivalDelay ;
                        flightDetailsWrapper.isFEvent =   item.eventId != null ;
                        flightDetailsWrapper.feLink =  item.eventId != null ? item.eventId : null;
                        flightDetailsWrapper.feName=  item.eventName ;
                        flightDetailsWrapper.fePresent = isFEPresent;
                        flightDetailsWrapper.source = item.source;
                        flightDetailsWrapper.disruptionDetails=item.disruptionDetails;
                        flightDetailsWrapper.disruptionCause=item.disruptionCause;
                        if(isFEPresent){
                            flightEventWrapperList = JSON.parse(JSON.stringify(item.flightEventWrapper));
                        }
                        flightDetailsWrapper.flightEventWrapperList = flightEventWrapperList;
                        if(flightDetailsWrapper.isDefault){
                            this.flightEventInfoDefaultLst.push(flightDetailsWrapper);
                        }
                        flightEventInfoWrapperLst.push(flightDetailsWrapper);
                        if(this.firstFlag){
                            this.flightDetailsFirst = flightDetailsWrapper;
                            this.firstFlag = false;
                        }
                        this.flightDetailsLast = flightDetailsWrapper;
                    }
                })

                console.log('final wrapper...'+JSON.stringify(flightEventInfoWrapperLst));
                this.flightInfoWrapper = JSON.parse(JSON.stringify(flightEventInfoWrapperLst));
                if(this.isDefaultPresent){ //Any default records present
                    this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(this.flightEventInfoDefaultLst));
                } else if(flightEventInfoWrapperLst.length > NOOFRECSDISPLAY){ //No defaults and more than 3 records
                    this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(flightEventInfoWrapperLst.slice(0,NOOFRECSDISPLAY)));
                } else{ //Show all records
                    this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(flightEventInfoWrapperLst));
                }
                
            })
            .catch(error => {
                
                console.error('Error fetching flightEventDetails: ', error);
            });

    }
   /*
    @wire(flightEventsApex, { caseId: "$recordId" })
    case(result){
        if(result.data) {  
            console.log('result...'+ JSON.stringify(result.data));
            let flightEventInfoWrapperLst = [];
            result.data.forEach((item) => {
                if(item.source == 'Error'){
                    this.errorMessage = item.message;
                } else{
                    let flightDetailsWrapper = {};
                    let flightEventWrapperList = [];
                    let isFEPresent = item.flightEventWrapper != null && item.flightEventWrapper.length != 0 ? true : false;
                    console.log('item...'+JSON.stringify(item));
                    flightDetailsWrapper.flightNumber =  item.flightNumber;
                    //flightDetailsWrapper.lgtngClass =  'light-card';
                    flightDetailsWrapper.isDefault = item.isDefaultRecord != null ? true : false;
                    if(flightDetailsWrapper.isDefault){
                        this.isDefaultPresent = true;
                    }
                    flightDetailsWrapper.isQantas =  item.flightNumber != null ? item.flightNumber.startsWith(QANTASFLGHTPREFIX) : false;
                    flightDetailsWrapper.departureAirport =  item.departureAirport;
                    flightDetailsWrapper.arrivalAirport =  item.arrivalAirport;
                    flightDetailsWrapper.departureCountryName =  item.departureCountryName;
                    flightDetailsWrapper.arrivalCountryName =  item.arrivalCountryName;
                    flightDetailsWrapper.departureAirportCode =  item.departureAirportCode;
                    flightDetailsWrapper.arrivalAirportCode = item.arrivalAirportCode;
                    flightDetailsWrapper.scheduledDepartureDate =  item.scheduledDepartureDate;
                    flightDetailsWrapper.scheduledArrivalDate =  item.scheduledArrivalDate;
                    flightDetailsWrapper.scheduledDepartureTime =  item.scheduledDepartureTime;
                    flightDetailsWrapper.scheduledArrivalTime =  item.scheduledArrivalTime;
                    flightDetailsWrapper.showEstActualDepArr =  (item.delayFailurecode != 'Cancelled') && ((item.estDepDate != null || item.estArrDate != null) || 
                                                            (item.actualDepartDate != null || item.actualArrivalDate != null));
                    flightDetailsWrapper.actualDepartDate = item.actualDepartDate != null ? 'Departed': item.estDepDate != null ? 'Estimated Dep.' : null;
                    flightDetailsWrapper.estActArrLabel = item.actualArrivalDate != null ? 'Arrived': item.estDepDate != null ? 'Estimated Arr.' : 
                    flightDetailsWrapper.estActDepLabel != null ? 'Estimated Arr.' : null;
                    flightDetailsWrapper.actualDepartDate =   item.actualDepartDate != null ? item.actualDepartDate : item.estDepDate != null ? item.estDepDate : null;
                    flightDetailsWrapper.actualArrivalDate =  item.actualArrivalDate != null ? item.actualArrivalDate : item.estArrDate != null ? item.estArrDate : null;
                    flightDetailsWrapper.actualDepartTime =  item.actualDepartTime != null ? item.actualDepartTime : item.estDepTime != null ? item.estDepTime : null;
                    flightDetailsWrapper.actualArrivalTime = item.actualArrivalTime != null ? item.actualArrivalTime : item.estArrTime != null ? item.estArrTime : 'N/A';
                    flightDetailsWrapper.feFailureCde =   item.delayFailurecode ;
                    flightDetailsWrapper.showDelay =  item.delayFailurecode != null ?  true : false;
                    flightDetailsWrapper.depDelay =  item.departureDelay ;
                    flightDetailsWrapper.arrDelay =   item.arrivalDelay ;
                    flightDetailsWrapper.isFEvent =   item.eventId != null ;
                    flightDetailsWrapper.feLink =  item.eventId != null ? item.eventId : null;
                    flightDetailsWrapper.feName=  item.eventName ;
                    flightDetailsWrapper.fePresent = isFEPresent;
                    if(isFEPresent){
                        flightEventWrapperList = JSON.parse(JSON.stringify(item.flightEventWrapper));
                    }
                    flightDetailsWrapper.flightEventWrapperList = flightEventWrapperList;
                    if(flightDetailsWrapper.isDefault){
                        this.flightEventInfoDefaultLst.push(flightDetailsWrapper);
                    }
                    flightEventInfoWrapperLst.push(flightDetailsWrapper);
                    if(this.firstFlag){
                        this.flightDetailsFirst = flightDetailsWrapper;
                        this.firstFlag = false;
                    }
                    this.flightDetailsLast = flightDetailsWrapper;
                }
            })

            console.log('final wrapper...'+JSON.stringify(flightEventInfoWrapperLst));
            this.flightInfoWrapper = JSON.parse(JSON.stringify(flightEventInfoWrapperLst));
            if(this.isDefaultPresent){ //Any default records present
                this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(this.flightEventInfoDefaultLst));
            } else if(flightEventInfoWrapperLst.length > NOOFRECSDISPLAY){ //No defaults and more than 3 records
                this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(flightEventInfoWrapperLst.slice(0,NOOFRECSDISPLAY)));
            } else{ //Show all records
                this.flightInfoWrapperTemp = JSON.parse(JSON.stringify(flightEventInfoWrapperLst));
            }
        }
        else{
            console.log('Resulet '+JSON.stringify(result));
        }
    }
    */

    get renderFEvents(){
        return this.flightInfoWrapper.length != 0;
    }

    get noPNRFlightData(){
        return !this.renderFEvents;
    }

    get noOfRecrds(){
        return this.flightInfoWrapper.length != 0 ? this.flightInfoWrapper.length : 0;
    }

    get parentCardTitle(){
        return this.errorMessage != null ? 'Flight Details' : 'Flight Details ('+ this.noOfRecrds + ')';
    }

    get showViewAllButton(){
        return this.noOfRecrds > NOOFRECSDISPLAY;
    }

    get buttonLabel(){
        return this.showViewLess ? VIEWLESSBUTTON : VIEWALLBUTTON;
    }

    get showButton(){
        return (this.isDefaultPresent &&  this.flightInfoWrapper.length > this.flightEventInfoDefaultLst.length) ||  
                (!this.isDefaultPresent && (this.showViewAllButton || this.showViewLess)) ? true : false;
    }

    renderedCallback(){
        console.log('frist invoke red call');
        if(this.isDefaultPresent){        
            const  articleElements = this.template.querySelectorAll('article');
            if(articleElements.length !== 0){
                articleElements.forEach((card) =>{
                console.log('frist invoke card..'+card.textContent);
                    if(card.textContent.includes('isDefaultfalse')){
                        card.style.setProperty('--slds-c-card-color-background','#F3F2F2');
                    }
                });
            }
        }
    }

    handleClick(){
        if(this.buttonLabel == VIEWALLBUTTON){
            this.flightInfoWrapperTemp = [];
            this.flightInfoWrapperTemp =  JSON.parse(JSON.stringify(this.flightInfoWrapper));
            this.showViewLess = true;
        } else {
            this.flightInfoWrapperTemp = [];
            this.flightInfoWrapperTemp = this.isDefaultPresent ? JSON.parse(JSON.stringify(this.flightEventInfoDefaultLst)) : 
                                        JSON.parse(JSON.stringify(this.flightInfoWrapper.slice(0,NOOFRECSDISPLAY)));;
            this.showViewLess = false;
        }
    }

    async handleFEClick(event){
        if (!this.tabId) {
            return;
        }
    
        const tabInfo = await getTabInfo(this.tabId);
        const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
    
        // Open a record as a subtab of the current tab
        await openSubtab(primaryTabId, { recordId: event.target.dataset.id, focus: true });
    }
}