import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getBookingsDetails from "@salesforce/apex/QCC_viewBookings.getBookingsDetails";
import getContactForBookingDetails from "@salesforce/apex/QCC_viewBookings.getContactForBookingDetails";

const columns = [
  {
    label: "PNR",
    fieldName: "pnr",
    type: "clickablePNR",
    typeAttributes: {
      pnrNum: { fieldName: "pnr" }
    }
  },
  { label: "DEP", fieldName: "departureAirportCode" },
  { label: "ARR", fieldName: "arrivalAirportCode" },
  { label: "Departure Date", fieldName: "departureLocalDate" },
  {
    label: "Ticketing Status",
    fieldName: "ticketStatus",
    cellAttributes: {
      alignment: 'center',
      class:"slds-text-color_error slds-text-title_bold"
  }
  },
  {
    label: "Flight Status",
    fieldName: "reservationStatusCode",
    cellAttributes: {
      class:
        "slds-text-color_error slds-text-title_bold",
      alignment: 'center'
    }
  }
];

export default class QccSuggestedBookingMatchesTable extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  contact;
  @track bookings = [];
  columns = columns;

  @track error;
  @track noData;
  errorStatus = 0;

  @api pageNumber = 1;
  @api hideNext = false;
  environmentUrl;


  connectedCallback() {
    this.loadData();
  }

  async loadData() {
    try {
      await this.getContactDetailFromApex();
      this.loadBookingDetails();
    } catch (error) {
      console.error('Error in loadData: ', error);
    }
    
  }

  async loadBookingDetails() {
    if (this.contact) {
      const ffNumberList = new Array(this.contact.Frequent_Flyer_Number__c); // create a list
      console.log(">>>ffNumberList: " + ffNumberList);
      console.log(">>>ffNumberList: " + JSON.stringify(ffNumberList));
      getBookingsDetails({
        ffNumberList: ffNumberList,
        pageNumber: this.pageNumber
      })
        .then((result) => {
          if(!result[0].errMsg){
            if (result && result.length > 0) {
              this.bookings = result;
              this.hideNext = result[0].lastPage;

              this.error = undefined;
              this.noData = undefined;
            } else {
              this.noData = true;
              this.error = undefined;
              this.bookings = undefined;
            }
          }
          else{
          this.error = result[0].errMsg;
            this.hideNext = true;
            this.noData = undefined;
            this.bookings = undefined;
          }
        })
        .catch((error) => {
          this.errorStatus = error.status;
          if (error.body && error.status === 500) {
            this.error = "Error: Unable to display bookings";
        }
            this.hideNext = true;
          this.noData = undefined;
          this.bookings = undefined;
        });
    }
  }

  async getContactDetailFromApex() {
    try {
      const result = await getContactForBookingDetails({
        recordId: this.recordId
      });
      this.contact = result[0];
    } catch (err) {
      console.error(err);
    }
  }

  get errorIconName (){
    return this.errorStatus === 404 ? 'utility:announcement' : 'utility:error';
  }

  get hidePrev() {
    return this.pageNumber === 1;
  }

  handlePrevious() {
    if (this.pageNumber > 1) {
      this.pageNumber--;
      this.loadData();
    }
  }

  handleNext() {
    if (!this.hideNext) {
      this.pageNumber++;
      this.loadData();
      // this.hidePrev = false;
    }
  }

  handleClick(event) {
    let pnr = JSON.parse(JSON.stringify(event.detail));
    console.log("handle click@@@@@@", pnr);

    //find the booking with the clicked PNR
    const selectedBooking = this.bookings.find(
      (booking) => booking.pnr === pnr.pnrNum
    );
    console.log("selecrtedBooking@@@@", selectedBooking);

    if (selectedBooking) {
      const { pnr: pnrNum, creationDate } = selectedBooking;
      this.navigateToAuraComponent(
        pnrNum,
        creationDate,
        this.recordId,
        "false",
        true
      );
    }
  }

  navigateToAuraComponent(pnr, creationDate, recordId, archivalData, isNeedToFormatDate) {
    this[NavigationMixin.Navigate]({type: "standard__component",
    attributes: {
        componentName: "c__QCC_PNRBookingFlightDetails"
    },
    state: {
      c__pnr: pnr,
      c__creationDate: creationDate,
      c__recordId: recordId,
      c__archivalData: archivalData,
      c__isNeedToFormatDate: isNeedToFormatDate
    }});
  }
}