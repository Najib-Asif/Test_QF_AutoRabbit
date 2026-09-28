({
	/*showPopover : function(component) {
        //component.set("v.showModal", true);
        component.find('overlayLib').showCustomPopover({
            body: msg,
            referenceSelector: ".mypopover",
            cssClass: "slds-nubbin_left,slds-popover_walkthrough,no-pointer,cQCC_LookupFrequentFlyer"
        }).then(function (overlay) {
            setTimeout(function(){ 
                //close the popover after 3 seconds
                overlay.close(); 
            }, 3000);
        });
	},*/
    
    executeAction : function(component) {
        component.set("v.isLoading", true);
        var action = component.get("c.lookupCustomer");
        action.setParams({
            "ffNumber": component.get("v.ffNumber"),
            "lastName": component.get("v.lastName")
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
                    var caseId = component.get("v.recId");
                    if(caseId){
                        console.log('111',caseId);
                        this.showCaseSearchModal(component, result);
                    }else{
                    	this.showSelectContactModal(component, result);
                    }
                } else {
                    this.showNotFoundModal(component, result);
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
    
    showSelectContactModal : function(component, result) {
        //component.set("v.displayNotFoundError", false);
        var modalBody;
        $A.createComponent("c:QCC_SelectContactMethod", {"firstName": result.firstName,
                                                         "lastName": result.lastName,
                                                         "ffNumber": result.ffNumber,
                                                         "ffTier": result.ffTier,
                                                         "ffTierSF": result.ffTierSF,
                                                         "capId": result.capId,
                                                         "email": result.email,
                                                         "phoneList": result.displayPhone,
                                                         "mycolumns": result.displayColumn,
                                                         "address": result.address},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var targetCmp = component.find('overlayLibFF');
                                   var body = targetCmp.get("v.body");
                                   body.push(content);
                                   targetCmp.set("v.body", body);
                                   modalBody = content;
                                   /*component.find('overlayLib').showCustomModal({
                                       header: "Select Contact Method",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal"
                                   })*/
                               }                               
                           });
    },
    showCaseSearchModal: function(component, result){
        var modalBody;
        //CRM-7179
        var phone = result.displayPhone.filter( item => {
             return item.phoneType === 'Other'});
        $A.createComponent("c:QCC_FFContactView", {"firstName": result.firstName,
                                                   "lastName": result.lastName,
                                                   "ffNumber": result.ffNumber,
                                                   "ffTier": result.ffTier,
                                                   "ffTierSF": result.ffTierSF,
                                                   "capId": result.capId,
                                                   "phone": phone[0].phoneNumber,
                                                   "email": result.email,
                                                   "caseId": component.get("v.recId")
                                                    },
                           function(content, status) {
                               
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Contact Detail",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal"
                                   })
                               }                               
                           });
	},
    
    showNotFoundModal : function(component, result) {
        var errorMsg;
        /*if(result == 'NameMismatch') {
            errorMsg = $A.get("$Label.c.NameMismatch");
        } else {*/
            errorMsg = $A.get("$Label.c.FrequentFlyerNotFound");
        //}
        component.set("v.showModal", true);
        component.set("v.errorMsg", errorMsg);
        //component.set("v.displayNotFoundError", true);
    }
})