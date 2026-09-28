({
    getContact: function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###'+params.contactDetail);
        component.set("v.objCon", params.contactDetail);  
	},

    refresh: function(component, event, helper) {
        component.set("v.flowModalEnabled", false);  
        component.set("v.isLoading", false);  
	},

    createCase: function(component, event, helper){ 
        var objCon = component.get("v.objCon");
        console.log("#### QCC_CreateCase - objCon### : ",objCon);
        if( objCon  && objCon.CAP_ID__c && objCon.CAP_ID__c !== ''){
            var action = component.get("c.lookupCustomer");
            action.setParams({
                "ffNumber": '',
                "lastName": '',
                "capId": objCon.CAP_ID__c
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
                        }else{
                            street = "";
                            suburb = "";
                            postCode = "";
                            stateCode = "";
                            country = "";
                        }
                        
                        var caseDetails = {
                            "sobjectType":"Case", 
                            "contactId" : objCon.Id,
                            "Booking_PNR__c": "",
                            "Contact_Email__c": result.email,
                            "Contact_Phone__c": phone,
                            "First_Name__c": result.firstName,
                            "Last_Name__c": result.lastName,
                            "Street__c": street,
                            "Suburb__c": suburb,
                            "Post_Code__c": postCode,
                            "State__c": stateCode,
                            "Country__c": country,
                        };

                        var flowParameters = [
                            { name : "contactId", type : "String", value : objCon.Id },
                            { name : "Input_Case_Details", type : "SObject", value: caseDetails }
                        ];

                        console.log('flow parameter details' + flowParameters);
                        console.log(flowParameters);
                        component.set("v.flowModalEnabled", true);
                        var flow = component.find("flowCreateCase");
                        // In that component, start your flow. Reference the flow's API Name.
                        flow.startFlow("QCC_Create_Case", flowParameters );
                        console.log('flow Started');

                    } else {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": "Problem no response from CAP ",
                            "message": "There was no response from the CAP system. Please refresh and try again. If the problem continues contact the system Administrator",
                            "duration" : "5"
                        });
                        resultsToast.fire();

                    }
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();    
                    console.log("Error: "+errors);
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "error",
                        "title": "There was an error with retreiveing the contact detials",
                        "message": "There was an error with retreiveing the contact detials. Please refresh and try again. If the problem continues contact the system Administrator",
                        "duration" : "5"
                    });
                    resultsToast.fire();
            } else {
                    console.log("Unknown error");
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "error",
                        "title": "There was an error with retreiveing the contact detials",
                        "message": "There was an error with retreiveing the contact detials. Please refresh and try again. If the problem continues contact the system Administrator",
                        "duration" : "5"
                    });
                    resultsToast.fire();
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": "Problem, no Contact or Cap ID ",
                "message": "Contact missing or there was no CAP ID",
                "duration" : "5"
            });
            resultsToast.fire();


        }
        
    }
})