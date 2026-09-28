({
    validateFields : function(component, event, helper) {
        console.log('Entered validateFields');
        var isValid = true;
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var email = component.get("v.email");
        var phone = component.get("v.phone");
        console.log(email);
        console.log(phone); 
        
        if(!firstName) {
            var domElement = component.find("firstName");
            helper.showError(component, "firstName", "Complete this field");
            isValid = false;
        } else {
            helper.hideError(component, "firstName");
        }
        if(!lastName) {
            var domElement = component.find("lastName");
            helper.showError(component, "lastName", "Complete this field");
            isValid = false;
        } else {
            helper.hideError(component,"lastName");
        }
        if(!email && !phone) {
            var emailField = component.find("email");
            helper.showError(component, "email", "Complete Email and/or Phone Detail fields");
            var phoneField = component.find("phone");
            helper.showError(component, "phone", "Complete Phone Detail and/or Email fields");
            isValid = false;
        }
        if(email) {
            var emailField = component.find("email");
            if(!emailField.checkValidity()) {
                isValid = false;
            } else {
                helper.hideError(component, "email");
            }
        }
        
        // if phone is specified, email is not required
        if(phone) {
            helper.hideError(component, "email");
        }
        
        console.log('Exiting validateFields with isValid= '+isValid);
        return isValid;
    },
    
    hideError : function(component, elementId) {
        var el = component.find(elementId);
        el.setCustomValidity("");
        el.reportValidity();
    },
    
    showError : function(component, elementId, msg) {
        var el = component.find(elementId);
        el.setCustomValidity(msg);
        el.reportValidity();
    },
    
    searchCases : function(component, event, helper) {
        component.set("v.isError", false);
        component.set("v.isLoading", true);
        console.log('Entered searchCases');
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var email = component.get("v.email");
        var phone = component.get("v.phone");
        var ffNumber = component.get("v.ffNumber");
        
        var action = component.get("c.search");
        action.setParams({
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "ffNumber": ffNumber,
            "component": "QCC_CaseSearchResult"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                /*if(!ffNumber && response.getReturnValue().length > 0) {
                        var aCase = component.get("v.cases")[0];
                        console.log(JSON.stringify(aCase));
                        if(aCase.Contact != null && aCase.Contact.Frequent_Flyer_Number__c != null) {
                            var ffNum = aCase.Contact.Frequent_Flyer_Number__c;
                            component.set("v.ffNumber", ffNum);
                            component.set("v.ffTier", aCase.Frequent_Flyer_Tier__c);
                        }
                        
                    }*/
                console.log('Response value'+response.getReturnValue());
                console.log(JSON.stringify(component.get("v.cases")));
                var showCasesEvent = $A.get("e.c:QCC_ShowCasesEvent");
                showCasesEvent.setParams({
                    "cases": component.get("v.cases")
                });
                console.log('Firing QCC_ShowCasesEvent');
                showCasesEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
        console.log('Exiting searchCases');
    },
    
    createCase : function(component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.isError", false);
        console.log('Enetered createCase of QCC_SearchContactInfo');
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var pNR = component.get("v.pNR");
        
        var action = component.get("c.getContactId");
        action.setParams({
            "firstName": firstName,
            "lastName": lastName,
            "capId": component.get("v.capId"),
            "ffTier": component.get("v.ffTier"),
            "ffNumber": component.get("v.ffNumber"),
            "email": component.get("v.email"),
            "phone": component.get("v.phone") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var contactId = response.getReturnValue().split("_")[0];
                var noreplyEmail = response.getReturnValue().split("_")[1];
                console.log('ContactId = '+contactId);
                if(contactId) {
                    var phone = component.get("v.phone");
                    if(phone && phone.length == 2) {
                        console.log('Phone length = '+phone.length);
                        phone = '';
                    }
                    var address = component.get("v.address");
                    var street, suburb, postCode, stateCode, country;
                    if(address) {
                        street = address.street;
                        suburb = address.suburb;
                        postCode = address.postCode;
                        stateCode = address.state;
                        country = address.country;
                    }
                    else{
                        street = "";
                        suburb = "";
                        postCode = "";
                        stateCode = "";
                        country = "";
                    }
                    
                    var isLtngOut = component.get("v.isLivePerson");
                    console.log('isLtngOut = '+isLtngOut);

                    var caseDetails = {
                        "sobjectType":"Case", 
                        "contactId" : contactId,
                        "Contact_Email__c": component.get("v.email") != null && component.get("v.email")!= '' ? component.get("v.email") : noreplyEmail,
                        "Contact_Phone__c": component.get("v.phone"),
                        "Booking_PNR__c": pNR,
                        "First_Name__c": firstName,
                        "Last_Name__c": lastName,
                        "Street__c": street,
                        "Suburb__c": suburb,
                        "Post_Code__c": postCode,
                        "State__c": stateCode,
                        "Country__c": country,
                    };

                    var flowParameters = [
                        { name : "contactId", type : "String", value : contactId },
                        { name : "Input_Case_Details", type : "SObject", value: caseDetails }
                    ];

                    console.log('flow parameter details' + flowParameters);
                    console.log(flowParameters);
                    component.set("v.flowModalEnabled", true);
                    var flow = component.find("flowCreateCase");
                    // In that component, start your flow. Reference the flow's API Name.
                    flow.startFlow("QCC_Create_Case", flowParameters );
                    console.log('flow Started');
                                
                }
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    combinePhoneNumber: function(component, event, helper) {
        if(event != null){
            var el = component.find(event.getSource().getLocalId());
            if(!el.reportValidity()){
                $A.util.removeClass(el, "hide-error-message"); // show error message
                $A.util.addClass(el, "slds-has-error");
            }
        }
        
        //phone logic - start
        console.log('phone change');
        var phone = '';
        var phone_Country_Code__c  = component.get('v.phone_Country_Code__c');
        var phone_Area_Code__c  = component.get('v.phone_Area_Code__c');
        var phone_Line_Number__c  = component.get('v.phone_Line_Number__c');
        if(phone_Country_Code__c == '' || phone_Country_Code__c == null){
            phone_Country_Code__c = '61';
        }
        if(phone_Country_Code__c != null && phone_Country_Code__c != ''){
            phone=phone_Country_Code__c.trim();
        }
        if(phone_Area_Code__c != null && phone_Area_Code__c != ''){
            phone+=phone_Area_Code__c.trim();
        }
        if(phone_Line_Number__c != null && phone_Line_Number__c != ''){
            phone+=phone_Line_Number__c.trim();
        }
        if(phone == '61'){
            phone = '';
        }
        var isnum = /^\d+$/.test(phone) || (phone == '');
        
        if(isnum){
            component.set('v.phone', phone);
        }
        console.log(phone);
    },
    findContact : function(component, event, helper) {
        
       component.set("v.isLoading", true);
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        
        var action = component.get("c.getContactId");
        action.setParams({
            "firstName": firstName,
            "lastName": lastName,
            "capId": component.get("v.capId"),
            "ffTier": component.get("v.ffTier"),
            "ffNumber": component.get("v.ffNumber") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
				var contactId = response.getReturnValue().split("_")[0];
                console.log('contactId###',contactId)
                 if(component.get("v.isLivePerson")) {
        
            var url = location.href;
            var baseurl = url.substring(0, url.indexOf('/', 14));
            window.open(baseurl + '/lightning/r/contact/' + contactId + '/view');
        } else {
           var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": contactId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
        }
                
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
                component.set("v.isError", true);
            } else {
                console.log("Unknown error");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
        console.log('Exiting searchCases');
   }
})