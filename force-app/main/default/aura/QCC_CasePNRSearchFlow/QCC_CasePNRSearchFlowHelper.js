({
	getBookingList: function(component) {
        var lastName = component.get("v.lastName");
        var pnr = component.get("v.pnr");
		var archivalData = component.get("v.history");

        var spinner = component.find("LoadingSpinner");
        $A.util.addClass(spinner, "slds-hide");    

        var action = component.get("c.fetchCAPBooking");
        console.log('### QCC_CasePNRSearchFlow Helper getBookingList - Search Input Values -  PNR : ' + pnr + ' - Last Name : ' + lastName + ' - archivalData : ' + archivalData)
        action.setParams({
            "lastName": lastName,
            "pnr": pnr,
            "archivalData": archivalData
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('invoke PNR call');
            if (state === "SUCCESS") {
                console.log('### QCC_CasePNRSearchFlow Helper - fetchCAPBooking Response: ' + JSON.stringify(response.getReturnValue()));
                this.doLayout(response, component);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("LoadingSpinner");
            $A.util.addClass(spinner, "slds-hide");    
        });
        
        $A.enqueueAction(action);
    },
    
    updateCaseDetails: function(component) {

        var contactInfo = component.get("v.contact");
    
        var caseDetails = component.get("v.caseDetails");
        var segment = component.get("v.segment");
        var fromBooking = true;


        var pnr = component.get("v.pnr");
        var passenger = component.get("v.passenger");
        var firstPassenger = component.get("v.firstPassenger");
        var selectedSSR = component.get("v.selectedSSR");
        var archivalData = component.get("v.archivalData");
        var createdDate = component.get("v.creationDate");

    

        caseDetails.TECH_bookingCreationDate__c = createdDate;
        caseDetails.TECH_bookingArchivalData__c = archivalData;

        caseDetails.Booking_PNR__c = pnr;

        console.log('### Case PNR : '+pnr);
        console.log("contactInfo###",contactInfo.CAP_ID__c);
        console.log("contactInfo###",contactInfo.FirstName);


        if (contactInfo) {
            caseDetails.ContactId = contactInfo.Id;
            console.log('ContactId = '+caseDetails.ContactId);
            if ( (!caseDetails.Contact_Email__c || caseDetails.Contact_Email__c === "") &&  contactInfo.Preferred_Email__c )
                caseDetails.Contact_Email__c = contactInfo.Preferred_Email__c;
            if ( (!caseDetails.Contact_Phone__c || caseDetails.Contact_Phone__c === "") &&  contactInfo.Preferred_Phone_Number__c )
                caseDetails.Contact_Phone__c = contactInfo.Preferred_Phone_Number__c;
            if ( (!caseDetails.Street__c || caseDetails.Street__c === "") &&  contactInfo.MailingStreet )
                caseDetails.Street__c = contactInfo.MailingStreet;
            if ( (!caseDetails.Suburb__c || caseDetails.Suburb__c === "") &&  contactInfo.MailingCity )
                caseDetails.Suburb__c = contactInfo.MailingCity;
            if ( (!caseDetails.State__c || caseDetails.State__c === "") &&  contactInfo.MailingState )
                caseDetails.State__c = contactInfo.MailingState;
            if ( (!caseDetails.Post_Code__c || caseDetails.Post_Code__c === "") &&  contactInfo.MailingPostalCode )
                caseDetails.Post_Code__c = contactInfo.MailingPostalCode;
            if ( (!caseDetails.Country__c || caseDetails.Country__c === "") &&  contactInfo.CountryName__c )
                caseDetails.Country__c = contactInfo.CountryName__c;
            if ( (!caseDetails.First_Name__c || caseDetails.First_Name__c === "") &&  contactInfo.FirstName )
                caseDetails.First_Name__c = contactInfo.FirstName;
            if ( (!caseDetails.Last_Name__c || caseDetails.Last_Name__c === "") &&  contactInfo.LastName )
                caseDetails.Last_Name__c = contactInfo.LastName;

            console.log('### Case Details with Contact Info Added : ' + JSON.stringify(caseDetails));

        }

        if(segment != null){

            console.log('### QCC_CasePNRSearchFlow - Update Case - Adding this segment details : ' + JSON.stringify(segment));
            caseDetails.TECH_BookingSegmentId__c = segment.segmentId;
            caseDetails.TECH_BookingSegmentTattoo__c = segment.segmentTattoo;
            caseDetails.Airline__c = segment.airline;
            caseDetails.Flight_Number__c = segment.operatingFlightNumber;
            caseDetails.Departure_Airport_Code__c = segment.departureAirportCode;
            caseDetails.Arrival_Airport_Code__c = segment.arrivalAirportCode;

            caseDetails.Departure_Airport__c = segment.departureAirport;
            caseDetails.Departure_City__c = segment.departureCity;                  // should this be departureCityCode
            caseDetails.Departure_Country__c = segment.departureCountry;            // Not in test data
            caseDetails.Arrival_Airport__c = segment.arrivalAirport;                
            caseDetails.Arrival_City__c = segment.arrivalCity;                      // should this be arrivalCityCode
            caseDetails.Arrival_Country__c = segment.arrivalCountry;                // Not in test data
            caseDetails.Departure_Date_Time__c = segment.departureDateTime;
            caseDetails.Departure_UTC_Date_Time__c = segment.departureUTCDateTime;
            caseDetails.Actual_Departure_Date_Time__c = segment.actualDepartureDateTime;
            caseDetails.Arrival_Date_Time__c = segment.arrivalDateTime;
            caseDetails.Arrival_UTC_Date_Time__c = segment.arrivalUTCDateTime;

            caseDetails.Actual_Arrival_Date_Time__c = segment.actualArrivalDateTime;
            caseDetails.Sector__c = segment.departureAirportCode + ' ' + segment.arrivalAirportCode;
            caseDetails.Flight_Type_Code__c = segment.flightTypeCode !='D'? 'International':'Domestic';
            caseDetails.Aircraft_Type_Code__c = segment.aircraftTypeCode;
            caseDetails.Segment_Id__c = segment.segmentId;

            caseDetails.Flight_Number_With_Code__c = segment.operatingCarrierAlphaCode + segment.operatingFlightNumber.replace(/^0+/,'');

    
            var flightSegmentsTable = '<html><table border="1" width="100%">';
            flightSegmentsTable = flightSegmentsTable + '<thead><tr><th>Flight Number</th><th>Departure Date</th><th>Departure Port</th><th>Arrival Port</th></tr></thead>';
            flightSegmentsTable = flightSegmentsTable + '<tbody><tr><td style="text-align:center">'+segment.operatingCarrierAlphaCode+segment.operatingFlightNumber.replace(/^0+/,'')+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td style="text-align:center">'+segment.departureLocalDate+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td style="text-align:center">'+segment.departureAirportCode+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td style="text-align:center">'+segment.arrivalAirportCode+'</td></tr></tbody></table></html>';

            caseDetails.Flight_Segments__c = flightSegmentsTable;
            
            var flighDelayed = false;
            var delayReason;
            var flightCancelled = false;
            
            if(segment.disrupts != null) {
                for(var i in segment.disrupts) {
                    if(segment.disrupts[i].type === 'DELAY' && segment.disrupts[i].details != null) {
                        flighDelayed = true;
                        for(var j in segment.disrupts[i].details) {
                            if(segment.disrupts[i].details[j].shortDescription != 'WEATHER' && segment.disrupts[i].details[j].shortDescription != 'WEA') {
                                delayReason = 'Operational';
                                break;
                            } else {
                                delayReason = 'Weather';
                            }
                        }
                    }
                    else if(segment.disrupts[i].type === 'CANCELLED') {
                        flightCancelled = true;
                    }
                }
            }
            caseDetails.Flight_Delay__c = flighDelayed;
            caseDetails.Flight_Cancellation__c = flightCancelled;
            caseDetails.Delay_Reason__c = delayReason;    
        }


        if(passenger != null) {
            caseDetails.Passenger_Id__c = passenger.passengerId;
            caseDetails.Passenger_First_Name__c = passenger.firstName;
            caseDetails.Passenger_Last_Name__c = passenger.lastName;
            caseDetails.ABN_Number__c = passenger.corpId;                           // Not in test data
            caseDetails.Qantas_Corporate_Identifier__c = passenger.smeId;           // Not in test data
            console.log('## QCC_CasePNRSearchFlow - Updating Passenger Details : ', JSON.stringify(passenger));
        }   
            


        var flightLegFlownTable = '<html><table border="1" width="100%">';
            flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';			

        var bookinginfo = component.get("v.completebooking");

            if(bookinginfo && bookinginfo.lstFlightPassenger)
                firstPassenger = bookinginfo.lstFlightPassenger[0];
    
            if(firstPassenger != null) {
            caseDetails.Cabin_Class__c = firstPassenger.cabinClass;
            caseDetails.Seat_Number__c = firstPassenger.seatNumber;
            caseDetails.Passenger_Id__c = firstPassenger.passengerSegmentId;
            flightLegFlownTable = flightLegFlownTable + '<tr><td>'+firstPassenger.depaturePort+'</td>';
            flightLegFlownTable = flightLegFlownTable + '<td>'+firstPassenger.arrivalPort+'</td>';
            
            if(firstPassenger.boardingStatus == 'Not Boarded') {
                flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                caseDetails.Check_In_Status__c = 'Not Boarded';
            } else if(firstPassenger.boardingStatus == 'Boarded') {
                flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                caseDetails.Check_In_Status__c = 'Boarded';
            }			
            flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';

            caseDetails.Flight_Leg_Flown_Statuses__c = flightLegFlownTable;
            console.log('## QCC_CasePNRSearchFlow - Updating First Passenger Details : '+ JSON.stringify(firstPassenger));
        }
            
        if(bookinginfo.lstPassengerSSR)
            selectedSSR = bookinginfo.lstPassengerSSR;

        if(selectedSSR != null) {
            var specificNeeds;
            for(var i in selectedSSR) {
                if(specificNeeds != null)
                specificNeeds += ";" + selectedSSR[i].description;
                else
                    specificNeeds = selectedSSR[i].description;
            }
        
            caseDetails.Specific_Needs__c = specificNeeds;

            console.log('### selectedSSR details are present : '+selectedSSR);
            console.log('specific needs = '+specificNeeds);        
        }
        
        component.set("v.caseDetails", caseDetails );
        console.log('### Case Details To Be Updated Update: ');
        console.log(JSON.stringify(caseDetails) );
        console.log('### Case Details To Be Updated Update: ' +      caseDetails.Departure_Airport__c + ' - '+
        caseDetails.Departure_City__c + ' - ' + caseDetails.Departure_Country__c);
    },

    getContactDetails: function(component, response){ 

        var contactDetails = component.get("v.contact");      
        var result;
        if(response.getReturnValue() == "NameMismatch") {
            result = response.getReturnValue();
        } else {
            result = JSON.parse(response.getReturnValue());
        }                
        console.log('### QCC_CasePNRSearchFlow Helper getContactDetails result : '+JSON.stringify(result));
        if(result != null && result != 'NameMismatch') {
            var phones = result.displayPhone;
            console.log('### QCC_CasePNRSearchFlow Helper getContactDetails, phones result  : '+JSON.stringify(phones));
            console.log('### QCC_CasePNRSearchFlow Helper getContactDetails, No. of Phones : '+phones.length);
            if(phones.length != 0) {
                var phoneSelected = false;
                var phone;
                for(var i in phones) {
                    if(phones[i].label.startsWith('Other')) {
                        console.log('### QCC_CasePNRSearchFlow Helper getContactDetails Phone Selected : '+JSON.stringify(phones[i]));
                        phone = phones[i].phoneNumber;
                        break;
                    } else if(!phoneSelected) {
                        phone = phones[i].phoneNumber;
                        phoneSelected = true;
                    }
                }
            }
            var address = result.address;
            var street, suburb, postCode, stateCode, country;
            if(address) { // Update details only if they are blank ro null
                if ( (!contactDetails.MailingStreet || contactDetails.MailingStreet === "") &&  address.street )
                    contactDetails.MailingStreet = address.street;
                if ( (!contactDetails.MailingCity || contactDetails.MailingCity === "") &&  address.suburb )
                    contactDetails.MailingCity = address.suburb;
                if ( (!contactDetails.stateCode || contactDetails.stateCode === "") &&  address.state )
                    contactDetails.stateCode = address.state;
                if ( (!contactDetails.MailingState || contactDetails.MailingState === "") &&  address.postCode )
                    contactDetails.MailingState = address.postCode;
                if ( (!contactDetails.CountryName__c || contactDetails.CountryName__c === "") &&  address.country )
                    contactDetails.CountryName__c = address.country;
                }
            if ( (!contactDetails.FirstName || contactDetails.FirstName === "") &&  result.firstName )
                contactDetails.FirstName = result.firstName;
            if ( (!contactDetails.CountryName__c || contactDetails.CountryName__c === "") &&  result.lastName )
                contactDetails.LastName = result.lastName;
            if ( (!contactDetails.Preferred_Email__c || contactDetails.CountryName__c === "") &&  result.email )
                contactDetails.Preferred_Email__c = result.email;
            if ( (!contactDetails.Preferred_Phone_Number__c || contactDetails.Preferred_Phone_Number__c === "") &&  phone )
                contactDetails.Preferred_Phone_Number__c = phone;

            // SHOULD UPDATE CONTACT DETAILS HERE
            component.set("v.contact",contactDetails);
            console.log('### QCC_CasePNRSearchFlow Helper getContactDetails updates : '+ JSON.stringify(contactDetails));

        } 
    },

    doLayout: function(response, component) {
        var data = response.getReturnValue(); 
        var state = response.getState();
        // component.set("v.hideNext", true);
        /*var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");*/
        var lstCurrentVal = [];
        console.log("state###",state);
        if(state === "SUCCESS" && data != null){
            if(data.bookings){
                component.set("v.lstCurrentBook",data.bookings); 
                console.log("### QCC_CasePNRSearchFlow Helper - ",data.bookings);
                console.log("### QCC_CasePNRSearchFlow Helper - departureTimeStamp "+data.bookings[0].departureTimeStamp); 
                console.log("### QCC_CasePNRSearchFlow Helper - bookingId "+data.bookings[0].bookingId); 
                //If there is only one booking then populate retrieve the booking details
                if(data.bookings.length == 1){
                    console.log("### QCC_CasePNRSearchFlow Helper - Only one Booking record. Opening Flight Details COmponent "); 
                    component.set("v.archivalData",data.bookings[0].archivalData);
                    component.set("v.creationDate",data.bookings[0].creationDate);
            
                    component.set("v.showSearchButton", false);
                    component.set("v.showFlightDetails", true);            
                   // var flightDetailComponent = component.find("flightDetailComponent");
                    //flightDetailComponent.flightSelected(data.bookings[0].bookingId);            
                }   

            }
        } else if (state === "ERROR") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        } else if (state === "INCOMPLETE") {
             component.set("v.showMsg", true);
            var error = "Error";
            component.set("v.lstCurrentBook",lstCurrentVal);
            component.set("v.hideNext", false);
        }else{
             component.set("v.lstCurrentBook",lstCurrentVal);
             component.set("v.showMsg", true);
        }
        
    },

    refreshSection : function(component,  history){
        console.log("### QCC_CasePNRSearchFlow - Executing refreshSection");
        var passengerId = component.get("v.passengerID");
        var segmentId = component.get("v.segmentID");
        var segmentTattoo = component.get("v.segmentTattoo");
        var onLoadInfo = component.get("v.completebooking");


        var firstName;
        var lastName;
        var passengers;

        if(onLoadInfo.pnrPassengerInfo != null) {
            passengers = onLoadInfo.pnrPassengerInfo.booking.passengers;
            var i;
            for(i in passengers){
                if(passengers[i].passengerId == passengerId){
                    firstName = passengers[i].firstName;
                    lastName = passengers[i].lastName;
                    component.set("v.passenger", passengers[i]);
                    component.set("v.passengerTattoo", passengers[i].passengerTattoo);
                    console.log("### QCC_CasePNRSearchFlow - Passengers a listed. Selected Passender Id : " + passengerId);

                    break;
                }
            }
        }
        if(onLoadInfo.pnrFlightInfo!= null){
            var segments = onLoadInfo.pnrFlightInfo.booking.segments;
            component.set("v.segment", segments);
            
            for(i in segments){
                console.log('segment**'+JSON.stringify(segments[i]));
                console.log(segmentId);
                if(segments[i].segmentId == segmentId){
                    component.set("v.segment", segments[i]);
                    console.log("### QCC_CasePNRSearchFlow - Segments found. SegmentId selected : " + segmentId);
                    break;
                }
            }
        }        
        if(onLoadInfo.pnrFlightInfo != null || onLoadInfo.pnrFlightHistInfo != null) {
            if(history) {
                 var segments = onLoadInfo.pnrFlightHistInfo.booking.segments;
                 component.set("v.segment", segments);
                 for(i in segments){
                    if(segments[i].segmentTattoo == segmentTattoo){
                        component.set("v.segment", segments[i]);
                        console.log("### QCC_CasePNRSearchFlow - Segments found. History Selected PassengerId selected : " + passengerId);
                        break;
                    }
                }
            }
        }
        var creationDate = component.get("v.creationDate");
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        component.set("v.creationDate", formatDate);

    },
    
})