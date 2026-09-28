({
    invokeCAPContact : function(component) {
        var selectedRow = component.get("v.selectedRow");
        console.log('SSSS',JSON.stringify(selectedRow));
        //check if passenger has a FF Number for calling CAP
        var action = component.get("c.invokeContactSearch");
        console.log('what are the details going ',JSON.stringify(selectedRow, null, 2),' ',component.get("v.pnr"),' ',component.get("v.caseId"));
        action.setParams({
            "passenger": JSON.stringify(selectedRow, null, 2),
            "cusPNR": component.get("v.pnr"),
            "recId": component.get("v.caseId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Response 14:", response.getReturnValue());
                var caseId = component.get("v.caseId");
                
                //JIra CRM-6258
                if (!this.isValidJSON(response.getReturnValue()))
                {
                    component.set("v.showModal", true);
                    component.set("v.errMSG", $A.get("$Label.c.QCC_NoValue"));

                }
                //From Case Page
                else if(caseId){
                    console.log('Inside Case Id');
                    var response = response.getReturnValue();
                    if(response === 'Pending_Recoveries') {
                        var toggleText = component.find("compId");
                        $A.util.addClass(toggleText, "toggle");
                        var showToast = $A.get("e.force:showToast");
                        showToast.setParams({
                            "type"		: "error",
                            "message"	: $A.get("$Label.c.QCC_PendingRecoveryMsg"),
                            "duration"	: 10
                        });
                        showToast.fire();
                    } else {
                        $A.get('e.force:refreshView').fire();
                        var toggleText = component.find("compId");
                        $A.util.addClass(toggleText, "toggle");
                        $A.get('e.force:refreshView').fire();
                        var showToast = $A.get("e.force:showToast");
                        showToast.setParams({
                            "type"		: "success",
                            "message"	: $A.get("$Label.c.ContactAssignToastMsg"),
                            "duration"	: 10
                        });
                        showToast.fire();
                    }
                    
                    //component.find("overlayLib").notifyClose();
                }else{ //Search Tab
                    var result = JSON.parse(response.getReturnValue());
                	console.log("Response value:", result);
                    if(result != null){
                        component.set("v.errMSG", '');
                        //NON-FF PNR
                        if(result.ffNumber == null){
                            console.log('nonFF');
                            this.nonFFContactMethod(component, result);
                        }else if(result.firstName == null && result.lastName == null){
                            this.searchContactInfoByPNR(component, selectedRow);
                        }
                        else{  //FF PNR
                            console.log("Inside Else");
                            this.ffContactMethod(component, result);
                        }
                    }
                    else{
                        // component.set("v.errMSG", $A.get("$Label.c.QCC_UsingPNRInfo")); 
                        // component.set("v.showModal", true);
                        // var result = {};
                        // result.firstName = selectedRow[0].firstName;
                        // result.lastName = selectedRow[0].lastName;
                        // this.nonFFContactMethod(component, result);

                        //check for PNR info
                        console.log('search info by PNR');
                        this.searchContactInfoByPNR(component, selectedRow);
                    }
                }
            }
            else if (state === "ERROR") {
                console.log('Error##',response.getError());
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('1111',errors[0].message);
                    message = errors[0].message;
                }
                component.set("v.errMSG", message);
                // Added by Purushotham for Remediation hotfix -- START
                var caseId = component.get("v.caseId");
                if(caseId){
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        "type"		: "error",
                        "message"	: message,
                        "duration"	: 10
                    });
                    showToast.fire();
                    var toggleText = component.find("compId");
                    $A.util.addClass(toggleText, "toggle");
                }
                // Added by Purushotham for Remediation hotfix -- END
                else{
                    component.set("v.showModal", true);
                }
                // Display the message
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },
    
    nonFFContactMethod : function(component, result){
        var contactInfoEvent = $A.get("e.c:QCC_ContactInfoEvent");
        contactInfoEvent.setParams({
            "firstName": result.fName,
            "lastName": result.lName,
            "phone": result.phone,
            "email": result.email,
            "pnr": component.get("v.pnr")         // RDC 11-03-2021 Added PNR details to event payload
        });
        contactInfoEvent.fire();
        var toggleText = component.find("compId");
        $A.util.addClass(toggleText, "toggle");
        //component.find("overlayLib").notifyClose();
    },
    
    
    // Jira CRM-6258
    isValidJSON: function(str){
        try {
          JSON.parse(str);
          return true;
        } catch (e) {
            //console.log('The exception in string parsing'+e.getError());
          return false;
        }
    },
    
    
    ffContactMethod : function(component, result) {
        var modalBody;
      
        $A.createComponent("c:QCC_SelectContactMethod", {"firstName": result.firstName,
                                                         "lastName": result.lastName,
                                                         "ffNumber": result.ffNumber,
                                                         "ffTier": result.ffTier,
                                                         "ffTierSF": result.ffTierSF,
                                                         "capId": result.capId,
                                                         "email": result.email,
                                                         "phoneList": result.displayPhone,
                                                         "address": result.address,
                                                         "mycolumns": result.displayColumn,
                                                         "pnr": component.get("v.pnr") },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var targetCmp = component.find('overlayLibFF');
                                   var body = targetCmp.get("v.body");
                                   body.push(content);
                                   targetCmp.set("v.body", body); 
                                   modalBody = content;
                                   /*component.find('overlayLibFF').showCustomModal({
                                       header: "Select Contact Method",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal"
                                   })*/
                               } 
                               var toggleText = component.find("compId");
                               $A.util.addClass(toggleText, "toggle");
                            
 
                                //component.destroy();
                               //component.find("overlayLib").notifyClose();
                           });
    },
    searchContactInfoByPNR : function(component, passenger) {
        
        //remove FFNumber for searching using PNR
        passenger[0].qantasFFNo = null;
        console.log('SSSS',JSON.stringify(passenger));
        var action = component.get("c.invokeContactSearch");
        action.setParams({
            "passenger": JSON.stringify(passenger, null, 2),
            "cusPNR": component.get("v.pnr"),
            "recId": component.get("v.caseId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if(state === "SUCCESS") {
                console.log("Response:", response.getReturnValue());
                var result = JSON.parse(response.getReturnValue());
                console.log("Response value:", result);
                if(result != null){
                    component.set("v.errMSG", $A.get("$Label.c.QCC_UsingPNRInfo")); 
                    component.set("v.showModal", true);  

                    console.log('nonFF');
                    this.nonFFContactMethod(component, result);
                }
                else{
                    component.set("v.errMSG", $A.get("$Label.c.QCC_UnexpectedError")); 
                    component.set("v.showModal", true);
                }
                
            } else if (state === "ERROR") {
                console.log('Error##',response.getError());
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('1111',errors[0].message);
                    message = errors[0].message;
                }
                component.set("v.errMSG", message);
                 component.set("v.showModal", true);
                // Display the message
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },
})