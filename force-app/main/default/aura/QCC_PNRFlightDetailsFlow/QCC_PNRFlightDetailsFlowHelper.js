({
    getCompleteDetail : function(component) {
        
        var spinner = component.find("detailSpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        var pnr = component.get("v.pnr");
        console.log("#### QCC_PNRFlightDetailsFlow Helper - booking pnr : ",pnr);

        var creationDate = component.get("v.creationDate");
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        console.log("#### QCC_PNRFlightDetailsFlow Helper - formated creationDate : ",formatDate);

        var archivalData = component.get("v.archivalData");

        // Fectch Bookings Details
        var action = component.get("c.fetchAllDetailonBooking");
        action.setParams({
            "pnr": pnr,
            "creationDate": formatDate,
            "archivalData": archivalData
        });        
        action.setCallback(this, function(response) {
            this.processResponse(response, component);
        });        
        $A.enqueueAction(action);
    },

    processResponse: function(response, component) {
        //console.log("response",response);
        var info = response.getReturnValue();
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        console.log('#### QCC_PNRFlightDetailsFlow Helper - fetchAllDetailonBooking : '+JSON.stringify(info));
        component.set("v.completebooking", info);

        var state = response.getState();
        console.log('#### QCC_PNRFlightDetailsFlow Helper - fetchAllDetailonBooking Call Result : '+ state);
        if(state === "SUCCESS"){
                //If pnrflight info is returns, present the segments and return to the parent component
            if(info && info.pnrFlightInfo){
                component.set("v.segmentID", info.pnrFlightInfo.booking.segments[0].segmentId);
                component.set("v.segment", info.pnrFlightInfo.booking.segments[0]);
                this.showFlightDetails(component,info.pnrFlightInfo.booking.segments);


                var myEvent = component.getEvent("flightEvent");
                myEvent.setParams({ "segmentId": info.pnrFlightInfo.booking.segments[0].segmentId, 
                                    "history": false, 
                                    "bookingInfo":info});
                myEvent.fire();
            } else{
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Unable to fetch Booking details",
                    "message": "Booking server might be down. Please contact your admin",
                    "duration" : "10"
                });
                resultsToast.fire();
            }
        
        }
        else {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": "Unable to fetch Booking details",
                "message": "Booking server might be down. Please contact your admin",
                "duration" : "10"
            });
            resultsToast.fire();
        }
    },
    
    showFlightDetails : function(component, flightdetails) {
        console.log('#### QCC_PNRFlightDetailsFlow Helper - flight Details : ',flightdetails);
        component.set("v.flightInfo", flightdetails);
        component.set("v.mycolumns", [
            {label: 'Airline', fieldName: 'operatingCarrierAlphaCode', type: 'text'},
            {label: 'Flight Number', fieldName: 'operatingFlightNumber', type: 'text'},
            {label: 'Departure Date', fieldName: 'departureLocalDate', type: 'text'},
            {label: 'Departure Port', fieldName: 'departureAirportCode', type: 'text'},
            {label: 'Arrival Port', fieldName: 'arrivalAirportCode', type: 'text'}
        ]);
        console.log('#### QCC_PNRFlightDetailsFlow Helper - No of light Rows',component.get("v.flightInfo").length);
        console.log('#### QCC_PNRFlightDetailsFlow Helper - Presented Columns',component.get("v.mycolumns"));
    },    

    highlightFlight: function (component, event, segmentId) {
        var rowIndex = segmentId;
        //var rowIndex = target.getAttribute("id");
        console.log("#### QCC_PNRFlightDetailsFlow Controller - highlightFlightRow Selected Row No : " + rowIndex);
        var d = document.getElementById(rowIndex);
        
        var arr = component.get("v.flightInfo");
        for(var i in arr) {
            if(rowIndex === arr[i].segmentId) {
                d.className += " onSelection";
            } else {
                var element = document.getElementById(arr[i].segmentId);
   				element.classList.remove("onSelection");
            }
        }
    },

})