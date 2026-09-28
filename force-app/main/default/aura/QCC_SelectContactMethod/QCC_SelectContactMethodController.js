({
    doInit : function(component, event, helper) {
        var phones = component.get("v.phoneList");
        console.log('In QCC_Select, phones = '+JSON.stringify(phones));
        console.log('No. of Phones = '+phones.length);
        if(phones.length != 0) {
            var phoneSelected = false;
            for(var i in phones) {
                if(phones[i].label.startsWith('Other')) {
                    console.log('PhoneToBeSelected = '+JSON.stringify(phones[i]));
                    console.log('Label = '+phones[i].label+' value = '+phones[i].label.substring(phones[i].label.indexOf(":") + 2));
                    component.set("v.value", phones[i].value);
                    break;
                } else if(!phoneSelected) {
                    component.set("v.value", phones[i].value);
                    phoneSelected = true;
                }
            }
            //var firstPhone = phones[0];
            //console.log('firstPhone = '+JSON.stringify(firstPhone));
            //component.set("v.value", firstPhone.value);
        }
    },
	selected : function(component, event, helper) {
        var email = component.get("v.email");
        var emailField = component.find("email");
        var emailInvalid = false;
        var phoneInvalid = false;
        if(!email || email == null || email == '') {
            emailInvalid = true;
            //clear email if email is invalid/blank
            email = '';
            //emailField.reportValidity();
            //return;
        }
        
        if(!emailField.checkValidity()) {
            emailInvalid = true;
            //clear email if email is invalid/blank
            email = '';
            //return;
        }
        
        component.set("v.showMsg", false);
        var selectedPhone = component.find("mygroup").get("v.value");
        if(selectedPhone == 'additional') {
            var phone = component.get("v.phone");
            var phoneField1 = component.find("phone1");
            var phoneField2 = component.find("phone2");
            var phoneField3 = component.find("phone3");
            //check phone is empty
            if(!phone || phone=='' || phone == '61' || component.get('v.phone_Line_Number__c') == null 
                    || component.get('v.phone_Line_Number__c') =='') {
                console.log('turn on error Phone empty');
                phoneInvalid = true;
                //check for empty String
                if(component.get('v.phone_Country_Code__c') == null 
                    || component.get('v.phone_Country_Code__c') ==''){
                    phoneField1.setCustomValidity("Complete this field");
                }
                if( component.get('v.checked') == false && (component.get('v.phone_Area_Code__c') == null 
                    || component.get('v.phone_Area_Code__c') =='')){
                    phoneField2.setCustomValidity("Complete this field");
                }
                if(component.get('v.phone_Line_Number__c') == null 
                    || component.get('v.phone_Line_Number__c') ==''){
                    phoneField3.setCustomValidity("Complete this field");
                }

               
            } else if(!phoneField1.checkValidity() || !phoneField2.checkValidity() || !phoneField3.checkValidity()){
                console.log('turn on error Phone invalid');
                //check for digit string
                var patternMismatch = false;
                if( !phoneField1.checkValidity()){
                    console.log('check phone1');
                    phoneField1.setCustomValidity("Numerical Field Only.");
                    //phoneField1.reportValidity();
                    patternMismatch = true;
                }
                console.log('check phone2');
                if( !phoneField2.checkValidity()){
                    console.log('check phone2');
                    phoneField2.setCustomValidity("Numerical Field Only.");
                    //phoneField2.reportValidity();
                    patternMismatch = true;
                }
                console.log('check phone3');
                if( !phoneField3.checkValidity()){
                    console.log('check phone3');
                    phoneField3.setCustomValidity("Numerical Field Only.");
                    //phoneField3.reportValidity();
                    patternMismatch = true;
                }
                if(patternMismatch){
                    phoneInvalid = true;
                    //return;
                }
            } 
            else {
                selectedPhone = phone;
            }
            //clear phone if phone is invalid/blank
            if(phoneInvalid){
                selectedPhone = '';
            }
        } else {
            selectedPhone = selectedPhone.substring(selectedPhone.indexOf(":") + 2);
        }

        //exit if both Phone and Email is invalid
        if(emailInvalid && phoneInvalid){
            if(emailInvalid){
                emailField.reportValidity();
            }
            if(phoneInvalid){
                phoneField1.reportValidity();
                phoneField2.reportValidity();
                phoneField3.reportValidity(); 
            }
            console.log('turn on error msg');
            return;
        }

        console.log('Selected Phone === '+selectedPhone);
        console.log('PNR === '+component.get("v.pnr"));
        var contactInfoEvent = $A.get("e.c:QCC_ContactInfoEvent");
        contactInfoEvent.setParams({
            "firstName": component.get("v.firstName"),
            "lastName": component.get("v.lastName"),
            "ffNumber": component.get("v.ffNumber"),
            "ffTier": component.get("v.ffTier"),
            "capId": component.get("v.capId"),
            "phone": selectedPhone,
            "email": email,
            "address": component.get("v.address"),
            "ffTierSF": component.get("v.ffTierSF"),
            "pnr" : component.get("v.pnr"),
        });
        contactInfoEvent.fire();
        component.destroy();
        //component.find("overlayLib").notifyClose();
		/*var phones = component.find("phoneTable").getSelectedRows();
        var msg = "Please select a Phone number;
        if(phones.length == 0) {
            //component.set("v.showModal", true);
            component.find('overlayLib').showCustomPopover({
                body: msg,
                referenceSelector: ".mypopover",
                cssClass: "slds-nubbin_top-left,slds-popover_walkthrough,no-pointer,cQCC_SelectContactMethod"
            }).then(function (overlay) {
                setTimeout(function(){ 
                    //close the popover after 3 seconds
                    overlay.close(); 
                }, 3000);
            });
        }
        if(phones.length != 0) {
            var phoneNumber = phones[0].phoneNumber;
            console.log('Selected Phone === '+JSON.stringify(phones[0]));
            var contactInfoEvent = $A.get("e.c:QCC_ContactInfoEvent");
            contactInfoEvent.setParams({
                "firstName": component.get("v.firstName"),
                "lastName": component.get("v.lastName"),
                "ffNumber": component.get("v.ffNumber"),
                "ffTier": component.get("v.ffTier"),
                "capId": component.get("v.capId"),
                "phone": phoneNumber,
                "email": component.get("v.email")
            });
            contactInfoEvent.fire();
            component.find("overlayLib").notifyClose();
        }*/
	},
    onSelect: function(component , event , helper){
        //phone logic - start
        //Mobile or phone?
        var selected = event.getSource().get("v.label");
        var checked = component.get("v.checked");
        if(selected == 'Mobile') {
            component.set("v.checked" , true);
            component.set('v.phone_Area_Code__c', '');
        }else{
            component.set("v.checked" , false);
        }
        helper.combinePhoneNumber(component , null , helper);
    },
    onPhoneChange: function(component , event , helper){
        console.log(event);
        helper.combinePhoneNumber(component , event , helper);

        //clear the error
        var phoneField1 = component.find("phone1");
        var phoneField2 = component.find("phone2");
        var phoneField3 = component.find("phone3");
        phoneField1.setCustomValidity("");
        phoneField2.setCustomValidity("");
        phoneField3.setCustomValidity("");

    },
    closeMe : function(component, event, helper)  { 
        component.destroy();
    }
})