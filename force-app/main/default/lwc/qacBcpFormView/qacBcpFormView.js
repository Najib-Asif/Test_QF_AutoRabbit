import { LightningElement, api, track, wire } from 'lwc';
import getJsonData from '@salesforce/apex/QacBcpFormView.getJsonData';
import QAC_BCP_Message from '@salesforce/label/c.QAC_BCP_Message';

export default class QacBcpFormView extends LightningElement {
    @api recordId;
    bcpData=null;
    hasError = false;
    showSpinner = true;
    isLoaded = false;
    activeSections = ['1', '2', '3', '4'];
    paxCount;
    noFileMessage = QAC_BCP_Message;


    columns = [
        { label: 'Object', fieldName: 'ObjectAPI'},
        { label: 'Field Api Name', fieldName: 'FieldAPI' },
        { label: 'Default Value', fieldName: 'Value' },
        { label: 'Payload Field', fieldName: 'RequestParam' },
        { label: 'Data Type', fieldName: 'type' },
    ];
    specialRequirementsColumns = [
      {label: 'Requirement', fieldName: 'requirement', initialWidth: 135},
      {label: 'Flight number (one or many)', fieldName: 'flightNumber', initialWidth: 135},
      {label: 'Companion First Name', fieldName: 'companionFirstName', initialWidth: 135},
      {label: 'Companion Middle Name (if any)', fieldName: 'companionMiddleName', initialWidth: 135},
      {label: 'Companion Last Name', fieldName: 'companionSurName', initialWidth: 135},
      {label: 'Companion Booking No.', fieldName: 'companionBookingNumber', initialWidth: 135},
      {label: 'Preferred communication', fieldName: 'preferredLang', initialWidth: 135},
      {label: 'Travelling accompanied', fieldName: 'travelType', initialWidth: 135},
      {label: 'Passenger requires Meet & Assist', fieldName: 'meetAssist', initialWidth: 135},
      {label: 'Wheelchair Type', fieldName: 'wheelchairType', initialWidth: 135},
      {label: 'Additional information', fieldName: 'additionalInfo', initialWidth: 135}
    ];
   
    bookingSegmentDetailsColumns = [
      { label: 'Origin', fieldName: 'origin'},
      { label: 'Destination', fieldName: 'destination'},
      { label: 'Departure', fieldName: 'departureDate', type: 'date-local' },
      { label: 'Return', fieldName: 'returnDate', type: 'date-local' },
      { label: 'Flexible with dates', fieldName: 'flexibleWithDates', type: 'boolean' },
  ];

  bookingFlightDetailsColumns = [
    { label: 'Flight Number', fieldName: 'flightNumber' },
    { label: 'Flight Date', fieldName: 'flightDate', type: 'date-local' }
];

bookingPaxDetailsColumns = [
  { label: 'First Name', fieldName: 'firstName', initialWidth: 135 },
  { label: 'Last name', fieldName: 'surName', initialWidth: 135 }
];

    /*@wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'ContentDocumentLinks',
        fields: ['ContentDocumentLink.ContentDocument.LatestPublishedVersion.VersionData'],
        where:'{ ContentDocument:{ LatestPublishedVersion:{ PathOnClient :{eq: "QacRequestFile.snote"}}}}',
        sortBy: ['-ContentDocumentLink.ContentDocument.CreatedDate']
      }) */
      @wire(getJsonData, {recordId : '$recordId'})
      getRequestFileWired(result) {
        this.requestFileWired = result;
        const {error, data} = result;
        console.log('print the record ID'+this.recordId);
        /*if (data && data.records.length > 0) {
          //var x = data.records[0].ContentDocument.LatestPublishedVersion.VersionData;
          var x = getFieldValue(data.records[0], DATAFIELD);
            var strData = atob(x);
            var doc = new DOMParser().parseFromString(strData, "text/html");
            strData = doc.documentElement.textContent;
            data.records?.length > 0 && (this.bcpData = JSON.parse(strData));
            this.showSpinner = false;
            this.isLoaded = true;
        }*/
        if (data) {
            if (data.fileData) this.bcpData = JSON.parse(data.fileData);
            this.showSpinner = false;
            this.isLoaded = true;
            console.log('>>> here is thr light data'+JSON.stringify(this.bcpData.bookingDetails.flightDetails));
            /*if(this.bcpData.requestDetails.flightDetails)
            {
                this.FlightCount=this.bcpData.requestDetails.flightDetails.map((flightDetails, index) => {
                  return { flightDetails, fno: 'Flight: '+index};
              });
            }
            if(this.bcpData.requestDetails.paxDetails)
            {
                this.PaxCount=this.bcpData.requestDetails.paxDetails.map((paxDetails, index) => {
                return { paxDetails, pno: 'Pax: '+index};
              });
            } */
        }
        else if (error) {
          this.hasError = true;
          this.showSpinner = false;
          console.log(JSON.stringify(error));
        }
      }

      get requestDetails_FlightData() {
        return this?.bcpData?.requestDetails?.flightDetails?.map((flightDetails, index) => {
            return { flightDetails, fno: `Flight ${index+1}:`};
            });
      }

      get requestDetails_PaxData() {
        return this?.bcpData?.requestDetails?.paxDetails?.map((paxDetails, index) => {
            return { paxDetails, pno: `Pax ${index+1}:`};
            });
      }

      
    
}