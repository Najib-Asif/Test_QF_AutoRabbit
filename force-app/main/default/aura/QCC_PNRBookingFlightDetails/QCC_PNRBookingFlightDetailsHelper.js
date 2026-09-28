({
    getCompleteDetail : function(component) {
        
        var recID = component.get("v.recordId");
        console.log("recID@@@@@@@",recID);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        if(recID.startsWith('003')){
            component.set("v.onContact", true);
        }
        var pnr = component.get("v.pnr");
        console.log("booking@@@@@@@",pnr);
        var creationDate = component.get("v.creationDate");
        console.log("creationDate@@@@@@@",creationDate);
        //Jira CRM-6052
        var formatDate = creationDate;
        if (component.get("v.isNeedToFormatDate") === true)
        {
            formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        }
        console.log("formatDate@@@@@@@",formatDate);
        var archivalData = component.get("v.archivalData");
        var action = component.get("c.fetchAllDetailonBooking");
        
        action.setParams({
            "pnr": pnr,
            "creationDate": formatDate,
            "archivalData": archivalData
        });
        
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        });
        
        $A.enqueueAction(action);
    },
    doLayout: function(response, component) {
        console.log("response",response);
        var info = response.getReturnValue();
        var spinner = component.find("mySpinner");
        component.set("v.completebooking", info);
        console.log("booking######",info);
        console.log("Strored info",component.get("v.completebooking"));
        var state = response.getState();
        if(state === "SUCCESS"){
            console.log('Info####'+JSON.stringify(info));
            
            if(info != null && info.pnrPassengerInfo != null && info.pnrFlightInfo != null){
                console.log("info.pnrPassengerInfo###",info.pnrPassengerInfo);
                var mapval = info.pnrFlightInfo.booking.segments[0].segmentId;
                component.set("v.segmentID", mapval);
                var segmentTattoo = info.pnrFlightInfo.booking.segments[0].segmentTattoo;
                component.set("v.segmentTattoo", segmentTattoo);
                var passengerId = info.pnrPassengerInfo.booking.passengers[0].passengerId;
                component.set("v.passengerID", passengerId);
                var passengerTattoo = info.pnrPassengerInfo.booking.passengers[0].passengerTattoo;
                component.set("v.passengerTattoo", passengerTattoo);
                component.set("v.passenger", info.pnrPassengerInfo.booking.passengers[0]);
                component.set("v.firstPassenger", info.lstFlightPassenger[0]);
                component.set("v.segment", info.pnrFlightInfo.booking.segments[0]);
                //console.log('mapval###',mapval);
                //console.log("info.pnrPassengerInfo passengers###",info.mapPNRBooking[mapval]);
                //console.log("info.pnrPassengerInfo flight###",info.pnrFlightInfo.booking.segments);
                var pasComp = component.find("passengerComponet");
                pasComp.passengerMethod(info.pnrPassengerInfo.booking.passengers); 
                var flightComp = component.find("flightComponet");
                flightComp.flightMethod(info.pnrFlightInfo.booking.segments);

                // Added by purushotham
                var flightHistComponent = component.find("flightHistComponent");
                if(info.pnrFlightHistInfo != null && info.pnrFlightHistInfo.booking != null) {
                	flightHistComponent.flightMethod(info.pnrFlightHistInfo.booking.segments);    
                }
                // End
                
                //var contComp = component.find("contactComponent");
                //contComp.contactMethod(info.pnrContactInfo.booking.contacts.phone);
                var ancillaryComp = component.find("ancillaryComponent");
                ancillaryComp.ancillaryMethod(info.lstPassengerAncillary);
                var singleComp = component.find("singleComponent");
                singleComp.singleMethod(info.mapPNRBooking[mapval]);
                var disruptComp = component.find("singleDisrupt");
                disruptComp.disruptMethod(info.mapPNRDisrupt[mapval]);
                var flgPassengerComp = component.find("flgPassengerComponent");
                flgPassengerComp.flgPassengerMethod(info.lstFlightPassenger);
                var ssrPassengerComp = component.find("ssrComponent");
                ssrPassengerComp.ssrPassengerMethod(info.lstPassengerSSR);
                var isContactPage = component.get("v.onContact");
                var showToProfilesCheck = component.get("v.showToProfiles");
        		if(showToProfilesCheck){
                    var highlightComp = component.find("highlightComponent");
                    highlightComp.highlightMethod(isContactPage, false);
                }
            }
            else if(info != null && info.pnrPassengerInfo == null && info.pnrFlightInfo != null) {
                var mapval = info.pnrFlightInfo.booking.segments[0].segmentId;
                var flightHistComponent = component.find("flightHistComponent");
                component.set("v.segment", info.pnrFlightInfo.booking.segments[0]);
                var segmentTattoo = info.pnrFlightInfo.booking.segments[0].segmentTattoo;
                component.set("v.segmentTattoo", segmentTattoo);
                if(info.pnrFlightHistInfo != null && info.pnrFlightHistInfo.booking != null) {
                    flightHistComponent.flightMethod(info.pnrFlightHistInfo.booking.segments);    
                }
                var singleComp = component.find("singleComponent");
                singleComp.singleMethod(info.mapPNRBooking[mapval]);
                var isContactPage = component.get("v.onContact");
                var showToProfilesCheck = component.get("v.showToProfiles");
        		if(showToProfilesCheck){
                    var highlightComp = component.find("highlightComponent");
                    highlightComp.highlightMethod(isContactPage, false);
                }
            }
            else if(info != null && info.pnrPassengerInfo != null && info.pnrFlightInfo == null) {
                console.log('Inside 3 else');
                var passengerId = info.pnrPassengerInfo.booking.passengers[0].passengerId;
                component.set("v.passengerID", passengerId);
                var passengerTattoo = info.pnrPassengerInfo.booking.passengers[0].passengerTattoo;
                component.set("v.passengerTattoo", passengerTattoo);
                component.set("v.passenger", info.pnrPassengerInfo.booking.passengers[0]);
               // component.set("v.firstPassenger", info.lstFlightPassenger[0]);
                var pasComp = component.find("passengerComponet");
                pasComp.passengerMethod(info.pnrPassengerInfo.booking.passengers);
                
                var mapval = "NoFlights";
                var singleComp = component.find("singleComponent");
                singleComp.singleMethod(info.mapPNRBooking[mapval]);

                // Added by purushotham
                var flightHistComponent = component.find("flightHistComponent");
                if(info.pnrFlightHistInfo != null && info.pnrFlightHistInfo.booking != null) {
                	flightHistComponent.flightMethod(info.pnrFlightHistInfo.booking.segments);    
                }
                // End
                
                //var contComp = component.find("contactComponent");
                //contComp.contactMethod(info.pnrContactInfo.booking.contacts.phone);
                var ancillaryComp = component.find("ancillaryComponent");
                ancillaryComp.ancillaryMethod(info.lstPassengerAncillary);
                //var flgPassengerComp = component.find("flgPassengerComponent");
                //flgPassengerComp.flgPassengerMethod(info.lstFlightPassenger);
                //var ssrPassengerComp = component.find("ssrComponent");
                //ssrPassengerComp.ssrPassengerMethod(info.lstPassengerSSR);
                var isContactPage = component.get("v.onContact");
                var showToProfilesCheck = component.get("v.showToProfiles");
        		if(showToProfilesCheck){
                    var highlightComp = component.find("highlightComponent");
                    highlightComp.highlightMethod(isContactPage, false);
                }
            }
            else {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Unable to fetch Booking details",
                    "message": "Booking server might be down. Please contact your admin",
                    duration : 10
                });
                resultsToast.fire();
            }
        }
        $A.util.toggleClass(spinner, "slds-hide");
    },
    Refreshsection : function(component, invokedFlight, history){
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var passengerId = component.get("v.passengerID");
        var segmentId = component.get("v.segmentID");
        //var passengerTattoo = component.get("v.passengerTattoo");
        var segmentTattoo = component.get("v.segmentTattoo");
        //var booking = component.get("v.selectedbooking");
        var onLoadInfo = component.get("v.completebooking");
        var pnr = component.get("v.pnr");
        //console.log("booking@@@@@@@",pnr);
        var creationDate = component.get("v.creationDate");
        //console.log("creationDate@@@@@@@",creationDate);
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        //console.log("formatDate@@@@@@@",formatDate);
        var archivalData = component.get("v.archivalData");
        var firstName;
        var lastName;
        var passengers;
        if(onLoadInfo.pnrPassengerInfo != null) {
            passengers = onLoadInfo.pnrPassengerInfo.booking.passengers;
            var i;
            for(i in passengers){
                //console.log(passengers[i]);
                //console.log(passengerId);
                if(passengers[i].passengerId == passengerId){
                    firstName = passengers[i].firstName;
                    lastName = passengers[i].lastName;
                    component.set("v.passenger", passengers[i]);
                    component.set("v.passengerTattoo", passengers[i].passengerTattoo);
                    break;
                }
            }
        }
        var passengerTattoo = component.get("v.passengerTattoo");
        if(onLoadInfo.pnrFlightInfo!= null){
            var segments = onLoadInfo.pnrFlightInfo.booking.segments;
            component.set("v.segment", segments);
            
            for(i in segments){
                console.log('segment**'+JSON.stringify(segments[i]));
                console.log(segmentId);
                if(segments[i].segmentId == segmentId){
                    component.set("v.segment", segments[i]);
                    break;
                }
            }
            console.log(invokedFlight);
            console.log(lastName);
            
        }
        
        if(onLoadInfo.pnrFlightInfo != null || onLoadInfo.pnrFlightHistInfo != null) {
            var action = component.get("c.showDynamicBooking");
            if(history) {
                 var segments = onLoadInfo.pnrFlightHistInfo.booking.segments;
                 component.set("v.segment", segments);
                 for(i in segments){
                    console.log('aaaaa'+JSON.stringify(segments[i]));
                    console.log('bbbbbbb'+segmentTattoo);
                    if(segments[i].segmentTattoo == segmentTattoo){
                        component.set("v.segment", segments[i]);
                        break;
                    }
                }
               
                action.setParams({
                    "pnr": pnr,
                    "creationDate": formatDate,
                    "passengerId": passengerTattoo,
                    "segmentId": segmentTattoo,
                    "firstName": firstName,
                    "lastName" : lastName,
                    "isHistory" : true,
                    "archivalData": archivalData
                });
                action.setCallback(this, function(response) {
                    this.doCenterLayout(response, component, invokedFlight, segmentTattoo);
                });
            }
            else {
                action.setParams({
                    "pnr": pnr,
                    "creationDate": formatDate,
                    "passengerId": passengerId,
                    "segmentId": segmentId,
                    "firstName": firstName,
                    "lastName" : lastName,
                    "isHistory": false,
                    "archivalData": archivalData
                });
                action.setCallback(this, function(response) {
                    this.doCenterLayout(response, component, invokedFlight, segmentId);
                });
            }
            
            $A.enqueueAction(action);
        }
        else {
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
        }
    },
    doCenterLayout: function(response, component, invokedFlight, segmentId) {
        //console.log("response",response);
        var spinner = component.find("mySpinner");
        var info = response.getReturnValue(); 
        console.log("INfo#####",info);
        var state = response.getState();
        if(state === "SUCCESS" && info != null){
            if(invokedFlight == true){
                console.log("Inside#####");
                var onLoad = component.get("v.completebooking");
                var singleComp = component.find("singleComponent");
                singleComp.singleMethod(onLoad.mapPNRBooking[segmentId]);
                var disruptComp = component.find("singleDisrupt");
                disruptComp.disruptMethod(onLoad.mapPNRDisrupt[segmentId]);
                component.set("v.firstPassenger", info.lstFlightPassenger[0]);
                
                var flightComp = component.find("flightComponet");
                flightComp.flightSelected(segmentId);
                var flightHistComponent = component.find("flightHistComponent");
                flightHistComponent.flightSelected(segmentId);
                
            }
            var flgPassengerComp = component.find("flgPassengerComponent");
            flgPassengerComp.flgPassengerMethod(info.lstFlightPassenger);
            var ssrPassengerComp = component.find("ssrComponent");
            ssrPassengerComp.ssrPassengerMethod(info.lstPassengerSSR);
        }
        $A.util.toggleClass(spinner, "slds-hide");
    },
    updateSelectedLeg : function(component){
        var showLegCase = component.get("v.showLegButton");
        var showSSRCase = component.get("v.showSSRButton");
        var showCase = false;
        /*
        if(showLegCase && showSSRCase){
            showCase = true;
        }*/
        var isContactPage = component.get("v.onContact");
        console.log(showCase);
        console.log(isContactPage);
        var showToProfilesCheck = component.get("v.showToProfiles");
        if(showToProfilesCheck){
           var highlightComp = component.find("highlightComponent");
           highlightComp.highlightMethod(isContactPage, showCase); 
        }
        
    },
    updateSelectedSSR : function(component){
        var showLegCase = component.get("v.showLegButton");
        var showSSRCase = component.get("v.showSSRButton");
        var showCase = false;
        /*
        if(showLegCase && showSSRCase){
            showCase = true;
        }*/
        var isContactPage = component.get("v.onContact");
        console.log(showCase);
        console.log(isContactPage);
        var showToProfilesCheck = component.get("v.showToProfiles");
        if(showToProfilesCheck){
            var highlightComp = component.find("highlightComponent");
            highlightComp.highlightMethod(isContactPage, showCase);
        }
    },
    addBookingInfotoCase: function(component){
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var recId = component.get("v.recordId");
        var segment = component.get("v.segment");
        var passenger = component.get("v.passenger");
        var pnr = component.get("v.pnr");
        console.log('segment#####',segment);
        console.log('passenger#####',passenger);
        var strSegment = JSON.stringify(segment, null, 2);
        var strPassenger = JSON.stringify(passenger, null, 2);
		var legStatus =  component.get("v.selectedLeg");
        console.log("legStatus",legStatus);
        if(legStatus == null) {
            legStatus = component.get("v.firstPassenger");
            console.log('In If @@##$$$ '+legStatus);
        }
        var strLeg = JSON.stringify(legStatus, null, 2);
        console.log("strLeg",strLeg);
        var selectedSSR = component.get("v.selectedSSR");
        if(selectedSSR.length == 0) {
            var info = component.get("v.completebooking");
            selectedSSR = info.lstPassengerSSR;
            console.log('selectedSSR@@@ '+selectedSSR);
        }
        console.log("selectedSSR",selectedSSR);
        var strSSR = JSON.stringify(selectedSSR, null, 2);
         console.log("strSSR",strSSR);
        /*if(pnr != "K5F5ZE") {
            pnr = "PNRT32";
        }*/
        var creationDate = component.get("v.creationDate");
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        var archivalData = component.get("v.archivalData");
        var action = component.get("c.addValueToCase"); 
        action.setParams({
            "caseId": recId,
            "segment": strSegment,
            "passenger": strPassenger,
            "ssr": strSSR,
            "legStatus": strLeg,
            "pnr": pnr,
            "createdDate": formatDate,
            "archivalData": archivalData
        });
        
        action.setCallback(this, function(response) {
            this.moveToCasePage(response, component);
        });
        
        $A.enqueueAction(action);
        
    },
    moveToCasePage: function(response, component) {        
        var state = response.getState();
        console.log('$$$$$$$ STATE = '+state);
        var spinner = component.find("mySpinner");
        var recId = component.get("v.recordId");
        if (state === 'SUCCESS'){
            var info = response.getReturnValue();
            if(info === 'true') {
                if(recId != null){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recId
                    });
                    //$A.get('e.force:refreshView').fire();
                    navEvt.fire();
                }
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Case Updated",
                    "message": "The Case record was updated.",
                    duration : 10
                });
                //$A.get('e.force:refreshView').fire();
                resultsToast.fire();
                
            }
            else if(info === 'InQueue') {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Case Update failed",
                    "message": "Case is currently assigned to a queue. Please assign the case to yourself to add the booking to the case",
                    duration : 10
                });
                resultsToast.fire();
            } else {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Case Update failed",
                    "message": "The Case record update was failed",
                    duration : 10
                });
                resultsToast.fire();                
            }
        }
        // Added by Purushotham for Remediation hotfix on 18 SEP 2018 -- START
        else if(state === "ERROR") {
            var errors = response.getError();
            var message = 'Unknown error'; // Default error message
            // Retrieve the error message sent by the server
            if (errors && Array.isArray(errors) && errors.length > 0) {
                console.log('1111',errors[0].message);
                message = errors[0].message;
            }
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": "Case Update failed",
                "message": message,
                duration : 10
            });
            resultsToast.fire();
            //helper.displayToastMessage('error',"Case not Saved", message, 10);
        }
        // Added by Purushotham for Remediation hotfix on 18 SEP 2018 -- END
        $A.util.toggleClass(spinner, "slds-hide");
        console.log(info);
    },
    showRecordType: function(component, event, helper){ 
        console.log('In showRecordType = '+JSON.stringify(component));
        
        var pnr = component.get("v.pnr");
        var creationDate = component.get("v.creationDate");
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        var archivalData = component.get("v.archivalData");
        var recId = component.get("v.recordId");
        var segment = component.get("v.segment");
        var passenger = component.get("v.passenger");
        var firstPassenger = component.get("v.selectedLeg");
        console.log('firstPass $$$ '+firstPassenger);
        if(firstPassenger == null) {
            firstPassenger = component.get("v.firstPassenger");
            console.log('In If @@##$$$ '+firstPassenger);
        }
        var selectedSSR = component.get("v.selectedSSR");
        console.log('selectedSSR### '+JSON.stringify(selectedSSR, null, 2));
        if(selectedSSR.length == 0) {
            var info = component.get("v.completebooking");
            selectedSSR = info.lstPassengerSSR;
            console.log('selectedSSR@@@ '+selectedSSR);
        }
        /* This is no longer needed as address needs to be fetched in real time as part of Remediation
        var contactDetails = component.get("v.contactF.Preferred_Email__c");
        contactDetails = contactDetails + '|' + component.get("v.contactF.Preferred_Phone_Number__c");
        contactDetails = contactDetails + '|' + component.get("v.contactF.MailingStreet");
        contactDetails = contactDetails + '|' + component.get("v.contactF.MailingCity");
        contactDetails = contactDetails + '|' + component.get("v.contactF.MailingState");
        contactDetails = contactDetails + '|' + component.get("v.contactF.MailingPostalCode");
        contactDetails = contactDetails + '|' + component.get("v.contactF.CountryName__c");
        console.log('Contact details = '+ contactDetails);*/
        var capId = component.get("v.contactF.CAP_ID__c");
        
        var action = component.get("c.lookupCustomer");
        action.setParams({
            "capId": capId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result;
                if(response.getReturnValue() == "NameMismatch") {
                    result = response.getReturnValue();
                } else {
                    result = JSON.parse(response.getReturnValue());
                }
                
                console.log('result==== '+JSON.stringify(result));
                if(result != null && result != 'NameMismatch') {
                    var phones = result.displayPhone;
                    console.log('In QCC_Select, phones = '+JSON.stringify(phones));
                    console.log('No. of Phones = '+phones.length);
                    if(phones.length != 0) {
                        var phoneSelected = false;
                        var phone;
                        for(var i in phones) {
                            if(phones[i].label.startsWith('Other')) {
                                console.log('PhoneToBeSelected = '+JSON.stringify(phones[i]));
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
                    if(address) {
                        street = address.street;
                        suburb = address.suburb;
                        postCode = address.postCode;
                        stateCode = address.state;
                        country = address.country;
                    }
                    component.set("v.con",{"FirstName": result.firstName, "LastName": result.lastName, 
                                           "Preferred_Email__c": result.email, 
                                           "Preferred_Phone_Number__c": phone,
                                           "MailingStreet": street,
                                           "MailingCity": suburb,
                                           "MailingState": stateCode, 
                                           "MailingPostalCode": postCode,
                                           "CountryName__c": country});
                    var modalBody;
                    var modalFooter;
                    console.log('111111111111'+segment);
                    $A.createComponents([
                        ["c:QCC_CustomCaseRecordTypeComponent",{"objCon":segment, "fromBooking":true, "contactId":recId, "objPassenger":passenger, "pnr":pnr,"createdDate":formatDate,"archivalData":archivalData, "con":component.get("v.con"), "firstPassenger":firstPassenger, "selectedSSR":selectedSSR}],
                    ],
                        function(components, status){
                            if (status === "SUCCESS") {
                                console.log('In showRecordType = '+JSON.stringify(component));
                                modalBody = components[0];
                                //modalFooter = components[1];
                                component.find('overlayLib').showCustomModal({
                                    header: "Case Record Type",
                                    body: modalBody, 
                                    //footer: modalFooter,
                                    showCloseButton: true,
                                    cssClass: "my-modal,my-custom-class,my-other-class",
                                })
                            }
                        });
					}
				} else if (state === "ERROR") {
					var errors = response.getError();    
                    console.log("Error: "+errors);
                } else {
                    console.log("Unknown error");
                }
			});
        $A.enqueueAction(action);
    },
            
    getHistoryDetails: function(component) {
        console.log('History Event Fired!!!!!!!');
        var pnr = component.get("v.pnr");
        var creationDate = component.get("v.creationDate");
        var formatDate =  $A.localizationService.formatDate(creationDate, "DD/MM/YYYY");
        var spinner = component.find("mySpinner");
        //$A.util.toggleClass(spinner, "slds-hide");
        //console.log("PNR ---> "+pnr+" formatdate --> "+formatDate);
        var completeBooking = JSON.stringify(component.get("v.completebooking"), null, 2);
        //console.log("Comp Booking --> "+completeBooking);
    	var action = component.get("c.fetchBookingHistory");
        action.setParams({
            "bookingInfoStr": completeBooking,
            "pnr": pnr,
            "creationDate": formatDate
        });
        action.setCallback(this, function(response) {
            var info = response.getReturnValue();
            
            component.set("v.completebooking", info);
			//console.log("booking######",info);            
            var state = response.getState();
            //console.log('state-->'+state);
            if(state === "SUCCESS"){
                if(info != null) {
                    var flightHistComponent = component.find("flightHistComponent");
                    if(info.pnrFlightHistInfo != null && info.pnrFlightHistInfo.booking != null) {
            			//console.log('flightHistory = '+info.pnrFlightHistInfo.booking.segments);
                        flightHistComponent.flightMethod(info.pnrFlightHistInfo.booking.segments);    
                    }
                }
            	if(info.pnrFlightHistInfo == null) {
                	var flightHistComponent = component.find("flightHistComponent");
            		flightHistComponent.flightMethod(null);
            		//console.log('Reached null part');
                }
            }
            //$A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
    },
    
    checkProfiles: function(component, event, helper){      
        var action = component.get("c.getProfileToHideForPNR");        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") {               
                var pflResult = response.getReturnValue();                
                if(pflResult == true){                   
                    component.set("v.showToProfiles", false);                     
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);        
    },
                     
})