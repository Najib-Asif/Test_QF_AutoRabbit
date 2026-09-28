({
    getContact: function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###'+params.contactDetail);
        component.set("v.objCon", params.contactDetail);  
	},
	createCase: function(component){
        var rectypeId = component.find("selectid").get("v.value");
        var contactInfo =  component.get("v.objCon");
        console.log("contactInfo###",contactInfo);
        var createCaseEvent = $A.get("e.force:createRecord");
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
                'Country__c': contactInfo.CountryName__c
                
             },
            "recordTypeId": rectypeId
        });
        createCaseEvent.fire();
        
    },
    showRecordType: function(component, event, helper){ 
        var objCon = component.get("v.objCon");
        console.log("objCon###",objCon);
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
                    }
                    component.set("v.con",{"Id": objCon.Id, "FirstName": result.firstName, "LastName": result.lastName, 
                                           "Preferred_Email__c": result.email, 
                                           "Preferred_Phone_Number__c": phone,
                                           "MailingStreet": street,
                                           "MailingCity": suburb,
                                           "MailingState": stateCode, 
                                           "MailingPostalCode": postCode,
                                           "CountryName__c": country});
                    var modalBody;
                    var modalFooter;
                    $A.createComponents([
                        ["c:QCC_CustomCaseRecordTypeComponent",{"objCon":component.get("v.con")}],
                    ],
                        function(components, status){
                            if (status === "SUCCESS") {
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
                } else {
                    //this.showNotFoundModal(component, result);
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
        
    }
})