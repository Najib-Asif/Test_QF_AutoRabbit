({
    doInit : function(component, event, helper) {
		var pnr = component.get("v.pnr");
        var inputCaseDetails = component.get("v.inputCaseDetails");

        console.log('### QCC_CasePNRSearchFlow - Initialisation : ' + pnr);

        var resetCase = {   "Contact_Email__c" : inputCaseDetails.Contact_Email__c,
                            "Contact_Phone__c" : inputCaseDetails.Contact_Phone__c,
                            "First_Name__c" : inputCaseDetails.First_Name__c,
                            "Last_Name__c" : inputCaseDetails.Last_Name__c,
                            "Type" : inputCaseDetails.Type,
                            "Booking_PNR__c" : component.get("v.pnr"),
                            "Street__c" : inputCaseDetails.Street__c,
                            "Suburb__c": inputCaseDetails.Suburb__c,
                            "State__c":inputCaseDetails.State__c,
                            "Post_Code__c" :inputCaseDetails.Post_Code__c,
                            "Country__c" : inputCaseDetails.Country__c
                        };
        component.set("v.caseDetails",resetCase);

        console.log("#### QCC_CasePNRSearchFlow Init - reset case details : " + JSON.stringify(resetCase));

        if(pnr){
            helper.getBookingList(component);
        }    
	},

	searchButtonClick : function(component, event, helper) {
        var pnr = component.get("v.pnr");

        if(pnr){
            helper.getBookingList(component);
        } else {
            component.set("v.showMsg", true);
        }   

	},

    resetClick : function(component, event, helper) {
        component.set("v.archivalData",'');
        component.set("v.arrivalPort",'');
        component.set("v.departurePort",'');
        component.set("v.bookingId",'');
        component.set("v.creationDate",'');
        component.set("v.departureTimeStamp",'');
        component.set("v.lastUpdatedTimeStamp",'');
        component.set("v.lstCurrentBook",[]); 


        
        component.set("v.showMsg", false);
        component.set("v.showFlightDetails", false);
        component.set("v.showPassengerDetails", false);
        component.set("v.showSearchButton", true);

        var inputCaseDetails = component.get("v.inputCaseDetails");

        var resetCase = {   "Contact_Email__c" : inputCaseDetails.Contact_Email__c,
                            "Contact_Phone__c" : inputCaseDetails.Contact_Phone__c,
                            "First_Name__c" : inputCaseDetails.First_Name__c,
                            "Last_Name__c" : inputCaseDetails.Last_Name__c,
                            "Type" : inputCaseDetails.Type,
                            "Booking_PNR__c" : component.get("v.pnr"),
                            "Street__c" : inputCaseDetails.Street__c,
                            "Suburb__c": inputCaseDetails.Suburb__c,
                            "State__c":inputCaseDetails.State__c,
                            "Post_Code__c" :inputCaseDetails.Post_Code__c,
                            "Country__c" : inputCaseDetails.Country__c
                        };
        component.set("v.caseDetails",resetCase);

        console.log("### QCC_CasePNRSearchFlow - resetCase  : " + resetCase);
        console.log("### QCC_CasePNRSearchFlow - Reseting Case Details to  : "+ JSON.stringify(component.get("v.caseDetails")));

	},

    passengerBasedSelection : function(component, event, helper) {
        var passengerId = event.getParam("passengerId");
        console.log("### QCC_CasePNRSearchFlow - Received Event From Passenger Selection");
        console.log("### QCC_CasePNRSearchFlow - Event Parameter passengerID : "+ passengerId);

        
        component.set("v.passengerID", passengerId);
        
    },

    flightBasedSelection : function(component, event, helper) {
        var bookingInfo = event.getParam("bookingInfo");
        var history = component.get("v.isHistory");
        console.log("### QCC_CasePNRSearchFlow - Received Event From FLight Selection");
        console.log("### QCC_CasePNRSearchFlow - Event Paramter History : "+ history);
        console.log("### QCC_CasePNRSearchFlow - Event Paramter Booking Info  : "+ JSON.stringify(bookingInfo));
        component.set("v.completebooking", bookingInfo);

        // Display Passenger details if the if passengers a present in the data.
        
        if(bookingInfo){
            if(bookingInfo.pnrPassengerInfo){
                component.set("v.showPassengerDetails",true);
                component.set("v.passengerInfo", bookingInfo.pnrPassengerInfo.booking.passengers);
                //If passengerID has not been set then set to the first passenger on the list
                if(! component.get("v.passengerID")){
                    component.set("v.passengerID",bookingInfo.pnrPassengerInfo.booking.passengers[0].passengerId)
                }
            } else  component.set("v.showPassengerDetails",false);
        } else      component.set("v.showPassengerDetails",false);

        // DONT UNDERSTAND THIS LOGIC RDC
        if(history) {
            var segmentTattoo = event.getParam("segmentId");
            console.log("### QCC_CasePNRSearchFlow - Received event with Segment ID with History TRUE setting segmentTattoo = "+ segmentTattoo);
            component.set("v.segmentTattoo", segmentTattoo);
        }
        else {
            var segmentID = event.getParam("segmentId");
            console.log("### QCC_CasePNRSearchFlow - Received event with Segment ID with History False setting segmentID = "+ segmentID);
            component.set("v.segmentID", segmentID);
        }
        
    },


    turnOffMsg: function(component, event, helper){
        component.set("v.showMsg", false);
        component.set("v.showSearchButton", true);
        component.set("v.showFlightDetails", false);
        component.set("v.showPassengerDetails", false);
        
    },

    updateCase: function(component,event, helper){        
    // Get contact details based on user CAP_ID__c if one was found in the inital search
        var contactDetails = component.get("v.contact");     
        console.log("#### QCC_CasePNRSearchFlow Contact Details : "+JSON.stringify(contactDetails));
        var capId = contactDetails.CAP_ID__c; 

        console.log("### QCC_CasePNRSearchFlow - UPDATE CASE SELECTED getContactDetails with capID: " + capId);
        if (capId) {

            var action = component.get("c.lookupCustomer");
            action.setParams({
                "capId": capId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    helper.getContactDetails(component, response );
                    helper.refreshSection(component, component.get("v.isHistory"));
                    helper.updateCaseDetails(component); 
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "success",
                        "title": "Booking Details have been applied ",
                        "message": "Booking Details have been applied",
                        "duration" : "5"
                    });
                    resultsToast.fire();
                
                }    
                else if (state === "ERROR") {
                    var errors = response.getError();    
                    console.log("Error: "+errors);
                } else {
                    console.log("Unknown error");
                
                }
            });
            $A.enqueueAction(action);
        }else{  //If there is no CAP ID then just update the details from PNR search

            helper.refreshSection(component, component.get("v.isHistory"));
            helper.updateCaseDetails(component); 
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "success",
                "title": "Booking Details have been applied ",
                "message": "Booking Details have been applied",
                "duration" : "5"
            });
            resultsToast.fire();

        }

                     
    },
            
})