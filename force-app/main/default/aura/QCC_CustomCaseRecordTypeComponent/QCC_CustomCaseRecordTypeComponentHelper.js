({
    getRecordType : function(component) {
        var action = component.get("c.fetchRecordTypeValues");
               
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        }); 
        $A.enqueueAction(action);
    },
    doLayout: function(response, component) {
        var data = response.getReturnValue();
        //for (var key in data) {
                component.set('v.lstOfRecordType', data);
            //};
    },
    createCase: function(component,event){
        var rectypeId = event.getSource();
        //alert('rectypeId'+ rectypeId.get("v.text"));
        var idsf = rectypeId.get("v.text");
        var contactInfo = component.get("v.objCon");
        var fromBooking = component.get("v.fromBooking");
        console.log("contactInfo###",contactInfo);
        var createCaseEvent = $A.get("e.force:createRecord");
        if(!fromBooking) {
            createCaseEvent.setParams({
                "entityApiName": "Case",
                "defaultFieldValues": {
                    'ContactId' : contactInfo.Id,
                    'Contact_Email__c': contactInfo.Preferred_Email__c,
                    'Contact_Phone__c': contactInfo.Preferred_Phone_Number__c,                
                    'Street__c' : contactInfo.MailingStreet,
                    'Suburb__c': contactInfo.MailingCity,
                    'State__c': contactInfo.MailingState, 
                    'Post_Code__c': contactInfo.MailingPostalCode,
                    'Country__c': contactInfo.CountryName__c,
                    'First_Name__c': contactInfo.FirstName,
                    'Last_Name__c': contactInfo.LastName
                 },
                "recordTypeId": idsf
            });
        }
        else {
            var pnr = component.get("v.pnr");
            var archivalData = component.get("v.archivalData");
            var createdDate = component.get("v.createdDate");
            var recId = component.get("v.contactId");
            var segment = component.get("v.objCon");
            var passenger = component.get("v.objPassenger");
            var conDetails = component.get("v.conDetails");
            var firstPassenger = component.get("v.firstPassenger");
            var selectedSSR = component.get("v.selectedSSR");
            console.log('selectedSSR = '+selectedSSR);
            /*var arr = conDetails.split("|");
            var email = arr[0] != 'null' ? arr[0] : '';
            var phone = arr[1] != 'null' ? arr[1] : '';
            var MailingStreet = arr[2] != 'null' ? arr[2] : '';
            var MailingCity = arr[3] != 'null' ? arr[3] : '';
            var MailingState = arr[4] != 'null' ? arr[4] : '';
            var MailingPostalCode = arr[5] != 'null' ? arr[5] : '';
            var CountryName = arr[6] != 'null' ? arr[6] : '';*/
            var contactInfo = component.get("v.con");
            var email = contactInfo.Preferred_Email__c;
            var phone = contactInfo.Preferred_Phone_Number__c;
            var MailingStreet = contactInfo.MailingStreet;
            var MailingCity = contactInfo.MailingCity;
            var MailingState = contactInfo.MailingState;
            var MailingPostalCode = contactInfo.MailingPostalCode;
            var CountryName = contactInfo.CountryName__c;
            console.log("segment#####",segment);
            console.log("passenger#####",passenger);
            console.log("pnr#####",pnr);
            
            var pasId, pasFirstName, pasLastName, pasCorpId, pasSmeId;
            if(passenger != null) {
                pasId = passenger.passengerId;
                pasFirstName = passenger.firstName;
                pasLastName = passenger.lastName;
                pasCorpId = passenger.corpId;
                pasSmeId = passenger.smeId;
            }
            if(segment != null){
                var flightSegmentsTable = '<html><table border="1" width="100%">';
                flightSegmentsTable = flightSegmentsTable + '<thead><tr><th>Flight Number</th><th>Departure Date</th><th>Departure Port</th><th>Arrival Port</th></tr></thead>';
                flightSegmentsTable = flightSegmentsTable + '<tbody><tr><td>'+segment.operatingCarrierAlphaCode+segment.operatingFlightNumber.replace(/^0+/,'')+'</td>';
                flightSegmentsTable = flightSegmentsTable + '<td>'+segment.departureLocalDate+'</td>';
                flightSegmentsTable = flightSegmentsTable + '<td>'+segment.departureAirportCode+'</td>';
                flightSegmentsTable = flightSegmentsTable + '<td>'+segment.arrivalAirportCode+'</td></tr></tbody></table></html>';
                
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
            }
            var cabinClass, seatNumber, passengerSegmentId;
            var checkInStatus;
            var flightLegFlownTable = '<html><table border="1" width="100%">';
            if(firstPassenger != null) {
                cabinClass = firstPassenger.cabinClass;
                seatNumber = firstPassenger.seatNumber;
                passengerSegmentId = firstPassenger.passengerSegmentId;
                flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';			
                flightLegFlownTable = flightLegFlownTable + '<tr><td>'+firstPassenger.depaturePort+'</td>';
                flightLegFlownTable = flightLegFlownTable + '<td>'+firstPassenger.arrivalPort+'</td>';
                
                if(firstPassenger.boardingStatus == 'Not Boarded') {
                    flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                    checkInStatus = 'Not Boarded';
                } else if(firstPassenger.boardingStatus == 'Boarded') {
                    flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                    checkInStatus = 'Boarded';
                }			
                flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
            }
            
            var specificNeeds;
            if(selectedSSR != null) {
                for(var i in selectedSSR) {
                    if(specificNeeds != null)
                    specificNeeds += ";" + selectedSSR[i].description;
                    else
                        specificNeeds = selectedSSR[i].description;
                }
            }
			console.log('specific needs = '+specificNeeds);
            
            var createCaseEvent = $A.get("e.force:createRecord");
            createCaseEvent.setParams({
                "entityApiName": "Case",
                "defaultFieldValues": {
                    'ContactId' : recId,
                    'Contact_Email__c': email,
                    'Contact_Phone__c': phone,                
                    'Street__c' : MailingStreet,
                    'Suburb__c': MailingCity,
                    'State__c': MailingState, 
                    'Post_Code__c': MailingPostalCode,
                    'Country__c': CountryName,
                    'Booking_PNR__c': pnr,
                    'TECH_bookingCreationDate__c': createdDate,
                    'TECH_bookingArchivalData__c': archivalData,
                    'TECH_BookingSegmentId__c': segment.segmentId,
                    'TECH_BookingSegmentTattoo__c': segment.segmentTattoo,
                    'Airline__c': segment.airline,
                    'Flight_Number__c': segment.operatingFlightNumber,
                    'Departure_Airport_Code__c': segment.departureAirportCode,
                    'Arrival_Airport_Code__c': segment.arrivalAirportCode,
                    'Departure_Airport__c': segment.departureAirport,
                    'Departure_City__c': segment.departureCity,
                    'Departure_Country__c': segment.departureCountry,
                    'Arrival_Airport__c': segment.arrivalAirport,
                    'Arrival_City__c': segment.arrivalCity,
                    'Arrival_Country__c': segment.arrivalCountry,
                    'Departure_Date_Time__c': segment.departureDateTime,
                    'Departure_UTC_Date_Time__c': segment.departureUTCDateTime,
                    'Actual_Departure_Date_Time__c': segment.actualDepartureDateTime,
                    'Arrival_Date_Time__c': segment.arrivalDateTime,//arrivalLocalDateTime,
                    'Arrival_UTC_Date_Time__c': segment.arrivalUTCDateTime,
                    'Actual_Arrival_Date_Time__c': segment.actualArrivalDateTime,
                    'Sector__c': segment.departureAirportCode + ' ' + segment.arrivalAirportCode,
                    'Flight_Type_Code__c': segment.flightTypeCode !='D'? 'International':'Domestic',
                    'Aircraft_Type_Code__c': segment.aircraftTypeCode,
                    'Segment_Id__c': segment.segmentId,
                    'Flight_Segments__c': flightSegmentsTable,
                    //'Flight_Segments__c': segment.operatingCarrierAlphaCode +' '+ segment.operatingFlightNumber +' '+ segment.departureLocalDate +' '+ segment.departureAirportCode +' '+ segment.arrivalAirportCode,
                    //'Delay_Reason__c': 
                    'Passenger_Id__c': pasId,
                    'Passenger_First_Name__c': pasFirstName,
                    'Passenger_Last_Name__c': pasLastName,
                    'ABN_Number__c': pasSmeId,
                    'Qantas_Corporate_Identifier__c': pasCorpId,
                    'Passenger_Segment_Id__c': passengerSegmentId,
                    'Cabin_Class__c': cabinClass,
                    'Check_In_Status__c': checkInStatus,
                    'Flight_Leg_Flown_Statuses__c': flightLegFlownTable,
                    'Seat_Number__c': seatNumber,
                    'Flight_Delay__c': flighDelayed,
                    'Flight_Cancellation__c': flightCancelled,
                    'Delay_Reason__c': delayReason,
                    'Specific_Needs__c': specificNeeds,
                    'Flight_Number_With_Code__c': segment.operatingCarrierAlphaCode + segment.operatingFlightNumber.replace(/^0+/,''),
                    'First_Name__c': contactInfo.FirstName,
                    'Last_Name__c': contactInfo.LastName
                },
                "recordTypeId": idsf
            });
        }
        
        createCaseEvent.fire();
        
    }
})