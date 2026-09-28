import { LightningElement ,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class QccFlightEventDetail extends NavigationMixin(LightningElement){
    @api flghtEvnt;
    @api cardName;
    baseurl = '';
    connectedCallback(){
        this.baseurl = window.location.origin +'/lightning/r/Event__c/'+this.flghtEvnt.eventId +'/view';
    }
    get isHeader(){
        return this.cardName == 'header';
    }
    get isDelayed(){
        return ( this.flghtEvnt.departureDelay != '' || this.flghtEvnt.arrivalDelay != '' );
    }
    handleOpenRecord() {
        var recordpage = {
            type: "standard__recordPage",
            attributes: {
                recordId: this.flghtEvnt.eventId,
                actionName: "view",
            },
        };
        
        this[NavigationMixin.GenerateUrl](recordpage).then((url) => (this.url = url));
        this[NavigationMixin.Navigate](recordpage);
    }
    get departureInfo(){        
        return ((this.flghtEvnt.departureAirport != null ? this.flghtEvnt.departureAirport +', ' : '') +(this.flghtEvnt.departureCountryName != null ? this.flghtEvnt.departureCountryName : ''));
    }
    get arrivalInfo(){        
        return ((this.flghtEvnt.arrivalAirport != null ? this.flghtEvnt.arrivalAirport +', ' : '') +(this.flghtEvnt.arrivalCountryName != null ? this.flghtEvnt.arrivalCountryName : ''));
    }
    get isEstimatedArrival(){
        return (this.flghtEvnt.actualArrivalDate == null ? (( this.flghtEvnt.estDepTime != null || this.flghtEvnt.actualDepartDate != null)   ? (this.flghtEvnt.source != 'API' ? 'Estimated Arr.' : 'Arrival' ) : '' ) : 'Arrival' );             
        
    }
    get isEstimatedDept(){
        return (this.flghtEvnt.actualDepartDate == null ? (this.flghtEvnt.source != 'API' && this.flghtEvnt.estDepTime != null ? 'Estimated Dep.' : '' ) : 'Departure' );             
        
    }
    
    get departTime(){
        if(this.flghtEvnt.actualDepartTime){
            return this.flghtEvnt.actualDepartTime;
        }else if(this.flghtEvnt.estDepTime){
            return this.flghtEvnt.estDepTime;  
        }      
        else
            return '';
    }
    get departDate(){
        if(this.flghtEvnt.actualDepartTime){
            return this.flghtEvnt.actualDepartDate;
        }else if(this.flghtEvnt.estDepDate){
            return this.flghtEvnt.estDepDate;
        }else
            return '';
    }
     get arrivalTime(){
        if(this.flghtEvnt.actualArrivalTime){
            return this.flghtEvnt.actualArrivalTime;
        }else if(this.flghtEvnt.estArrTime){
            return this.flghtEvnt.estArrTime;
        }else if(this.flghtEvnt.actualDepartTime != null)
            return 'N/A';
        else
            return '';
    }
    get arrivalDate(){
        if(this.flghtEvnt.actualArrivalDate){
            return this.flghtEvnt.actualArrivalDate;
        }else if(this.flghtEvnt.estArrDate){
            return this.flghtEvnt.estArrDate;
        }else 
            return '';        
    }
}