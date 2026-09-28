/**
**********************************************************************************************
Author:        Capgemini
Company:       Capgemini
Description:   QCC Customer search form client controller
     
************************************************************************************************
History
************************************************************************************************
Oct-2017      Cyrille Jeufo               Initial Design
**********************************************************************************************/

({
    doInit: function(component , event , helper){
        if(component.get("v.recordId")){
            var cmpTarget = component.find('phoneArea');
            console.log('component target ' + cmpTarget);
            $A.util.removeClass(cmpTarget, 'flag');
        }
        var recId = component.get("v.recordId")
        if(recId== null){
            console.log("Customer Search Loaded");
        }else if(recId.startsWith("500")){
            component.set("v.notOnCaseLayout",false);
            component.set("v.onCaseLayout", true);
        }
        if(!component.get("v.recordId")){
            helper.setFocusedTabLabel(component , event , helper);
        }
    },
    searchOnEnter: function(component , event , helper){
        if(event.keyCode == 13){
            $A.enqueueAction(component.get('c.searchCustomer'));
        }
        return;
    },
    onSelect: function(component , event , helper){
        //phone logic - start
        //Mobile or phone?
        var selected = event.getSource().get("v.label");
        var checked = component.get("v.checked");
        if(selected == 'Mobile') {
            component.set("v.checked" , true);
        }else{
            component.set("v.checked" , false);
        }

    },
    resetForm : function(component , event , helper){
        document.getElementById('myForm').reset();
        component.set("v.myContact",{'sobjectType':'Contact',
         'FirstName':'',
         'LastName': '',
         'Frequent_Flyer_Number__c': '',
         'Phone_Country_Code__c':'',
         'Phone_Area_Code__c':'',
         'Phone_Line_Number__c':'',
         'Email': ''});

        var object = $A.get('e.force:refreshView');
        if(object){
            object.fire();
            return;
        }
    }
    ,
    searchLocal:function(component , event , helper){
        component.set("v.isSearchLocal", true );
        component.set("v.tryLocal", false );
        $A.enqueueAction(component.get('c.searchCustomer'));
    }
    ,
    searchCustomer: function(component , event , helper){ 
        var caseId = component.get("v.recordId");

        //check for required fields
        var pnr = component.get("v.pnr");
        if(pnr) pnr = pnr.trim();
        var contact = component.get("v.myContact");
        var firstname = contact.FirstName;
        var lastname = contact.LastName;
        var email = contact.Email;
        //trim input
        if(firstname) firstname = firstname.trim();
        if(lastname) lastname = lastname.trim();
        if(email) email = email.trim();
        if(contact.Phone_Line_Number__c) contact.Phone_Line_Number__c = contact.Phone_Line_Number__c.trim();
        
        var checked = component.get("v.checked");
        console.log('checked ' + checked);
        var lineNumber;
        //was country code entered?
        if(!contact.Phone_Country_Code__c){
            contact.Phone_Country_Code__c = '61';
        }
        var temp = contact.Phone_Line_Number__c;
        //is mobile number?
        if(checked){
            if(contact.Phone_Line_Number__c)
            {
                if(contact.Phone_Country_Code__c == '61')
                {
                    if(contact.Phone_Line_Number__c.length === 8){
                        lineNumber = "04" + contact.Phone_Line_Number__c;
                    }else if(contact.Phone_Line_Number__c.length === 9){
                        lineNumber = "0" + contact.Phone_Line_Number__c;
                    }else{
                        lineNumber = contact.Phone_Line_Number__c;
                    }
                }
                if(lineNumber)
                {
                    contact.Phone_Line_Number__c = lineNumber.trim();
                    component.set("v.myContact.Phone_Line_Number__c" , lineNumber.trim());
                }
            }
        }else{

            if(contact.Phone_Country_Code__c == '61' && contact.Phone_Line_Number__c)
            {
                if(contact.Phone_Line_Number__c.length === 9){
                    contact.Phone_Line_Number__c = "0" + contact.Phone_Line_Number__c.trim();
                }
            }
            
        }
        var phone = contact.Phone_Line_Number__c;

        if(!contact.Phone_Line_Number__c) contact.Phone_Country_Code__c = null;
        
        console.log('phone ' + phone);
        var ffNumber = contact.Frequent_Flyer_Number__c;
        var rule_1 = pnr && (firstname || lastname || ffNumber || phone || email);
        var rule_2 = lastname && (ffNumber || phone || email || firstname);
        var rule_3 = firstname && (ffNumber || phone || email || lastname);
        var message = 'Please enter an additional field in the search criteria';
        if(rule_1 || rule_2 || rule_3 || ffNumber)
        {
            component.set("v.message", false );
            helper.searchContact(component, contact , pnr , caseId);
        }else{
            component.set("v.contacts", null );
            //component.set("v.message", false );
            var toastEvent = $A.get("e.force:showToast");
            let url = window.location.href;
            var result = url.match(/liveperson/i);
            if(result){
                component.set("v.message", 'Please enter an additional field in the search criteria' );
            }else{
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "duration" : "5000",
                    "message": message
                });
                toastEvent.fire();
            }

            return;
        }

    },
    newContact: function(component , event , helper){
        var url = window.location.href;
        var contact = component.get("v.myContact");
        var caseId = component.get("v.recordId");
        var result = url.match(/liveengage/i);
        var checked = component.get("v.checked"); 2
        var phoneNumber;
        var lineNumber = contact.Phone_Line_Number__c;
        var areaCode   = contact.Phone_Area_Code__c;
        var countryCode = contact.Phone_Country_Code__c;
        if(lineNumber) phoneNumber = lineNumber;
        if(checked){
            if(countryCode){
                phoneNumber = countryCode + lineNumber;
            }  
        }else{
            if(areaCode){
                phoneNumber = areaCode + phoneNumber;
            }
            if(countryCode){
                phoneNumber = countryCode + phoneNumber;
            }

        }

        console.log('url ' + url);
        console.log('result ' + result);
        if(phoneNumber) component.set("v.phoneNumber" , phoneNumber.trim());
        if(result){
            //this.openModal(component);
            component.set("v.createContactMessage", '' );
            component.set("v.isOpen", true);
        }else{
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Contact",
                "defaultFieldValues": {
                    'Alternate_Email__c': contact.Email,
                    'Alternate_Phone__c': phoneNumber, 
                    'Preferred_Contact_Method__c': 'Alternate',
                    'Phone_Line_Number__c': contact.Phone_Line_Number__c,
                    'Phone_Country_Code__c': contact.Phone_Country_Code__c,
                    'Phone_Area_Code__c' : contact.Phone_Area_Code__c,
                    'CaseId__c': caseId,                
                    'FirstName' : contact.FirstName,
                    'Email': contact.Email,
                    'LastName': contact.LastName, 
                    'Phone': phoneNumber                }
            });
            createRecordEvent.fire();
        }
    },
    createCustomer: function(component , event , helper){
        var contact = component.get("v.myContact");
        var caseId = component.get("v.recordId");
        var checked = component.get("v.checked");
        var phoneNumber = component.get("v.phoneNumber");

        if((contact.Phone_Line_Number__c || contact.Email) &&  contact.LastName ){
            var validContact = component.find('contactForm').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            contact.Phone = phoneNumber;
            contact.Alternate_Phone__c = phoneNumber;
            if(contact.Email) contact.Alternate_Email__c = contact.Email;
            contact.Preferred_Contact_Method__c = 'Alternate';

            var pnr = component.get("v.pnr");
            if(validContact){
                var contact = component.get("v.myContact");
                if(caseId){
                    helper.createContact(component,contact);
                }else{
                    helper.saveContactClient(component,contact);
                }
                
            }
            component.set("v.message" , '');
        }else{
            var toastEvent = $A.get("e.force:showToast");
            var url = window.location.href;
            var result = url.match(/liveperson/i);
            if(result){
                component.set("v.createContactMessage", 'These required fields must be completed: Phone or Email and Surname!' );
            }else{
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "duration" : "5000",
                    "message": "These required fields must be completed: Phone or Email and Surname!"
                });
                toastEvent.fire();
            }
            return;
        }
    },
    assignToCase : function(component , event , helper){
        var idx = event.target.value; 
        var caseId = component.get("v.recordId");
        var contact = component.get("v.contacts")[idx];
        helper.attachCaseToContact(component ,contact , caseId);
        event.stopPropagation();
    },
    navigateToRecord : function(component, event, helper) {              
        var idx = event.currentTarget.getAttribute('data-record'); 
        var cur = component.get("v.pageNumber");       
        //navigating to right index
        idx = (cur == 1)||(cur < 1) ? idx : ((cur-1)*10+parseInt(idx));
        var contact = component.get("v.contacts")[idx]; 
        helper.saveContactClient(component , contact);       
    },
    
    openModal: function(component) {
        // for Display Model,set the "isOpen" attribute to "true"
        // var 
        component.set("v.createContactMessage", '' );
        component.set("v.isOpen", true);
    },
    closeModal: function(component) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"  
        component.set("v.isOpen", false);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    }
})